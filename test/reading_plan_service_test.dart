import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/reading_plan_service.dart';
import 'package:everyday_christian/core/models/reading_plan.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ReadingPlanService', () {
    late DatabaseService databaseService;
    late ReadingPlanService readingPlanService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
      databaseService = DatabaseService();
      readingPlanService = ReadingPlanService(databaseService);
      await databaseService.initialize();
    });

    tearDown(() async {
      DatabaseService.setTestDatabasePath(null);
    });

    group('Get Plans', () {
      test('should get all reading plans', () async {
        final plans = await readingPlanService.getAllPlans();

        expect(plans, isA<List<ReadingPlan>>());
        expect(plans.length, greaterThan(0));
      });

      test('should get active plans only', () async {
        // Start a plan first
        final allPlans = await readingPlanService.getAllPlans();
        if (allPlans.isNotEmpty) {
          await readingPlanService.startPlan(allPlans.first.id);

          final activePlans = await readingPlanService.getActivePlans();

          expect(activePlans, isA<List<ReadingPlan>>());
          expect(activePlans.length, equals(1));
          expect(activePlans.first.isStarted, isTrue);
        }
      });

      test('should get current plan', () async {
        final allPlans = await readingPlanService.getAllPlans();
        if (allPlans.isNotEmpty) {
          await readingPlanService.startPlan(allPlans.first.id);

          final currentPlan = await readingPlanService.getCurrentPlan();

          expect(currentPlan, isNotNull);
          expect(currentPlan!.id, equals(allPlans.first.id));
          expect(currentPlan.isStarted, isTrue);
        }
      });

      test('should return null when no plan is active', () async {
        // Stop all plans first
        final allPlans = await readingPlanService.getAllPlans();
        for (final plan in allPlans) {
          await readingPlanService.stopPlan(plan.id);
        }

        final currentPlan = await readingPlanService.getCurrentPlan();

        expect(currentPlan, isNull);
      });
    });

    group('Start and Stop Plans', () {
      test('should start a reading plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final planToStart = plans.first;

          await readingPlanService.startPlan(planToStart.id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(1));
          expect(activePlans.first.id, equals(planToStart.id));
          expect(activePlans.first.startDate, isNotNull);
        }
      });

      test('should stop all other plans when starting a new one', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.length >= 2) {
          // Start first plan
          await readingPlanService.startPlan(plans[0].id);

          // Start second plan (should stop first)
          await readingPlanService.startPlan(plans[1].id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(1));
          expect(activePlans.first.id, equals(plans[1].id));
        }
      });

      test('should stop a reading plan', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          // Start the plan
          await readingPlanService.startPlan(plan.id);
          expect((await readingPlanService.getActivePlans()).length, equals(1));

          // Stop the plan
          await readingPlanService.stopPlan(plan.id);

          final activePlans = await readingPlanService.getActivePlans();
          expect(activePlans.length, equals(0));
        }
      });
    });

    group('Update Progress', () {
      test('should update plan progress', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          await readingPlanService.updateProgress(plan.id, 5);

          final updatedPlans = await readingPlanService.getAllPlans();
          final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

          expect(updatedPlan.completedReadings, equals(5));
        }
      });

      test('should increment progress correctly', () async {
        final plans = await readingPlanService.getAllPlans();
        if (plans.isNotEmpty) {
          final plan = plans.first;

          await readingPlanService.updateProgress(plan.id, 3);
          await readingPlanService.updateProgress(plan.id, 7);

          final updatedPlans = await readingPlanService.getAllPlans();
          final updatedPlan = updatedPlans.firstWhere((p) => p.id == plan.id);

          expect(updatedPlan.completedReadings, equals(7));
        }
      });
    });

    group('Daily Readings', () {
      test('should get todays readings for a plan', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        await readingPlanService.startPlan(plan.id);

        // Insert a daily reading for today
        final db = await databaseService.database;
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);

        await db.insert('daily_readings', {
          'id': 'test_reading_today',
          'plan_id': plan.id,
          'title': 'Test Reading Today',
          'description': 'Today\'s reading',
          'book': 'Genesis',
          'chapters': '1-2',
          'estimated_time': '10 minutes',
          'date': startOfDay.millisecondsSinceEpoch,
          'is_completed': 0,
        });

        final todaysReadings = await readingPlanService.getTodaysReadings(plan.id);

        expect(todaysReadings, isA<List<DailyReading>>());
        expect(todaysReadings.length, greaterThan(0));
        expect(todaysReadings.first.title, equals('Test Reading Today'));
      });

      test('should get all readings for a plan', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert multiple readings with different dates
        final readings = [
          {
            'id': 'reading_1',
            'plan_id': plan.id,
            'title': 'Reading Day 1',
            'description': 'First reading',
            'book': 'Genesis',
            'chapters': '1',
            'estimated_time': '5 minutes',
            'date': DateTime(2024, 1, 1).millisecondsSinceEpoch,
            'is_completed': 0,
          },
          {
            'id': 'reading_2',
            'plan_id': plan.id,
            'title': 'Reading Day 2',
            'description': 'Second reading',
            'book': 'Genesis',
            'chapters': '2',
            'estimated_time': '5 minutes',
            'date': DateTime(2024, 1, 2).millisecondsSinceEpoch,
            'is_completed': 0,
          },
          {
            'id': 'reading_3',
            'plan_id': plan.id,
            'title': 'Reading Day 3',
            'description': 'Third reading',
            'book': 'Genesis',
            'chapters': '3',
            'estimated_time': '5 minutes',
            'date': DateTime(2024, 1, 3).millisecondsSinceEpoch,
            'is_completed': 0,
          },
        ];

        for (final reading in readings) {
          await db.insert('daily_readings', reading);
        }

        final result = await readingPlanService.getReadingsForPlan(plan.id);

        expect(result, isA<List<DailyReading>>());
        expect(result.length, greaterThanOrEqualTo(3));

        // Verify readings are ordered by date
        for (int i = 0; i < result.length - 1; i++) {
          expect(
            result[i].date.isBefore(result[i + 1].date) ||
                result[i].date.isAtSameMomentAs(result[i + 1].date),
            isTrue,
          );
        }
      });

      test('should mark reading as completed and update plan progress', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert a test reading
        await db.insert('daily_readings', {
          'id': 'test_reading_complete',
          'plan_id': plan.id,
          'title': 'Test Reading',
          'description': 'Test description',
          'book': 'Psalms',
          'chapters': '23',
          'estimated_time': '3 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 0,
        });

        // Get the count before marking complete
        final countBefore = await readingPlanService.getCompletedReadingsCount(plan.id);

        await readingPlanService.markReadingCompleted('test_reading_complete');

        // Verify reading is marked as completed
        final updatedReadings = await db.query(
          'daily_readings',
          where: 'id = ?',
          whereArgs: ['test_reading_complete'],
        );

        expect(updatedReadings.first['is_completed'], equals(1));
        expect(updatedReadings.first['completed_date'], isNotNull);

        // Verify plan progress is updated
        final countAfter = await readingPlanService.getCompletedReadingsCount(plan.id);
        expect(countAfter, equals(countBefore + 1));
      });

      test('should get completed readings count', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert multiple readings
        await db.insert('daily_readings', {
          'id': 'count_reading_1',
          'plan_id': plan.id,
          'title': 'Reading 1',
          'description': 'First',
          'book': 'Matthew',
          'chapters': '1',
          'estimated_time': '5 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 0,
        });

        await db.insert('daily_readings', {
          'id': 'count_reading_2',
          'plan_id': plan.id,
          'title': 'Reading 2',
          'description': 'Second',
          'book': 'Matthew',
          'chapters': '2',
          'estimated_time': '5 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 0,
        });

        // Mark both as complete
        await readingPlanService.markReadingCompleted('count_reading_1');
        await readingPlanService.markReadingCompleted('count_reading_2');

        final count = await readingPlanService.getCompletedReadingsCount(plan.id);

        expect(count, greaterThanOrEqualTo(2));
      });

      test('should handle marking reading with null completed_date initially', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert reading without completed_date
        await db.insert('daily_readings', {
          'id': 'null_date_reading',
          'plan_id': plan.id,
          'title': 'Null Date Test',
          'description': 'Testing null completed_date',
          'book': 'John',
          'chapters': '3:16',
          'estimated_time': '2 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 0,
          'completed_date': null,
        });

        // Verify reading has null completed_date initially
        final readingsBeforeCompletion = await readingPlanService.getReadingsForPlan(plan.id);
        final readingBeforeCompletion = readingsBeforeCompletion.firstWhere(
          (r) => r.id == 'null_date_reading',
        );
        expect(readingBeforeCompletion.completedDate, isNull);

        // Mark as completed
        await readingPlanService.markReadingCompleted('null_date_reading');

        // Verify completed_date is now set
        final readingsAfterCompletion = await readingPlanService.getReadingsForPlan(plan.id);
        final readingAfterCompletion = readingsAfterCompletion.firstWhere(
          (r) => r.id == 'null_date_reading',
        );
        expect(readingAfterCompletion.isCompleted, isTrue);
        expect(readingAfterCompletion.completedDate, isNotNull);
      });
    });

    group('Plan Model Conversion', () {
      test('should correctly convert database map to ReadingPlan', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;

        expect(plan.id, isNotEmpty);
        expect(plan.title, isNotEmpty);
        expect(plan.description, isNotEmpty);
        expect(plan.duration, isNotEmpty);
        expect(plan.category, isA<PlanCategory>());
        expect(plan.difficulty, isA<PlanDifficulty>());
        expect(plan.estimatedTimePerDay, isNotEmpty);
        expect(plan.totalReadings, greaterThan(0));
        expect(plan.completedReadings, greaterThanOrEqualTo(0));
        expect(plan.isStarted, isA<bool>());
      });

      test('should correctly convert database map to DailyReading', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert a daily reading for conversion testing
        await db.insert('daily_readings', {
          'id': 'conversion_test_reading',
          'plan_id': plan.id,
          'title': 'Conversion Test',
          'description': 'Test description',
          'book': 'Revelation',
          'chapters': '21-22',
          'estimated_time': '7 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 0,
        });

        final readings = await readingPlanService.getReadingsForPlan(plan.id);
        final reading = readings.firstWhere((r) => r.id == 'conversion_test_reading');

        expect(reading.id, equals('conversion_test_reading'));
        expect(reading.planId, equals(plan.id));
        expect(reading.title, equals('Conversion Test'));
        expect(reading.description, equals('Test description'));
        expect(reading.book, equals('Revelation'));
        expect(reading.chapters, equals('21-22'));
        expect(reading.estimatedTime, equals('7 minutes'));
        expect(reading.date, isA<DateTime>());
        expect(reading.isCompleted, isFalse);
        expect(reading.completedDate, isNull);
      });

      test('should handle unknown category with default fallback', () async {
        final db = await databaseService.database;

        // Insert a plan with an invalid/unknown category
        await db.insert('reading_plans', {
          'id': 'unknown_category_plan',
          'title': 'Unknown Category Plan',
          'description': 'Testing unknown category',
          'duration': '30 days',
          'category': 'unknownCategory', // Invalid category
          'difficulty': 'beginner',
          'estimated_time_per_day': '10 minutes',
          'total_readings': 30,
          'completed_readings': 0,
          'is_started': 0,
        });

        final plans = await readingPlanService.getAllPlans();
        final planWithUnknownCategory = plans.firstWhere(
          (p) => p.id == 'unknown_category_plan',
        );

        // Should fallback to PlanCategory.completeBible
        expect(planWithUnknownCategory.category, equals(PlanCategory.completeBible));
      });

      test('should handle unknown difficulty with default fallback', () async {
        final db = await databaseService.database;

        // Insert a plan with an invalid/unknown difficulty
        await db.insert('reading_plans', {
          'id': 'unknown_difficulty_plan',
          'title': 'Unknown Difficulty Plan',
          'description': 'Testing unknown difficulty',
          'duration': '60 days',
          'category': 'completeBible',
          'difficulty': 'unknownDifficulty', // Invalid difficulty
          'estimated_time_per_day': '15 minutes',
          'total_readings': 60,
          'completed_readings': 0,
          'is_started': 0,
        });

        final plans = await readingPlanService.getAllPlans();
        final planWithUnknownDifficulty = plans.firstWhere(
          (p) => p.id == 'unknown_difficulty_plan',
        );

        // Should fallback to PlanDifficulty.beginner
        expect(planWithUnknownDifficulty.difficulty, equals(PlanDifficulty.beginner));
      });

      test('should correctly parse plan with start_date as null', () async {
        final db = await databaseService.database;

        // Insert a plan with null start_date
        await db.insert('reading_plans', {
          'id': 'null_start_date_plan',
          'title': 'Null Start Date Plan',
          'description': 'Testing null start_date',
          'duration': '90 days',
          'category': 'completeBible',
          'difficulty': 'beginner',
          'estimated_time_per_day': '20 minutes',
          'total_readings': 90,
          'completed_readings': 0,
          'is_started': 0,
          'start_date': null,
        });

        final plans = await readingPlanService.getAllPlans();
        final plan = plans.firstWhere((p) => p.id == 'null_start_date_plan');

        // Initially plan should not have a start date
        expect(plan.startDate, isNull);
        expect(plan.isStarted, isFalse);

        // Start the plan
        await readingPlanService.startPlan(plan.id);

        // Now it should have a start date
        final updatedPlans = await readingPlanService.getAllPlans();
        final startedPlan = updatedPlans.firstWhere((p) => p.id == 'null_start_date_plan');
        expect(startedPlan.startDate, isNotNull);
        expect(startedPlan.isStarted, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple readings completed on same day', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        // Insert multiple readings for the same day
        final today = DateTime.now();
        await db.insert('daily_readings', {
          'id': 'same_day_1',
          'plan_id': plan.id,
          'title': 'Reading 1',
          'description': 'First',
          'book': 'Mark',
          'chapters': '1',
          'estimated_time': '5 minutes',
          'date': today.millisecondsSinceEpoch,
          'is_completed': 0,
        });

        await db.insert('daily_readings', {
          'id': 'same_day_2',
          'plan_id': plan.id,
          'title': 'Reading 2',
          'description': 'Second',
          'book': 'Mark',
          'chapters': '2',
          'estimated_time': '5 minutes',
          'date': today.millisecondsSinceEpoch,
          'is_completed': 0,
        });

        await db.insert('daily_readings', {
          'id': 'same_day_3',
          'plan_id': plan.id,
          'title': 'Reading 3',
          'description': 'Third',
          'book': 'Mark',
          'chapters': '3',
          'estimated_time': '5 minutes',
          'date': today.millisecondsSinceEpoch,
          'is_completed': 0,
        });

        // Mark all as complete
        await readingPlanService.markReadingCompleted('same_day_1');
        await readingPlanService.markReadingCompleted('same_day_2');
        await readingPlanService.markReadingCompleted('same_day_3');

        final count = await readingPlanService.getCompletedReadingsCount(plan.id);
        expect(count, greaterThanOrEqualTo(3));
      });

      test('should handle starting same plan multiple times', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;

        await readingPlanService.startPlan(plan.id);
        final firstStartDate = (await readingPlanService.getCurrentPlan())!.startDate;

        // Wait a moment
        await Future.delayed(const Duration(milliseconds: 10));

        await readingPlanService.startPlan(plan.id);
        final secondStartDate = (await readingPlanService.getCurrentPlan())!.startDate;

        // Start date should be updated
        expect(secondStartDate!.isAfter(firstStartDate!), isTrue);
      });

      test('should return empty list for non-existent plan readings', () async {
        final readings = await readingPlanService.getReadingsForPlan('non_existent_id');

        expect(readings, isEmpty);
      });

      test('should handle completed reading with completed_date set', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;
        final db = await databaseService.database;

        final completedDate = DateTime.now().subtract(const Duration(days: 1));

        // Insert a reading that's already completed
        await db.insert('daily_readings', {
          'id': 'already_completed_reading',
          'plan_id': plan.id,
          'title': 'Already Completed',
          'description': 'Pre-completed reading',
          'book': 'Luke',
          'chapters': '1',
          'estimated_time': '5 minutes',
          'date': DateTime.now().millisecondsSinceEpoch,
          'is_completed': 1,
          'completed_date': completedDate.millisecondsSinceEpoch,
        });

        final readings = await readingPlanService.getReadingsForPlan(plan.id);
        final completedReading = readings.firstWhere(
          (r) => r.id == 'already_completed_reading',
        );

        expect(completedReading.isCompleted, isTrue);
        expect(completedReading.completedDate, isNotNull);
        expect(
          completedReading.completedDate!.millisecondsSinceEpoch,
          equals(completedDate.millisecondsSinceEpoch),
        );
      });
    });
  });
}
