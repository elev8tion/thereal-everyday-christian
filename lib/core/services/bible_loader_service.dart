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
    // Copy English Bible
    await _copyEnglishBible();
    // Copy Spanish Bible
    await _copySpanishBible();
  }

  /// Copy English Bible verses from the pre-populated asset database
  Future<void> _copyEnglishBible() async {
    try {
      final db = await _database.database;
      final databasesPath = await getDatabasesPath();
      final assetDbPath = join(databasesPath, 'asset_bible_en.db');

      // Copy asset database to app directory
      final data = await rootBundle.load('assets/bible.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(assetDbPath).writeAsBytes(bytes, flush: true);


      // Attach the asset database
      await db.execute("ATTACH DATABASE '$assetDbPath' AS asset_db_en");

      // Copy verses from asset_db_en.verses to main db.bible_verses
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
        FROM asset_db_en.verses
        WHERE translation = 'WEB'
      ''');

      // Copy daily verse schedule from asset_db_en to main db
      // Match verses by (book, chapter, verse) to get correct verse_id in target db
      await db.execute('''
        INSERT OR REPLACE INTO daily_verse_schedule (month, day, verse_id, language)
        SELECT
          s.month,
          s.day,
          bv.id,
          'en' as language
        FROM asset_db_en.daily_verse_schedule s
        JOIN asset_db_en.verses av ON s.verse_id = av.id
        JOIN bible_verses bv ON (
          av.book = bv.book AND
          av.chapter = bv.chapter AND
          av.verse_number = bv.verse AND
          av.translation = bv.version
        )
        WHERE av.translation = 'WEB'
      ''');

      // Detach the asset database
      await db.execute('DETACH DATABASE asset_db_en');

      // Clean up the copied asset database file
      await File(assetDbPath).delete();

    } catch (e) {
      rethrow;
    }
  }

  /// Copy Spanish Bible verses from the pre-populated asset database
  Future<void> _copySpanishBible() async {
    try {
      final db = await _database.database;
      final databasesPath = await getDatabasesPath();
      final assetDbPath = join(databasesPath, 'asset_bible_es.db');

      // Copy asset database to app directory
      final data = await rootBundle.load('assets/spanish_bible_rvr1909.db');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(assetDbPath).writeAsBytes(bytes, flush: true);

      // Attach the asset database
      await db.execute("ATTACH DATABASE '$assetDbPath' AS asset_db_es");

      // Copy verses from asset_db_es.verses to main db.bible_verses
      // Map columns: spanish_text->text, verse_number->verse, add language='es'
      await db.execute('''
        INSERT OR REPLACE INTO bible_verses (version, book, chapter, verse, text, language)
        SELECT
          translation as version,
          book,
          chapter,
          verse_number as verse,
          spanish_text as text,
          'es' as language
        FROM asset_db_es.verses
        WHERE spanish_text IS NOT NULL AND LENGTH(spanish_text) > 0
      ''');

      // Copy daily verse schedule for Spanish
      // Match English schedule entries by (book, chapter, verse) to find Spanish equivalents
      // Use CASE to translate English book names to Spanish book names for JOIN
      await db.execute('''
        INSERT OR REPLACE INTO daily_verse_schedule (month, day, verse_id, language)
        SELECT
          s.month,
          s.day,
          bv_es.id,
          'es' as language
        FROM daily_verse_schedule s
        JOIN bible_verses bv_en ON s.verse_id = bv_en.id AND s.language = 'en'
        JOIN bible_verses bv_es ON (
          CASE bv_en.book
            WHEN 'Genesis' THEN 'Génesis'
            WHEN 'Exodus' THEN 'Éxodo'
            WHEN 'Leviticus' THEN 'Levítico'
            WHEN 'Numbers' THEN 'Números'
            WHEN 'Deuteronomy' THEN 'Deuteronomio'
            WHEN 'Joshua' THEN 'Josué'
            WHEN 'Judges' THEN 'Jueces'
            WHEN 'Ruth' THEN 'Rut'
            WHEN '1 Samuel' THEN '1 Samuel'
            WHEN '2 Samuel' THEN '2 Samuel'
            WHEN '1 Kings' THEN '1 Reyes'
            WHEN '2 Kings' THEN '2 Reyes'
            WHEN '1 Chronicles' THEN '1 Crónicas'
            WHEN '2 Chronicles' THEN '2 Crónicas'
            WHEN 'Ezra' THEN 'Esdras'
            WHEN 'Nehemiah' THEN 'Nehemías'
            WHEN 'Esther' THEN 'Ester'
            WHEN 'Job' THEN 'Job'
            WHEN 'Psalms' THEN 'Salmos'
            WHEN 'Proverbs' THEN 'Proverbios'
            WHEN 'Ecclesiastes' THEN 'Eclesiastés'
            WHEN 'Song of Solomon' THEN 'Cantares'
            WHEN 'Isaiah' THEN 'Isaías'
            WHEN 'Jeremiah' THEN 'Jeremías'
            WHEN 'Lamentations' THEN 'Lamentaciones'
            WHEN 'Ezekiel' THEN 'Ezequiel'
            WHEN 'Daniel' THEN 'Daniel'
            WHEN 'Hosea' THEN 'Oseas'
            WHEN 'Joel' THEN 'Joel'
            WHEN 'Amos' THEN 'Amós'
            WHEN 'Obadiah' THEN 'Abdías'
            WHEN 'Jonah' THEN 'Jonás'
            WHEN 'Micah' THEN 'Miqueas'
            WHEN 'Nahum' THEN 'Nahúm'
            WHEN 'Habakkuk' THEN 'Habacuc'
            WHEN 'Zephaniah' THEN 'Sofonías'
            WHEN 'Haggai' THEN 'Hageo'
            WHEN 'Zechariah' THEN 'Zacarías'
            WHEN 'Malachi' THEN 'Malaquías'
            WHEN 'Matthew' THEN 'Mateo'
            WHEN 'Mark' THEN 'Marcos'
            WHEN 'Luke' THEN 'Lucas'
            WHEN 'John' THEN 'Juan'
            WHEN 'Acts' THEN 'Hechos'
            WHEN 'Romans' THEN 'Romanos'
            WHEN '1 Corinthians' THEN '1 Corintios'
            WHEN '2 Corinthians' THEN '2 Corintios'
            WHEN 'Galatians' THEN 'Gálatas'
            WHEN 'Ephesians' THEN 'Efesios'
            WHEN 'Philippians' THEN 'Filipenses'
            WHEN 'Colossians' THEN 'Colosenses'
            WHEN '1 Thessalonians' THEN '1 Tesalonicenses'
            WHEN '2 Thessalonians' THEN '2 Tesalonicenses'
            WHEN '1 Timothy' THEN '1 Timoteo'
            WHEN '2 Timothy' THEN '2 Timoteo'
            WHEN 'Titus' THEN 'Tito'
            WHEN 'Philemon' THEN 'Filemón'
            WHEN 'Hebrews' THEN 'Hebreos'
            WHEN 'James' THEN 'Santiago'
            WHEN '1 Peter' THEN '1 Pedro'
            WHEN '2 Peter' THEN '2 Pedro'
            WHEN '1 John' THEN '1 Juan'
            WHEN '2 John' THEN '2 Juan'
            WHEN '3 John' THEN '3 Juan'
            WHEN 'Jude' THEN 'Judas'
            WHEN 'Revelation' THEN 'Apocalipsis'
            ELSE bv_en.book
          END = bv_es.book AND
          bv_en.chapter = bv_es.chapter AND
          bv_en.verse = bv_es.verse AND
          bv_es.language = 'es'
        )
      ''');

      // Detach the asset database
      await db.execute('DETACH DATABASE asset_db_es');

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
