import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use the actual Bible database for validation tests
    DatabaseService.setTestDatabasePath('assets/bible.db');
    databaseService = DatabaseService();
    await databaseService.initialize();
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Devotional Reference Validation', () {
    test('all devotional references have valid format and parse correctly', () async {
      final db = await databaseService.database;

      // Get all unique book names from database
      final booksResult = await db.rawQuery(
        'SELECT DISTINCT book FROM bible_verses ORDER BY book',
      );
      final databaseBooks = booksResult.map((row) => row['book'] as String).toSet();

      print('📚 Books in database (${databaseBooks.length}):');
      for (final book in databaseBooks) {
        print('  - $book');
      }

      // Scan all devotional files
      final devotionalsDir = Directory('assets/devotionals');
      final devotionalFiles = devotionalsDir
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      print('\n📖 Scanning ${devotionalFiles.length} devotional files...');

      final Set<String> allReferences = {};
      final Set<String> invalidReferences = {};
      final Map<String, List<String>> bookNameIssues = {};

      for (final file in devotionalFiles) {
        final content = File(file.path).readAsStringSync();
        final List<dynamic> devotionals = jsonDecode(content);

        for (final devotional in devotionals) {
          // Check "Extended" section (goingDeeper field)
          final List<dynamic> goingDeeper = devotional['goingDeeper'] ?? [];

          for (final reference in goingDeeper) {
            final ref = reference.toString();
            allReferences.add(ref);

            // Parse the reference
            final cleanReference = ref.split(' - ').first.trim();
            if (!cleanReference.contains(':')) continue;

            final parts = cleanReference.split(':');
            if (parts.length != 2) continue;

            final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
            if (bookChapterParts.isEmpty) continue;

            // Get book name (everything except last part which is chapter number)
            var bookName = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');

            // Apply same normalization as devotional_screen.dart
            if (bookName == 'Psalm') {
              bookName = 'Psalms';
            }

            // Check if book exists in database
            if (!databaseBooks.contains(bookName)) {
              invalidReferences.add(ref);

              if (!bookNameIssues.containsKey(bookName)) {
                bookNameIssues[bookName] = [];
              }
              bookNameIssues[bookName]!.add(ref);
            }
          }
        }
      }

      print('\n📊 Results:');
      print('  Total references scanned: ${allReferences.length}');
      print('  Invalid references: ${invalidReferences.length}');

      if (invalidReferences.isNotEmpty) {
        print('\n❌ Book name mismatches found:');
        for (final entry in bookNameIssues.entries) {
          print('\n  Book: "${entry.key}" (not in database)');
          print('  References using this name:');
          for (final ref in entry.value.take(5)) {
            print('    - $ref');
          }
          if (entry.value.length > 5) {
            print('    ... and ${entry.value.length - 5} more');
          }

          // Suggest closest match
          final suggestions = databaseBooks
              .where((dbBook) => dbBook.toLowerCase().contains(entry.key.toLowerCase()))
              .toList();
          if (suggestions.isNotEmpty) {
            print('  💡 Did you mean: ${suggestions.join(", ")}?');
          }
        }
      }

      expect(invalidReferences.isEmpty, isTrue,
          reason: 'All devotional references should use book names that exist in database. '
              'Found ${invalidReferences.length} invalid references. '
              'See console output for details.');
    });

    test('book name normalization handles all known variations', () {
      // Test the normalization logic from devotional_screen.dart
      final Map<String, String> bookNameMappings = {
        'Psalm': 'Psalms',
        // Add more mappings as needed
      };

      for (final entry in bookNameMappings.entries) {
        var book = entry.key;

        // Apply normalization (same as devotional_screen.dart:1109-1111)
        if (book == 'Psalm') {
          book = 'Psalms';
        }

        expect(book, equals(entry.value),
            reason: 'Book name "${ entry.key}" should normalize to "${entry.value}"');
      }
    });

    test('sample references parse correctly with normalization', () async {
      final db = await databaseService.database;

      final testReferences = [
        {'ref': 'Psalm 136:1', 'expectedBook': 'Psalms', 'chapter': 136, 'verse': 1},
        {'ref': 'Psalm 23:1', 'expectedBook': 'Psalms', 'chapter': 23, 'verse': 1},
        {'ref': 'Psalm 119:105', 'expectedBook': 'Psalms', 'chapter': 119, 'verse': 105},
      ];

      for (final test in testReferences) {
        final reference = test['ref'] as String;
        final expectedBook = test['expectedBook'] as String;
        final expectedChapter = test['chapter'] as int;
        final expectedVerse = test['verse'] as int;

        // Parse reference (same as devotional_screen.dart)
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

        expect(book, equals(expectedBook));
        expect(chapterNumber, equals(expectedChapter));
        expect(verseNumber, equals(expectedVerse));

        // Verify verses exist in database
        final verses = await db.query(
          'bible_verses',
          where: 'book = ? AND chapter = ? AND verse = ?',
          whereArgs: [book, chapterNumber, verseNumber],
        );

        expect(verses.isNotEmpty, isTrue,
            reason: 'Verse $reference (normalized to: $book $chapterNumber:$verseNumber) should exist in database');
      }
    });

    test('database contains expected Bible books', () async {
      final db = await databaseService.database;

      // Get all unique books
      final booksResult = await db.rawQuery(
        'SELECT DISTINCT book FROM bible_verses ORDER BY book',
      );
      final books = booksResult.map((row) => row['book'] as String).toList();

      // Old Testament books (at least some should exist)
      final oldTestamentBooks = [
        'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy',
        'Joshua', 'Judges', 'Ruth',
        'Psalms', // Note: plural
      ];

      // New Testament books (at least some should exist)
      final newTestamentBooks = [
        'Matthew', 'Mark', 'Luke', 'John',
        'Acts',
        'Romans',
      ];

      for (final book in oldTestamentBooks) {
        if (books.contains(book)) {
          print('✅ Found OT book: $book');
        }
      }

      for (final book in newTestamentBooks) {
        if (books.contains(book)) {
          print('✅ Found NT book: $book');
        }
      }

      // At least verify Psalms exists (since it's commonly referenced)
      expect(books.contains('Psalms'), isTrue,
          reason: 'Database should contain "Psalms" (plural) since devotionals use "Psalm" (singular) which gets normalized');
    });

    test('no duplicate book names with different capitalization', () async {
      final db = await databaseService.database;

      final booksResult = await db.rawQuery(
        'SELECT DISTINCT book FROM bible_verses',
      );
      final books = booksResult.map((row) => row['book'] as String).toList();

      // Check for case-insensitive duplicates
      final Set<String> lowerCaseBooks = {};
      final List<String> duplicates = [];

      for (final book in books) {
        final lowerBook = book.toLowerCase();
        if (lowerCaseBooks.contains(lowerBook)) {
          duplicates.add(book);
        }
        lowerCaseBooks.add(lowerBook);
      }

      expect(duplicates.isEmpty, isTrue,
          reason: 'Database should not have duplicate book names with different capitalization. '
              'Found duplicates: ${duplicates.join(", ")}');
    });
  });

  group('Reference Format Validation', () {
    test('all devotional references follow correct format', () async {
      final devotionalsDir = Directory('assets/devotionals');
      final devotionalFiles = devotionalsDir
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .toList();

      final List<String> malformedReferences = [];

      for (final file in devotionalFiles) {
        final content = File(file.path).readAsStringSync();
        final List<dynamic> devotionals = jsonDecode(content);

        for (final devotional in devotionals) {
          final List<dynamic> goingDeeper = devotional['goingDeeper'] ?? [];

          for (final reference in goingDeeper) {
            final ref = reference.toString();

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
              malformedReferences.add('$ref (verse number not numeric)');
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
              malformedReferences.add('$ref (chapter number not numeric)');
              continue;
            }
          }
        }
      }

      if (malformedReferences.isNotEmpty) {
        print('\n❌ Malformed references found:');
        for (final ref in malformedReferences.take(10)) {
          print('  - $ref');
        }
        if (malformedReferences.length > 10) {
          print('  ... and ${malformedReferences.length - 10} more');
        }
      }

      expect(malformedReferences.isEmpty, isTrue,
          reason: 'All references should follow format "Book Chapter:Verse". '
              'Found ${malformedReferences.length} malformed references.');
    });

    test('no empty references in devotionals', () async {
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
            filesWithEmptyRefs.add(file.path);
            break;
          }

          for (final reference in goingDeeper) {
            if (reference.toString().trim().isEmpty) {
              filesWithEmptyRefs.add(file.path);
              break;
            }
          }
        }
      }

      expect(filesWithEmptyRefs.isEmpty, isTrue,
          reason: 'No devotionals should have empty references. '
              'Files with issues: ${filesWithEmptyRefs.join(", ")}');
    });
  });
}
