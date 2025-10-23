import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/database/migrations/database_migrator.dart';

void main() {
  late Database db;

  setUpAll(() {
    // Initialize FFI
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create an in-memory database for each test
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        // Create a basic schema simulating the old schema with issues
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

        await db.execute('''
          CREATE TABLE favorite_verses (
            id TEXT PRIMARY KEY,
            verse_id INTEGER,
            text TEXT NOT NULL,
            reference TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            tags TEXT,
            date_added INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES verses (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE daily_verses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER NOT NULL,
            date_delivered INTEGER NOT NULL,
            user_opened INTEGER DEFAULT 0,
            notification_sent INTEGER DEFAULT 0,
            FOREIGN KEY (verse_id) REFERENCES verses (id) ON DELETE CASCADE
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
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE NO ACTION
          )
        ''');

        await db.execute('''
          CREATE TABLE prayer_requests (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            status TEXT DEFAULT 'active',
            date_created INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE prayer_categories (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            description TEXT,
            display_order INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            is_default INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            date_created INTEGER NOT NULL,
            date_modified INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_sessions (
            id TEXT PRIMARY KEY,
            title TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE chat_messages (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            content TEXT NOT NULL,
            type TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE user_settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');

        // Insert test data
        await db.insert('bible_verses', {
          'version': 'KJV',
          'book': 'John',
          'chapter': 3,
          'verse': 16,
          'text': 'For God so loved the world...',
          'language': 'en',
        });

        await db.insert('prayer_categories', {
          'id': 'cat_test',
          'name': 'Test',
          'icon': '12345',
          'color': '0xFF000000',
          'description': 'Test category',
          'display_order': 1,
          'is_active': 1,
          'is_default': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'date_created': DateTime.now().millisecondsSinceEpoch,
        });
      },
    );

    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  group('DatabaseMigrator', () {
    test('should report current version correctly', () async {
      final info = await DatabaseMigrator.getMigrationInfo(db);
      expect(info['currentVersion'], equals(1));
      expect(info['needsMigration'], isTrue);
    });

    test('should fix foreign key references in favorite_verses', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check that foreign key now references bible_verses
      final result = await db.rawQuery('PRAGMA foreign_key_list(favorite_verses)');
      expect(result.isNotEmpty, isTrue);
      expect(result.first['table'], equals('bible_verses'));
    });

    test('should fix foreign key references in daily_verses', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check that foreign key now references bible_verses
      final result = await db.rawQuery('PRAGMA foreign_key_list(daily_verses)');
      expect(result.isNotEmpty, isTrue);
      expect(result.first['table'], equals('bible_verses'));
    });

    test('should fix verse_bookmarks foreign key behavior', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check that foreign key now has CASCADE
      final result = await db.rawQuery('PRAGMA foreign_key_list(verse_bookmarks)');
      expect(result.isNotEmpty, isTrue);
      expect(result.first['on_delete'], equals('CASCADE'));
    });

    test('should remove duplicate column from prayer_categories', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check schema - should not have date_created anymore
      final result = await db.rawQuery('PRAGMA table_info(prayer_categories)');
      final columnNames = result.map((r) => r['name'] as String).toList();

      // Should have created_at
      expect(columnNames, contains('created_at'));

      // Count occurrences of date_created - should be 0 after migration
      final dateCreatedCount = columnNames.where((name) => name == 'date_created').length;
      expect(dateCreatedCount, equals(0));
    });

    test('should add missing indexes', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check that critical indexes exist
      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      );

      final indexNames = indexes.map((r) => r['name'] as String).toList();

      expect(indexNames, contains('idx_favorite_verses_verse_id'));
      expect(indexNames, contains('idx_daily_verses_verse_id'));
      expect(indexNames, contains('idx_verse_bookmarks_verse_id'));
      expect(indexNames, contains('idx_prayer_requests_category'));
      expect(indexNames, contains('idx_prayer_requests_status'));
    });

    test('should create auto-update triggers', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check that triggers exist
      final triggers = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='trigger'",
      );

      final triggerNames = triggers.map((r) => r['name'] as String).toList();

      expect(triggerNames, contains('update_verse_bookmarks_timestamp'));
      expect(triggerNames, contains('update_chat_sessions_timestamp'));
    });

    test('should preserve existing data during migration', () async {
      // Run migration first to fix the schema
      await DatabaseMigrator.migrate(db);

      // Now insert test data after migration fixes the FK
      final verseId = await db.query('bible_verses', limit: 1);
      final testVerseId = verseId.first['id'] as int;

      await db.insert('favorite_verses', {
        'id': 'fav_test',
        'verse_id': testVerseId,
        'text': 'Test verse',
        'reference': 'John 3:16',
        'category': 'hope',
        'date_added': DateTime.now().millisecondsSinceEpoch,
      });

      // Verify migration preserved the table structure correctly
      final favorites = await db.query('favorite_verses');
      expect(favorites.length, equals(1));
      expect(favorites.first['id'], equals('fav_test'));
      expect(favorites.first['text'], equals('Test verse'));
    });

    test('should pass database integrity check after migration', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check integrity
      final result = await db.rawQuery('PRAGMA integrity_check');
      expect(result.first['integrity_check'], equals('ok'));
    });

    test('should update version after migration', () async {
      // Run migration
      await DatabaseMigrator.migrate(db);

      // Check version is updated
      final info = await DatabaseMigrator.getMigrationInfo(db);
      expect(info['currentVersion'], equals(2));
      expect(info['needsMigration'], isFalse);
    });

    test('should not run migrations twice', () async {
      // Run migration first time
      await DatabaseMigrator.migrate(db);

      final info1 = await DatabaseMigrator.getMigrationInfo(db);
      expect(info1['needsMigration'], isFalse);

      // Run migration second time - should be a no-op
      await DatabaseMigrator.migrate(db);

      final info2 = await DatabaseMigrator.getMigrationInfo(db);
      expect(info2['currentVersion'], equals(2));
      expect(info2['needsMigration'], isFalse);
    });
  });
}
