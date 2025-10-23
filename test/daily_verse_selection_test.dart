import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/verse_service.dart';

void main() {
  late DatabaseService databaseService;
  late VerseService verseService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    verseService = VerseService(databaseService);

    // Insert test verses with themes
    final db = await databaseService.database;

    // Insert verses for different themes
    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'John',
      'chapter': 3,
      'verse': 16,
      'text': 'For God so loved the world, that he gave his only begotten Son',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Psalms',
      'chapter': 23,
      'verse': 1,
      'text': 'The LORD is my shepherd; I shall not want',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Philippians',
      'chapter': 4,
      'verse': 13,
      'text': 'I can do all things through Christ which strengtheneth me',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Isaiah',
      'chapter': 41,
      'verse': 10,
      'text': 'Fear not; for I am with thee: be not dismayed; for I am thy God',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Romans',
      'chapter': 8,
      'verse': 28,
      'text': 'And we know that all things work together for good to them that love God',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Proverbs',
      'chapter': 3,
      'verse': 5,
      'text': 'Trust in the LORD with all thine heart; and lean not unto thine own understanding',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Matthew',
      'chapter': 11,
      'verse': 28,
      'text': 'Come unto me, all ye that labour and are heavy laden, and I will give you rest',
      'language': 'en',
    });

    await db.insert('bible_verses', {
      'version': 'KJV',
      'book': 'Joshua',
      'chapter': 1,
      'verse': 9,
      'text': 'Be strong and of a good courage; be not afraid, neither be thou dismayed',
      'language': 'en',
    });

    // Populate FTS5 table
    await db.execute('''
      INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
      SELECT id, book, chapter, verse, text FROM bible_verses
    ''');

    // Verify default verse preferences exist (created by database initialization)
    final existingPrefs = await db.query('verse_preferences');
    if (existingPrefs.isEmpty) {
      // Set up default verse preferences if not already set
      await db.insert('verse_preferences', {
        'preference_key': 'preferred_themes',
        'preference_value': 'faith,hope,love',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('verse_preferences', {
        'preference_key': 'avoid_recent_days',
        'preference_value': '30',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('verse_preferences', {
        'preference_key': 'preferred_version',
        'preference_value': 'KJV',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Daily Verse Selection', () {
    test('should return a verse for today', () async {
      final verse = await verseService.getVerseOfTheDay();
      expect(verse, isNotNull);
      expect(verse!.text, isNotEmpty);
      expect(verse.reference, isNotEmpty);
    });

    test('should return the same verse when called multiple times on same day', () async {
      final verse1 = await verseService.getVerseOfTheDay();
      final verse2 = await verseService.getVerseOfTheDay();

      expect(verse1, isNotNull);
      expect(verse2, isNotNull);
      expect(verse1!.id, equals(verse2!.id));
      expect(verse1.text, equals(verse2.text));
    });

    test('should record verse in daily_verse_history table', () async {
      final verse = await verseService.getVerseOfTheDay();
      expect(verse, isNotNull);

      final db = await databaseService.database;
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

      final history = await db.query(
        'daily_verse_history',
        where: 'shown_date = ?',
        whereArgs: [todayTimestamp],
      );

      expect(history, isNotEmpty);
      expect(history.first['verse_id'], equals(int.parse(verse!.id)));
    });

    test('should avoid recently shown verses', () async {
      final db = await databaseService.database;

      // Mark verse 1 as shown yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayTimestamp = DateTime(yesterday.year, yesterday.month, yesterday.day).millisecondsSinceEpoch;

      await db.insert('daily_verse_history', {
        'verse_id': 1,
        'shown_date': yesterdayTimestamp,
        'theme': 'love',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Get today's verse
      final todayVerse = await verseService.getVerseOfTheDay();
      expect(todayVerse, isNotNull);

      // Should not be verse 1 since it was shown yesterday
      expect(todayVerse!.id, isNot(equals('1')));
    });

    test('should select verse based on theme preferences', () async {
      // Update preferences to prefer specific themes
      await verseService.updatePreferredThemes(['strength', 'courage']);

      // Clear today's verse to force new selection
      final db = await databaseService.database;
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      await db.delete('daily_verse_history', where: 'shown_date = ?', whereArgs: [todayTimestamp]);

      // Get verse - should prefer strength/courage themes
      final verse = await verseService.getVerseOfTheDay();
      expect(verse, isNotNull);

      // Verify it's a valid verse
      expect(verse!.text, isNotEmpty);
    });

    test('should respect avoid_recent_days preference', () async {
      final db = await databaseService.database;

      // Update preference to avoid verses from last 7 days
      await verseService.updateAvoidRecentDays(7);

      // Mark verse 2 as shown 5 days ago (within avoidance window)
      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final fiveDaysAgoTimestamp = DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day).millisecondsSinceEpoch;

      await db.insert('daily_verse_history', {
        'verse_id': 2,
        'shown_date': fiveDaysAgoTimestamp,
        'theme': 'peace',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Get today's verse
      final todayVerse = await verseService.getVerseOfTheDay();
      expect(todayVerse, isNotNull);

      // Should not be verse 2 since it was shown within 7 days
      expect(todayVerse!.id, isNot(equals('2')));
    });

    test('should handle empty database gracefully', () async {
      // Clear all verses
      final db = await databaseService.database;
      await db.delete('bible_verses');

      final verse = await verseService.getVerseOfTheDay();

      // Should return null or handle gracefully
      expect(verse, isNull);
    });

    test('should update preferred themes successfully', () async {
      final newThemes = ['hope', 'faith', 'peace'];
      await verseService.updatePreferredThemes(newThemes);

      final db = await databaseService.database;
      final result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['preferred_themes'],
      );

      expect(result, isNotEmpty);
      expect(result.first['preference_value'], equals(newThemes.join(',')));
    });

    test('should update avoid_recent_days successfully', () async {
      await verseService.updateAvoidRecentDays(45);

      final db = await databaseService.database;
      final result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['avoid_recent_days'],
      );

      expect(result, isNotEmpty);
      expect(result.first['preference_value'], equals('45'));
    });

    test('should update preferred version successfully', () async {
      await verseService.updatePreferredVersion('ESV');

      final db = await databaseService.database;
      final result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['preferred_version'],
      );

      expect(result, isNotEmpty);
      expect(result.first['preference_value'], equals('ESV'));
    });

    test('should retrieve daily verse history', () async {
      // Insert some historical verses
      final db = await databaseService.database;
      final now = DateTime.now();

      for (int i = 1; i <= 5; i++) {
        final date = now.subtract(Duration(days: i));
        final timestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

        await db.insert('daily_verse_history', {
          'verse_id': i,
          'shown_date': timestamp,
          'theme': 'faith',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      final history = await verseService.getDailyVerseHistory(limit: 10);
      expect(history.length, greaterThanOrEqualTo(5));

      // Verify history is sorted by date descending
      if (history.length > 1) {
        final first = history[0]['shownDate'] as DateTime;
        final second = history[1]['shownDate'] as DateTime;
        expect(first.isAfter(second) || first.isAtSameMomentAs(second), isTrue);
      }
    });

    test('should clear daily verse history', () async {
      // Insert some historical verses
      final db = await databaseService.database;
      final now = DateTime.now();

      for (int i = 1; i <= 3; i++) {
        final date = now.subtract(Duration(days: i));
        final timestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

        await db.insert('daily_verse_history', {
          'verse_id': i,
          'shown_date': timestamp,
          'theme': 'hope',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Verify history exists
      var history = await verseService.getDailyVerseHistory();
      expect(history.length, greaterThan(0));

      // Clear history
      await verseService.clearDailyVerseHistory();

      // Verify history is empty
      history = await verseService.getDailyVerseHistory();
      expect(history, isEmpty);
    });

    test('should handle theme rotation by day of year', () async {
      // This test verifies that the theme selection uses day of year for rotation
      final verse = await verseService.getVerseOfTheDay();
      expect(verse, isNotNull);

      // The verse should have been selected with a theme from preferences
      final db = await databaseService.database;
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

      final history = await db.query(
        'daily_verse_history',
        where: 'shown_date = ?',
        whereArgs: [todayTimestamp],
      );

      expect(history, isNotEmpty);
      expect(history.first['theme'], isNotNull);
    });

    test('should fallback to random verse if no theme matches', () async {
      final db = await databaseService.database;

      // Set preference to a theme that won't match any verses
      await verseService.updatePreferredThemes(['nonexistent_theme']);

      // Clear today's verse
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      await db.delete('daily_verse_history', where: 'shown_date = ?', whereArgs: [todayTimestamp]);

      // Should still return a verse (fallback to random)
      final verse = await verseService.getVerseOfTheDay();
      expect(verse, isNotNull);
      expect(verse!.text, isNotEmpty);
    });

    test('should handle force theme parameter', () async {
      final db = await databaseService.database;

      // Clear today's verse
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
      await db.delete('daily_verse_history', where: 'shown_date = ?', whereArgs: [todayTimestamp]);

      // Force a specific theme
      final verse = await verseService.getVerseOfTheDay(forceTheme: 'strength');
      expect(verse, isNotNull);

      // Verify the forced theme was recorded
      final history = await db.query(
        'daily_verse_history',
        where: 'shown_date = ?',
        whereArgs: [todayTimestamp],
      );

      expect(history, isNotEmpty);
      expect(history.first['theme'], equals('strength'));
    });
  });

  group('Verse Preferences Management', () {
    test('should maintain multiple preferences independently', () async {
      await verseService.updatePreferredThemes(['love', 'joy']);
      await verseService.updateAvoidRecentDays(60);
      await verseService.updatePreferredVersion('NIV');

      final db = await databaseService.database;
      final prefs = await db.query('verse_preferences');

      final prefsMap = {
        for (var pref in prefs)
          pref['preference_key'] as String: pref['preference_value'] as String
      };

      expect(prefsMap['preferred_themes'], equals('love,joy'));
      expect(prefsMap['avoid_recent_days'], equals('60'));
      expect(prefsMap['preferred_version'], equals('NIV'));
    });

    test('should handle empty theme list', () async {
      await verseService.updatePreferredThemes([]);

      final db = await databaseService.database;
      final result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['preferred_themes'],
      );

      expect(result, isNotEmpty);
      expect(result.first['preference_value'], equals(''));
    });

    test('should validate avoid_recent_days bounds', () async {
      // Test minimum value
      await verseService.updateAvoidRecentDays(1);

      final db = await databaseService.database;
      var result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['avoid_recent_days'],
      );

      expect(result.first['preference_value'], equals('1'));

      // Test maximum value
      await verseService.updateAvoidRecentDays(365);
      result = await db.query(
        'verse_preferences',
        where: 'preference_key = ?',
        whereArgs: ['avoid_recent_days'],
      );

      expect(result.first['preference_value'], equals('365'));
    });
  });

  group('Verse History Tracking', () {
    test('should not allow duplicate entries for same verse and date', () async {
      final db = await databaseService.database;
      final today = DateTime.now();
      final todayTimestamp = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;

      // Insert first entry
      await db.insert('daily_verse_history', {
        'verse_id': 1,
        'shown_date': todayTimestamp,
        'theme': 'faith',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Try to insert duplicate - should replace due to UNIQUE constraint
      await db.insert(
        'daily_verse_history',
        {
          'verse_id': 1,
          'shown_date': todayTimestamp,
          'theme': 'hope',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final history = await db.query(
        'daily_verse_history',
        where: 'shown_date = ?',
        whereArgs: [todayTimestamp],
      );

      // Should only have one entry
      expect(history.length, equals(1));
      expect(history.first['theme'], equals('hope')); // Updated value
    });

    test('should track verses across multiple days', () async {
      final db = await databaseService.database;
      final now = DateTime.now();

      // Insert verses for last 7 days
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: i));
        final timestamp = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;

        await db.insert('daily_verse_history', {
          'verse_id': (i % 5) + 1, // Rotate through verses 1-5
          'shown_date': timestamp,
          'theme': 'peace',
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      final history = await verseService.getDailyVerseHistory(limit: 10);
      expect(history.length, equals(7));
    });
  });
}
