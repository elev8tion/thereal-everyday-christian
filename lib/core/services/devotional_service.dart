import '../models/devotional.dart';
import 'database_service.dart';

class DevotionalService {
  final DatabaseService _database;

  DevotionalService(this._database);

  Future<List<Devotional>> getAllDevotionals() async {
    final db = await _database.database;
    final maps = await db.query(
      'devotionals',
      orderBy: 'date ASC',
    );
    return maps.map((map) => _devotionalFromMap(map)).toList();
  }

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

  Future<void> markDevotionalCompleted(String id) async {
    final db = await _database.database;
    await db.update(
      'devotionals',
      {
        'is_completed': 1,
        'completed_date': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markDevotionalIncomplete(String id) async {
    final db = await _database.database;
    await db.update(
      'devotionals',
      {
        'is_completed': 0,
        'completed_date': null,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getCompletedCount() async {
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM devotionals WHERE is_completed = 1',
    );
    return result.first['count'] as int;
  }

  Future<int> getCurrentStreak() async {
    final devotionals = await getCompletedDevotionals();
    if (devotionals.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final devotional in devotionals) {
      if (devotional.completedDate == null) continue;

      final completedDate = devotional.completedDate!;
      final dayOnly = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      if (lastDate == null) {
        lastDate = dayOnly;
        streak = 1;
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (dayOnly == expectedDate) {
          streak++;
          lastDate = dayOnly;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Devotional _devotionalFromMap(Map<String, dynamic> map) {
    return Devotional(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      content: map['content'],
      verse: map['verse'],
      verseReference: map['verse_reference'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      readingTime: map['reading_time'],
      isCompleted: map['is_completed'] == 1,
      completedDate: map['completed_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completed_date'])
          : null,
    );
  }
}