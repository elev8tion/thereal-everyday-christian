import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/reading_plan_progress_service.dart';
import 'package:everyday_christian/core/services/reading_plan_service.dart';

void main() {
  late DatabaseService databaseService;
  late ReadingPlanProgressService progressService;
  late ReadingPlanService planService;
  late String testPlanId;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);

    databaseService = DatabaseService();
    progressService = ReadingPlanProgressService(databaseService);
    planService = ReadingPlanService(databaseService);

    await databaseService.initialize();

    final plans = await planService.getAllPlans();
    expect(plans, isNotEmpty, reason: 'Database should have default plans');
    testPlanId = plans.first.id;

    await progressService.resetPlan(testPlanId);
  });

  tearDown(() async {
    await databaseService.resetDatabase();
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('Enhanced Progress Tracking - Calendar Heatmap', () {
    test('should return empty heatmap for new plan', () async {
      await planService.startPlan(testPlanId);

      final heatmapData = await progressService.getCalendarHeatmapData(testPlanId);

      expect(heatmapData, isEmpty);
    });

    test('should track completed readings in heatmap', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 5);

      // Get today's readings
      final readings = await progressService.getTodaysReadings(testPlanId);
      expect(readings, isNotEmpty);

      // Mark first reading as complete
      await progressService.markDayComplete(readings.first.id);

      final heatmapData = await progressService.getCalendarHeatmapData(testPlanId);

      // Should have at least one entry for today
      expect(heatmapData, isNotEmpty);

      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      expect(heatmapData.containsKey(normalizedToday), isTrue);
      expect(heatmapData[normalizedToday], equals(1));
    });

    test('should aggregate multiple completions on same day', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final readings = await progressService.getTodaysReadings(testPlanId);

      // Mark all today's readings as complete
      for (final reading in readings) {
        await progressService.markDayComplete(reading.id);
      }

      final heatmapData = await progressService.getCalendarHeatmapData(testPlanId);

      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      expect(heatmapData[normalizedToday], equals(readings.length));
    });

    test('should only include data within specified days range', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final readings = await progressService.getTodaysReadings(testPlanId);
      if (readings.isNotEmpty) {
        await progressService.markDayComplete(readings.first.id);
      }

      // Get last 7 days only
      final heatmapData = await progressService.getCalendarHeatmapData(
        testPlanId,
        days: 7,
      );

      // All dates should be within last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      for (final date in heatmapData.keys) {
        expect(date.isAfter(sevenDaysAgo), isTrue);
        expect(date.isBefore(now) || date.isAtSameMomentAs(now), isTrue);
      }
    });
  });

  group('Enhanced Progress Tracking - Completion Stats', () {
    test('should return comprehensive statistics', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 20);

      // Complete 5 readings
      final readings = await progressService.getIncompleteReadings(testPlanId);
      for (int i = 0; i < 5 && i < readings.length; i++) {
        await progressService.markDayComplete(readings[i].id);
      }

      final stats = await progressService.getCompletionStats(testPlanId);

      expect(stats, isNotNull);
      expect(stats.containsKey('total_readings'), isTrue);
      expect(stats.containsKey('completed_readings'), isTrue);
      expect(stats.containsKey('incomplete_readings'), isTrue);
      expect(stats.containsKey('progress_percentage'), isTrue);
      expect(stats.containsKey('current_streak'), isTrue);
      expect(stats.containsKey('longest_streak'), isTrue);
      expect(stats.containsKey('total_days_active'), isTrue);
      expect(stats.containsKey('average_per_day'), isTrue);

      expect(stats['total_readings'], greaterThan(0));
      expect(stats['completed_readings'], equals(5));
      expect(stats['incomplete_readings'], equals(stats['total_readings'] - 5));
      expect(stats['progress_percentage'], greaterThan(0.0));
    });

    test('should calculate correct progress percentage', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      // Complete 3 out of 10
      final readings = await progressService.getIncompleteReadings(testPlanId);
      for (int i = 0; i < 3; i++) {
        await progressService.markDayComplete(readings[i].id);
      }

      final stats = await progressService.getCompletionStats(testPlanId);

      expect(stats['progress_percentage'], closeTo(30.0, 0.1));
    });

    test('should track current and longest streak', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final db = await databaseService.database;
      final readings = await progressService.getIncompleteReadings(testPlanId);

      // Create a 3-day streak
      final now = DateTime.now();
      for (int i = 0; i < 3; i++) {
        final completionDate = now.subtract(Duration(days: 2 - i));
        await db.update(
          'daily_readings',
          {
            'is_completed': 1,
            'completed_date': completionDate.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [readings[i].id],
        );
      }

      await db.update(
        'reading_plans',
        {'completed_readings': 3},
        where: 'id = ?',
        whereArgs: [testPlanId],
      );

      final stats = await progressService.getCompletionStats(testPlanId);

      expect(stats['current_streak'], equals(3));
      expect(stats['longest_streak'], equals(3));
    });
  });

  group('Enhanced Progress Tracking - Missed Days', () {
    test('should identify missed days', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create readings for the past 5 days
      for (int i = 5; i > 0; i--) {
        final date = now.subtract(Duration(days: i));
        await db.insert('daily_readings', {
          'id': 'reading_$i',
          'plan_id': testPlanId,
          'title': 'Reading Day $i',
          'description': 'Test reading',
          'book': 'Genesis',
          'chapters': '$i',
          'estimated_time': '5 minutes',
          'date': date.millisecondsSinceEpoch,
          'is_completed': 0,
        });
      }

      final missedDays = await progressService.getMissedDays(testPlanId);

      // All 5 days should be missed
      expect(missedDays.length, equals(5));
    });

    test('should not include completed readings as missed', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create readings for the past 3 days
      for (int i = 3; i > 0; i--) {
        final date = now.subtract(Duration(days: i));
        final isCompleted = i == 2; // Complete day 2 only

        await db.insert('daily_readings', {
          'id': 'reading_$i',
          'plan_id': testPlanId,
          'title': 'Reading Day $i',
          'description': 'Test reading',
          'book': 'Genesis',
          'chapters': '$i',
          'estimated_time': '5 minutes',
          'date': date.millisecondsSinceEpoch,
          'is_completed': isCompleted ? 1 : 0,
          'completed_date': isCompleted ? date.millisecondsSinceEpoch : null,
        });
      }

      final missedDays = await progressService.getMissedDays(testPlanId);

      // Only 2 days should be missed (days 1 and 3)
      expect(missedDays.length, equals(2));
    });

    test('should not include future readings as missed', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create a future reading
      final futureDate = now.add(const Duration(days: 3));
      await db.insert('daily_readings', {
        'id': 'future_reading',
        'plan_id': testPlanId,
        'title': 'Future Reading',
        'description': 'Test reading',
        'book': 'Genesis',
        'chapters': '1',
        'estimated_time': '5 minutes',
        'date': futureDate.millisecondsSinceEpoch,
        'is_completed': 0,
      });

      final missedDays = await progressService.getMissedDays(testPlanId);

      // Should be empty since the reading is in the future
      expect(missedDays, isEmpty);
    });
  });

  group('Enhanced Progress Tracking - Weekly Completion Rate', () {
    test('should calculate weekly completion rate', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create 7 readings for the past week
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        await db.insert('daily_readings', {
          'id': 'reading_$i',
          'plan_id': testPlanId,
          'title': 'Reading Day $i',
          'description': 'Test reading',
          'book': 'Genesis',
          'chapters': '${i + 1}',
          'estimated_time': '5 minutes',
          'date': date.millisecondsSinceEpoch,
          'is_completed': 0,
        });
      }

      // Complete 5 out of 7
      for (int i = 0; i < 5; i++) {
        await planService.markReadingCompleted('reading_$i');
      }

      final rate = await progressService.getWeeklyCompletionRate(testPlanId);

      expect(rate, closeTo(71.4, 0.5)); // 5/7 ≈ 71.4%
    });

    test('should return 0% for week with no readings', () async {
      await planService.startPlan(testPlanId);

      final rate = await progressService.getWeeklyCompletionRate(testPlanId);

      expect(rate, equals(0.0));
    });

    test('should return 100% for fully completed week', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create and complete all 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        await db.insert('daily_readings', {
          'id': 'reading_$i',
          'plan_id': testPlanId,
          'title': 'Reading Day $i',
          'description': 'Test reading',
          'book': 'Genesis',
          'chapters': '${i + 1}',
          'estimated_time': '5 minutes',
          'date': date.millisecondsSinceEpoch,
          'is_completed': 1,
          'completed_date': date.millisecondsSinceEpoch,
        });
      }

      final rate = await progressService.getWeeklyCompletionRate(testPlanId);

      expect(rate, equals(100.0));
    });
  });

  group('Enhanced Progress Tracking - Estimated Completion Date', () {
    test('should return null for plan with no progress', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final estimatedDate =
          await progressService.getEstimatedCompletionDate(testPlanId);

      expect(estimatedDate, isNull);
    });

    test('should return null for newly started plan', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      // Complete one reading right away
      final readings = await progressService.getTodaysReadings(testPlanId);
      if (readings.isNotEmpty) {
        await progressService.markDayComplete(readings.first.id);
      }

      final estimatedDate =
          await progressService.getEstimatedCompletionDate(testPlanId);

      expect(estimatedDate, isNull);
    });

    test('should calculate estimated date based on current pace', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;

      // Create 10 total readings
      await progressService.createSampleReadings(testPlanId, 10);

      // Simulate completing 5 readings over 5 days (1 per day)
      final now = DateTime.now();
      final readings = await progressService.getIncompleteReadings(testPlanId);

      for (int i = 0; i < 5; i++) {
        final completionDate = now.subtract(Duration(days: 5 - i));
        await db.update(
          'daily_readings',
          {
            'is_completed': 1,
            'completed_date': completionDate.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [readings[i].id],
        );
      }

      // Update start date to 5 days ago
      await db.update(
        'reading_plans',
        {'start_date': now.subtract(const Duration(days: 5)).millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [testPlanId],
      );

      final estimatedDate =
          await progressService.getEstimatedCompletionDate(testPlanId);

      expect(estimatedDate, isNotNull);

      // At 1 reading per day, 5 remaining readings should take 5 days
      final expectedDate = now.add(const Duration(days: 5));

      // Allow 1 day margin for rounding
      final daysDifference =
          estimatedDate!.difference(expectedDate).inDays.abs();
      expect(daysDifference, lessThanOrEqualTo(1));
    });
  });

  group('Enhanced Progress Tracking - Longest Streak Calculation', () {
    test('should track longest streak correctly', () async {
      await planService.startPlan(testPlanId);

      final db = await databaseService.database;
      final now = DateTime.now();

      // Create readings
      await progressService.createSampleReadings(testPlanId, 15);
      final readings = await progressService.getIncompleteReadings(testPlanId);

      // Create first streak of 3 days (10-12 days ago)
      for (int i = 0; i < 3; i++) {
        final date = now.subtract(Duration(days: 12 - i));
        await db.update(
          'daily_readings',
          {
            'is_completed': 1,
            'completed_date': date.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [readings[i].id],
        );
      }

      // Gap of 2 days

      // Create second streak of 5 days (5-9 days ago)
      for (int i = 3; i < 8; i++) {
        final date = now.subtract(Duration(days: 9 - (i - 3)));
        await db.update(
          'daily_readings',
          {
            'is_completed': 1,
            'completed_date': date.millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [readings[i].id],
        );
      }

      final stats = await progressService.getCompletionStats(testPlanId);

      // Longest streak should be 5 days
      expect(stats['longest_streak'], equals(5));
    });
  });
}
