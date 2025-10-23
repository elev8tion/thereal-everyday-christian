import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

/// Handles database schema migrations
class DatabaseMigrator {
  static const String _migrationKey = 'schema_version';
  static const int _currentVersion = 2;

  /// Run all pending migrations
  static Future<void> migrate(Database db) async {
    final currentVersion = await _getCurrentVersion(db);

    if (currentVersion >= _currentVersion) {
      debugPrint('✅ Database schema is up to date (v$currentVersion)');
      return;
    }

    debugPrint('📦 Running database migrations from v$currentVersion to v$_currentVersion');

    // Run migrations in sequence
    if (currentVersion < 2) {
      await _migrateToV2(db);
    }

    // Update version
    await _setVersion(db, _currentVersion);
    debugPrint('✅ Database migrations complete!');
  }

  /// Migrate to version 2: Fix foreign keys, add indexes, improve constraints
  static Future<void> _migrateToV2(Database db) async {
    debugPrint('🔄 Migrating to schema v2...');

    try {
      await db.transaction((txn) async {
        // Enable foreign keys
        await txn.execute('PRAGMA foreign_keys = ON');

        // Fix favorite_verses table
        debugPrint('  → Fixing favorite_verses foreign key...');
        await txn.execute('''
          CREATE TABLE favorite_verses_new (
            id TEXT PRIMARY KEY,
            verse_id INTEGER,
            text TEXT NOT NULL,
            reference TEXT NOT NULL,
            category TEXT NOT NULL,
            note TEXT,
            tags TEXT,
            date_added INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
          )
        ''');
        await txn.execute('INSERT INTO favorite_verses_new SELECT * FROM favorite_verses');
        await txn.execute('DROP TABLE favorite_verses');
        await txn.execute('ALTER TABLE favorite_verses_new RENAME TO favorite_verses');

        // Fix daily_verses table
        debugPrint('  → Fixing daily_verses foreign key...');
        await txn.execute('''
          CREATE TABLE daily_verses_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER NOT NULL,
            date_delivered INTEGER NOT NULL,
            user_opened INTEGER DEFAULT 0,
            notification_sent INTEGER DEFAULT 0,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE,
            UNIQUE(verse_id, date_delivered)
          )
        ''');
        await txn.execute('INSERT INTO daily_verses_new SELECT * FROM daily_verses');
        await txn.execute('DROP TABLE daily_verses');
        await txn.execute('ALTER TABLE daily_verses_new RENAME TO daily_verses');

        // Fix verse_bookmarks foreign key behavior
        debugPrint('  → Fixing verse_bookmarks foreign key...');
        await txn.execute('''
          CREATE TABLE verse_bookmarks_new (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            verse_id INTEGER NOT NULL,
            note TEXT,
            tags TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
          )
        ''');
        await txn.execute('INSERT INTO verse_bookmarks_new SELECT * FROM verse_bookmarks');
        await txn.execute('DROP TABLE verse_bookmarks');
        await txn.execute('ALTER TABLE verse_bookmarks_new RENAME TO verse_bookmarks');

        // Fix prayer_categories duplicate column
        debugPrint('  → Removing duplicate column from prayer_categories...');
        await txn.execute('''
          CREATE TABLE prayer_categories_new (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color TEXT NOT NULL,
            description TEXT,
            display_order INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            is_default INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            date_modified INTEGER
          )
        ''');
        await txn.execute('''
          INSERT INTO prayer_categories_new (
            id, name, icon, color, description, display_order,
            is_active, is_default, created_at, date_modified
          )
          SELECT
            id, name, icon, color, description, display_order,
            is_active, is_default, created_at, date_modified
          FROM prayer_categories
        ''');
        await txn.execute('DROP TABLE prayer_categories');
        await txn.execute('ALTER TABLE prayer_categories_new RENAME TO prayer_categories');

        // Add missing indexes
        debugPrint('  → Creating performance indexes...');
        final indexes = [
          'CREATE INDEX IF NOT EXISTS idx_favorite_verses_verse_id ON favorite_verses(verse_id)',
          'CREATE INDEX IF NOT EXISTS idx_daily_verses_verse_id ON daily_verses(verse_id)',
          'CREATE INDEX IF NOT EXISTS idx_verse_bookmarks_verse_id ON verse_bookmarks(verse_id)',
          'CREATE INDEX IF NOT EXISTS idx_prayer_requests_category ON prayer_requests(category)',
          'CREATE INDEX IF NOT EXISTS idx_prayer_requests_status ON prayer_requests(status)',
          'CREATE INDEX IF NOT EXISTS idx_prayer_requests_date_created ON prayer_requests(date_created DESC)',
          'CREATE INDEX IF NOT EXISTS idx_chat_sessions_created ON chat_sessions(created_at DESC)',
          'CREATE INDEX IF NOT EXISTS idx_favorite_verses_date_added ON favorite_verses(date_added DESC)',
          'CREATE INDEX IF NOT EXISTS idx_favorite_verses_category ON favorite_verses(category)',
          'CREATE INDEX IF NOT EXISTS idx_prayer_categories_display_order ON prayer_categories(display_order)',
        ];

        for (final index in indexes) {
          await txn.execute(index);
        }

        // Create auto-update triggers
        debugPrint('  → Creating timestamp triggers...');
        await txn.execute('''
          CREATE TRIGGER IF NOT EXISTS update_verse_bookmarks_timestamp
          AFTER UPDATE ON verse_bookmarks
          FOR EACH ROW
          BEGIN
            UPDATE verse_bookmarks
            SET updated_at = strftime('%s', 'now')
            WHERE id = NEW.id;
          END
        ''');

        await txn.execute('''
          CREATE TRIGGER IF NOT EXISTS update_chat_sessions_timestamp
          AFTER UPDATE ON chat_sessions
          FOR EACH ROW
          BEGIN
            UPDATE chat_sessions
            SET updated_at = strftime('%s', 'now')
            WHERE id = NEW.id;
          END
        ''');

        debugPrint('✅ Schema v2 migration complete!');
      });

      // Verify integrity after migration
      final result = await db.rawQuery('PRAGMA integrity_check');
      if (result.first['integrity_check'] != 'ok') {
        throw Exception('Database integrity check failed after migration');
      }

      debugPrint('✅ Database integrity verified');
    } catch (e, stackTrace) {
      debugPrint('❌ Migration to v2 failed: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Get current schema version
  static Future<int> _getCurrentVersion(Database db) async {
    try {
      // Check if user_settings table exists
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='user_settings'",
      );

      if (tables.isEmpty) {
        return 1; // Initial version
      }

      final result = await db.query(
        'user_settings',
        where: 'key = ?',
        whereArgs: [_migrationKey],
      );

      if (result.isEmpty) {
        return 1; // No version recorded yet
      }

      return int.tryParse(result.first['value'] as String? ?? '1') ?? 1;
    } catch (e) {
      debugPrint('⚠️  Error reading schema version: $e');
      return 1; // Assume initial version on error
    }
  }

  /// Set schema version
  static Future<void> _setVersion(Database db, int version) async {
    try {
      // First check if created_at column exists
      final columns = await db.rawQuery('PRAGMA table_info(user_settings)');
      final hasCreatedAt = columns.any((col) => col['name'] == 'created_at');

      if (hasCreatedAt) {
        await db.insert(
          'user_settings',
          {
            'key': _migrationKey,
            'value': version.toString(),
            'type': 'int',
            'created_at': DateTime.now().millisecondsSinceEpoch,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      } else {
        // Old schema without created_at column
        await db.insert(
          'user_settings',
          {
            'key': _migrationKey,
            'value': version.toString(),
            'type': 'int',
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('⚠️  Error setting schema version: $e');
    }
  }

  /// Check if migration is needed
  static Future<bool> needsMigration(Database db) async {
    final currentVersion = await _getCurrentVersion(db);
    return currentVersion < _currentVersion;
  }

  /// Get migration info for debugging
  static Future<Map<String, dynamic>> getMigrationInfo(Database db) async {
    final currentVersion = await _getCurrentVersion(db);
    final needsMigration = currentVersion < _currentVersion;

    return {
      'currentVersion': currentVersion,
      'targetVersion': _currentVersion,
      'needsMigration': needsMigration,
      'pendingMigrations': needsMigration ? _currentVersion - currentVersion : 0,
    };
  }
}
