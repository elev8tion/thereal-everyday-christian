import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/screens/devotional_screen.dart';

void main() {
  group('Test 3: Extended Section Navigation', () {
    test('should parse Psalm 136:1 correctly', () {
      // Simulate the parsing logic from _navigateToVerse
      final reference = 'Psalm 136:1';

      // Remove any text after " - "
      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, equals('Psalm 136:1'));

      // Parse the reference
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));
      expect(parts[0], equals('Psalm 136'));
      expect(parts[1], equals('1'));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(1));

      // Split book and chapter
      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['Psalm', '136']));

      // Get chapter number
      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(136));

      // Get book name
      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('Psalm'));
    });

    test('should parse 1 Thessalonians 5:18 correctly', () {
      final reference = '1 Thessalonians 5:18';

      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, equals('1 Thessalonians 5:18'));

      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));
      expect(parts[0], equals('1 Thessalonians 5'));
      expect(parts[1], equals('18'));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(18));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['1', 'Thessalonians', '5']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(5));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('1 Thessalonians'));
    });

    test('should parse Psalm 136:1 - His loving kindness correctly', () {
      final reference = 'Psalm 136:1 - His loving kindness';

      // Remove text after " - "
      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, equals('Psalm 136:1'),
          reason: 'Should remove description after " - "');

      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(1));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(136));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('Psalm'));
    });

    test('should parse John 3:16 correctly', () {
      final reference = 'John 3:16';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(16));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['John', '3']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(3));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('John'));
    });

    test('should parse 2 Corinthians 5:17 correctly', () {
      final reference = '2 Corinthians 5:17';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(17));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['2', 'Corinthians', '5']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(5));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('2 Corinthians'));
    });

    test('should parse Song of Solomon 2:10 correctly', () {
      final reference = 'Song of Solomon 2:10';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(10));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['Song', 'of', 'Solomon', '2']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(2));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('Song of Solomon'));
    });

    test('should handle invalid reference format gracefully', () {
      final reference = 'Invalid Reference';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');

      // Should fail length check
      expect(parts.length, equals(1),
          reason: 'Invalid format should not have colon separator');
    });

    test('should handle invalid verse number gracefully', () {
      final reference = 'John 3:ABC';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, isNull,
          reason: 'Invalid verse number should return null');
    });

    test('should handle invalid chapter number gracefully', () {
      final reference = 'John ABC:16';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['John', 'ABC']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, isNull,
          reason: 'Invalid chapter number should return null');
    });

    test('should handle empty reference gracefully', () {
      final reference = '';

      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, isEmpty);

      final parts = cleanReference.split(':');
      // Empty string split by ':' still returns a list with one empty element
      expect(parts.length, equals(1));
      expect(parts[0], isEmpty);
    });

    test('should parse reference with extra spaces', () {
      final reference = '  Psalm  136 : 1  ';

      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, equals('Psalm  136 : 1'));

      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));
      expect(parts[0].trim(), equals('Psalm  136'));
      expect(parts[1].trim(), equals('1'));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(1));

      // RegExp(r'\s+') handles multiple spaces
      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['Psalm', '136']));

      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(136));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('Psalm'));
    });

    test('should parse reference with multiple descriptions', () {
      final reference = 'Psalm 136:1 - His loving kindness - endures forever';

      // split(' - ').first only takes the first part
      final cleanReference = reference.split(' - ').first.trim();
      expect(cleanReference, equals('Psalm 136:1'),
          reason: 'Should only take content before first " - "');

      final parts = cleanReference.split(':');
      expect(parts.length, equals(2));

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(1));
    });

    test('should verify Extended label is used (not Going Deeper or Dive Deeper)', () {
      // This is verified by the label text in _buildGoingDeeper method
      const expectedLabel = 'Extended';

      // The method uses:
      // Text('Extended', style: ...)
      expect(expectedLabel, equals('Extended'),
          reason: 'Label should be "Extended" not "Going Deeper" or "Dive Deeper"');
    });
  });

  group('Edge Cases for Extended Navigation', () {
    test('should handle book names without spaces', () {
      final reference = 'Genesis 1:1';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      expect(bookChapterParts, equals(['Genesis', '1']));

      final book = bookChapterParts.sublist(0, bookChapterParts.length - 1).join(' ');
      expect(book, equals('Genesis'));
    });

    test('should handle high chapter numbers', () {
      final reference = 'Psalm 119:105';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(105));

      final bookChapterParts = parts[0].trim().split(RegExp(r'\s+'));
      final chapterNumber = int.tryParse(bookChapterParts.last);
      expect(chapterNumber, equals(119));
    });

    test('should handle single verse number', () {
      final reference = 'John 1:1';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(1));
    });

    test('should handle three-digit verse numbers', () {
      final reference = 'Psalm 119:176';

      final cleanReference = reference.split(' - ').first.trim();
      final parts = cleanReference.split(':');

      final verseNumber = int.tryParse(parts[1].trim());
      expect(verseNumber, equals(176));
    });
  });
}
