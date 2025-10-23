import 'package:sqflite/sqflite.dart';
import '../models/bible_verse.dart';
import 'database_service.dart';

class VerseService {
  final DatabaseService _database;

  VerseService(this._database);

  Future<List<BibleVerse>> getAllVerses() async {
    final db = await _database.database;
    final maps = await db.query('bible_verses');
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> getFavoriteVerses() async {
    final db = await _database.database;
    final maps = await db.query('favorite_verses');
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<List<BibleVerse>> getVersesByCategory(VerseCategory category) async {
    final db = await _database.database;
    final maps = await db.query(
      'favorite_verses',
      where: 'category = ?',
      whereArgs: [category.name],
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  /// Search verses using FTS5 full-text search (FAST!)
  Future<List<BibleVerse>> searchVerses(String query, {String? version, int limit = 50}) async {
    if (query.trim().isEmpty) return [];

    final db = await _database.database;

    // Save to search history
    await _saveSearchHistory(query, 'full_text');

    try {
      // Use FTS5 for fast full-text search
      final versionFilter = version != null ? 'AND bv.version = ?' : '';
      final versionArgs = version != null ? [version] : [];

      final maps = await db.rawQuery('''
        SELECT bv.* FROM bible_verses bv
        INNER JOIN bible_verses_fts fts ON bv.id = fts.rowid
        WHERE bible_verses_fts MATCH ? $versionFilter
        ORDER BY rank
        LIMIT ?
      ''', [query, ...versionArgs, limit]);

      return maps.map((map) => BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      )).toList();
    } catch (e) {
      // Fallback to LIKE search if FTS5 fails
      final maps = await db.query(
        'verses',
        where: 'text LIKE ? ${version != null ? 'AND version = ?' : ''}',
        whereArgs: version != null ? ['%$query%', version] : ['%$query%'],
        limit: limit,
      );
      return maps.map((map) => BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      )).toList();
    }
  }

  /// Search by theme/topic (searches themes column if exists, or uses keywords)
  Future<List<BibleVerse>> searchByTheme(String theme, {String? version, int limit = 50}) async {
    // Save to search history
    await _saveSearchHistory(theme, 'theme');

    // Map common themes to search keywords
    final themeKeywords = {
      'love': 'love loved loving',
      'faith': 'faith believe trust',
      'hope': 'hope hopeful future',
      'peace': 'peace calm rest',
      'strength': 'strength strong power',
      'forgiveness': 'forgive forgiveness mercy',
      'joy': 'joy joyful rejoice glad',
      'prayer': 'pray prayer praying',
      'wisdom': 'wisdom wise understanding',
      'grace': 'grace gracious mercy',
    };

    final searchTerms = themeKeywords[theme.toLowerCase()] ?? theme;
    return searchVerses(searchTerms, version: version, limit: limit);
  }

  Future<void> toggleFavorite(String verseId) async {
    final db = await _database.database;
    final verse = await db.query(
      'verses',
      where: 'id = ?',
      whereArgs: [verseId],
    );

    if (verse.isNotEmpty) {
      final isFavorite = verse.first['is_favorite'] == 1;
      await db.update(
        'verses',
        {'is_favorite': isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [verseId],
      );
    }
  }

  /// Get smart daily verse based on user preferences and history
  Future<BibleVerse?> getVerseOfTheDay({String? forceTheme}) async {
    final today = _getTodayTimestamp();

    // Check if we already selected a verse for today
    final todayVerse = await _getTodaySelectedVerse(today);
    if (todayVerse != null) {
      return todayVerse;
    }

    // Get user preferences
    final preferences = await _getVersePreferences();
    final preferredThemes = preferences['preferred_themes']?.split(',') ?? ['faith', 'hope', 'love'];
    final avoidRecentDays = int.tryParse(preferences['avoid_recent_days'] ?? '30') ?? 30;
    final preferredVersion = preferences['preferred_version'] ?? 'WEB';

    // Get recently shown verses to avoid
    final recentVerseIds = await _getRecentVerseIds(avoidRecentDays);

    // Select theme (use forced theme or rotate through preferences)
    final theme = forceTheme ?? await _selectDailyTheme(preferredThemes);

    // Search for verse matching theme, excluding recent ones
    BibleVerse? selectedVerse = await _findVerseByThemeExcluding(
      theme: theme,
      excludeIds: recentVerseIds,
      version: preferredVersion,
    );

    // Fallback: if no verse found, get any random verse excluding recent
    selectedVerse ??= await _getRandomVerseExcluding(
      excludeIds: recentVerseIds,
      version: preferredVersion,
    );

    // Record the selection in history
    if (selectedVerse != null) {
      await _recordDailyVerse(
        int.parse(selectedVerse.id),
        today,
        theme,
      );
    }

    return selectedVerse;
  }

  /// Get today's timestamp (date only, no time)
  int _getTodayTimestamp() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.millisecondsSinceEpoch;
  }

  /// Check if we already selected a verse for today
  Future<BibleVerse?> _getTodaySelectedVerse(int todayTimestamp) async {
    final db = await _database.database;
    final maps = await db.rawQuery('''
      SELECT bv.* FROM bible_verses bv
      INNER JOIN daily_verse_history dvh ON bv.id = dvh.verse_id
      WHERE dvh.shown_date = ?
      LIMIT 1
    ''', [todayTimestamp]);

    if (maps.isEmpty) return null;

    final verse = maps.first;
    return BibleVerse(
      id: verse['id'].toString(),
      text: verse['text'] as String,
      reference: '${verse['book']} ${verse['chapter']}:${verse['verse']}',
      category: VerseCategory.faith,
      isFavorite: false,
    );
  }

  /// Get user verse preferences
  Future<Map<String, String>> _getVersePreferences() async {
    final db = await _database.database;
    final maps = await db.query('verse_preferences');

    final prefs = <String, String>{};
    for (final map in maps) {
      prefs[map['preference_key'] as String] = map['preference_value'] as String;
    }
    return prefs;
  }

  /// Get verse IDs shown in the last N days
  Future<List<int>> _getRecentVerseIds(int days) async {
    final db = await _database.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final cutoffTimestamp = cutoffDate.millisecondsSinceEpoch;

    final maps = await db.query(
      'daily_verse_history',
      columns: ['verse_id'],
      where: 'shown_date >= ?',
      whereArgs: [cutoffTimestamp],
    );

    return maps.map((map) => map['verse_id'] as int).toList();
  }

  /// Select theme for today (rotating through preferences)
  Future<String> _selectDailyTheme(List<String> themes) async {
    if (themes.isEmpty) return 'faith';

    // Use day of year to rotate through themes
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final themeIndex = dayOfYear % themes.length;
    return themes[themeIndex];
  }

  /// Find verse by theme, excluding recent IDs
  Future<BibleVerse?> _findVerseByThemeExcluding({
    required String theme,
    required List<int> excludeIds,
    String version = 'WEB',
  }) async {
    // Use FTS5 search for theme
    final verses = await searchByTheme(theme, version: version, limit: 100);

    // Filter out recently shown verses
    final filtered = verses.where((v) {
      final id = int.tryParse(v.id);
      return id != null && !excludeIds.contains(id);
    }).toList();

    // Return random from filtered results
    if (filtered.isEmpty) return null;
    filtered.shuffle();
    return filtered.first;
  }

  /// Get random verse excluding recent IDs
  Future<BibleVerse?> _getRandomVerseExcluding({
    required List<int> excludeIds,
    String version = 'WEB',
  }) async {
    final db = await _database.database;

    String excludeClause = '';
    if (excludeIds.isNotEmpty) {
      final placeholders = excludeIds.map((_) => '?').join(',');
      excludeClause = 'AND id NOT IN ($placeholders)';
    }

    final maps = await db.rawQuery('''
      SELECT * FROM bible_verses
      WHERE version = ? $excludeClause
      ORDER BY RANDOM()
      LIMIT 1
    ''', [version, ...excludeIds]);

    if (maps.isEmpty) return null;

    final verse = maps.first;
    return BibleVerse(
      id: verse['id'].toString(),
      text: verse['text'] as String,
      reference: '${verse['book']} ${verse['chapter']}:${verse['verse']}',
      category: VerseCategory.faith,
      isFavorite: false,
    );
  }

  /// Record daily verse selection in history
  Future<void> _recordDailyVerse(int verseId, int shownDate, String theme) async {
    final db = await _database.database;
    await db.insert(
      'daily_verse_history',
      {
        'verse_id': verseId,
        'shown_date': shownDate,
        'theme': theme,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get a specific verse by reference (e.g., "John 3:16")
  Future<BibleVerse?> getVerseByReference({
    required String book,
    required int chapter,
    required int verse,
    String version = 'WEB',
  }) async {
    final db = await _database.database;
    final maps = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
      whereArgs: [version, book, chapter, verse],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final result = maps.first;
      return BibleVerse(
        id: result['id'].toString(),
        text: result['text'] as String,
        reference: '$book $chapter:$verse',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }
    return null;
  }

  /// Search Bible verses by text content
  Future<List<BibleVerse>> searchBibleText(String query, {String version = 'WEB'}) async {
    final db = await _database.database;
    final maps = await db.query(
      'verses',
      where: 'version = ? AND text LIKE ?',
      whereArgs: [version, '%$query%'],
      limit: 50,
    );

    return maps.map((map) {
      return BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }).toList();
  }

  /// Get all verses from a chapter
  Future<List<BibleVerse>> getChapter({
    required String book,
    required int chapter,
    String version = 'WEB',
  }) async {
    final db = await _database.database;
    final maps = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse ASC',
    );

    return maps.map((map) {
      return BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '$book $chapter:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      );
    }).toList();
  }

  Future<List<BibleVerse>> getVersesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final db = await _database.database;
    final placeholders = ids.map((_) => '?').join(',');
    final maps = await db.query(
      'verses',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map((map) => _verseFromMap(map)).toList();
  }

  Future<int> getFavoriteCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM bible_verses WHERE is_favorite = 1',
    );
    return result.first['count'] as int;
  }

  BibleVerse _verseFromMap(Map<String, dynamic> map) {
    return BibleVerse(
      id: map['id'],
      text: map['text'],
      reference: map['reference'],
      category: VerseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => VerseCategory.faith,
      ),
      isFavorite: map['is_favorite'] == 1,
      dateAdded: map['date_added'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['date_added'])
          : null,
    );
  }

  // ============================================================================
  // BOOKMARK METHODS
  // ============================================================================

  /// Add a bookmark for a verse
  Future<void> addBookmark(int verseId, {String? note, List<String>? tags}) async {
    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.insert(
      'verse_bookmarks',
      {
        'verse_id': verseId,
        'note': note,
        'tags': tags?.join(','),
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Remove a bookmark
  Future<void> removeBookmark(int verseId) async {
    final db = await _database.database;
    await db.delete(
      'verse_bookmarks',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
  }

  /// Update bookmark note or tags
  Future<void> updateBookmark(int verseId, {String? note, List<String>? tags}) async {
    final db = await _database.database;
    await db.update(
      'verse_bookmarks',
      {
        'note': note,
        'tags': tags?.join(','),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
  }

  /// Check if a verse is bookmarked
  Future<bool> isBookmarked(int verseId) async {
    final db = await _database.database;
    final result = await db.query(
      'verse_bookmarks',
      where: 'verse_id = ?',
      whereArgs: [verseId],
    );
    return result.isNotEmpty;
  }

  /// Get all bookmarked verses with their notes and tags
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await _database.database;
    final maps = await db.rawQuery('''
      SELECT
        bv.*,
        vb.note,
        vb.tags,
        vb.created_at as bookmark_created_at
      FROM bible_verses bv
      INNER JOIN verse_bookmarks vb ON bv.id = vb.verse_id
      ORDER BY vb.created_at DESC
    ''');

    return maps.map((map) => {
      'verse': BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      ),
      'note': map['note'] as String?,
      'tags': (map['tags'] as String?)?.split(',') ?? <String>[],
      'bookmarkedAt': DateTime.fromMillisecondsSinceEpoch(map['bookmark_created_at'] as int),
    }).toList();
  }

  /// Search bookmarks by tag
  Future<List<Map<String, dynamic>>> searchBookmarksByTag(String tag) async {
    final db = await _database.database;
    final maps = await db.rawQuery('''
      SELECT
        bv.*,
        vb.note,
        vb.tags,
        vb.created_at as bookmark_created_at
      FROM bible_verses bv
      INNER JOIN verse_bookmarks vb ON bv.id = vb.verse_id
      WHERE vb.tags LIKE ?
      ORDER BY vb.created_at DESC
    ''', ['%$tag%']);

    return maps.map((map) => {
      'verse': BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      ),
      'note': map['note'] as String?,
      'tags': (map['tags'] as String?)?.split(',') ?? <String>[],
      'bookmarkedAt': DateTime.fromMillisecondsSinceEpoch(map['bookmark_created_at'] as int),
    }).toList();
  }

  // ============================================================================
  // SEARCH HISTORY METHODS
  // ============================================================================

  /// Save search to history
  Future<void> _saveSearchHistory(String query, String searchType) async {
    final db = await _database.database;
    await db.insert('search_history', {
      'query': query,
      'search_type': searchType,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Get recent search history
  Future<List<Map<String, dynamic>>> getSearchHistory({int limit = 20}) async {
    final db = await _database.database;
    final maps = await db.query(
      'search_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return maps.map((map) => {
      'query': map['query'] as String,
      'searchType': map['search_type'] as String,
      'searchedAt': DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    }).toList();
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    final db = await _database.database;
    await db.delete('search_history');
  }

  /// Get distinct search suggestions from history
  Future<List<String>> getSearchSuggestions({int limit = 10}) async {
    final db = await _database.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT query
      FROM search_history
      ORDER BY created_at DESC
      LIMIT ?
    ''', [limit]);

    return maps.map((map) => map['query'] as String).toList();
  }

  // ============================================================================
  // VERSE PREFERENCE METHODS
  // ============================================================================

  /// Update user's preferred themes for daily verses
  Future<void> updatePreferredThemes(List<String> themes) async {
    final db = await _database.database;
    await db.update(
      'verse_preferences',
      {
        'preference_value': themes.join(','),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'preference_key = ?',
      whereArgs: ['preferred_themes'],
    );
  }

  /// Update how many days to avoid showing recent verses
  Future<void> updateAvoidRecentDays(int days) async {
    final db = await _database.database;
    await db.update(
      'verse_preferences',
      {
        'preference_value': days.toString(),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'preference_key = ?',
      whereArgs: ['avoid_recent_days'],
    );
  }

  /// Update preferred Bible version for daily verses
  Future<void> updatePreferredVersion(String version) async {
    final db = await _database.database;
    await db.update(
      'verse_preferences',
      {
        'preference_value': version,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'preference_key = ?',
      whereArgs: ['preferred_version'],
    );
  }

  /// Get daily verse history
  Future<List<Map<String, dynamic>>> getDailyVerseHistory({int limit = 30}) async {
    final db = await _database.database;
    final maps = await db.rawQuery('''
      SELECT
        bv.*,
        dvh.shown_date,
        dvh.theme,
        dvh.created_at
      FROM bible_verses bv
      INNER JOIN daily_verse_history dvh ON bv.id = dvh.verse_id
      ORDER BY dvh.shown_date DESC
      LIMIT ?
    ''', [limit]);

    return maps.map((map) => {
      'verse': BibleVerse(
        id: map['id'].toString(),
        text: map['text'] as String,
        reference: '${map['book']} ${map['chapter']}:${map['verse']}',
        category: VerseCategory.faith,
        isFavorite: false,
      ),
      'theme': map['theme'] as String?,
      'shownDate': DateTime.fromMillisecondsSinceEpoch(map['shown_date'] as int),
    }).toList();
  }

  /// Clear daily verse history (for testing or user request)
  Future<void> clearDailyVerseHistory() async {
    final db = await _database.database;
    await db.delete('daily_verse_history');
  }
}
