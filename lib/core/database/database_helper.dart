import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../error/error_handler.dart';
import '../error/app_error.dart';
import '../logging/app_logger.dart';

/// Unified database helper with all tables in one schema
class DatabaseHelper {
  static const String _databaseName = 'everyday_christian.db';
  static const int _databaseVersion = 14;

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static final AppLogger _logger = AppLogger.instance;

  /// Optional test database path (for in-memory testing)
  static String? _testDatabasePath;

  /// Set test database path for testing with in-memory DB
  static void setTestDatabasePath(String? path) {
    _testDatabasePath = path;
    _database = null; // Reset database when changing path
  }

  /// Get database instance
  Future<Database> get database async {
    try {
      _database ??= await _initDatabase();
      return _database!;
    } catch (e, stackTrace) {
      _logger.fatal(
        'Failed to get database instance',
        context: 'DatabaseHelper',
        stackTrace: stackTrace,
      );
      throw ErrorHandler.databaseError(
        message: 'Failed to initialize database',
        details: e.toString(),
        severity: ErrorSeverity.fatal,
      );
    }
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      String path;

      if (_testDatabasePath != null) {
        path = _testDatabasePath!;
      } else {
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, _databaseName);
      }

      _logger.info('Initializing database at: $path', context: 'DatabaseHelper');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onOpen: _onOpen,
      );
    } catch (e, stackTrace) {
      _logger.fatal(
        'Database initialization failed',
        context: 'DatabaseHelper',
        stackTrace: stackTrace,
      );
      throw ErrorHandler.databaseError(
        message: 'Failed to open database',
        details: e.toString(),
        severity: ErrorSeverity.fatal,
      );
    }
  }

  /// Create all database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      _logger.info('Creating database schema v$version', context: 'DatabaseHelper');

      // ==================== BIBLE VERSES TABLES ====================

      // Bible verses table (full Bible storage)
      await db.execute('''
        CREATE TABLE bible_verses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          version TEXT NOT NULL,
          book TEXT NOT NULL,
          chapter INTEGER NOT NULL,
          verse INTEGER NOT NULL,
          text TEXT NOT NULL,
          language TEXT NOT NULL,
          themes TEXT,
          category TEXT,
          reference TEXT
        )
      ''');

      // Bible verses indexes
      await db.execute('CREATE INDEX idx_bible_version ON bible_verses(version)');
      await db.execute('CREATE INDEX idx_bible_book_chapter ON bible_verses(book, chapter)');
      await db.execute('CREATE INDEX idx_bible_search ON bible_verses(book, chapter, verse)');

      // Bible verses FTS5
      await db.execute('''
        CREATE VIRTUAL TABLE bible_verses_fts USING fts5(
          book,
          chapter,
          verse,
          text,
          content=bible_verses,
          content_rowid=id
        )
      ''');

      // Bible verses FTS triggers
      await db.execute('''
        CREATE TRIGGER bible_verses_ai AFTER INSERT ON bible_verses BEGIN
          INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
          VALUES (new.id, new.book, new.chapter, new.verse, new.text);
        END
      ''');

      await db.execute('''
        CREATE TRIGGER bible_verses_ad AFTER DELETE ON bible_verses BEGIN
          DELETE FROM bible_verses_fts WHERE rowid = old.id;
        END
      ''');

      await db.execute('''
        CREATE TRIGGER bible_verses_au AFTER UPDATE ON bible_verses BEGIN
          DELETE FROM bible_verses_fts WHERE rowid = old.id;
          INSERT INTO bible_verses_fts(rowid, book, chapter, verse, text)
          VALUES (new.id, new.book, new.chapter, new.verse, new.text);
        END
      ''');

      // Favorite verses
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
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
        )
      ''');

      // Daily verses
      await db.execute('''
        CREATE TABLE daily_verses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          date_delivered INTEGER NOT NULL,
          user_opened INTEGER DEFAULT 0,
          notification_sent INTEGER DEFAULT 0,
          FOREIGN KEY (verse_id) REFERENCES verses (id) ON DELETE CASCADE,
          UNIQUE(verse_id, date_delivered)
        )
      ''');

      // Daily verse history
      await db.execute('''
        CREATE TABLE daily_verse_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          shown_date INTEGER NOT NULL,
          theme TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
          UNIQUE(verse_id, shown_date)
        )
      ''');

      await db.execute('CREATE INDEX idx_daily_verse_date ON daily_verse_history(shown_date DESC)');

      // Daily verse schedule (365-day calendar of verses)
      await db.execute('''
        CREATE TABLE daily_verse_schedule (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          month INTEGER NOT NULL,
          day INTEGER NOT NULL,
          verse_id INTEGER NOT NULL,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
          UNIQUE(month, day)
        )
      ''');

      await db.execute('CREATE INDEX idx_daily_verse_schedule_date ON daily_verse_schedule(month, day)');

      // Verse bookmarks
      await db.execute('''
        CREATE TABLE verse_bookmarks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          verse_id INTEGER NOT NULL,
          note TEXT,
          tags TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
          UNIQUE(verse_id)
        )
      ''');

      await db.execute('CREATE INDEX idx_bookmarks_created ON verse_bookmarks(created_at DESC)');

      // Verse preferences
      await db.execute('''
        CREATE TABLE verse_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          preference_key TEXT NOT NULL UNIQUE,
          preference_value TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      // ==================== CHAT TABLES ====================

      // Chat sessions
      await db.execute('''
        CREATE TABLE chat_sessions (
          id TEXT PRIMARY KEY,
          title TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_archived INTEGER DEFAULT 0,
          message_count INTEGER DEFAULT 0,
          last_message_at INTEGER,
          last_message_preview TEXT
        )
      ''');

      // Chat messages
      await db.execute('''
        CREATE TABLE chat_messages (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          content TEXT NOT NULL,
          type TEXT NOT NULL,
          timestamp INTEGER NOT NULL,
          status TEXT DEFAULT 'sent',
          verse_references TEXT,
          metadata TEXT,
          user_id TEXT,
          FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_chat_messages_session ON chat_messages(session_id)');
      await db.execute('CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp DESC)');

      // Shared chats tracking
      await db.execute('''
        CREATE TABLE shared_chats (
          id TEXT PRIMARY KEY,
          session_id TEXT NOT NULL,
          shared_at INTEGER NOT NULL,
          FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_shared_chats_session ON shared_chats(session_id)');
      await db.execute('CREATE INDEX idx_shared_chats_timestamp ON shared_chats(shared_at DESC)');

      // Shared verses tracking
      await db.execute('''
        CREATE TABLE shared_verses (
          id TEXT PRIMARY KEY,
          verse_id INTEGER NOT NULL,
          book TEXT NOT NULL,
          chapter INTEGER NOT NULL,
          verse_number INTEGER NOT NULL,
          reference TEXT NOT NULL,
          translation TEXT NOT NULL,
          text TEXT NOT NULL,
          themes TEXT,
          channel TEXT NOT NULL,
          shared_at INTEGER NOT NULL,
          FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_shared_verses_verse ON shared_verses(verse_id)');
      await db.execute('CREATE INDEX idx_shared_verses_timestamp ON shared_verses(shared_at DESC)');

      // Shared devotionals tracking
      await db.execute('''
        CREATE TABLE shared_devotionals (
          id TEXT PRIMARY KEY,
          devotional_id TEXT NOT NULL,
          shared_at INTEGER NOT NULL,
          FOREIGN KEY (devotional_id) REFERENCES devotionals (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('CREATE INDEX idx_shared_devotionals_devotional ON shared_devotionals(devotional_id)');
      await db.execute('CREATE INDEX idx_shared_devotionals_timestamp ON shared_devotionals(shared_at DESC)');

      // ==================== PRAYER TABLES ====================

      // Prayer requests
      await db.execute('''
        CREATE TABLE prayer_requests (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          status TEXT DEFAULT 'active',
          date_created INTEGER NOT NULL,
          date_answered INTEGER,
          is_answered INTEGER DEFAULT 0,
          answer_description TEXT,
          testimony TEXT,
          is_private INTEGER DEFAULT 1,
          reminder_frequency TEXT,
          grace TEXT,
          need_help TEXT,
          FOREIGN KEY (category) REFERENCES prayer_categories (id) ON DELETE RESTRICT
        )
      ''');

      // Prayer categories
      await db.execute('''
        CREATE TABLE prayer_categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL UNIQUE,
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

      // Prayer streak activity
      await db.execute('''
        CREATE TABLE prayer_streak_activity (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          activity_date INTEGER NOT NULL UNIQUE,
          created_at INTEGER NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX idx_prayer_activity_date ON prayer_streak_activity(activity_date)');

      // ==================== DEVOTIONAL TABLES ====================

      // Devotionals (8-section format)
      await db.execute('''
        CREATE TABLE devotionals (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          opening_scripture_reference TEXT NOT NULL,
          opening_scripture_text TEXT NOT NULL,
          key_verse_reference TEXT NOT NULL,
          key_verse_text TEXT NOT NULL,
          reflection TEXT NOT NULL,
          life_application TEXT NOT NULL,
          prayer TEXT NOT NULL,
          action_step TEXT NOT NULL,
          going_deeper TEXT NOT NULL,
          reading_time TEXT NOT NULL,
          is_completed INTEGER NOT NULL DEFAULT 0,
          completed_date INTEGER,
          action_step_completed INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // ==================== READING PLAN TABLES ====================

      // Reading plans
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

      // Daily readings
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
          completed_date INTEGER,
          FOREIGN KEY (plan_id) REFERENCES reading_plans (id)
        )
      ''');

      // Reading plan indexes for performance
      await db.execute('CREATE INDEX idx_reading_plans_started ON reading_plans(is_started)');
      await db.execute('CREATE INDEX idx_daily_readings_plan ON daily_readings(plan_id)');
      await db.execute('CREATE INDEX idx_daily_readings_completion ON daily_readings(plan_id, is_completed, completed_date)');
      await db.execute('CREATE INDEX idx_daily_readings_date ON daily_readings(plan_id, date)');

      // ==================== USER SETTINGS ====================

      // User settings
      await db.execute('''
        CREATE TABLE user_settings (
          key TEXT PRIMARY KEY,
          value TEXT NOT NULL,
          type TEXT NOT NULL,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

      // ==================== SEARCH HISTORY ====================

      // Search history
      await db.execute('''
        CREATE TABLE search_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          query TEXT NOT NULL,
          search_type TEXT NOT NULL,
          created_at INTEGER NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX idx_search_history ON search_history(created_at DESC)');

      // ==================== ACHIEVEMENTS ====================

      // Achievement completions table (tracks when users complete/earn achievements)
      await db.execute('''
        CREATE TABLE achievement_completions (
          id TEXT PRIMARY KEY,
          achievement_type TEXT NOT NULL,
          completed_at INTEGER NOT NULL,
          completion_count INTEGER NOT NULL,
          progress_at_completion INTEGER NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX idx_achievement_completions_type ON achievement_completions(achievement_type)');
      await db.execute('CREATE INDEX idx_achievement_completions_timestamp ON achievement_completions(completed_at DESC)');

      // ==================== ADDITIONAL PERFORMANCE INDEXES ====================
      // These indexes improve query performance for common operations

      // Favorite verses indexes
      await db.execute('CREATE INDEX idx_favorite_verses_verse_id ON favorite_verses(verse_id)');
      await db.execute('CREATE INDEX idx_favorite_verses_date_added ON favorite_verses(date_added DESC)');
      await db.execute('CREATE INDEX idx_favorite_verses_category ON favorite_verses(category)');

      // Daily verses index
      await db.execute('CREATE INDEX idx_daily_verses_verse_id ON daily_verses(verse_id)');

      // Verse bookmarks index
      await db.execute('CREATE INDEX idx_verse_bookmarks_verse_id ON verse_bookmarks(verse_id)');

      // Prayer requests indexes
      await db.execute('CREATE INDEX idx_prayer_requests_category ON prayer_requests(category)');
      await db.execute('CREATE INDEX idx_prayer_requests_status ON prayer_requests(status)');
      await db.execute('CREATE INDEX idx_prayer_requests_date_created ON prayer_requests(date_created DESC)');

      // Chat sessions index
      await db.execute('CREATE INDEX idx_chat_sessions_created ON chat_sessions(created_at DESC)');

      // Prayer categories index
      await db.execute('CREATE INDEX idx_prayer_categories_display_order ON prayer_categories(display_order)');

      // ==================== TRIGGERS ====================
      // Auto-update timestamp trigger for verse_bookmarks
      await db.execute('''
        CREATE TRIGGER update_verse_bookmarks_timestamp
        AFTER UPDATE ON verse_bookmarks
        FOR EACH ROW
        BEGIN
          UPDATE verse_bookmarks
          SET updated_at = strftime('%s', 'now')
          WHERE id = NEW.id;
        END
      ''');

      // Insert default data
      await _insertDefaultSettings(db);
      await _insertVersePreferences(db);
      await _insertDefaultPrayerCategories(db);
      await _insertDefaultReadingPlans(db);

      _logger.info('Database schema created successfully', context: 'DatabaseHelper');
    } catch (e, stackTrace) {
      _logger.fatal(
        'Failed to create database schema',
        context: 'DatabaseHelper',
        stackTrace: stackTrace,
      );
      throw ErrorHandler.databaseError(
        message: 'Database schema creation failed',
        details: e.toString(),
        severity: ErrorSeverity.fatal,
      );
    }
  }

  /// Handle database upgrade
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Fix Issue #1: Rename sort_order to display_order
        await db.execute('ALTER TABLE prayer_categories RENAME COLUMN sort_order TO display_order');
        _logger.info('Successfully renamed sort_order to display_order');
      } catch (e) {
        _logger.error('Migration v1→v2 failed: $e');
        // If column already has correct name, continue
        if (!e.toString().contains('no such column')) {
          rethrow;
        }
      }

      try {
        // Fix Issue #5: Add cat_ prefix to default category IDs if missing
        await db.execute("""
          UPDATE prayer_categories
          SET id = 'cat_' || id
          WHERE id NOT LIKE 'cat_%'
        """);
        _logger.info('Successfully updated category IDs with cat_ prefix');
      } catch (e) {
        _logger.error('Category ID migration failed: $e');
      }
    }

    if (oldVersion < 3) {
      try {
        // Add foreign key constraint by recreating table
        await db.execute('''
          CREATE TABLE prayer_requests_new (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            category TEXT NOT NULL,
            status TEXT DEFAULT 'active',
            date_created INTEGER NOT NULL,
            date_answered INTEGER,
            is_answered INTEGER DEFAULT 0,
            answer_description TEXT,
            testimony TEXT,
            is_private INTEGER DEFAULT 1,
            reminder_frequency TEXT,
            grace TEXT,
            need_help TEXT,
            FOREIGN KEY (category) REFERENCES prayer_categories (id) ON DELETE RESTRICT
          )
        ''');

        // Copy data from old table
        await db.execute('''
          INSERT INTO prayer_requests_new
          SELECT * FROM prayer_requests
        ''');

        // Drop old table
        await db.execute('DROP TABLE prayer_requests');

        // Rename new table
        await db.execute('ALTER TABLE prayer_requests_new RENAME TO prayer_requests');

        _logger.info('Successfully added foreign key constraint to prayer_requests');
      } catch (e) {
        _logger.error('Foreign key migration failed: $e');
      }
    }

    if (oldVersion < 4) {
      try {
        // Add missing columns to prayer_categories table
        await db.execute('ALTER TABLE prayer_categories ADD COLUMN is_default INTEGER DEFAULT 0');
        _logger.info('Successfully added is_default column');
      } catch (e) {
        _logger.error('Failed to add is_default column: $e');
      }

      try {
        await db.execute('ALTER TABLE prayer_categories ADD COLUMN date_created INTEGER NOT NULL DEFAULT 0');
        _logger.info('Successfully added date_created column');
      } catch (e) {
        _logger.error('Failed to add date_created column: $e');
      }

      try {
        await db.execute('ALTER TABLE prayer_categories ADD COLUMN date_modified INTEGER');
        _logger.info('Successfully added date_modified column');
      } catch (e) {
        _logger.error('Failed to add date_modified column: $e');
      }

      // Update existing rows to set created_at as date_created if it exists
      try {
        await db.execute('UPDATE prayer_categories SET date_created = created_at WHERE date_created = 0');
        _logger.info('Successfully migrated created_at to date_created');
      } catch (e) {
        _logger.error('Failed to migrate created_at: $e');
      }
    }

    if (oldVersion < 5) {
      try {
        // v4→v5: Remove duplicate "verses" table and use only "bible_verses"
        // Drop old verses table and its FTS index
        _logger.info('Migrating v4→v5: Removing duplicate verses table');

        await db.execute('DROP TRIGGER IF EXISTS verses_fts_insert');
        await db.execute('DROP TRIGGER IF EXISTS verses_fts_delete');
        await db.execute('DROP TRIGGER IF EXISTS verses_fts_update');
        await db.execute('DROP TABLE IF EXISTS verses_fts');
        await db.execute('DROP TABLE IF EXISTS verses');

        _logger.info('✅ Migration v4→v5 complete: Removed verses table, using bible_verses only');
      } catch (e) {
        _logger.error('Migration v4→v5 failed: $e');
        // Continue - table may not exist in fresh installs
      }
    }

    if (oldVersion < 6) {
      try {
        // v5→v6: Add daily_verse_schedule table for calendar-based verse rotation
        _logger.info('Migrating v5→v6: Adding daily_verse_schedule table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS daily_verse_schedule (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            month INTEGER NOT NULL,
            day INTEGER NOT NULL,
            verse_id INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id),
            UNIQUE(month, day)
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_verse_schedule_date ON daily_verse_schedule(month, day)');

        // If Bible verses are already loaded, populate the schedule from assets
        final verseCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bible_verses WHERE version = ?', ['WEB'])) ?? 0;

        if (verseCount > 0) {
          _logger.info('Bible data exists ($verseCount verses), populating daily_verse_schedule from assets...');

          // Copy asset database to temp location
          final databasesPath = await getDatabasesPath();
          final assetDbPath = join(databasesPath, 'asset_bible_temp.db');

          final data = await rootBundle.load('assets/bible.db');
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(assetDbPath).writeAsBytes(bytes, flush: true);

          // Attach and copy schedule
          await db.execute("ATTACH DATABASE '$assetDbPath' AS asset_db");

          await db.execute('''
            INSERT OR REPLACE INTO daily_verse_schedule (month, day, verse_id)
            SELECT
              s.month,
              s.day,
              bv.id
            FROM asset_db.daily_verse_schedule s
            JOIN asset_db.verses av ON s.verse_id = av.id
            JOIN bible_verses bv ON (
              av.book = bv.book AND
              av.chapter = bv.chapter AND
              av.verse_number = bv.verse AND
              av.translation = bv.version
            )
            WHERE av.translation = 'WEB'
          ''');

          await db.execute('DETACH DATABASE asset_db');
          await File(assetDbPath).delete();

          final scheduleCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM daily_verse_schedule')) ?? 0;
          _logger.info('✅ Populated $scheduleCount daily verses');
        }

        _logger.info('✅ Migration v5→v6 complete: Added daily_verse_schedule table');
      } catch (e) {
        _logger.error('Migration v5→v6 failed: $e');
        // Continue - table may already exist
      }
    }

    if (oldVersion < 7) {
      try {
        _logger.info('Migrating v6→v7: Adding shared_verses table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS shared_verses (
            id TEXT PRIMARY KEY,
            verse_id INTEGER,
            book TEXT NOT NULL,
            chapter INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            reference TEXT NOT NULL,
            translation TEXT NOT NULL,
            text TEXT NOT NULL,
            themes TEXT,
            channel TEXT,
            shared_at INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE SET NULL
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_verses_shared_at ON shared_verses(shared_at DESC)');

        _logger.info('✅ Migration v6→v7 complete: Added shared_verses table');
      } catch (e) {
        _logger.error('Migration v6→v7 failed: $e');
      }
    }

    if (oldVersion < 8) {
      try {
        _logger.info('Migrating v7→v8: Adding reading plan indexes for performance');

        // Add indexes for reading plans queries
        await db.execute('CREATE INDEX IF NOT EXISTS idx_reading_plans_started ON reading_plans(is_started)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_readings_plan ON daily_readings(plan_id)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_readings_completion ON daily_readings(plan_id, is_completed, completed_date)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_readings_date ON daily_readings(plan_id, date)');

        _logger.info('✅ Migration v7→v8 complete: Added 4 reading plan indexes');
      } catch (e) {
        _logger.error('Migration v7→v8 failed: $e');
      }
    }

    if (oldVersion < 9) {
      try {
        _logger.info('Migrating v8→v9: Updating devotionals table to 8-section format');

        // Drop old devotionals table (no user data to preserve - will reload from JSON)
        await db.execute('DROP TABLE IF EXISTS devotionals');

        // Create new devotionals table with 8-section format
        await db.execute('''
          CREATE TABLE devotionals (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            title TEXT NOT NULL,
            opening_scripture_reference TEXT NOT NULL,
            opening_scripture_text TEXT NOT NULL,
            key_verse_reference TEXT NOT NULL,
            key_verse_text TEXT NOT NULL,
            reflection TEXT NOT NULL,
            life_application TEXT NOT NULL,
            prayer TEXT NOT NULL,
            action_step TEXT NOT NULL,
            going_deeper TEXT NOT NULL,
            reading_time TEXT NOT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            completed_date INTEGER,
            action_step_completed INTEGER NOT NULL DEFAULT 0
          )
        ''');

        _logger.info('✅ Migration v8→v9 complete: Devotionals table updated to 8-section format');
      } catch (e) {
        _logger.error('Migration v8→v9 failed: $e');
        rethrow;
      }
    }

    if (oldVersion < 10) {
      try {
        // v9→v10: Add shared_chats table for tracking chat shares
        _logger.info('Migrating v9→v10: Adding shared_chats table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS shared_chats (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            shared_at INTEGER NOT NULL,
            FOREIGN KEY (session_id) REFERENCES chat_sessions (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_chats_session ON shared_chats(session_id)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_chats_timestamp ON shared_chats(shared_at DESC)');

        _logger.info('✅ Migration v9→v10 complete: shared_chats table created');
      } catch (e) {
        _logger.error('Migration v9→v10 failed: $e');
        rethrow;
      }
    }

    if (oldVersion < 11) {
      try {
        // v10→v11: Add shared_verses table for tracking verse shares
        _logger.info('Migrating v10→v11: Adding shared_verses table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS shared_verses (
            id TEXT PRIMARY KEY,
            verse_id INTEGER NOT NULL,
            shared_at INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_verses_verse ON shared_verses(verse_id)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_verses_timestamp ON shared_verses(shared_at DESC)');

        _logger.info('✅ Migration v10→v11 complete: shared_verses table created');
      } catch (e) {
        _logger.error('Migration v10→v11 failed: $e');
        rethrow;
      }
    }

    if (oldVersion < 12) {
      try {
        // v11→v12: Add shared_devotionals table for tracking devotional shares
        _logger.info('Migrating v11→v12: Adding shared_devotionals table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS shared_devotionals (
            id TEXT PRIMARY KEY,
            devotional_id TEXT NOT NULL,
            shared_at INTEGER NOT NULL,
            FOREIGN KEY (devotional_id) REFERENCES devotionals (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_devotionals_devotional ON shared_devotionals(devotional_id)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_shared_devotionals_timestamp ON shared_devotionals(shared_at DESC)');

        _logger.info('✅ Migration v11→v12 complete: shared_devotionals table created');
      } catch (e) {
        _logger.error('Migration v11→v12 failed: $e');
        rethrow;
      }
    }

    if (oldVersion < 13) {
      try {
        // v12→v13: Fix shared_verses table schema to include all required columns
        _logger.info('Migrating v12→v13: Updating shared_verses table schema');

        // Drop the old 3-column table
        await db.execute('DROP TABLE IF EXISTS shared_verses');
        await db.execute('DROP INDEX IF EXISTS idx_shared_verses_verse');
        await db.execute('DROP INDEX IF EXISTS idx_shared_verses_timestamp');

        // Recreate with all 11 columns needed by unified_verse_service.dart
        await db.execute('''
          CREATE TABLE shared_verses (
            id TEXT PRIMARY KEY,
            verse_id INTEGER NOT NULL,
            book TEXT NOT NULL,
            chapter INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            reference TEXT NOT NULL,
            translation TEXT NOT NULL,
            text TEXT NOT NULL,
            themes TEXT,
            channel TEXT NOT NULL,
            shared_at INTEGER NOT NULL,
            FOREIGN KEY (verse_id) REFERENCES bible_verses (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('CREATE INDEX idx_shared_verses_verse ON shared_verses(verse_id)');
        await db.execute('CREATE INDEX idx_shared_verses_timestamp ON shared_verses(shared_at DESC)');

        _logger.info('✅ Migration v12→v13 complete: shared_verses table updated with full schema');
      } catch (e) {
        _logger.error('Migration v12→v13 failed: $e');
        rethrow;
      }
    }

    if (oldVersion < 14) {
      try {
        // v13→v14: Add achievement_completions table for tracking achievement progress
        _logger.info('Migrating v13→v14: Adding achievement_completions table');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS achievement_completions (
            id TEXT PRIMARY KEY,
            achievement_type TEXT NOT NULL,
            completed_at INTEGER NOT NULL,
            completion_count INTEGER NOT NULL,
            progress_at_completion INTEGER NOT NULL
          )
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_achievement_completions_type ON achievement_completions(achievement_type)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_achievement_completions_timestamp ON achievement_completions(completed_at DESC)');

        _logger.info('✅ Migration v13→v14 complete: achievement_completions table created');
      } catch (e) {
        _logger.error('Migration v13→v14 failed: $e');
        rethrow;
      }
    }
  }

  /// Handle database open
  Future<void> _onOpen(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _insertDefaultSettings(Database db) async {
    final defaultSettings = [
      {'key': 'daily_verse_time', 'value': '09:30', 'type': 'String'},
      {'key': 'daily_verse_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'preferred_translation', 'value': 'ESV', 'type': 'String'},
      {'key': 'theme_mode', 'value': 'system', 'type': 'String'},
      {'key': 'notifications_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'biometric_enabled', 'value': 'false', 'type': 'bool'},
      {'key': 'onboarding_completed', 'value': 'false', 'type': 'bool'},
      {'key': 'first_launch', 'value': 'true', 'type': 'bool'},
      {'key': 'verse_streak_count', 'value': '0', 'type': 'int'},
      {'key': 'last_verse_date', 'value': '0', 'type': 'int'},
      {'key': 'preferred_verse_themes', 'value': '["hope", "strength", "comfort"]', 'type': 'String'},
      {'key': 'chat_history_days', 'value': '30', 'type': 'int'},
      {'key': 'prayer_reminder_enabled', 'value': 'true', 'type': 'bool'},
      {'key': 'font_size_scale', 'value': '1.0', 'type': 'double'},
    ];

    for (final setting in defaultSettings) {
      await db.insert('user_settings', setting);
    }
  }

  Future<void> _insertVersePreferences(Database db) async {
    final versePreferences = [
      {
        'preference_key': 'preferred_themes',
        'preference_value': 'faith,hope,love,peace,strength',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'preference_key': 'avoid_recent_days',
        'preference_value': '30',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'preference_key': 'preferred_version',
        'preference_value': 'WEB',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
    ];

    for (final pref in versePreferences) {
      await db.insert('verse_preferences', pref);
    }
  }

  Future<void> _insertDefaultPrayerCategories(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final categories = [
      {
        'id': 'cat_family',
        'name': 'Family',
        'icon': '58387', // Material Icons: people
        'color': '0xFF4CAF50',
        'description': 'Prayers for family members',
        'display_order': 1,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': '59408', // Material Icons: favorite
        'color': '0xFFF44336',
        'description': 'Prayers for health and healing',
        'display_order': 2,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_work',
        'name': 'Work',
        'icon': '59641', // Material Icons: work
        'color': '0xFF2196F3',
        'description': 'Prayers for work and career',
        'display_order': 3,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_faith',
        'name': 'Faith',
        'icon': '57452', // Material Icons: church
        'color': '0xFF9C27B0',
        'description': 'Prayers for spiritual growth and faith',
        'display_order': 4,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_relationships',
        'name': 'Relationships',
        'icon': '59409', // Material Icons: favorite_border
        'color': '0xFFE91E63',
        'description': 'Prayers for relationships and friendships',
        'display_order': 5,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_guidance',
        'name': 'Guidance',
        'icon': '58733', // Material Icons: explore
        'color': '0xFF673AB7',
        'description': 'Prayers for direction and wisdom',
        'display_order': 6,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_gratitude',
        'name': 'Gratitude',
        'icon': '60106', // Material Icons: celebration
        'color': '0xFFFFC107',
        'description': 'Prayers of thanksgiving and gratitude',
        'display_order': 7,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
      {
        'id': 'cat_other',
        'name': 'Other',
        'icon': '58835', // Material Icons: more_horiz
        'color': '0xFF9E9E9E',
        'description': 'Other prayer requests',
        'display_order': 8,
        'is_active': 1,
        'is_default': 1,
        'created_at': now,
        'date_created': now,
        'date_modified': null,
      },
    ];

    for (final category in categories) {
      await db.insert('prayer_categories', category);
    }
  }

  Future<void> _insertDefaultReadingPlans(Database db) async {
    final plans = [
      {
        'id': 'plan_new_testament',
        'title': 'New Testament in 90 Days',
        'description': 'Read through the entire New Testament in just 90 days. Perfect for understanding the life of Jesus and the early church.',
        'duration': '90 days',
        'category': 'newTestament',
        'difficulty': 'beginner',
        'estimated_time_per_day': '15-20 min',
        'total_readings': 90,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_psalms_proverbs',
        'title': 'Wisdom Literature',
        'description': 'Journey through the five wisdom books: Job, Psalms, Proverbs, Ecclesiastes, and Song of Solomon. Discover timeless insights for living wisely and worshiping deeply.',
        'duration': '60 days',
        'category': 'wisdom',
        'difficulty': 'beginner',
        'estimated_time_per_day': '15-20 min',
        'total_readings': 60,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_gospels',
        'title': 'Life of Jesus (4 Gospels)',
        'description': 'Journey through the life, teachings, death, and resurrection of Jesus Christ through all four Gospel accounts.',
        'duration': '40 days',
        'category': 'gospels',
        'difficulty': 'beginner',
        'estimated_time_per_day': '15-20 min',
        'total_readings': 40,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_one_year_bible',
        'title': 'One Year Bible Reading',
        'description': 'Read the entire Bible in one year with a balanced mix of Old Testament, New Testament, Psalms, and Proverbs daily.',
        'duration': '365 days',
        'category': 'completeBible',
        'difficulty': 'challenging',
        'estimated_time_per_day': '20-30 min',
        'total_readings': 365,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_paul_letters',
        'title': 'Paul\'s Letters',
        'description': 'Study all of Paul\'s epistles to understand his theology, church teachings, and practical Christian living.',
        'duration': '45 days',
        'category': 'epistles',
        'difficulty': 'intermediate',
        'estimated_time_per_day': '15-20 min',
        'total_readings': 45,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_pentateuch',
        'title': 'Books of Moses (Pentateuch)',
        'description': 'Discover God\'s covenant with His people through Genesis, Exodus, Leviticus, Numbers, and Deuteronomy.',
        'duration': '75 days',
        'category': 'oldTestament',
        'difficulty': 'intermediate',
        'estimated_time_per_day': '20-25 min',
        'total_readings': 75,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      // NEW BOOK-BASED PLANS
      {
        'id': 'plan_gospel_john',
        'title': 'Gospel of John in 21 Days',
        'description': 'Experience Jesus through John\'s Gospel - the most theological account of Christ\'s life, teachings, and identity as the Son of God.',
        'duration': '21 days',
        'category': 'gospels',
        'difficulty': 'beginner',
        'estimated_time_per_day': '10-15 min',
        'total_readings': 21,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_proverbs_month',
        'title': 'Proverbs - A Chapter a Day',
        'description': 'Gain practical wisdom for daily living with one chapter of Proverbs each day. Perfect for building a habit of seeking godly wisdom.',
        'duration': '31 days',
        'category': 'proverbs',
        'difficulty': 'beginner',
        'estimated_time_per_day': '5-10 min',
        'total_readings': 31,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
      {
        'id': 'plan_psalms_prayer',
        'title': 'Psalms for Prayer',
        'description': 'Let the Psalms guide your prayer life. Read 5 psalms each day and learn to express your heart to God through worship, lament, and praise.',
        'duration': '30 days',
        'category': 'psalms',
        'difficulty': 'beginner',
        'estimated_time_per_day': '15-20 min',
        'total_readings': 30,
        'completed_readings': 0,
        'is_started': 0,
        'start_date': null,
      },
    ];

    for (final plan in plans) {
      await db.insert('reading_plans', plan);
    }
  }

  /// Close database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  /// Delete database
  Future<void> deleteDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    if (await File(path).exists()) {
      await File(path).delete();
    }
    _database = null;
  }

  /// Initialize (for compatibility)
  Future<void> initialize() async {
    await database;
  }

  /// Reset database
  Future<void> resetDatabase() async {
    await close();
    await deleteDatabase();
    await database;
  }

  // ==================== CRUD OPERATIONS ====================
  // (Keep all existing methods from both classes)

  Future<int> insertVerse(Map<String, dynamic> verse) async {
    return await ErrorHandler.handleAsync(
      () async {
        final db = await database;
        return await db.insert('verses', verse, conflictAlgorithm: ConflictAlgorithm.replace);
      },
      context: 'DatabaseHelper.insertVerse',
    );
  }

  Future<Map<String, dynamic>?> getVerse(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> searchVerses({
    String? query,
    List<String>? themes,
    String? translation,
    int? limit,
  }) async {
    return await ErrorHandler.handleAsync(
      () async {
        final db = await database;

        if (query != null && query.isNotEmpty) {
          String sql = '''
            SELECT v.*
            FROM bible_verses v
            INNER JOIN bible_verses_fts fts ON v.id = fts.rowid
            WHERE bible_verses_fts MATCH ?
          ''';
          List<dynamic> args = [query];

          if (themes != null && themes.isNotEmpty) {
            sql += ' AND (${themes.map((theme) => 'v.themes LIKE ?').join(' OR ')})';
            args.addAll(themes.map((theme) => '%"$theme"%'));
          }

          if (translation != null) {
            sql += ' AND v.version = ?';
            args.add(translation);
          }

          sql += ' ORDER BY RANDOM()';

          if (limit != null) {
            sql += ' LIMIT ?';
            args.add(limit);
          }

          return await db.rawQuery(sql, args);
        }

        String whereClause = '';
        List<dynamic> whereArgs = [];

        if (themes != null && themes.isNotEmpty) {
          whereClause += '(${themes.map((theme) => 'themes LIKE ?').join(' OR ')})';
          whereArgs.addAll(themes.map((theme) => '%"$theme"%'));
        }

        if (translation != null) {
          if (whereClause.isNotEmpty) whereClause += ' AND ';
          whereClause += 'version = ?';
          whereArgs.add(translation);
        }

        return await db.query(
          'bible_verses',
          where: whereClause.isNotEmpty ? whereClause : null,
          whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
          orderBy: 'RANDOM()',
          limit: limit,
        );
      },
      context: 'DatabaseHelper.searchVerses',
      fallbackValue: <Map<String, dynamic>>[],
    );
  }

  Future<List<Map<String, dynamic>>> getVersesByTheme(String theme, {int? limit}) async {
    return await searchVerses(themes: [theme], limit: limit);
  }

  Future<Map<String, dynamic>?> getRandomVerse({List<String>? themes}) async {
    final verses = await searchVerses(themes: themes, limit: 1);
    return verses.isNotEmpty ? verses.first : null;
  }

  Future<int> insertChatMessage(Map<String, dynamic> message) async {
    final db = await database;
    return await db.insert('chat_messages', message);
  }

  Future<List<Map<String, dynamic>>> getChatMessages({
    String? sessionId,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    return await db.query(
      'chat_messages',
      where: sessionId != null ? 'session_id = ?' : null,
      whereArgs: sessionId != null ? [sessionId] : null,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );
  }

  Future<int> deleteOldChatMessages(int days) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;

    return await db.delete(
      'chat_messages',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate],
    );
  }

  /// Delete excess chat messages, keeping only the N most recent
  Future<int> deleteExcessChatMessages(int keepCount) async {
    final db = await database;

    // Get the timestamp of the Nth most recent message
    final result = await db.query(
      'chat_messages',
      columns: ['timestamp'],
      orderBy: 'timestamp DESC',
      limit: 1,
      offset: keepCount,
    );

    if (result.isEmpty) {
      // Less than keepCount messages exist, nothing to delete
      return 0;
    }

    final cutoffTimestamp = result.first['timestamp'] as int;

    // Delete all messages older than the cutoff
    return await db.delete(
      'chat_messages',
      where: 'timestamp < ?',
      whereArgs: [cutoffTimestamp],
    );
  }

  /// Perform automatic cleanup: remove messages older than 60 days OR keep only 100 most recent
  Future<Map<String, int>> autoCleanupChatMessages() async {
    // Delete messages older than 60 days
    final deletedByAge = await deleteOldChatMessages(60);

    // Delete excess messages, keeping only 100 most recent
    final deletedByCount = await deleteExcessChatMessages(100);

    return {
      'deleted_by_age': deletedByAge,
      'deleted_by_count': deletedByCount,
      'total_deleted': deletedByAge + deletedByCount,
    };
  }

  Future<int> insertPrayerRequest(Map<String, dynamic> prayer) async {
    final db = await database;
    return await db.insert('prayer_requests', prayer);
  }

  Future<int> updatePrayerRequest(String id, Map<String, dynamic> prayer) async {
    final db = await database;
    return await db.update(
      'prayer_requests',
      prayer,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getPrayerRequests({
    String? status,
    String? category,
  }) async {
    final db = await database;

    String? whereClause;
    List<dynamic>? whereArgs;

    if (status != null || category != null) {
      List<String> conditions = [];
      whereArgs = [];

      if (status != null) {
        conditions.add('status = ?');
        whereArgs.add(status);
      }

      if (category != null) {
        conditions.add('category = ?');
        whereArgs.add(category);
      }

      whereClause = conditions.join(' AND ');
    }

    return await db.query(
      'prayer_requests',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date_created DESC',
    );
  }

  Future<void> setSetting(String key, dynamic value) async {
    final db = await database;

    await db.insert(
      'user_settings',
      {
        'key': key,
        'value': value.toString(),
        'type': value.runtimeType.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<T?> getSetting<T>(String key, {T? defaultValue}) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );

    if (result.isEmpty) return defaultValue;

    final setting = result.first;
    final String value = setting['value'];
    final String type = setting['type'];

    switch (type) {
      case 'bool':
        return (value.toLowerCase() == 'true') as T?;
      case 'int':
        return int.tryParse(value) as T?;
      case 'double':
        return double.tryParse(value) as T?;
      case 'String':
      default:
        return value as T?;
    }
  }

  Future<int> deleteSetting(String key) async {
    final db = await database;
    return await db.delete(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }

  Future<int> getDatabaseSize() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    File file = File(path);

    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<String> exportDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String sourcePath = join(documentsDirectory.path, _databaseName);
    String backupPath = join(documentsDirectory.path, 'backup_$_databaseName');

    await File(sourcePath).copy(backupPath);
    return backupPath;
  }
}
