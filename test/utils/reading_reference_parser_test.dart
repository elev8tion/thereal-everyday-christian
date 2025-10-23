import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/utils/reading_reference_parser.dart';

void main() {
  group('ReadingReferenceParser', () {
    group('parse with full reference', () {
      test('parses single chapter reference', () {
        final result = ReadingReferenceParser.parse('Genesis 1');

        expect(result.book, 'Genesis');
        expect(result.startChapter, 1);
        expect(result.endChapter, 1);
        expect(result.isMultiChapter, false);
        expect(result.chapterCount, 1);
        expect(result.description, 'Genesis 1');
      });

      test('parses multi-chapter reference', () {
        final result = ReadingReferenceParser.parse('Genesis 1-3');

        expect(result.book, 'Genesis');
        expect(result.startChapter, 1);
        expect(result.endChapter, 3);
        expect(result.isMultiChapter, true);
        expect(result.chapterCount, 3);
        expect(result.description, 'Genesis 1-3');
      });

      test('parses book with number in name (1 John)', () {
        final result = ReadingReferenceParser.parse('1 John 3');

        expect(result.book, '1 John');
        expect(result.startChapter, 3);
        expect(result.endChapter, 3);
      });

      test('parses book with number and multi-chapter', () {
        final result = ReadingReferenceParser.parse('2 Corinthians 5-8');

        expect(result.book, '2 Corinthians');
        expect(result.startChapter, 5);
        expect(result.endChapter, 8);
        expect(result.chapterCount, 4);
      });

      test('parses book with multiple words', () {
        final result = ReadingReferenceParser.parse('Song of Solomon 2');

        expect(result.book, 'Song of Solomon');
        expect(result.startChapter, 2);
        expect(result.endChapter, 2);
      });

      test('handles extra whitespace', () {
        final result = ReadingReferenceParser.parse('  Genesis   1-3  ');

        expect(result.book, 'Genesis');
        expect(result.startChapter, 1);
        expect(result.endChapter, 3);
      });

      test('throws FormatException for invalid format', () {
        expect(
          () => ReadingReferenceParser.parse('Invalid'),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException for missing chapter', () {
        expect(
          () => ReadingReferenceParser.parse('Genesis'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('parse with separate book parameter', () {
      test('parses single chapter', () {
        final result = ReadingReferenceParser.parse('1', book: 'Genesis');

        expect(result.book, 'Genesis');
        expect(result.startChapter, 1);
        expect(result.endChapter, 1);
      });

      test('parses chapter range', () {
        final result = ReadingReferenceParser.parse('1-3', book: 'Genesis');

        expect(result.book, 'Genesis');
        expect(result.startChapter, 1);
        expect(result.endChapter, 3);
      });

      test('handles whitespace in chapter range', () {
        final result = ReadingReferenceParser.parse('  5-10  ', book: 'Psalms');

        expect(result.book, 'Psalms');
        expect(result.startChapter, 5);
        expect(result.endChapter, 10);
      });
    });

    group('fromDailyReading', () {
      test('parses single chapter from DailyReading', () {
        final result = ReadingReferenceParser.fromDailyReading('John', '3');

        expect(result.book, 'John');
        expect(result.startChapter, 3);
        expect(result.endChapter, 3);
      });

      test('parses chapter range from DailyReading', () {
        final result = ReadingReferenceParser.fromDailyReading('Matthew', '5-7');

        expect(result.book, 'Matthew');
        expect(result.startChapter, 5);
        expect(result.endChapter, 7);
        expect(result.chapterCount, 3);
      });

      test('handles large chapter numbers', () {
        final result = ReadingReferenceParser.fromDailyReading('Psalms', '119');

        expect(result.book, 'Psalms');
        expect(result.startChapter, 119);
        expect(result.endChapter, 119);
      });
    });

    group('ReadingReference', () {
      test('equality works correctly', () {
        final ref1 = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 3,
        );
        final ref2 = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 3,
        );
        final ref3 = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 4,
        );

        expect(ref1, equals(ref2));
        expect(ref1, isNot(equals(ref3)));
      });

      test('hashCode works correctly', () {
        final ref1 = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 3,
        );
        final ref2 = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 3,
        );

        expect(ref1.hashCode, equals(ref2.hashCode));
      });

      test('toString returns description', () {
        final ref = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 3,
        );

        expect(ref.toString(), equals('Genesis 1-3'));
      });

      test('chapterCount calculates correctly', () {
        final singleChapter = ReadingReference(
          book: 'John',
          startChapter: 3,
          endChapter: 3,
        );
        final multiChapter = ReadingReference(
          book: 'Genesis',
          startChapter: 1,
          endChapter: 50,
        );

        expect(singleChapter.chapterCount, 1);
        expect(multiChapter.chapterCount, 50);
      });
    });

    group('Edge cases and error handling', () {
      test('handles Psalm 119 (longest chapter)', () {
        final result = ReadingReferenceParser.parse('Psalm 119');

        expect(result.book, 'Psalm');
        expect(result.startChapter, 119);
      });

      test('handles 3 John (shortest book)', () {
        final result = ReadingReferenceParser.parse('3 John 1');

        expect(result.book, '3 John');
        expect(result.startChapter, 1);
      });

      test('throws FormatException for invalid chapter range', () {
        expect(
          () => ReadingReferenceParser.parse('abc', book: 'Genesis'),
          throwsA(isA<FormatException>()),
        );
      });

      test('throws FormatException for negative chapters', () {
        expect(
          () => ReadingReferenceParser.fromDailyReading('Genesis', '-1'),
          throwsA(isA<FormatException>()),
        );
      });

      test('parses reverse range correctly (larger start)', () {
        // This should parse successfully but the range semantics are up to the caller
        final result = ReadingReferenceParser.parse('Genesis 10-5');

        expect(result.startChapter, 10);
        expect(result.endChapter, 5);
        // Note: chapterCount will be negative in this case
      });
    });

    group('Real-world test cases', () {
      final testCases = [
        {'input': 'Genesis 1-3', 'book': 'Genesis', 'start': 1, 'end': 3},
        {'input': 'Exodus 20', 'book': 'Exodus', 'start': 20, 'end': 20},
        {'input': 'Leviticus 19', 'book': 'Leviticus', 'start': 19, 'end': 19},
        {'input': 'Numbers 6-7', 'book': 'Numbers', 'start': 6, 'end': 7},
        {'input': 'Deuteronomy 28', 'book': 'Deuteronomy', 'start': 28, 'end': 28},
        {'input': 'Joshua 1', 'book': 'Joshua', 'start': 1, 'end': 1},
        {'input': 'Judges 6-7', 'book': 'Judges', 'start': 6, 'end': 7},
        {'input': 'Ruth 1-2', 'book': 'Ruth', 'start': 1, 'end': 2},
        {'input': '1 Samuel 17', 'book': '1 Samuel', 'start': 17, 'end': 17},
        {'input': '2 Kings 2', 'book': '2 Kings', 'start': 2, 'end': 2},
        {'input': 'Psalms 23', 'book': 'Psalms', 'start': 23, 'end': 23},
        {'input': 'Proverbs 3', 'book': 'Proverbs', 'start': 3, 'end': 3},
        {'input': 'Isaiah 53', 'book': 'Isaiah', 'start': 53, 'end': 53},
        {'input': 'Jeremiah 29', 'book': 'Jeremiah', 'start': 29, 'end': 29},
        {'input': 'Ezekiel 37', 'book': 'Ezekiel', 'start': 37, 'end': 37},
        {'input': 'Daniel 6', 'book': 'Daniel', 'start': 6, 'end': 6},
        {'input': 'Matthew 5-7', 'book': 'Matthew', 'start': 5, 'end': 7},
        {'input': 'Mark 1', 'book': 'Mark', 'start': 1, 'end': 1},
        {'input': 'Luke 15', 'book': 'Luke', 'start': 15, 'end': 15},
        {'input': 'John 3', 'book': 'John', 'start': 3, 'end': 3},
        {'input': 'Acts 2', 'book': 'Acts', 'start': 2, 'end': 2},
        {'input': 'Romans 8', 'book': 'Romans', 'start': 8, 'end': 8},
        {'input': '1 Corinthians 13', 'book': '1 Corinthians', 'start': 13, 'end': 13},
        {'input': '2 Corinthians 5', 'book': '2 Corinthians', 'start': 5, 'end': 5},
        {'input': 'Galatians 5', 'book': 'Galatians', 'start': 5, 'end': 5},
        {'input': 'Ephesians 6', 'book': 'Ephesians', 'start': 6, 'end': 6},
        {'input': 'Philippians 4', 'book': 'Philippians', 'start': 4, 'end': 4},
        {'input': 'Colossians 3', 'book': 'Colossians', 'start': 3, 'end': 3},
        {'input': '1 Thessalonians 5', 'book': '1 Thessalonians', 'start': 5, 'end': 5},
        {'input': 'Hebrews 11', 'book': 'Hebrews', 'start': 11, 'end': 11},
        {'input': 'James 1', 'book': 'James', 'start': 1, 'end': 1},
        {'input': '1 Peter 3', 'book': '1 Peter', 'start': 3, 'end': 3},
        {'input': '1 John 4', 'book': '1 John', 'start': 4, 'end': 4},
        {'input': 'Revelation 21', 'book': 'Revelation', 'start': 21, 'end': 21},
      ];

      for (final testCase in testCases) {
        test('parses "${testCase['input']}" correctly', () {
          final result = ReadingReferenceParser.parse(testCase['input'] as String);

          expect(result.book, testCase['book']);
          expect(result.startChapter, testCase['start']);
          expect(result.endChapter, testCase['end']);
        });
      }
    });
  });
}
