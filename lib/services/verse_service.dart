import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';

/// Service for managing Bible verses and search functionality
class VerseService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Search verses by text content using full-text search
  Future<List<Map<String, dynamic>>> searchVerses(String query, {int limit = 20}) async {
    if (query.trim().isEmpty) return [];

    try {
      final database = await _db.database;

      // Use FTS5 for full-text search
      final results = await database.rawQuery('''
        SELECT v.*,
               snippet(bible_verses_fts, 0, '<mark>', '</mark>', '...', 32) as snippet,
               rank
        FROM bible_bible_verses_fts
        JOIN verses v ON bible_verses_fts.rowid = v.id
        WHERE bible_verses_fts MATCH ?
        ORDER BY rank
        LIMIT ?
      ''', [query, limit]);

      return results;
    } catch (e) {
      // Log error in production, replace with proper logging
      // print('Error searching verses: $e');
      // Fallback to LIKE search if FTS fails
      return _fallbackSearch(query, limit);
    }
  }

  /// Fallback search using LIKE operator
  Future<List<Map<String, dynamic>>> _fallbackSearch(String query, int limit) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT * FROM bible_verses
      WHERE text LIKE ? OR reference LIKE ? OR themes LIKE ?
      ORDER BY
        CASE
          WHEN text LIKE ? THEN 1
          WHEN reference LIKE ? THEN 2
          ELSE 3
        END
      LIMIT ?
    ''', [
      '%$query%', '%$query%', '%$query%',
      '%$query%', '%$query%',
      limit
    ]);

    return results;
  }

  /// Get verses by theme (searches text for theme keywords)
  Future<List<Map<String, dynamic>>> getVersesByTheme(String theme, {int limit = 10}) async {
    final database = await _db.database;

    // Search verse text for theme-related keywords
    final results = await database.rawQuery('''
      SELECT * FROM bible_verses
      WHERE themes LIKE ?
      ORDER BY RANDOM()
      LIMIT ?
    ''', ['%$theme%', limit]);

    return results;
  }

  /// Get verses by category (searches text for category keywords)
  Future<List<Map<String, dynamic>>> getVersesByCategory(String category, {int limit = 10}) async {
    final database = await _db.database;

    // Search verse text for category-related keywords
    final results = await database.rawQuery('''
      SELECT * FROM bible_verses
      WHERE category = ?
      ORDER BY RANDOM()
      LIMIT ?
    ''', [category, limit]);

    return results;
  }

  /// Get random daily verse
  Future<Map<String, dynamic>?> getDailyVerse({String? preferredTheme}) async {
    final database = await _db.database;

    String query = 'SELECT * FROM bible_verses';
    List<dynamic> args = [];

    if (preferredTheme != null && preferredTheme.isNotEmpty) {
      query += ' WHERE themes LIKE ? OR category = ?';
      args.addAll(['%$preferredTheme%', preferredTheme]);
    }

    query += ' ORDER BY RANDOM() LIMIT 1';

    final results = await database.rawQuery(query, args);
    return results.isNotEmpty ? results.first : null;
  }

  /// Get verses for specific situations/emotions
  Future<List<Map<String, dynamic>>> getVersesForSituation(String situation, {int limit = 5}) async {
    // Map common situations to themes
    final situationThemes = {
      'anxiety': ['peace', 'comfort', 'trust'],
      'depression': ['hope', 'comfort', 'strength'],
      'fear': ['courage', 'strength', 'protection'],
      'loneliness': ['comfort', 'presence', 'love'],
      'doubt': ['faith', 'trust', 'assurance'],
      'anger': ['peace', 'forgiveness', 'patience'],
      'grief': ['comfort', 'hope', 'healing'],
      'stress': ['peace', 'rest', 'trust'],
      'guilt': ['forgiveness', 'grace', 'redemption'],
      'purpose': ['purpose', 'identity', 'calling'],
      'relationships': ['love', 'forgiveness', 'unity'],
      'finances': ['provision', 'trust', 'contentment'],
      'health': ['healing', 'strength', 'peace'],
      'work': ['purpose', 'diligence', 'integrity'],
      'decisions': ['wisdom', 'guidance', 'discernment'],
    };

    final themes = situationThemes[situation.toLowerCase()] ?? [situation];
    final database = await _db.database;

    // Build WHERE clause for multiple themes
    final themeClauses = themes.map((_) => 'themes LIKE ? OR category = ?').join(' OR ');
    final args = themes.expand((theme) => ['%$theme%', theme]).toList();

    final results = await database.rawQuery('''
      SELECT * FROM bible_verses
      WHERE $themeClauses
      ORDER BY RANDOM()
      LIMIT ?
    ''', [...args, limit]);

    return results;
  }

  /// Get verse by exact reference (e.g., "John 3:16")
  Future<Map<String, dynamic>?> getVerseByReference(String reference) async {
    final database = await _db.database;

    final results = await database.query(
      'bible_verses',
      where: 'reference = ?',
      whereArgs: [reference],
      limit: 1,
    );

    return results.isNotEmpty ? results.first : null;
  }

  /// Get verse recommendations based on user's reading history
  Future<List<Map<String, dynamic>>> getRecommendedVerses(
    List<String> favoriteThemes,
    {int limit = 10}
  ) async {
    if (favoriteThemes.isEmpty) {
      return getVersesByTheme('hope', limit: limit);
    }

    final database = await _db.database;

    // Build query for user's favorite themes
    final themeClauses = favoriteThemes.map((_) => 'themes LIKE ? OR category = ?').join(' OR ');
    final args = favoriteThemes.expand((theme) => ['%$theme%', theme]).toList();

    final results = await database.rawQuery('''
      SELECT *,
        CASE
          ${favoriteThemes.asMap().entries.map((entry) =>
            'WHEN themes LIKE "%${entry.value}%" OR category = "${entry.value}" THEN ${favoriteThemes.length - entry.key}'
          ).join(' ')}
          ELSE 0
        END as relevance_score
      FROM bible_verses
      WHERE $themeClauses
      ORDER BY relevance_score DESC, RANDOM()
      LIMIT ?
    ''', [...args, limit]);

    return results;
  }

  /// Get all available themes from verses
  Future<List<String>> getAllThemes() async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT DISTINCT themes FROM bible_verses WHERE themes IS NOT NULL
    ''');

    final Set<String> allThemes = {};

    for (final row in results) {
      final themesJson = row['themes'] as String?;
      if (themesJson != null) {
        try {
          final List<dynamic> themes = jsonDecode(themesJson);
          allThemes.addAll(themes.cast<String>());
        } catch (e) {
          // Handle malformed JSON gracefully
          continue;
        }
      }
    }

    final sortedThemes = allThemes.toList()..sort();
    return sortedThemes;
  }

  /// Get all available categories
  Future<List<String>> getAllCategories() async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT DISTINCT category FROM bible_verses
      WHERE category IS NOT NULL
      ORDER BY category
    ''');

    return results.map((row) => row['category'] as String).toList();
  }

  /// Get verse statistics
  Future<Map<String, dynamic>> getVerseStats() async {
    final database = await _db.database;

    final totalCount = await database.rawQuery('SELECT COUNT(*) as count FROM bible_verses');
    final categoryStats = await database.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM bible_verses
      WHERE category IS NOT NULL
      GROUP BY category
      ORDER BY count DESC
    ''');

    final versionStats = await database.rawQuery('''
      SELECT version, COUNT(*) as count
      FROM bible_verses
      GROUP BY version
      ORDER BY count DESC
    ''');

    return {
      'total_verses': totalCount.first['count'],
      'categories': categoryStats,
      'versions': versionStats,
    };
  }

  /// Bookmark a verse for a user
  Future<void> bookmarkVerse(int verseId, String userId) async {
    final database = await _db.database;

    await database.insert(
      'bookmarks',
      {
        'verse_id': verseId,
        'user_id': userId,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove bookmark
  Future<void> removeBookmark(int verseId, String userId) async {
    final database = await _db.database;

    await database.delete(
      'bookmarks',
      where: 'verse_id = ? AND user_id = ?',
      whereArgs: [verseId, userId],
    );
  }

  /// Get user's bookmarked verses
  Future<List<Map<String, dynamic>>> getBookmarkedVerses(String userId) async {
    final database = await _db.database;

    final results = await database.rawQuery('''
      SELECT v.*, b.created_at as bookmarked_at
      FROM bible_verses v
      JOIN bookmarks b ON v.id = b.verse_id
      WHERE b.user_id = ?
      ORDER BY b.created_at DESC
    ''', [userId]);

    return results;
  }

  /// Check if verse is bookmarked
  Future<bool> isVerseBookmarked(int verseId, String userId) async {
    final database = await _db.database;

    final results = await database.query(
      'bookmarks',
      where: 'verse_id = ? AND user_id = ?',
      whereArgs: [verseId, userId],
      limit: 1,
    );

    return results.isNotEmpty;
  }
}