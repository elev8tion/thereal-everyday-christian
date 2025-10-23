import '../core/database/database_helper.dart';
import '../models/bible_verse.dart';

/// Service for fetching Bible chapters and verses from bible_verses table
class BibleChapterService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Get all verses for a specific book and chapter
  Future<List<BibleVerse>> getChapterVerses(
    String book,
    int chapter, {
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    final results = await database.query(
      'bible_verses',
      where: 'book = ? AND chapter = ? AND version = ? AND language = ?',
      whereArgs: [book, chapter, version, language],
      orderBy: 'verse ASC',
    );

    return results.map((map) {
      // Map bible_verses columns to BibleVerse expected columns
      return BibleVerse.fromMap({
        'id': map['id'],
        'book': map['book'],
        'chapter': map['chapter'],
        'verse_number': map['verse'], // Map 'verse' to 'verse_number'
        'text': map['text'],
        'translation': map['version'],
      });
    }).toList();
  }

  /// Get verses for a range of chapters
  Future<Map<int, List<BibleVerse>>> getChapterRange(
    String book,
    int startChapter,
    int endChapter, {
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    final results = await database.query(
      'bible_verses',
      where: 'book = ? AND chapter >= ? AND chapter <= ? AND version = ? AND language = ?',
      whereArgs: [book, startChapter, endChapter, version, language],
      orderBy: 'chapter ASC, verse ASC',
    );

    // Group verses by chapter
    final Map<int, List<BibleVerse>> chapterMap = {};
    for (final map in results) {
      final chapterNum = map['chapter'] as int;

      // Map bible_verses columns to BibleVerse expected columns
      final verse = BibleVerse.fromMap({
        'id': map['id'],
        'book': map['book'],
        'chapter': map['chapter'],
        'verse_number': map['verse'], // Map 'verse' to 'verse_number'
        'text': map['text'],
        'translation': map['version'],
      });

      if (!chapterMap.containsKey(chapterNum)) {
        chapterMap[chapterNum] = [];
      }
      chapterMap[chapterNum]!.add(verse);
    }

    return chapterMap;
  }

  /// Get the total number of chapters in a book
  Future<int> getChapterCount(
    String book, {
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT MAX(chapter) as max_chapter
      FROM bible_verses
      WHERE book = ? AND version = ? AND language = ?
    ''', [book, version, language]);

    if (results.isEmpty) return 0;
    return (results.first['max_chapter'] as int?) ?? 0;
  }

  /// Get all available books
  Future<List<String>> getAllBooks({
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT DISTINCT book
      FROM bible_verses
      WHERE version = ? AND language = ?
      ORDER BY id ASC
    ''', [version, language]);

    return results.map((row) => row['book'] as String).toList();
  }

  /// Check if a chapter exists
  Future<bool> chapterExists(
    String book,
    int chapter, {
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    final results = await database.query(
      'bible_verses',
      where: 'book = ? AND chapter = ? AND version = ? AND language = ?',
      whereArgs: [book, chapter, version, language],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Mark a daily reading as complete
  Future<void> markReadingComplete(String readingId) async {
    final database = await _db.database;

    await database.update(
      'daily_readings',
      {'is_completed': 1, 'completed_date': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [readingId],
    );

    // Update the reading plan's completed_readings count
    await database.rawUpdate('''
      UPDATE reading_plans
      SET completed_readings = (
        SELECT COUNT(*) FROM daily_readings
        WHERE plan_id = (SELECT plan_id FROM daily_readings WHERE id = ?)
        AND is_completed = 1
      )
      WHERE id = (SELECT plan_id FROM daily_readings WHERE id = ?)
    ''', [readingId, readingId]);
  }

  /// Check if a reading is completed
  Future<bool> isReadingComplete(String readingId) async {
    final database = await _db.database;

    final results = await database.query(
      'daily_readings',
      where: 'id = ? AND is_completed = 1',
      whereArgs: [readingId],
      limit: 1,
    );

    return results.isNotEmpty;
  }

  /// Search verses by content using Full-Text Search
  Future<List<BibleVerse>> searchVerses(
    String query, {
    String version = 'WEB',
    String language = 'en',
    int limit = 50,
  }) async {
    if (query.trim().isEmpty) return [];

    final database = await _db.database;

    // Use FTS5 MATCH for full-text search
    final results = await database.rawQuery('''
      SELECT bv.id, bv.book, bv.chapter, bv.verse, bv.text, bv.version,
             bv.reference, bv.themes, bv.category
      FROM bible_verses_fts fts
      JOIN bible_verses bv ON fts.rowid = bv.id
      WHERE fts.bible_verses_fts MATCH ?
        AND bv.version = ?
        AND bv.language = ?
      ORDER BY bv.book, bv.chapter, bv.verse
      LIMIT ?
    ''', [query, version, language, limit]);

    return results.map((map) {
      return BibleVerse.fromMap({
        'id': map['id'],
        'book': map['book'],
        'chapter': map['chapter'],
        'verse_number': map['verse'],
        'text': map['text'],
        'translation': map['version'],
        'reference': map['reference'],
        'themes': map['themes'],
        'category': map['category'],
      });
    }).toList();
  }

  /// Get specific verse(s) by reference (e.g., John 3:16 or Gen 1:1-3)
  Future<List<BibleVerse>> getVersesByReference(
    String book,
    int chapter,
    int startVerse, {
    int? endVerse,
    String version = 'WEB',
    String language = 'en',
  }) async {
    final database = await _db.database;

    String whereClause = 'book = ? AND chapter = ? AND verse >= ? AND version = ? AND language = ?';
    List<dynamic> whereArgs = [book, chapter, startVerse, version, language];

    if (endVerse != null) {
      whereClause += ' AND verse <= ?';
      whereArgs.insert(3, endVerse);
    } else {
      // Single verse lookup
      whereClause = 'book = ? AND chapter = ? AND verse = ? AND version = ? AND language = ?';
      whereArgs[2] = startVerse;
    }

    final results = await database.query(
      'bible_verses',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'verse ASC',
    );

    return results.map((map) {
      return BibleVerse.fromMap({
        'id': map['id'],
        'book': map['book'],
        'chapter': map['chapter'],
        'verse_number': map['verse'],
        'text': map['text'],
        'translation': map['version'],
        'reference': map['reference'],
        'themes': map['themes'],
        'category': map['category'],
      });
    }).toList();
  }
}
