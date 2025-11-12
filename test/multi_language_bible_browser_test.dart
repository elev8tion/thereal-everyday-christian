import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/bible_book_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-Language Bible Browser Tests', () {
    late BibleBookService bookService;

    setUp(() async {
      bookService = BibleBookService.instance;
    });

    test('BibleBookService loads all 66 books', () async {
      final allBooks = await bookService.getAllBooks();
      expect(allBooks.length, 66, reason: 'Should have all 66 Bible books');
    });

    test('Old Testament has 39 books', () async {
      final otBooks = await bookService.getOldTestamentBooks();
      expect(otBooks.length, 39, reason: 'Old Testament should have 39 books');

      // Verify first and last OT books
      expect(otBooks.first.englishName, 'Genesis');
      expect(otBooks.last.englishName, 'Malachi');
    });

    test('New Testament has 27 books', () async {
      final ntBooks = await bookService.getNewTestamentBooks();
      expect(ntBooks.length, 27, reason: 'New Testament should have 27 books');

      // Verify first and last NT books
      expect(ntBooks.first.englishName, 'Matthew');
      expect(ntBooks.last.englishName, 'Revelation');
    });

    test('Spanish book names are correct', () async {
      final otBooks = await bookService.getOldTestamentBooks();
      final ntBooks = await bookService.getNewTestamentBooks();

      // Verify first and last OT books in Spanish
      expect(otBooks.first.spanishName, 'Génesis');
      expect(otBooks.last.spanishName, 'Malaquías');

      // Verify first and last NT books in Spanish
      expect(ntBooks.first.spanishName, 'Mateo');
      expect(ntBooks.last.spanishName, 'Apocalipsis');
    });

    test('Bible book metadata is correct for both languages', () async {
      final allBooks = await bookService.getAllBooks();

      // Verify critical books have correct metadata
      final genesis = allBooks.firstWhere((b) => b.englishName == 'Genesis');
      expect(genesis.spanishName, 'Génesis');
      expect(genesis.chapters, 50);
      expect(genesis.testament, 'Old Testament');

      final john = allBooks.firstWhere((b) => b.englishName == 'John');
      expect(john.spanishName, 'Juan');
      expect(john.chapters, 21);
      expect(john.testament, 'New Testament');

      final psalms = allBooks.firstWhere((b) => b.englishName == 'Psalms');
      expect(psalms.spanishName, 'Salmos');
      expect(psalms.chapters, 150);
      expect(psalms.testament, 'Old Testament');

      final revelation = allBooks.firstWhere((b) => b.englishName == 'Revelation');
      expect(revelation.spanishName, 'Apocalipsis');
      expect(revelation.chapters, 22);
      expect(revelation.testament, 'New Testament');
    });

    test('BibleBookService getName() returns correct language', () async {
      final allBooks = await bookService.getAllBooks();
      final genesis = allBooks.firstWhere((b) => b.englishName == 'Genesis');

      // English
      expect(genesis.getName('en'), 'Genesis');

      // Spanish
      expect(genesis.getName('es'), 'Génesis');

      // Default fallback
      expect(genesis.getName('fr'), 'Genesis', reason: 'Should fallback to English for unsupported languages');
    });

    test('BibleBookService matchesName() works for both languages', () async {
      final allBooks = await bookService.getAllBooks();
      final matthew = allBooks.firstWhere((b) => b.englishName == 'Matthew');

      // English name
      expect(matthew.matchesName('Matthew'), true);
      expect(matthew.matchesName('matthew'), true);

      // Spanish name
      expect(matthew.matchesName('Mateo'), true);
      expect(matthew.matchesName('mateo'), true);

      // Wrong name
      expect(matthew.matchesName('Genesis'), false);
      expect(matthew.matchesName('Génesis'), false);
    });

    test('All 66 books have valid bilingual names', () async {
      final allBooks = await bookService.getAllBooks();

      for (final book in allBooks) {
        expect(book.englishName, isNotEmpty, reason: 'Book ${book.id} missing English name');
        expect(book.spanishName, isNotEmpty, reason: 'Book ${book.id} missing Spanish name');
        expect(book.chapters, greaterThan(0), reason: 'Book ${book.id} must have at least 1 chapter');
        expect(book.testament, anyOf('Old Testament', 'New Testament'),
          reason: 'Book ${book.id} has invalid testament');
      }

      // Verify some books have different names (most do)
      final genesisBook = allBooks.firstWhere((b) => b.id == 1);
      expect(genesisBook.englishName, 'Genesis');
      expect(genesisBook.spanishName, 'Génesis');

      // Some books like "1 Samuel" are the same in both languages (proper nouns)
      final samuelBook = allBooks.firstWhere((b) => b.id == 9);
      expect(samuelBook.englishName, '1 Samuel');
      expect(samuelBook.spanishName, '1 Samuel');
    });

    test('Book IDs are sequential from 1 to 66', () async {
      final allBooks = await bookService.getAllBooks();

      for (int i = 0; i < allBooks.length; i++) {
        expect(allBooks[i].id, i + 1, reason: 'Book at index $i should have ID ${i + 1}');
      }
    });

    test('Testament counts are correct', () async {
      final otBooks = await bookService.getOldTestamentBooks();
      final ntBooks = await bookService.getNewTestamentBooks();

      expect(otBooks.length, 39);
      expect(ntBooks.length, 27);
      expect(otBooks.length + ntBooks.length, 66);
    });
  });
}
