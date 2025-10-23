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
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Database Initialization', () {
    test('should initialize database successfully', () async {
      final db = await databaseService.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create database with correct version', () async {
      final db = await databaseService.database;
      expect(await db.getVersion(), equals(5));
    });

    test('should return same database instance on multiple calls', () async {
      final db1 = await databaseService.database;
      final db2 = await databaseService.database;
      expect(db1, same(db2));
    });

    test('should use test database path when set', () async {
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
      final service = DatabaseService();
      final db = await service.database;
      expect(db, isNotNull);
      await service.close();
    });
  });

  group('Table Creation', () {
    test('should create prayer_requests table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'prayer_requests']);
      expect(result.length, equals(1));
    });

    test('should create bible_verses table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'bible_verses']);
      expect(result.length, equals(1));
    });

    test('should create favorite_verses table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'favorite_verses']);
      expect(result.length, equals(1));
    });

    test('should create devotionals table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'devotionals']);
      expect(result.length, equals(1));
    });

    test('should create reading_plans table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'reading_plans']);
      expect(result.length, equals(1));
    });

    test('should create daily_readings table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'daily_readings']);
      expect(result.length, equals(1));
    });

    test('should create prayer_streak_activity table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'prayer_streak_activity']);
      expect(result.length, equals(1));
    });

    test('should create verse_bookmarks table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'verse_bookmarks']);
      expect(result.length, equals(1));
    });

    test('should create search_history table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'search_history']);
      expect(result.length, equals(1));
    });

    test('should create daily_verse_history table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'daily_verse_history']);
      expect(result.length, equals(1));
    });

    test('should create verse_preferences table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'verse_preferences']);
      expect(result.length, equals(1));
    });
  });

  group('FTS5 Virtual Table', () {
    test('should create bible_verses_fts virtual table', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['table', 'bible_verses_fts']);
      expect(result.length, equals(1));
    });

    test('FTS table should sync with bible_verses on insert', () async {
      final db = await databaseService.database;

      await db.insert('bible_verses', {
        'version': 'KJV',
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'text': 'In the beginning God created the heaven and the earth.',
        'language': 'en',
      });

      // Check FTS table has the verse
      final ftsResult = await db.rawQuery(
        'SELECT * FROM bible_verses_fts WHERE text MATCH ?',
        ['beginning'],
      );
      expect(ftsResult.length, greaterThan(0));
    });
  });

  group('Indexes', () {
    test('should create bible_verses version index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_bible_version']);
      expect(result.length, equals(1));
    });

    test('should create bible_verses book_chapter index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_bible_book_chapter']);
      expect(result.length, equals(1));
    });

    test('should create bible_verses search index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_bible_search']);
      expect(result.length, equals(1));
    });

    test('should create prayer_activity_date index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_prayer_activity_date']);
      expect(result.length, equals(1));
    });

    test('should create bookmarks_created index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_bookmarks_created']);
      expect(result.length, equals(1));
    });

    test('should create search_history index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_search_history']);
      expect(result.length, equals(1));
    });

    test('should create daily_verse_date index', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['index', 'idx_daily_verse_date']);
      expect(result.length, equals(1));
    });
  });

  group('Triggers', () {
    test('should create bible_verses_ai trigger', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['trigger', 'bible_verses_ai']);
      expect(result.length, equals(1));
    });

    test('should create bible_verses_ad trigger', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['trigger', 'bible_verses_ad']);
      expect(result.length, equals(1));
    });

    test('should create bible_verses_au trigger', () async {
      final db = await databaseService.database;
      final result = await db.query('sqlite_master',
          where: 'type = ? AND name = ?',
          whereArgs: ['trigger', 'bible_verses_au']);
      expect(result.length, equals(1));
    });
  });

  group('Initial Data', () {
    test('should insert sample favorite verses', () async {
      final db = await databaseService.database;
      final verses = await db.query('favorite_verses');
      expect(verses.length, equals(2));
    });

    test('should insert default verse preferences', () async {
      final db = await databaseService.database;
      final prefs = await db.query('verse_preferences');
      expect(prefs.length, equals(3));
    });

    test('should have preferred_themes preference', () async {
      final db = await databaseService.database;
      final pref = await db.query('verse_preferences',
          where: 'preference_key = ?', whereArgs: ['preferred_themes']);
      expect(pref.length, equals(1));
      expect(pref.first['preference_value'],
          equals('faith,hope,love,peace,strength'));
    });

    test('should have avoid_recent_days preference', () async {
      final db = await databaseService.database;
      final pref = await db.query('verse_preferences',
          where: 'preference_key = ?', whereArgs: ['avoid_recent_days']);
      expect(pref.length, equals(1));
      expect(pref.first['preference_value'], equals('30'));
    });

    test('should have preferred_version preference', () async {
      final db = await databaseService.database;
      final pref = await db.query('verse_preferences',
          where: 'preference_key = ?', whereArgs: ['preferred_version']);
      expect(pref.length, equals(1));
      expect(pref.first['preference_value'], equals('KJV'));
    });

    test('should insert sample reading plan', () async {
      final db = await databaseService.database;
      final plans = await db.query('reading_plans');
      expect(plans.length, equals(1));
      expect(plans.first['title'], equals('Bible in a Year'));
    });
  });

  group('Database Lifecycle', () {
    test('should close database connection', () async {
      final db = await databaseService.database;
      expect(db.isOpen, isTrue);

      await databaseService.close();
      expect(db.isOpen, isFalse);
    });

    test('should handle close when database is null', () async {
      final service = DatabaseService();
      await service.close();
      expect(true, isTrue);
    });

    test('should reset database and recreate tables', () async {
      final db = await databaseService.database;

      await db.insert('favorite_verses', {
        'id': 'test123',
        'text': 'Test verse',
        'reference': 'Test 1:1',
        'category': 'Test',
        'date_added': DateTime.now().millisecondsSinceEpoch,
      });

      final beforeReset = await db.query('favorite_verses');
      expect(beforeReset.length, equals(3));

      await databaseService.resetDatabase();

      final afterReset =
          await (await databaseService.database).query('favorite_verses');
      expect(afterReset.length, equals(2));
    });
  });

  group('Table Schema Validation', () {
    test('prayer_requests table has correct columns', () async {
      final db = await databaseService.database;
      final columns = await db.rawQuery('PRAGMA table_info(prayer_requests)');

      final columnNames = columns.map((col) => col['name']).toList();
      expect(columnNames, contains('id'));
      expect(columnNames, contains('title'));
      expect(columnNames, contains('description'));
      expect(columnNames, contains('category'));
      expect(columnNames, contains('date_created'));
      expect(columnNames, contains('is_answered'));
    });

    test('bible_verses table has correct columns', () async {
      final db = await databaseService.database;
      final columns = await db.rawQuery('PRAGMA table_info(bible_verses)');

      final columnNames = columns.map((col) => col['name']).toList();
      expect(columnNames, contains('id'));
      expect(columnNames, contains('version'));
      expect(columnNames, contains('book'));
      expect(columnNames, contains('chapter'));
      expect(columnNames, contains('verse'));
      expect(columnNames, contains('text'));
      expect(columnNames, contains('language'));
    });

    test('verse_bookmarks table has correct columns', () async {
      final db = await databaseService.database;
      final columns = await db.rawQuery('PRAGMA table_info(verse_bookmarks)');

      final columnNames = columns.map((col) => col['name']).toList();
      expect(columnNames, contains('id'));
      expect(columnNames, contains('verse_id'));
      expect(columnNames, contains('note'));
      expect(columnNames, contains('tags'));
      expect(columnNames, contains('created_at'));
    });
  });

  group('Foreign Keys', () {
    test('daily_readings has foreign key to reading_plans', () async {
      final db = await databaseService.database;
      final fks = await db.rawQuery('PRAGMA foreign_key_list(daily_readings)');
      expect(fks.length, greaterThan(0));
      expect(fks.first['table'], equals('reading_plans'));
    });

    test('verse_bookmarks has foreign key to bible_verses', () async {
      final db = await databaseService.database;
      final fks = await db.rawQuery('PRAGMA foreign_key_list(verse_bookmarks)');
      expect(fks.length, greaterThan(0));
      expect(fks.first['table'], equals('bible_verses'));
    });
  });
}
