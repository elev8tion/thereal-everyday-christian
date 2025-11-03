import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Devotional Reference Format Validation', () {
    test('all devotional references follow correct format "Book Chapter:Verse"', () {
      final devotionalsDir = Directory('assets/devotionals');
      final devotionalFiles = devotionalsDir
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      print('\n📖 Scanning ${devotionalFiles.length} devotional files...');

      final List<String> malformedReferences = [];
      int totalReferences = 0;

      for (final file in devotionalFiles) {
        final content = File(file.path).readAsStringSync();
        final List<dynamic> devotionals = jsonDecode(content);

        for (final devotional in devotionals) {
          final List<dynamic> goingDeeper = devotional['goingDeeper'] ?? [];

          for (final reference in goingDeeper) {
            final ref = reference.toString();
            totalReferences++;

            // Remove description if present
            final cleanReference = ref.split(' - ').first.trim();

            // Valid format: "Book Chapter:Verse" (e.g., "John 3:16", "1 Thessalonians 5:18")
            if (!cleanReference.contains(':')) {
              malformedReferences.add('$ref (missing colon)');
              continue;
            }

            final parts = cleanReference.split(':');
            if (parts.length != 2) {
              malformedReferences.add('$ref (invalid colon usage)');
              continue;
            }

            // Verify verse number is numeric
            final verseNumber = int.tryParse(parts[1].trim());
            if (verseNumber == null) {
              malformedReferences.add('$ref (verse number not numeric: "${parts[1]}")');
              continue;
            }

            // Verify book and chapter part has at least 2 words (book name + chapter)
            final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
            if (bookChapterParts.length < 2) {
              malformedReferences.add('$ref (missing book or chapter)');
              continue;
            }

            // Verify chapter number is numeric
            final chapterNumber = int.tryParse(bookChapterParts.last);
            if (chapterNumber == null) {
              malformedReferences.add('$ref (chapter number not numeric: "${bookChapterParts.last}")');
              continue;
            }
          }
        }
      }

      print('📊 Results:');
      print('  Total references scanned: $totalReferences');
      print('  Malformed references: ${malformedReferences.length}');

      if (malformedReferences.isNotEmpty) {
        print('\n❌ Malformed references found:');
        for (final ref in malformedReferences.take(10)) {
          print('  - $ref');
        }
        if (malformedReferences.length > 10) {
          print('  ... and ${malformedReferences.length - 10} more');
        }
      } else {
        print('✅ All references have valid format!');
      }

      expect(malformedReferences.isEmpty, isTrue,
          reason: 'All references should follow format "Book Chapter:Verse". '
              'Found ${malformedReferences.length} malformed references.');
    });

    test('book name normalization handles Psalm/Psalms correctly', () {
      // This is the actual normalization from devotional_screen.dart:1109-1111
      String normalizeBookName(String book) {
        if (book == 'Psalm') {
          return 'Psalms';
        }
        return book;
      }

      // Test cases
      expect(normalizeBookName('Psalm'), equals('Psalms'),
          reason: '"Psalm" should normalize to "Psalms"');
      expect(normalizeBookName('Psalms'), equals('Psalms'),
          reason: '"Psalms" should remain "Psalms"');
      expect(normalizeBookName('John'), equals('John'),
          reason: 'Other book names should not change');
      expect(normalizeBookName('1 Thessalonians'), equals('1 Thessalonians'),
          reason: 'Multi-word book names should not change');
    });

    test('sample devotional references parse correctly with normalization', () {
      // Simulate the parsing logic from devotional_screen.dart
      String parseAndNormalize(String reference) {
        final cleanReference = reference.split(' - ').first.trim();
        final parts = cleanReference.split(':');
        final verseNumber = int.tryParse(parts[1].trim());
        final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
        final chapterNumber = int.tryParse(bookChapterParts.last);
        var book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');

        // Apply normalization
        if (book == 'Psalm') {
          book = 'Psalms';
        }

        return '$book $chapterNumber:$verseNumber';
      }

      // Test references that should work
      expect(parseAndNormalize('Psalm 136:1'), equals('Psalms 136:1'));
      expect(parseAndNormalize('Psalm 23:1 - The Lord is my shepherd'), equals('Psalms 23:1'));
      expect(parseAndNormalize('John 3:16'), equals('John 3:16'));
      expect(parseAndNormalize('1 Thessalonians 5:18'), equals('1 Thessalonians 5:18'));
      expect(parseAndNormalize('Song of Solomon 2:10'), equals('Song of Solomon 2:10'));
    });

    test('no empty or whitespace-only references in devotionals', () {
      final devotionalsDir = Directory('assets/devotionals');
      final devotionalFiles = devotionalsDir
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      final List<String> filesWithEmptyRefs = [];

      for (final file in devotionalFiles) {
        final content = File(file.path).readAsStringSync();
        final List<dynamic> devotionals = jsonDecode(content);

        for (final devotional in devotionals) {
          final List<dynamic> goingDeeper = devotional['goingDeeper'] ?? [];

          if (goingDeeper.isEmpty) {
            filesWithEmptyRefs.add('${file.path} - empty goingDeeper array');
            break;
          }

          for (final reference in goingDeeper) {
            if (reference.toString().trim().isEmpty) {
              filesWithEmptyRefs.add('${file.path} - empty reference string');
              break;
            }
          }
        }
      }

      expect(filesWithEmptyRefs.isEmpty, isTrue,
          reason: 'No devotionals should have empty references. '
              'Files with issues: ${filesWithEmptyRefs.join(", ")}');
    });

    test('common book name variations are handled', () {
      // List of book name variations we might encounter
      final variations = {
        'Psalm': 'Psalms',  // Singular to plural (already normalized)
        // Add more variations here if we find them
      };

      for (final entry in variations.entries) {
        var book = entry.key;

        // Apply same normalization as devotional_screen.dart
        if (book == 'Psalm') {
          book = 'Psalms';
        }

        expect(book, equals(entry.value),
            reason: '"${entry.key}" should normalize to "${entry.value}"');
      }

      print('\n✅ Book name normalization rules:');
      for (final entry in variations.entries) {
        print('  "${entry.key}" → "${entry.value}"');
      }
    });
  });
}
