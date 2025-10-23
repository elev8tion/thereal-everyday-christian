import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:path/path.dart' as path;

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() {
    // Reset to default path after each test
    DatabaseService.setTestDatabasePath(null);
  });

  group('Database Migration Logic', () {
    test('v1 to v2 migration - adds reading plan columns', () async {
      // Create a temporary file-based database
      final tempDir = Directory.systemTemp.createTempSync('migration_test_');
      final dbPath = path.join(tempDir.path, 'test_v1.db');

      try {
        // Create v1 database with base tables (no start_date or completed_date columns)
        final dbV1 = await databaseFactoryFfi.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 1,
            onCreate: (db, version) async {
              // V1 schema - tables without migration columns
              await db.execute('''
                CREATE TABLE reading_plans (
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL,
                  duration TEXT NOT NULL,
                  category TEXT NOT NULL,
                  difficulty TEXT NOT NULL,
                  estimated_time_per_day TEXT NOT NULL,
                  total_readings INTEGER NOT NULL,
                  completed_readings INTEGER NOT NULL DEFAULT 0,
                  is_started INTEGER NOT NULL DEFAULT 0
                )
              ''');
              await db.execute('''
                CREATE TABLE daily_readings (
                  id TEXT PRIMARY KEY,
                  plan_id TEXT NOT NULL,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL,
                  book TEXT NOT NULL,
                  chapters TEXT NOT NULL,
                  estimated_time TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  is_completed INTEGER NOT NULL DEFAULT 0
                )
              ''');
              // V1 also has devotionals, bible_verses, prayer_requests
              await db.execute('''
                CREATE TABLE devotionals (
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  subtitle TEXT NOT NULL,
                  content TEXT NOT NULL,
                  verse TEXT NOT NULL,
                  verse_reference TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  reading_time TEXT NOT NULL,
                  is_completed INTEGER NOT NULL DEFAULT 0
                )
              ''');
              await db.execute('''
                CREATE TABLE bible_verses (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  version TEXT NOT NULL,
                  book TEXT NOT NULL,
                  chapter INTEGER NOT NULL,
                  verse INTEGER NOT NULL,
                  text TEXT NOT NULL,
                  language TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        await dbV1.close();

        // Use DatabaseService to upgrade from v1 to current version
        DatabaseService.setTestDatabasePath(dbPath);
        final service = DatabaseService();
        final db = await service.database;

        // Verify columns exist after migration
        final planCols = await db.rawQuery('PRAGMA table_info(reading_plans)');
        final readingCols =
            await db.rawQuery('PRAGMA table_info(daily_readings)');

        expect(
            planCols.map((c) => c['name']).toList(), contains('start_date'));
        expect(readingCols.map((c) => c['name']).toList(),
            contains('completed_date'));

        await db.close();
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('v2 to v3 migration - adds devotional column and prayer table',
        () async {
      final tempDir = Directory.systemTemp.createTempSync('migration_test_');
      final dbPath = path.join(tempDir.path, 'test_v2.db');

      try {
        // Create v2 database (has start_date and completed_date columns from v2 migration)
        final dbV2 = await databaseFactoryFfi.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 2,
            onCreate: (db, version) async {
              // V2 schema - tables WITH start_date and completed_date but NO completed_date on devotionals
              await db.execute('''
                CREATE TABLE devotionals (
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  subtitle TEXT NOT NULL,
                  content TEXT NOT NULL,
                  verse TEXT NOT NULL,
                  verse_reference TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  reading_time TEXT NOT NULL,
                  is_completed INTEGER NOT NULL DEFAULT 0
                )
              ''');
              await db.execute('''
                CREATE TABLE reading_plans (
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL,
                  duration TEXT NOT NULL,
                  category TEXT NOT NULL,
                  difficulty TEXT NOT NULL,
                  estimated_time_per_day TEXT NOT NULL,
                  total_readings INTEGER NOT NULL,
                  completed_readings INTEGER NOT NULL DEFAULT 0,
                  is_started INTEGER NOT NULL DEFAULT 0,
                  start_date INTEGER
                )
              ''');
              await db.execute('''
                CREATE TABLE daily_readings (
                  id TEXT PRIMARY KEY,
                  plan_id TEXT NOT NULL,
                  title TEXT NOT NULL,
                  description TEXT NOT NULL,
                  book TEXT NOT NULL,
                  chapters TEXT NOT NULL,
                  estimated_time TEXT NOT NULL,
                  date INTEGER NOT NULL,
                  is_completed INTEGER NOT NULL DEFAULT 0,
                  completed_date INTEGER
                )
              ''');
              await db.execute('''
                CREATE TABLE bible_verses (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  version TEXT NOT NULL,
                  book TEXT NOT NULL,
                  chapter INTEGER NOT NULL,
                  verse INTEGER NOT NULL,
                  text TEXT NOT NULL,
                  language TEXT NOT NULL
                )
              ''');
            },
          ),
        );
        await dbV2.close();

        // Upgrade to current version using DatabaseService
        DatabaseService.setTestDatabasePath(dbPath);
        final service = DatabaseService();
        final db = await service.database;

        // Verify v3 migration
        final devCols = await db.rawQuery('PRAGMA table_info(devotionals)');
        expect(
            devCols.map((c) => c['name']).toList(), contains('completed_date'));

        final tables = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'prayer_streak_activity'],
        );
        expect(tables.length, equals(1));

        final indexes = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['index', 'idx_prayer_activity_date'],
        );
        expect(indexes.length, equals(1));

        await db.close();
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('v3 to v4 migration - adds FTS5 and bookmarks', () async {
      final tempDir = Directory.systemTemp.createTempSync('migration_test_');
      final dbPath = path.join(tempDir.path, 'test_v3.db');

      try {
        // Create v3 database
        final dbV3 = await databaseFactoryFfi.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 3,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE bible_verses (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  version TEXT,
                  book TEXT,
                  chapter INTEGER,
                  verse INTEGER,
                  text TEXT,
                  language TEXT
                )
              ''');
              await db.execute('''
                CREATE TABLE devotionals (
                  id TEXT PRIMARY KEY,
                  title TEXT NOT NULL,
                  completed_date INTEGER
                )
              ''');
              await db.execute('''
                CREATE TABLE prayer_streak_activity (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  activity_date INTEGER NOT NULL UNIQUE,
                  created_at INTEGER NOT NULL
                )
              ''');

              await db.insert('bible_verses', {
                'version': 'KJV',
                'book': 'Genesis',
                'chapter': 1,
                'verse': 1,
                'text': 'In the beginning',
                'language': 'en',
              });
            },
          ),
        );
        await dbV3.close();

        // Upgrade to current version
        DatabaseService.setTestDatabasePath(dbPath);
        final service = DatabaseService();
        final db = await service.database;

        // Verify FTS
        final ftsTables = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'bible_verses_fts'],
        );
        expect(ftsTables.length, equals(1));

        final ftsData = await db.rawQuery(
            'SELECT * FROM bible_verses_fts WHERE text MATCH ?',
            ['beginning']);
        expect(ftsData.length, greaterThan(0));

        // Verify triggers
        final triggers = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ?',
          ['trigger'],
        );
        expect(triggers.length, greaterThanOrEqualTo(3));

        // Verify bookmarks
        final bookmarks = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'verse_bookmarks'],
        );
        expect(bookmarks.length, equals(1));

        // Verify search history
        final search = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'search_history'],
        );
        expect(search.length, equals(1));

        await db.close();
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('v4 to v5 migration - adds daily verse tracking', () async {
      final tempDir = Directory.systemTemp.createTempSync('migration_test_');
      final dbPath = path.join(tempDir.path, 'test_v4.db');

      try {
        // Create v4 database with all previous tables
        final dbV4 = await databaseFactoryFfi.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(
            version: 4,
            onCreate: (db, version) async {
              await db.execute('''
                CREATE TABLE bible_verses (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  version TEXT,
                  book TEXT,
                  chapter INTEGER,
                  verse INTEGER,
                  text TEXT,
                  language TEXT
                )
              ''');
              await db.execute('''
                CREATE VIRTUAL TABLE bible_verses_fts USING fts5(
                  book, chapter, verse, text,
                  content=bible_verses,
                  content_rowid=id
                )
              ''');
              await db.execute('''
                CREATE TABLE verse_bookmarks (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  verse_id INTEGER NOT NULL,
                  note TEXT,
                  tags TEXT,
                  created_at INTEGER NOT NULL,
                  updated_at INTEGER,
                  UNIQUE(verse_id)
                )
              ''');
              await db.execute('''
                CREATE TABLE search_history (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  query TEXT NOT NULL,
                  search_type TEXT NOT NULL,
                  created_at INTEGER NOT NULL
                )
              ''');
            },
          ),
        );
        await dbV4.close();

        // Upgrade to current version
        DatabaseService.setTestDatabasePath(dbPath);
        final service = DatabaseService();
        final db = await service.database;

        // Verify daily_verse_history
        final historyTables = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'daily_verse_history'],
        );
        expect(historyTables.length, equals(1));

        // Verify index
        final indexes = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['index', 'idx_daily_verse_date'],
        );
        expect(indexes.length, equals(1));

        // Verify verse_preferences
        final prefTables = await db.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
          ['table', 'verse_preferences'],
        );
        expect(prefTables.length, equals(1));

        // Verify default preferences
        final prefs = await db.query('verse_preferences');
        expect(prefs.length, equals(3));

        final keys = prefs.map((p) => p['preference_key']).toList();
        expect(keys, contains('preferred_themes'));
        expect(keys, contains('avoid_recent_days'));
        expect(keys, contains('preferred_version'));

        await db.close();
      } finally {
        tempDir.deleteSync(recursive: true);
      }
    });
  });
}
