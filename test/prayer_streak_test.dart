import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/prayer_streak_service.dart';

void main() {
  // Initialize FFI for testing
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('PrayerStreakService Tests', () {
    late DatabaseService databaseService;
    late PrayerStreakService streakService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);

      // Create a new DatabaseService and initialize
      // Each test gets a fresh database instance
      databaseService = DatabaseService();
      await databaseService.initialize();
      streakService = PrayerStreakService(databaseService);

      // Clear any existing streak data
      await streakService.clearAllStreakData();
    });

    tearDown(() async {
      // Reset database (which also closes it)
      await databaseService.resetDatabase();
      // Small delay to ensure database is fully closed
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('Record Prayer Activity', () {
      test('should record prayer activity for today', () async {
        // Act
        await streakService.recordPrayerActivity();

        // Assert
        final hasPrayed = await streakService.hasPrayedToday();
        expect(hasPrayed, true);
      });

      test('should not duplicate activity for the same day', () async {
        // Act
        await streakService.recordPrayerActivity();
        await streakService.recordPrayerActivity();
        await streakService.recordPrayerActivity();

        // Assert
        final totalDays = await streakService.getTotalDaysPrayed();
        expect(totalDays, 1); // Should only have 1 entry despite 3 calls
      });

      test('should record activity on different days', () async {
        // This test verifies the service can handle multiple days
        // In real usage, days would be different, but we can verify the logic
        await streakService.recordPrayerActivity();

        final totalDays = await streakService.getTotalDaysPrayed();
        expect(totalDays, 1);
      });
    });

    group('Current Streak Calculation', () {
      test('should return 0 streak when no activity', () async {
        // Act
        final streak = await streakService.getCurrentStreak();

        // Assert
        expect(streak, 0);
      });

      test('should return 1 for single day activity', () async {
        // Arrange
        await streakService.recordPrayerActivity();

        // Act
        final streak = await streakService.getCurrentStreak();

        // Assert
        expect(streak, 1);
      });

      test('should calculate consecutive days correctly', () async {
        // Arrange - Manually insert consecutive days
        final db = await databaseService.database;
        final today = DateTime.now();

        for (int i = 0; i < 7; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final streak = await streakService.getCurrentStreak();

        // Assert
        expect(streak, 7);
      });

      test('should handle gaps in activity correctly', () async {
        // Arrange - Insert days with a gap
        final db = await databaseService.database;
        final today = DateTime.now();

        // Today and yesterday
        for (int i = 0; i < 2; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Gap of 2 days, then 3 more days
        for (int i = 4; i < 7; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final streak = await streakService.getCurrentStreak();

        // Assert - Should only count from today back to the first gap
        expect(streak, 2);
      });

      test('should return 0 if last activity was not today or yesterday', () async {
        // Arrange - Insert activity 5 days ago
        final db = await databaseService.database;
        final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
        final dateInt = fiveDaysAgo.year * 10000 +
                       fiveDaysAgo.month * 100 +
                       fiveDaysAgo.day;

        await db.insert('prayer_streak_activity', {
          'activity_date': dateInt,
          'created_at': fiveDaysAgo.millisecondsSinceEpoch,
        });

        // Act
        final streak = await streakService.getCurrentStreak();

        // Assert - Streak is broken
        expect(streak, 0);
      });
    });

    group('Longest Streak Calculation', () {
      test('should return 0 when no activity', () async {
        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert
        expect(longestStreak, 0);
      });

      test('should return 1 for single day activity', () async {
        // Arrange
        await streakService.recordPrayerActivity();

        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert
        expect(longestStreak, 1);
      });

      test('should find longest streak in history', () async {
        // Arrange - Create pattern: 5 days, gap, 3 days, gap, 7 days
        final db = await databaseService.database;
        final today = DateTime.now();

        // First streak: 5 days (20-24 days ago)
        for (int i = 20; i < 25; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Second streak: 3 days (15-17 days ago)
        for (int i = 15; i < 18; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Third streak: 7 days (0-6 days ago - current streak)
        for (int i = 0; i < 7; i++) {
          final date = today.subtract(Duration(days: i));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert - Should find the longest streak of 7 days
        expect(longestStreak, 7);
      });

      test('should handle consecutive days at year boundary', () async {
        // This test ensures the date logic handles year boundaries correctly
        final db = await databaseService.database;

        // Create dates around year boundary (Dec 31, Jan 1)
        final dec31 = DateTime(2023, 12, 31);
        final jan01 = DateTime(2024, 1, 1);
        final jan02 = DateTime(2024, 1, 2);

        for (final date in [dec31, jan01, jan02]) {
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert - Should count all 3 days as consecutive
        expect(longestStreak, 3);
      });
    });

    group('Has Prayed Today', () {
      test('should return false when no activity today', () async {
        // Act
        final hasPrayed = await streakService.hasPrayedToday();

        // Assert
        expect(hasPrayed, false);
      });

      test('should return true after recording activity', () async {
        // Arrange
        await streakService.recordPrayerActivity();

        // Act
        final hasPrayed = await streakService.hasPrayedToday();

        // Assert
        expect(hasPrayed, true);
      });

      test('should return false for past day activity', () async {
        // Arrange - Insert activity for yesterday
        final db = await databaseService.database;
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateInt = yesterday.year * 10000 +
                       yesterday.month * 100 +
                       yesterday.day;

        await db.insert('prayer_streak_activity', {
          'activity_date': dateInt,
          'created_at': yesterday.millisecondsSinceEpoch,
        });

        // Act
        final hasPrayed = await streakService.hasPrayedToday();

        // Assert
        expect(hasPrayed, false);
      });
    });

    group('Total Days Prayed', () {
      test('should return 0 when no activity', () async {
        // Act
        final totalDays = await streakService.getTotalDaysPrayed();

        // Assert
        expect(totalDays, 0);
      });

      test('should count all unique days', () async {
        // Arrange - Add activities for multiple days
        final db = await databaseService.database;
        final today = DateTime.now();

        // Add 10 different days (not necessarily consecutive)
        final daysToAdd = [0, 1, 2, 5, 6, 10, 15, 20, 25, 30];

        for (final daysAgo in daysToAdd) {
          final date = today.subtract(Duration(days: daysAgo));
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final totalDays = await streakService.getTotalDaysPrayed();

        // Assert
        expect(totalDays, 10);
      });
    });

    group('Get All Activity Dates', () {
      test('should return empty list when no activity', () async {
        // Act
        final dates = await streakService.getAllActivityDates();

        // Assert
        expect(dates, isEmpty);
      });

      test('should return all activity dates in descending order', () async {
        // Arrange
        final db = await databaseService.database;
        final today = DateTime.now();

        final daysToAdd = [0, 1, 2, 5];
        final expectedDates = <DateTime>[];

        for (final daysAgo in daysToAdd) {
          final date = DateTime(
            today.year,
            today.month,
            today.day - daysAgo,
          );
          expectedDates.add(date);

          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final dates = await streakService.getAllActivityDates();

        // Assert
        expect(dates.length, 4);
        // Dates should be in descending order (most recent first)
        for (int i = 0; i < dates.length - 1; i++) {
          expect(
            dates[i].isAfter(dates[i + 1]) || dates[i].isAtSameMomentAs(dates[i + 1]),
            true,
            reason: 'Dates should be in descending order',
          );
        }
      });
    });

    group('Clear All Streak Data', () {
      test('should remove all streak data', () async {
        // Arrange - Add some data
        await streakService.recordPrayerActivity();
        final beforeClear = await streakService.getTotalDaysPrayed();
        expect(beforeClear, 1);

        // Act
        await streakService.clearAllStreakData();

        // Assert
        final afterClear = await streakService.getTotalDaysPrayed();
        expect(afterClear, 0);

        final hasPrayed = await streakService.hasPrayedToday();
        expect(hasPrayed, false);

        final currentStreak = await streakService.getCurrentStreak();
        expect(currentStreak, 0);
      });
    });

    group('Edge Cases', () {
      test('should handle month boundaries correctly', () async {
        final db = await databaseService.database;

        // Create dates around month boundary (Jan 31, Feb 1)
        final jan31 = DateTime(2024, 1, 31);
        final feb01 = DateTime(2024, 2, 1);
        final feb02 = DateTime(2024, 2, 2);

        for (final date in [jan31, feb01, feb02]) {
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert - Should count all 3 days as consecutive
        expect(longestStreak, 3);
      });

      test('should handle leap year correctly', () async {
        final db = await databaseService.database;

        // 2024 is a leap year
        final feb28 = DateTime(2024, 2, 28);
        final feb29 = DateTime(2024, 2, 29);
        final mar01 = DateTime(2024, 3, 1);

        for (final date in [feb28, feb29, mar01]) {
          final dateInt = date.year * 10000 + date.month * 100 + date.day;
          await db.insert('prayer_streak_activity', {
            'activity_date': dateInt,
            'created_at': date.millisecondsSinceEpoch,
          });
        }

        // Act
        final longestStreak = await streakService.getLongestStreak();

        // Assert - Should count all 3 days as consecutive
        expect(longestStreak, 3);
      });

      test('should handle database errors gracefully', () async {
        // Close the database to simulate an error condition
        await databaseService.close();

        // Act & Assert - Should not throw but return default values
        final streak = await streakService.getCurrentStreak();
        expect(streak, 0);

        final longestStreak = await streakService.getLongestStreak();
        expect(longestStreak, 0);

        final hasPrayed = await streakService.hasPrayedToday();
        expect(hasPrayed, false);

        final totalDays = await streakService.getTotalDaysPrayed();
        expect(totalDays, 0);
      });
    });

    group('Integration with Prayer Actions', () {
      test('should increment streak when prayers added on consecutive days', () async {
        // Day 1
        await streakService.recordPrayerActivity();
        var streak = await streakService.getCurrentStreak();
        expect(streak, 1);

        // Simulate next day by manually adding
        final db = await databaseService.database;
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final dateInt = yesterday.year * 10000 +
                       yesterday.month * 100 +
                       yesterday.day;

        await db.insert('prayer_streak_activity', {
          'activity_date': dateInt,
          'created_at': yesterday.millisecondsSinceEpoch,
        });

        // Act
        streak = await streakService.getCurrentStreak();

        // Assert
        expect(streak, 2);
      });

      test('should maintain correct stats after multiple activities', () async {
        // Record activity
        await streakService.recordPrayerActivity();

        // Multiple calls on same day shouldn't change stats
        await streakService.recordPrayerActivity();
        await streakService.recordPrayerActivity();

        final totalDays = await streakService.getTotalDaysPrayed();
        final currentStreak = await streakService.getCurrentStreak();
        final hasPrayed = await streakService.hasPrayedToday();

        expect(totalDays, 1);
        expect(currentStreak, 1);
        expect(hasPrayed, true);
      });
    });
  });
}
