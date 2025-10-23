import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_service.dart';

/// Service for loading Bible data into the local SQLite database
class BibleLoaderService {
  final DatabaseService _database;

  BibleLoaderService(this._database);

  /// Load all Bible versions into the database
  Future<void> loadAllBibles() async {
    // Copy verses from assets/bible.db to app database
    await _copyFromAssetDatabase();
  }

  /// Copy Bible verses from the pre-populated asset database
  Future<void> _copyFromAssetDatabase() async {
    try {
      final db = await _database.database;
      final databasesPath = await getDatabasesPath();
      final assetDbPath = join(databasesPath, 'asset_bible.db');

      // Copy asset database to app directory
      final data = await rootBundle.load('assets/bible.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(assetDbPath).writeAsBytes(bytes, flush: true);


      // Attach the asset database
      await db.execute("ATTACH DATABASE '$assetDbPath' AS asset_db");

      // Copy verses from asset_db.verses to main db.bible_verses
      // Map columns: translation->version, verse_number->verse, add language='en'
      await db.execute('''
        INSERT OR REPLACE INTO bible_verses (version, book, chapter, verse, text, language)
        SELECT
          translation as version,
          book,
          chapter,
          verse_number as verse,
          clean_text as text,
          'en' as language
        FROM asset_db.verses
        WHERE translation = 'WEB'
      ''');

      // Copy daily verse schedule from asset_db to main db
      // Match verses by (book, chapter, verse) to get correct verse_id in target db
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

      // Detach the asset database
      await db.execute('DETACH DATABASE asset_db');

      // Clean up the copied asset database file
      await File(assetDbPath).delete();

    } catch (e) {
      rethrow;
    }
  }


  /// Check if Bible data is already loaded
  Future<bool> isBibleLoaded(String version) async {
    final db = await _database.database;
    final result = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: [version],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Get loading progress (for UI feedback)
  Future<Map<String, dynamic>> getLoadingProgress() async {
    final db = await _database.database;

    final webCount = await db.query(
      'bible_verses',
      where: 'version = ?',
      whereArgs: ['WEB'],
    );

    return {
      'WEB': webCount.length,
      'total': webCount.length,
    };
  }
}
