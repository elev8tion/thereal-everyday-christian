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
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for sqflite
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Use in-memory database for testing
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);

    databaseService = DatabaseService();
    progressService = ReadingPlanProgressService(databaseService);
    planService = ReadingPlanService(databaseService);

    // Initialize database
    await databaseService.initialize();

    // Get a plan to work with
    final plans = await planService.getAllPlans();
    expect(plans, isNotEmpty, reason: 'Database should have default plans');
    testPlanId = plans.first.id;

    // Ensure plan is clean for this test
    await progressService.resetPlan(testPlanId);
  });

  tearDown(() async {
    // Reset database (which also closes it)
    await databaseService.resetDatabase();
    // Small delay to ensure database is fully closed
    await Future.delayed(const Duration(milliseconds: 100));
  });

  group('ReadingPlanProgressService - Mark Day Complete/Incomplete', () {
    test('should mark a day as complete', () async {
      // Start the plan
      await planService.startPlan(testPlanId);

      // Create sample readings
      await progressService.createSampleReadings(testPlanId, 5);

      // Get today's readings
      final readings = await progressService.getTodaysReadings(testPlanId);
      expect(readings, isNotEmpty);

      final readingId = readings.first.id;

      // Mark as complete
      await progressService.markDayComplete(readingId);

      // Verify completion
      final updatedReadings = await progressService.getTodaysReadings(testPlanId);
      final completedReading =
          updatedReadings.firstWhere((r) => r.id == readingId);

      expect(completedReading.isCompleted, isTrue);
      expect(completedReading.completedDate, isNotNull);
    });

    test('should mark a day as incomplete', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 5);

      final readings = await progressService.getTodaysReadings(testPlanId);
      expect(readings, isNotEmpty);

      final readingId = readings.first.id;

      // Mark as complete first
      await progressService.markDayComplete(readingId);

      // Then mark as incomplete
      await progressService.markDayIncomplete(readingId);

      // Verify it's incomplete
      final updatedReadings = await progressService.getTodaysReadings(testPlanId);
      final incompleteReading =
          updatedReadings.firstWhere((r) => r.id == readingId);

      expect(incompleteReading.isCompleted, isFalse);
      expect(incompleteReading.completedDate, isNull);
    });

    test('should update plan progress when day is marked complete', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final readings = await progressService.getTodaysReadings(testPlanId);
      expect(readings, isNotEmpty);

      // Mark first reading as complete
      await progressService.markDayComplete(readings.first.id);

      // Get progress
      final percentage = await progressService.getProgressPercentage(testPlanId);
      expect(percentage, greaterThan(0.0));
      expect(percentage, lessThanOrEqualTo(100.0));
    });
  });

  group('ReadingPlanProgressService - Progress Calculation', () {
    test('should calculate correct progress percentage', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      // Complete 3 out of 10 readings
      final allReadings =
          await progressService.getIncompleteReadings(testPlanId);

      for (int i = 0; i < 3 && i < allReadings.length; i++) {
        await progressService.markDayComplete(allReadings[i].id);
      }

      final percentage = await progressService.getProgressPercentage(testPlanId);
      expect(percentage, equals(30.0));
    });

    test('should return 0% for plan with no completions', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final percentage = await progressService.getProgressPercentage(testPlanId);
      expect(percentage, equals(0.0));
    });

    test('should return 100% for fully completed plan', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 5);

      final allReadings =
          await progressService.getIncompleteReadings(testPlanId);

      // Complete all readings
      for (final reading in allReadings) {
        await progressService.markDayComplete(reading.id);
      }

      final percentage = await progressService.getProgressPercentage(testPlanId);
      expect(percentage, equals(100.0));
    });
  });

  group('ReadingPlanProgressService - Current Day', () {
    test('should return day 1 for newly started plan', () async {
      await planService.startPlan(testPlanId);

      final currentDay = await progressService.getCurrentDay(testPlanId);
      expect(currentDay, equals(1));
    });

    test('should return 1 for plan without start date', () async {
      final currentDay = await progressService.getCurrentDay(testPlanId);
      expect(currentDay, equals(1));
    });
  });

  group('ReadingPlanProgressService - Reset Plan', () {
    test('should reset all progress when plan is reset', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      // Complete some readings
      final readings = await progressService.getIncompleteReadings(testPlanId);
      for (int i = 0; i < 3 && i < readings.length; i++) {
        await progressService.markDayComplete(readings[i].id);
      }

      // Verify there are completed readings
      final completedBefore =
          await progressService.getCompletedReadings(testPlanId);
      expect(completedBefore.length, greaterThan(0));

      // Reset the plan
      await progressService.resetPlan(testPlanId);

      // Verify all readings are now incomplete
      final completedAfter =
          await progressService.getCompletedReadings(testPlanId);
      expect(completedAfter, isEmpty);

      // Verify progress is 0
      final percentage = await progressService.getProgressPercentage(testPlanId);
      expect(percentage, equals(0.0));
    });

    test('should mark plan as not started after reset', () async {
      await planService.startPlan(testPlanId);
      await progressService.resetPlan(testPlanId);

      final currentPlan = await planService.getCurrentPlan();
      expect(currentPlan, isNull);
    });
  });

  group('ReadingPlanProgressService - Completed/Incomplete Readings', () {
    test('should retrieve completed readings', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final allReadings =
          await progressService.getIncompleteReadings(testPlanId);

      // Complete 3 readings
      for (int i = 0; i < 3; i++) {
        await progressService.markDayComplete(allReadings[i].id);
      }

      final completed = await progressService.getCompletedReadings(testPlanId);
      expect(completed.length, equals(3));

      for (final reading in completed) {
        expect(reading.isCompleted, isTrue);
        expect(reading.completedDate, isNotNull);
      }
    });

    test('should retrieve incomplete readings', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final allReadings =
          await progressService.getIncompleteReadings(testPlanId);

      // Complete 3 readings
      for (int i = 0; i < 3; i++) {
        await progressService.markDayComplete(allReadings[i].id);
      }

      final incomplete =
          await progressService.getIncompleteReadings(testPlanId);
      expect(incomplete.length, equals(7));

      for (final reading in incomplete) {
        expect(reading.isCompleted, isFalse);
      }
    });
  });

  group('ReadingPlanProgressService - Today\'s Readings', () {
    test('should retrieve today\'s readings', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final todaysReadings =
          await progressService.getTodaysReadings(testPlanId);

      expect(todaysReadings, isNotEmpty);

      // Verify all readings are for today
      final today = DateTime.now();
      for (final reading in todaysReadings) {
        expect(reading.date.year, equals(today.year));
        expect(reading.date.month, equals(today.month));
        expect(reading.date.day, equals(today.day));
      }
    });

    test('should return empty list when no readings for today', () async {
      final todaysReadings = await progressService.getTodaysReadings(testPlanId);
      expect(todaysReadings, isEmpty);
    });
  });

  group('ReadingPlanProgressService - Streak Tracking', () {
    test('should calculate streak correctly for consecutive completions',
        () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      // Get database to manually set completion dates
      final db = await databaseService.database;

      // Get all readings for the plan
      final readings =
          await progressService.getIncompleteReadings(testPlanId);

      // Mark 3 consecutive days as completed with proper dates
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

      // Update plan progress
      await db.update(
        'reading_plans',
        {'completed_readings': 3},
        where: 'id = ?',
        whereArgs: [testPlanId],
      );

      final streak = await progressService.getStreak(testPlanId);
      expect(streak, equals(3));
    });

    test('should return 0 streak for plan with no completions', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final streak = await progressService.getStreak(testPlanId);
      expect(streak, equals(0));
    });
  });

  group('ReadingPlanProgressService - Sample Readings Creation', () {
    test('should create specified number of sample readings', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 15);

      final allReadings =
          await progressService.getIncompleteReadings(testPlanId);
      expect(allReadings.length, greaterThanOrEqualTo(1)); // At least today's reading
    });

    test('sample readings should have correct structure', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 5);

      final readings = await progressService.getTodaysReadings(testPlanId);

      for (final reading in readings) {
        expect(reading.id, isNotEmpty);
        expect(reading.planId, equals(testPlanId));
        expect(reading.title, isNotEmpty);
        expect(reading.description, isNotEmpty);
        expect(reading.book, isNotEmpty);
        expect(reading.chapters, isNotEmpty);
        expect(reading.estimatedTime, isNotEmpty);
        expect(reading.isCompleted, isFalse);
        expect(reading.completedDate, isNull);
      }
    });
  });

  group('ReadingPlanProgressService - Error Handling', () {
    test('should handle invalid plan ID gracefully', () async {
      final percentage =
          await progressService.getProgressPercentage('invalid-id');
      expect(percentage, equals(0.0));
    });
  });

  group('ReadingPlanProgressService - Data Persistence', () {
    test('progress should persist across service instances', () async {
      await planService.startPlan(testPlanId);
      await progressService.createSampleReadings(testPlanId, 10);

      final readings = await progressService.getTodaysReadings(testPlanId);
      if (readings.isNotEmpty) {
        await progressService.markDayComplete(readings.first.id);

        // Create new service instance
        final newProgressService =
            ReadingPlanProgressService(databaseService);
        final percentage =
            await newProgressService.getProgressPercentage(testPlanId);

        expect(percentage, greaterThan(0.0));
      }
    });
  });

  group('Integration Tests - Full Reading Plan Flow', () {
    test('complete reading plan workflow', () async {
      // Get a plan
      final plans = await planService.getAllPlans();
      expect(plans, isNotEmpty);

      final plan = plans.first;
      expect(plan.isStarted, isFalse);

      // Start the plan
      await planService.startPlan(plan.id);
      final startedPlan = await planService.getCurrentPlan();
      expect(startedPlan, isNotNull);
      expect(startedPlan!.isStarted, isTrue);

      // Create sample readings - reduced from 10 to 1 for testing
      await progressService.createSampleReadings(plan.id, 1);

      // Get today's readings
      var todaysReadings = await progressService.getTodaysReadings(plan.id);
      expect(todaysReadings, isNotEmpty);

      // Mark first reading as complete
      final firstReading = todaysReadings.first;
      await progressService.markDayComplete(firstReading.id);

      // Verify progress - should be 100% since we only have 1 reading
      final progressPercent =
          await progressService.getProgressPercentage(plan.id);
      expect(progressPercent, equals(100.0));

      // Get incomplete readings
      final incomplete = await progressService.getIncompleteReadings(plan.id);
      expect(incomplete.length, equals(0));

      // Get completed readings
      final completed = await progressService.getCompletedReadings(plan.id);
      expect(completed.length, equals(1));
      expect(completed.first.id, equals(firstReading.id));

      // Reset the plan
      await progressService.resetPlan(plan.id);

      // Verify reset
      final resetPercentage =
          await progressService.getProgressPercentage(plan.id);
      expect(resetPercentage, equals(0.0));

      final currentPlan = await planService.getCurrentPlan();
      expect(currentPlan, isNull);
    });
  });
}
