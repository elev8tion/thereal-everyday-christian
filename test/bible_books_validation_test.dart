import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/bible_book_service.dart';
import 'package:everyday_christian/models/bible_book.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bible_books.json Validation Tests', () {
    late BibleBookService bookService;
    late List<BibleBook> allBooks;

    setUpAll(() async {
      bookService = BibleBookService.instance;

      // Clear cache to ensure fresh load
      bookService.clearCache();

      // Load books from JSON
      allBooks = await bookService.getAllBooks();
    });

    test('JSON file must contain exactly 66 books', () {
      expect(
        allBooks.length,
        66,
        reason: 'Bible must have exactly 66 canonical books',
      );
    });

    test('Must have exactly 39 Old Testament books', () {
      final otBooks = allBooks.where((b) => b.testament == 'Old Testament').toList();
      expect(
        otBooks.length,
        39,
        reason: 'Old Testament must have 39 books (Genesis through Malachi)',
      );
    });

    test('Must have exactly 27 New Testament books', () {
      final ntBooks = allBooks.where((b) => b.testament == 'New Testament').toList();
      expect(
        ntBooks.length,
        27,
        reason: 'New Testament must have 27 books (Matthew through Revelation)',
      );
    });

    test('All books must have valid IDs (1-66)', () {
      for (final book in allBooks) {
        expect(
          book.id,
          inInclusiveRange(1, 66),
          reason: 'Book "${book.englishName}" has invalid ID: ${book.id}',
        );
      }
    });

    test('Book IDs must be sequential and unique', () {
      final ids = allBooks.map((b) => b.id).toList();
      final expectedIds = List.generate(66, (i) => i + 1);

      expect(
        ids,
        containsAll(expectedIds),
        reason: 'All IDs from 1-66 must be present',
      );

      expect(
        ids.toSet().length,
        66,
        reason: 'All IDs must be unique (no duplicates)',
      );
    });

    test('All books must have non-empty English names', () {
      for (final book in allBooks) {
        expect(
          book.englishName,
          isNotEmpty,
          reason: 'Book ID ${book.id} has empty English name',
        );
        expect(
          book.englishName.trim(),
          book.englishName,
          reason: 'Book "${book.englishName}" has leading/trailing whitespace',
        );
      }
    });

    test('All books must have non-empty Spanish names', () {
      for (final book in allBooks) {
        expect(
          book.spanishName,
          isNotEmpty,
          reason: 'Book ID ${book.id} (${book.englishName}) has empty Spanish name',
        );
        expect(
          book.spanishName.trim(),
          book.spanishName,
          reason: 'Book "${book.spanishName}" has leading/trailing whitespace',
        );
      }
    });

    test('All books must have valid abbreviations', () {
      for (final book in allBooks) {
        expect(
          book.abbreviation,
          isNotEmpty,
          reason: 'Book "${book.englishName}" has empty abbreviation',
        );
        expect(
          book.abbreviation.length,
          lessThanOrEqualTo(3),
          reason: 'Book "${book.englishName}" abbreviation "${book.abbreviation}" is too long (max 3 chars)',
        );
      }
    });

    test('All books must have valid chapter counts', () {
      for (final book in allBooks) {
        expect(
          book.chapters,
          greaterThan(0),
          reason: 'Book "${book.englishName}" has invalid chapter count: ${book.chapters}',
        );
        expect(
          book.chapters,
          lessThanOrEqualTo(150),
          reason: 'Book "${book.englishName}" has suspiciously high chapter count: ${book.chapters}',
        );
      }
    });

    test('Testament values must be exactly "Old Testament" or "New Testament"', () {
      for (final book in allBooks) {
        expect(
          book.testament,
          anyOf(['Old Testament', 'New Testament']),
          reason: 'Book "${book.englishName}" has invalid testament: "${book.testament}"',
        );
      }
    });

    test('First book must be Genesis', () {
      final firstBook = allBooks.firstWhere((b) => b.id == 1);
      expect(firstBook.englishName, 'Genesis');
      expect(firstBook.spanishName, 'Génesis');
      expect(firstBook.testament, 'Old Testament');
      expect(firstBook.chapters, 50);
    });

    test('Last Old Testament book must be Malachi (ID 39)', () {
      final malachi = allBooks.firstWhere((b) => b.id == 39);
      expect(malachi.englishName, 'Malachi');
      expect(malachi.spanishName, 'Malaquías');
      expect(malachi.testament, 'Old Testament');
      expect(malachi.chapters, 4);
    });

    test('First New Testament book must be Matthew (ID 40)', () {
      final matthew = allBooks.firstWhere((b) => b.id == 40);
      expect(matthew.englishName, 'Matthew');
      expect(matthew.spanishName, 'Mateo');
      expect(matthew.testament, 'New Testament');
      expect(matthew.chapters, 28);
    });

    test('Last book must be Revelation (ID 66)', () {
      final revelation = allBooks.firstWhere((b) => b.id == 66);
      expect(revelation.englishName, 'Revelation');
      expect(revelation.spanishName, 'Apocalipsis');
      expect(revelation.testament, 'New Testament');
      expect(revelation.chapters, 22);
    });

    test('Psalms must have 150 chapters (largest book)', () {
      final psalms = allBooks.firstWhere((b) => b.englishName == 'Psalms');
      expect(psalms.chapters, 150);
      expect(psalms.spanishName, 'Salmos');
    });

    test('English names must be unique', () {
      final englishNames = allBooks.map((b) => b.englishName).toList();
      expect(
        englishNames.toSet().length,
        66,
        reason: 'English names must be unique (found duplicates)',
      );
    });

    test('Spanish names must be unique', () {
      final spanishNames = allBooks.map((b) => b.spanishName).toList();
      expect(
        spanishNames.toSet().length,
        66,
        reason: 'Spanish names must be unique (found duplicates)',
      );
    });

    test('BibleBookService getByName() works for English names', () async {
      final genesis = await bookService.getBookByEnglishName('Genesis');
      expect(genesis, isNotNull);
      expect(genesis!.id, 1);
      expect(genesis.chapters, 50);
    });

    test('BibleBookService getByName() works for Spanish names', () async {
      final genesis = await bookService.getBookBySpanishName('Génesis');
      expect(genesis, isNotNull);
      expect(genesis!.id, 1);
      expect(genesis.chapters, 50);
    });

    test('BibleBookService getOldTestamentBooks() returns 39 books', () async {
      final otBooks = await bookService.getOldTestamentBooks();
      expect(otBooks.length, 39);
      expect(otBooks.first.englishName, 'Genesis');
      expect(otBooks.last.englishName, 'Malachi');
    });

    test('BibleBookService getNewTestamentBooks() returns 27 books', () async {
      final ntBooks = await bookService.getNewTestamentBooks();
      expect(ntBooks.length, 27);
      expect(ntBooks.first.englishName, 'Matthew');
      expect(ntBooks.last.englishName, 'Revelation');
    });

    test('Known books must have correct metadata', () {
      // Test a few key books to ensure data integrity
      final keyBooks = {
        'Genesis': {'spanish': 'Génesis', 'chapters': 50, 'testament': 'Old Testament'},
        'Exodus': {'spanish': 'Éxodo', 'chapters': 40, 'testament': 'Old Testament'},
        'Psalms': {'spanish': 'Salmos', 'chapters': 150, 'testament': 'Old Testament'},
        'John': {'spanish': 'Juan', 'chapters': 21, 'testament': 'New Testament'},
        'Romans': {'spanish': 'Romanos', 'chapters': 16, 'testament': 'New Testament'},
        'Revelation': {'spanish': 'Apocalipsis', 'chapters': 22, 'testament': 'New Testament'},
      };

      for (final entry in keyBooks.entries) {
        final englishName = entry.key;
        final expectedData = entry.value;

        final book = allBooks.firstWhere((b) => b.englishName == englishName);

        expect(
          book.spanishName,
          expectedData['spanish'],
          reason: 'Book "$englishName" has incorrect Spanish name',
        );
        expect(
          book.chapters,
          expectedData['chapters'],
          reason: 'Book "$englishName" has incorrect chapter count',
        );
        expect(
          book.testament,
          expectedData['testament'],
          reason: 'Book "$englishName" has incorrect testament',
        );
      }
    });
  });
}
