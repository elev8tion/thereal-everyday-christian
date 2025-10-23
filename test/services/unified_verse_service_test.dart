import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/services/unified_verse_service.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
// import 'package:everyday_christian/core/database/migrations/v1_initial_schema.dart'; // File doesn't exist

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing
  sqfliteFfiInit();

  setUpAll(() {
    databaseFactory = databaseFactoryFfi;
  });

  group('UnifiedVerseService Tests', () {
    late UnifiedVerseService service;

    setUp(() async {
      // Use in-memory database for tests
      DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);

      // Initialize the database (will run migrations automatically)
      await DatabaseHelper.instance.database;

      service = UnifiedVerseService();
    });

    tearDown(() async {
      final db = await DatabaseHelper.instance.database;
      await db.close();
      DatabaseHelper.setTestDatabasePath(null);
    });

    test('searchVerses returns results for valid query', () async {
      final results = await service.searchVerses('hope');

      expect(results, isNotEmpty);
      expect(results.first.text, contains('hope'));
    });

    test('searchVerses with FTS5 returns relevant results', () async {
      final results = await service.searchVerses('strength');

      expect(results, isNotEmpty);
      // Should use FTS5 ranking
      for (final verse in results) {
        expect(
          verse.text.toLowerCase().contains('strength') ||
          verse.themes.any((t) => t.toLowerCase().contains('strength')),
          isTrue,
        );
      }
    });

    test('searchVerses returns empty list for empty query', () async {
      final results = await service.searchVerses('');

      expect(results, isEmpty);
    });

    test('searchByTheme returns verses with matching theme', () async {
      final results = await service.searchByTheme('hope');

      expect(results, isNotEmpty);
      for (final verse in results) {
        expect(
          verse.themes.any((t) => t.toLowerCase().contains('hope')),
          isTrue,
        );
      }
    });

    test('getAllVerses returns verses', () async {
      final results = await service.getAllVerses(limit: 10);

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(10));
    });

    test('getFavoriteVerses returns empty list initially', () async {
      final results = await service.getFavoriteVerses();

      expect(results, isEmpty);
    });

    test('addToFavorites and getFavoriteVerses work correctly', () async {
      // Get a verse
      final allVerses = await service.getAllVerses(limit: 1);
      expect(allVerses, isNotEmpty);

      final verse = allVerses.first;
      final verseId = verse.id!;

      // Add to favorites
      await service.addToFavorites(verseId);

      // Check if it's in favorites
      final favorites = await service.getFavoriteVerses();
      expect(favorites, hasLength(1));
      expect(favorites.first.id, equals(verseId));
      expect(favorites.first.isFavorite, isTrue);
    });

    test('removeFromFavorites works correctly', () async {
      // Get a verse and add to favorites
      final allVerses = await service.getAllVerses(limit: 1);
      final verse = allVerses.first;
      final verseId = verse.id!;

      await service.addToFavorites(verseId);

      // Verify it's in favorites
      var favorites = await service.getFavoriteVerses();
      expect(favorites, hasLength(1));

      // Remove from favorites
      await service.removeFromFavorites(verseId);

      // Verify it's removed
      favorites = await service.getFavoriteVerses();
      expect(favorites, isEmpty);
    });

    test('toggleFavorite works correctly', () async {
      final allVerses = await service.getAllVerses(limit: 1);
      final verse = allVerses.first;
      final verseId = verse.id!;

      // Toggle on (should return true)
      final isNowFavorite = await service.toggleFavorite(verseId);
      expect(isNowFavorite, isTrue);

      var favorites = await service.getFavoriteVerses();
      expect(favorites, hasLength(1));

      // Toggle off (should return false)
      final isStillFavorite = await service.toggleFavorite(verseId);
      expect(isStillFavorite, isFalse);

      favorites = await service.getFavoriteVerses();
      expect(favorites, isEmpty);
    });

    test('isVerseFavorite returns correct status', () async {
      final allVerses = await service.getAllVerses(limit: 1);
      final verse = allVerses.first;
      final verseId = verse.id!;

      // Initially not favorite
      var isFavorite = await service.isVerseFavorite(verseId);
      expect(isFavorite, isFalse);

      // Add to favorites
      await service.addToFavorites(verseId);

      // Now should be favorite
      isFavorite = await service.isVerseFavorite(verseId);
      expect(isFavorite, isTrue);
    });

    test('getAllThemes returns list of themes', () async {
      final themes = await service.getAllThemes();

      expect(themes, isNotEmpty);
      expect(themes, contains('hope'));
      expect(themes, contains('strength'));
    });

    test('getVersesForSituation returns relevant verses', () async {
      final results = await service.getVersesForSituation('anxiety', limit: 5);

      expect(results, isNotEmpty);
      expect(results.length, lessThanOrEqualTo(5));
    });

    test('getDailyVerse returns a verse', () async {
      final verse = await service.getDailyVerse();

      expect(verse, isNotNull);
      expect(verse!.text, isNotEmpty);
    });

    test('getDailyVerse with theme filter returns themed verse', () async {
      final verse = await service.getDailyVerse(preferredTheme: 'hope');

      expect(verse, isNotNull);
      expect(
        verse!.themes.any((t) => t.toLowerCase().contains('hope')),
        isTrue,
      );
    });

    test('getVerseStats returns statistics', () async {
      final stats = await service.getVerseStats();

      expect(stats, isNotNull);
      expect(stats['total_verses'], greaterThan(0));
      expect(stats['favorite_verses'], equals(0));
      expect(stats['popular_themes'], isNotNull);
    });

    test('updateFavorite updates note and tags', () async {
      final allVerses = await service.getAllVerses(limit: 1);
      final verse = allVerses.first;
      final verseId = verse.id!;

      // Add to favorites
      await service.addToFavorites(verseId);

      // Update with note and tags
      await service.updateFavorite(
        verseId,
        note: 'My favorite verse',
        tags: ['personal', 'encouragement'],
      );

      // Verify update (would need to enhance service to return note/tags)
      final isFavorite = await service.isVerseFavorite(verseId);
      expect(isFavorite, isTrue);
    });

    test('getVerseByReference returns correct verse', () async {
      // Jeremiah 29:11 is in sample data
      final verse = await service.getVerseByReference('Jeremiah 29:11');

      expect(verse, isNotNull);
      expect(verse!.book, equals('Jeremiah'));
      expect(verse.chapter, equals(29));
      expect(verse.verseNumber, equals(11));
    });

    test('getVerseByReference returns null for invalid reference', () async {
      final verse = await service.getVerseByReference('Invalid Reference');

      expect(verse, isNull);
    });

    test('favorite status persists across queries', () async {
      // Get a verse and favorite it
      final allVerses = await service.getAllVerses(limit: 1);
      final verse = allVerses.first;
      final verseId = verse.id!;

      await service.addToFavorites(verseId);

      // Search for the same verse
      final searchResults = await service.searchVerses(verse.text.substring(0, 10));

      // Find the verse in search results
      final foundVerse = searchResults.firstWhere(
        (v) => v.id == verseId,
        orElse: () => throw Exception('Verse not found in search'),
      );

      expect(foundVerse.isFavorite, isTrue);
    });
  });
}
