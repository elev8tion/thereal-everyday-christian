import '../models/devotional.dart';
import 'database_service.dart';

/// Service for tracking devotional completion progress
class DevotionalProgressService {
  final DatabaseService _database;

  DevotionalProgressService(this._database);

  /// Mark a devotional as complete with the current timestamp
  Future<void> markAsComplete(String devotionalId) async {
    final db = await _database.database;
    final now = DateTime.now();

    await db.update(
      'devotionals',
      {
        'is_completed': 1,
        'completed_date': now.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [devotionalId],
    );

  }

  /// Mark a devotional as incomplete
  Future<void> markAsIncomplete(String devotionalId) async {
    final db = await _database.database;

    await db.update(
      'devotionals',
      {
        'is_completed': 0,
        'completed_date': null,
      },
      where: 'id = ?',
      whereArgs: [devotionalId],
    );

  }

  /// Get completion status for a specific devotional
  Future<bool> getCompletionStatus(String devotionalId) async {
    final db = await _database.database;

    final result = await db.query(
      'devotionals',
      columns: ['is_completed'],
      where: 'id = ?',
      whereArgs: [devotionalId],
      limit: 1,
    );

    if (result.isEmpty) {
      return false;
    }

    return result.first['is_completed'] == 1;
  }

  /// Get total number of completed devotionals
  Future<int> getTotalCompleted() async {
    final db = await _database.database;

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM devotionals WHERE is_completed = 1',
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Get list of all completed devotionals
  Future<List<Devotional>> getCompletedDevotionals() async {
    final db = await _database.database;

    final maps = await db.query(
      'devotionals',
      where: 'is_completed = ?',
      whereArgs: [1],
      orderBy: 'completed_date DESC',
    );

    return maps.map((map) => _devotionalFromMap(map)).toList();
  }

  /// Get current streak (consecutive days of completed devotionals)
  Future<int> getStreakCount() async {
    final completedDevotionals = await getCompletedDevotionals();

    if (completedDevotionals.isEmpty) {
      return 0;
    }

    // Sort by scheduled date descending (most recent first)
    final sortedDevotionals = List<Devotional>.from(completedDevotionals)
      ..sort((a, b) {
        final dateA = a.date;
        final dateB = b.date;
        return dateB.compareTo(dateA);
      });

    // Calculate streak by counting consecutive days
    int streak = 0;
    DateTime? lastScheduledDate;

    for (final devotional in sortedDevotionals) {
      final scheduledDate = devotional.date;

      final scheduledDay = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      if (lastScheduledDate == null) {
        // First devotional in the list
        lastScheduledDate = scheduledDay;
        streak = 1;
      } else {
        // Check if this devotional's scheduled date was the day before the last one
        final expectedDate = lastScheduledDate.subtract(const Duration(days: 1));

        if (scheduledDay.year == expectedDate.year &&
            scheduledDay.month == expectedDate.month &&
            scheduledDay.day == expectedDate.day) {
          // Consecutive day found
          streak++;
          lastScheduledDate = scheduledDay;
        } else if (scheduledDay.year == lastScheduledDate.year &&
                   scheduledDay.month == lastScheduledDate.month &&
                   scheduledDay.day == lastScheduledDate.day) {
          // Same day, don't increment streak but continue
          continue;
        } else {
          // Gap found, break the streak counting
          break;
        }
      }
    }

    // Check if the streak is still "active"
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (sortedDevotionals.isNotEmpty) {
      // Check both the most recent and earliest devotionals in the streak
      final mostRecentDate = sortedDevotionals.first.date;
      final mostRecentDay = DateTime(mostRecentDate.year, mostRecentDate.month, mostRecentDate.day);

      // Days from today (positive = past, negative = future)
      final daysDiffFromMostRecent = today.difference(mostRecentDay).inDays;

      // Reject if the most recent completed devotional's scheduled date is:
      // - More than 1 day in the past (> 1): Streak is inactive/broken
      //
      // Allow completing future devotionals (people can be proactive)
      if (daysDiffFromMostRecent > 1) {
        return 0;
      }

      // Also check the earliest devotional in the streak
      if (lastScheduledDate != null) {
        final daysSinceEarliest = today.difference(lastScheduledDate).inDays;

        // The earliest devotional must not be too far in the past
        if (daysSinceEarliest > 1) {
          return 0;
        }
      }
    }

    return streak;
  }

  /// Get completion percentage (0.0 to 1.0)
  Future<double> getCompletionPercentage() async {
    final db = await _database.database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM devotionals',
    );
    final total = totalResult.first['count'] as int? ?? 0;

    if (total == 0) {
      return 0.0;
    }

    final completedCount = await getTotalCompleted();
    return completedCount / total;
  }

  /// Get all devotionals with their completion status
  Future<List<Devotional>> getAllDevotionals() async {
    final db = await _database.database;

    final maps = await db.query(
      'devotionals',
      orderBy: 'date ASC',
    );

    return maps.map((map) => _devotionalFromMap(map)).toList();
  }

  /// Get today's devotional
  Future<Devotional?> getTodaysDevotional() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _database.database;
    final maps = await db.query(
      'devotionals',
      where: 'date >= ? AND date < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return _devotionalFromMap(maps.first);
    }
    return null;
  }

  /// Helper method to convert database map to Devotional object
  Devotional _devotionalFromMap(Map<String, dynamic> map) {
    return Devotional(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      content: map['content'] as String,
      verse: map['verse'] as String,
      verseReference: map['verse_reference'] as String,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      readingTime: map['reading_time'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      completedDate: map['completed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_date'] as int)
          : null,
    );
  }
}
