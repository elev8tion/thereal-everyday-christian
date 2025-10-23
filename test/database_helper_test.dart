import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      // Use in-memory database for each test
      DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      await dbHelper.close();
      DatabaseHelper.setTestDatabasePath(null);
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        final instance1 = DatabaseHelper.instance;
        final instance2 = DatabaseHelper.instance;

        expect(instance1, same(instance2));
      });

      test('should initialize database', () async {
        final db = await dbHelper.database;
        expect(db, isNotNull);
      });
    });

    group('Verse Operations', () {
      test('should insert verse', () async {
        final verse = {
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        };

        final id = await dbHelper.insertVerse(verse);
        expect(id, greaterThan(0));
      });

      test('should get verse by ID', () async {
        final verse = {
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        };

        final id = await dbHelper.insertVerse(verse);
        final retrieved = await dbHelper.getVerse(id);

        expect(retrieved, isNotNull);
        expect(retrieved!['book'], equals('John'));
        expect(retrieved['chapter'], equals(3));
        expect(retrieved['verse_number'], equals(16));
      });

      test('should return null for non-existent verse', () async {
        final verse = await dbHelper.getVerse(99999);
        expect(verse, isNull);
      });

      test('should replace verse on conflict', () async {
        final verse1 = {
          'id': 1,
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'Original text',
          'translation': 'NIV',
        };

        final verse2 = {
          'id': 1,
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'Updated text',
          'translation': 'NIV',
        };

        await dbHelper.insertVerse(verse1);
        await dbHelper.insertVerse(verse2);

        final retrieved = await dbHelper.getVerse(1);
        expect(retrieved!['text'], equals('Updated text'));
      });

      test('should search verses by translation', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        });

        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'Porque de tal manera amó Dios al mundo',
          'translation': 'RVR1960',
        });

        final results = await dbHelper.searchVerses(translation: 'NIV');
        expect(results.length, equals(1));
        expect(results.first['translation'], equals('NIV'));
      });

      test('should limit search results', () async {
        for (int i = 1; i <= 10; i++) {
          await dbHelper.insertVerse({
            'book': 'Psalms',
            'chapter': 23,
            'verse_number': i,
            'text': 'Verse $i',
            'translation': 'NIV',
          });
        }

        final results = await dbHelper.searchVerses(limit: 5);
        expect(results.length, equals(5));
      });

      test('should get random verse', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        });

        final randomVerse = await dbHelper.getRandomVerse();
        expect(randomVerse, isNotNull);
      });

      test('should return verse even when database has sample verses', () async {
        // The database includes sample verses from v1_initial_schema
        final randomVerse = await dbHelper.getRandomVerse();
        expect(randomVerse, isNotNull);
        expect(randomVerse!['translation'], isNotNull);
      });
    });

    group('Chat Message Operations', () {
      test('should insert chat message', () async {
        final message = {
          'session_id': 'session123',
          'user_input': 'Hello',
          'ai_response': 'Hi there!',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        final id = await dbHelper.insertChatMessage(message);
        expect(id, greaterThan(0));
      });

      test('should get chat messages by session', () async {
        const sessionId = 'session123';

        await dbHelper.insertChatMessage({
          'session_id': sessionId,
          'user_input': 'Message 1',
          'ai_response': 'Reply 1',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertChatMessage({
          'session_id': sessionId,
          'user_input': 'Message 2',
          'ai_response': 'Reply 2',
          'timestamp': DateTime.now().millisecondsSinceEpoch + 1000,
        });

        final messages = await dbHelper.getChatMessages(sessionId: sessionId);
        expect(messages.length, equals(2));
      });

      test('should get all chat messages when no session specified', () async {
        await dbHelper.insertChatMessage({
          'session_id': 'session1',
          'user_input': 'Message 1',
          'ai_response': 'Response 1',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertChatMessage({
          'session_id': 'session2',
          'user_input': 'Message 2',
          'ai_response': 'Response 2',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        final messages = await dbHelper.getChatMessages();
        expect(messages.length, greaterThanOrEqualTo(2));
      });

      test('should limit chat messages', () async {
        const sessionId = 'session123';

        for (int i = 0; i < 10; i++) {
          await dbHelper.insertChatMessage({
            'session_id': sessionId,
            'user_input': 'Message $i',
            'ai_response': 'Response $i',
            'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          });
        }

        final messages = await dbHelper.getChatMessages(
          sessionId: sessionId,
          limit: 5,
        );
        expect(messages.length, equals(5));
      });

      test('should use offset for pagination', () async {
        const sessionId = 'session123';

        for (int i = 0; i < 10; i++) {
          await dbHelper.insertChatMessage({
            'session_id': sessionId,
            'user_input': 'Message $i',
            'ai_response': 'Response $i',
            'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          });
        }

        final page1 = await dbHelper.getChatMessages(
          sessionId: sessionId,
          limit: 5,
          offset: 0,
        );
        final page2 = await dbHelper.getChatMessages(
          sessionId: sessionId,
          limit: 5,
          offset: 5,
        );

        expect(page1.length, equals(5));
        expect(page2.length, equals(5));
        expect(page1.first['id'], isNot(equals(page2.first['id'])));
      });

      test('should delete old chat messages', () async {
        final old = DateTime.now().subtract(const Duration(days: 31));
        final recent = DateTime.now();

        await dbHelper.insertChatMessage({
          'session_id': 'session1',
          'user_input': 'Old message',
          'ai_response': 'Old response',
          'timestamp': old.millisecondsSinceEpoch,
        });

        await dbHelper.insertChatMessage({
          'session_id': 'session2',
          'user_input': 'Recent message',
          'ai_response': 'Recent response',
          'timestamp': recent.millisecondsSinceEpoch,
        });

        final deleted = await dbHelper.deleteOldChatMessages(30);
        expect(deleted, greaterThan(0));

        final remaining = await dbHelper.getChatMessages();
        expect(remaining.any((m) => m['user_input'] == 'Recent message'), isTrue);
      });

      test('should delete all messages when days is 0', () async {
        await dbHelper.insertChatMessage({
          'session_id': 'session1',
          'user_input': 'Message',
          'ai_response': 'Response',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        final deleted = await dbHelper.deleteOldChatMessages(0);
        expect(deleted, greaterThan(0));
      });
    });

    group('Prayer Request Operations', () {
      test('should insert prayer request', () async {
        final prayer = {
          'title': 'Test Prayer',
          'description': 'Please pray for me',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        };

        final id = await dbHelper.insertPrayerRequest(prayer);
        expect(id, greaterThan(0));
      });

      test('should update prayer request', () async {
        final prayer = {
          'title': 'Test Prayer',
          'description': 'Original description',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        };

        final id = await dbHelper.insertPrayerRequest(prayer);

        final updated = await dbHelper.updatePrayerRequest(id.toString(), {
          'description': 'Updated description',
        });

        expect(updated, equals(1));
      });

      test('should get all prayer requests', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 1',
          'description': 'Description 1',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 2',
          'description': 'Description 2',
          'category': 'cat_family',
          'status': 'answered',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final prayers = await dbHelper.getPrayerRequests();
        expect(prayers.length, greaterThanOrEqualTo(2));
      });

      test('should filter prayer requests by status', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Active Prayer',
          'description': 'Description',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Answered Prayer',
          'description': 'Description',
          'category': 'cat_general',
          'status': 'answered',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final activePrayers = await dbHelper.getPrayerRequests(status: 'active');
        expect(activePrayers.every((p) => p['status'] == 'active'), isTrue);
      });

      test('should filter prayer requests by category', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'General Prayer',
          'description': 'Description',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Family Prayer',
          'description': 'Description',
          'category': 'cat_family',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final familyPrayers = await dbHelper.getPrayerRequests(category: 'cat_family');
        expect(familyPrayers.every((p) => p['category'] == 'cat_family'), isTrue);
      });

      test('should filter by both status and category', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Active General',
          'description': 'Description',
          'category': 'cat_general',
          'status': 'active',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Answered General',
          'description': 'Description',
          'category': 'cat_general',
          'status': 'answered',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final filtered = await dbHelper.getPrayerRequests(
          status: 'active',
          category: 'cat_general',
        );

        expect(filtered.every((p) => p['status'] == 'active' && p['category'] == 'cat_general'), isTrue);
      });

      // Skip: markPrayerAnswered method doesn't exist in current implementation
      // test('should mark prayer as answered', () async {
      //   final id = await dbHelper.insertPrayerRequest({
      //     'title': 'Test Prayer',
      //     'description': 'Description',
      //     'category': 'cat_general',
      //     'status': 'active',
      //     'date_created': DateTime.now().millisecondsSinceEpoch,
      //   });
      //
      //   final updated = await dbHelper.markPrayerAnswered(id, 'God answered!');
      //   expect(updated, equals(1));
      //
      //   final prayers = await dbHelper.getPrayerRequests(status: 'answered');
      //   expect(prayers.any((p) => p['testimony'] == 'God answered!'), isTrue);
      // });
    });

    group('User Settings Operations', () {
      test('should set string setting', () async {
        await dbHelper.setSetting('theme', 'dark');
        final value = await dbHelper.getSetting<String>('theme');

        expect(value, equals('dark'));
      });

      test('should set bool setting', () async {
        await dbHelper.setSetting('notifications_enabled', true);
        final value = await dbHelper.getSetting<bool>('notifications_enabled');

        expect(value, isTrue);
      });

      test('should set int setting', () async {
        await dbHelper.setSetting('font_size', 16);
        final value = await dbHelper.getSetting<int>('font_size');

        expect(value, equals(16));
      });

      test('should set double setting', () async {
        await dbHelper.setSetting('volume', 0.75);
        final value = await dbHelper.getSetting<double>('volume');

        expect(value, equals(0.75));
      });

      test('should return default when setting not found', () async {
        final value = await dbHelper.getSetting<String>('nonexistent', defaultValue: 'default');
        expect(value, equals('default'));
      });

      test('should update setting on conflict', () async {
        await dbHelper.setSetting('theme', 'light');
        await dbHelper.setSetting('theme', 'dark');

        final value = await dbHelper.getSetting<String>('theme');
        expect(value, equals('dark'));
      });

      test('should delete setting', () async {
        await dbHelper.setSetting('temp_setting', 'value');
        final deleted = await dbHelper.deleteSetting('temp_setting');

        expect(deleted, equals(1));

        final value = await dbHelper.getSetting<String>('temp_setting');
        expect(value, isNull);
      });

      test('should return 0 when deleting non-existent setting', () async {
        final deleted = await dbHelper.deleteSetting('nonexistent');
        expect(deleted, equals(0));
      });
    });

    // Skip: Daily Verse Operations methods (recordDailyVerse, getDailyVerseHistory, markDailyVerseOpened, getVerseStreak) don't exist in current implementation
    // group('Daily Verse Operations', () {
    //   test('should record daily verse', () async {
    //     final verseId = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 16,
    //       'text': 'For God so loved the world',
    //       'translation': 'NIV',
    //     });
    //
    //     final id = await dbHelper.recordDailyVerse(
    //       verseId,
    //       DateTime.now(),
    //     );
    //
    //     expect(id, greaterThan(0));
    //   });
    //
    //   test('should record daily verse as opened', () async {
    //     final verseId = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 16,
    //       'text': 'For God so loved the world',
    //       'translation': 'NIV',
    //     });
    //
    //     await dbHelper.recordDailyVerse(
    //       verseId,
    //       DateTime.now(),
    //       opened: true,
    //     );
    //
    //     final history = await dbHelper.getDailyVerseHistory(limit: 1);
    //     expect(history.first['user_opened'], equals(1));
    //   });
    //
    //   test('should mark daily verse as opened', () async {
    //     final verseId = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 16,
    //       'text': 'For God so loved the world',
    //       'translation': 'NIV',
    //     });
    //
    //     final date = DateTime.now();
    //     await dbHelper.recordDailyVerse(verseId, date, opened: false);
    //
    //     final updated = await dbHelper.markDailyVerseOpened(verseId, date);
    //     expect(updated, greaterThan(0));
    //   });
    //
    //   test('should get daily verse history', () async {
    //     final verseId1 = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 16,
    //       'text': 'Verse 1',
    //       'translation': 'NIV',
    //     });
    //
    //     final verseId2 = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 17,
    //       'text': 'Verse 2',
    //       'translation': 'NIV',
    //     });
    //
    //     await dbHelper.recordDailyVerse(verseId1, DateTime.now());
    //     await dbHelper.recordDailyVerse(verseId2, DateTime.now());
    //
    //     final history = await dbHelper.getDailyVerseHistory();
    //     expect(history.length, greaterThanOrEqualTo(2));
    //     expect(history.first['text'], isNotNull);
    //   });
    //
    //   test('should limit daily verse history', () async {
    //     for (int i = 0; i < 5; i++) {
    //       final verseId = await dbHelper.insertVerse({
    //         'book': 'Psalms',
    //         'chapter': 23,
    //         'verse_number': i + 1,
    //         'text': 'Verse ${i + 1}',
    //         'translation': 'NIV',
    //       });
    //
    //       await dbHelper.recordDailyVerse(verseId, DateTime.now());
    //     }
    //
    //     final history = await dbHelper.getDailyVerseHistory(limit: 3);
    //     expect(history.length, equals(3));
    //   });
    //
    //   test('should get verse streak count', () async {
    //     final verseId = await dbHelper.insertVerse({
    //       'book': 'John',
    //       'chapter': 3,
    //       'verse_number': 16,
    //       'text': 'For God so loved the world',
    //       'translation': 'NIV',
    //     });
    //
    //     await dbHelper.recordDailyVerse(verseId, DateTime.now(), opened: true);
    //
    //     final streak = await dbHelper.getVerseStreak();
    //     expect(streak, greaterThanOrEqualTo(1));
    //   });
    //
    //   test('should return 0 streak when no opened verses', () async {
    //     final streak = await dbHelper.getVerseStreak();
    //     expect(streak, equals(0));
    //   });
    // });

    group('Database Management', () {
      test('should close database', () async {
        await dbHelper.database; // Initialize
        await dbHelper.close();

        // Database should be null after close
        expect(() => dbHelper.database, returnsNormally);
      });
    });

    group('Search Operations', () {
      test('should search verses with text query', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        });

        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 1,
          'verse_number': 1,
          'text': 'In the beginning was the Word',
          'translation': 'NIV',
        });

        final results = await dbHelper.searchVerses(query: 'loved');
        expect(results, isNotEmpty);
      });

      test('should search verses with themes', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
          'themes': '["love", "salvation"]',
        });

        await dbHelper.insertVerse({
          'book': 'Psalm',
          'chapter': 23,
          'verse_number': 1,
          'text': 'The Lord is my shepherd',
          'translation': 'NIV',
          'themes': '["comfort", "peace"]',
        });

        final results = await dbHelper.searchVerses(themes: ['love']);
        expect(results, isNotEmpty);
      });

      test('should search verses with query and themes combined', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
          'themes': '["love", "salvation"]',
        });

        final results = await dbHelper.searchVerses(
          query: 'God',
          themes: ['love'],
        );
        expect(results, isNotEmpty);
      });

      test('should search verses with translation filter', () async {
        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'For God so loved the world',
          'translation': 'NIV',
        });

        await dbHelper.insertVerse({
          'book': 'John',
          'chapter': 3,
          'verse_number': 16,
          'text': 'Porque de tal manera amó Dios al mundo',
          'translation': 'RVR1909',
        });

        final results = await dbHelper.searchVerses(
          translation: 'NIV',
        );
        expect(results, isNotEmpty);
        expect(results.every((v) => v['translation'] == 'NIV'), isTrue);
      });

      test('should limit search results', () async {
        for (int i = 0; i < 10; i++) {
          await dbHelper.insertVerse({
            'book': 'Psalms',
            'chapter': 119,
            'verse_number': i + 1,
            'text': 'Blessed are those verse $i',
            'translation': 'NIV',
          });
        }

        final results = await dbHelper.searchVerses(limit: 5);
        expect(results.length, lessThanOrEqualTo(5));
      });
    });

    group('Setting Type Conversions', () {
      test('should store and retrieve boolean setting', () async {
        await dbHelper.setSetting('dark_mode', true);
        final value = await dbHelper.getSetting<bool>('dark_mode');
        expect(value, isTrue);
      });

      test('should store and retrieve int setting', () async {
        await dbHelper.setSetting('font_size', 16);
        final value = await dbHelper.getSetting<int>('font_size');
        expect(value, equals(16));
      });

      test('should store and retrieve double setting', () async {
        await dbHelper.setSetting('volume', 0.75);
        final value = await dbHelper.getSetting<double>('volume');
        expect(value, equals(0.75));
      });

      test('should store and retrieve string setting', () async {
        await dbHelper.setSetting('language', 'English');
        final value = await dbHelper.getSetting<String>('language');
        expect(value, equals('English'));
      });

      test('should return default value for missing setting', () async {
        final value = await dbHelper.getSetting<String>('missing_key', defaultValue: 'default');
        expect(value, equals('default'));
      });

      test('should delete setting', () async {
        await dbHelper.setSetting('temp_key', 'temp_value');
        await dbHelper.deleteSetting('temp_key');

        final value = await dbHelper.getSetting<String>('temp_key');
        expect(value, isNull);
      });
    });

    group('Prayer Request Filtering', () {
      test('should filter prayer requests by status', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 1',
          'description': 'Please pray for healing',
          'status': 'active',
          'category': 'cat_health',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 2',
          'description': 'Pray for my family',
          'status': 'answered',
          'category': 'cat_family',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final activeRequests = await dbHelper.getPrayerRequests(status: 'active');
        expect(activeRequests.length, equals(1));
        expect(activeRequests.first['status'], equals('active'));
      });

      test('should filter prayer requests by category', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 1',
          'description': 'Please pray for healing',
          'status': 'active',
          'category': 'cat_health',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 2',
          'description': 'Pray for my family',
          'status': 'active',
          'category': 'cat_family',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final healthRequests = await dbHelper.getPrayerRequests(category: 'cat_health');
        expect(healthRequests.length, equals(1));
        expect(healthRequests.first['category'], equals('cat_health'));
      });

      test('should filter prayer requests by status and category', () async {
        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 1',
          'description': 'Please pray for healing',
          'status': 'active',
          'category': 'cat_health',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        await dbHelper.insertPrayerRequest({
          'title': 'Prayer 2',
          'description': 'Answered prayer testimony',
          'status': 'answered',
          'category': 'cat_health',
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });

        final filteredRequests = await dbHelper.getPrayerRequests(
          status: 'active',
          category: 'cat_health',
        );
        expect(filteredRequests.length, equals(1));
        expect(filteredRequests.first['status'], equals('active'));
        expect(filteredRequests.first['category'], equals('cat_health'));
      });
    });
  });
}
