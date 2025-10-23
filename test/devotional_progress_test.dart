import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/devotional_progress_service.dart';
import 'package:everyday_christian/core/services/devotional_content_loader.dart';
import 'package:everyday_christian/core/models/devotional.dart';

void main() {
  // Initialize FFI for testing
  sqfliteFfiInit();

  group('DevotionalProgressService', () {
    late DatabaseService databaseService;
    late DevotionalProgressService progressService;
    late DevotionalContentLoader contentLoader;

    setUp(() async {
      // Use in-memory database for testing with explicit factory
      databaseFactory = databaseFactoryFfi;
      DatabaseService.setTestDatabasePath(inMemoryDatabasePath);

      databaseService = DatabaseService();
      progressService = DevotionalProgressService(databaseService);
      contentLoader = DevotionalContentLoader(databaseService);

      // Initialize database and load devotionals
      await databaseService.initialize();
      await contentLoader.loadDevotionals();
    });

    tearDown(() async {
      // Reset database (which also closes it)
      await databaseService.resetDatabase();
      // Small delay to ensure database is fully closed
      await Future.delayed(const Duration(milliseconds: 100));
    });

    group('Devotional Retrieval', () {
      test('should retrieve all devotionals', () async {
        final devotionals = await progressService.getAllDevotionals();

        expect(devotionals, isNotEmpty);
        expect(devotionals.length, equals(7)); // DevotionalContentLoader loads 7 devotionals
        expect(devotionals.first, isA<Devotional>());
      });

      test('should retrieve today\'s devotional', () async {
        final todaysDevotional = await progressService.getTodaysDevotional();

        // The first devotional should be today's
        expect(todaysDevotional, isNotNull);
        expect(todaysDevotional!.title, equals('Walking in Faith'));
      });

      test('should return null when no devotional for today', () async {
        // Mark all devotionals as old (from past dates)
        // This test would require modifying dates, skipping for now
        // In a real scenario, you'd test edge cases like future dates
      });
    });

    group('Completion Tracking', () {
      test('should mark devotional as complete', () async {
        final devotionals = await progressService.getAllDevotionals();
        final firstDevotional = devotionals.first;

        // Initially should not be completed
        expect(firstDevotional.isCompleted, isFalse);
        expect(firstDevotional.completedDate, isNull);

        // Mark as complete
        await progressService.markAsComplete(firstDevotional.id);

        // Verify completion status
        final isCompleted = await progressService.getCompletionStatus(firstDevotional.id);
        expect(isCompleted, isTrue);

        // Verify completed date is set
        final updatedDevotionals = await progressService.getAllDevotionals();
        final updatedDevotional = updatedDevotionals.firstWhere((d) => d.id == firstDevotional.id);
        expect(updatedDevotional.isCompleted, isTrue);
        expect(updatedDevotional.completedDate, isNotNull);
      });

      test('should mark devotional as incomplete', () async {
        final devotionals = await progressService.getAllDevotionals();
        final firstDevotional = devotionals.first;

        // Mark as complete first
        await progressService.markAsComplete(firstDevotional.id);
        expect(await progressService.getCompletionStatus(firstDevotional.id), isTrue);

        // Mark as incomplete
        await progressService.markAsIncomplete(firstDevotional.id);

        // Verify it's incomplete
        final isCompleted = await progressService.getCompletionStatus(firstDevotional.id);
        expect(isCompleted, isFalse);

        // Verify completed date is null
        final updatedDevotionals = await progressService.getAllDevotionals();
        final updatedDevotional = updatedDevotionals.firstWhere((d) => d.id == firstDevotional.id);
        expect(updatedDevotional.isCompleted, isFalse);
        expect(updatedDevotional.completedDate, isNull);
      });

      test('should get completion status for specific devotional', () async {
        final devotionals = await progressService.getAllDevotionals();
        final firstDevotional = devotionals.first;
        final secondDevotional = devotionals[1];

        // Mark only first devotional as complete
        await progressService.markAsComplete(firstDevotional.id);

        // Check completion statuses
        expect(await progressService.getCompletionStatus(firstDevotional.id), isTrue);
        expect(await progressService.getCompletionStatus(secondDevotional.id), isFalse);
      });

      test('should handle marking non-existent devotional', () async {
        // Should not throw error for non-existent ID
        expect(() async {
          await progressService.markAsComplete('non-existent-id');
        }, returnsNormally);

        // Status should be false for non-existent devotional
        final status = await progressService.getCompletionStatus('non-existent-id');
        expect(status, isFalse);
      });
    });

    group('Total Completed Count', () {
      test('should return 0 when no devotionals are completed', () async {
        final count = await progressService.getTotalCompleted();
        expect(count, equals(0));
      });

      test('should return correct count when devotionals are completed', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Mark 3 devotionals as complete
        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[1].id);
        await progressService.markAsComplete(devotionals[2].id);

        final count = await progressService.getTotalCompleted();
        expect(count, equals(3));
      });

      test('should update count when devotional is marked incomplete', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Mark 2 as complete
        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[1].id);
        expect(await progressService.getTotalCompleted(), equals(2));

        // Mark one as incomplete
        await progressService.markAsIncomplete(devotionals[0].id);
        expect(await progressService.getTotalCompleted(), equals(1));
      });
    });

    group('Streak Calculation', () {
      test('should return 0 streak when no devotionals are completed', () async {
        final streak = await progressService.getStreakCount();
        expect(streak, equals(0));
      });

      test('should return 1 when only today\'s devotional is completed', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete today's devotional (first one)
        await progressService.markAsComplete(devotionals[0].id);

        final streak = await progressService.getStreakCount();
        expect(streak, equals(1));
      });

      test('should calculate consecutive day streak correctly', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete first 3 devotionals (consecutive days)
        for (int i = 0; i < 3; i++) {
          await progressService.markAsComplete(devotionals[i].id);
        }

        final streak = await progressService.getStreakCount();
        expect(streak, equals(3));
      });

      test('should break streak when there is a gap', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete devotionals with a gap (0, 1, skip 2, complete 3)
        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[1].id);
        // Skip devotionals[2]
        await progressService.markAsComplete(devotionals[3].id);

        final streak = await progressService.getStreakCount();
        // Should only count from the most recent consecutive completions
        expect(streak, equals(1));
      });

      test('should return 0 streak when last completion was more than 1 day ago', () async {
        // Manually insert a devotional scheduled 2 days in the past
        final db = await databaseService.database;
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        const oldDevotionalId = 'test-old-devotional';

        await db.insert('devotionals', {
          'id': oldDevotionalId,
          'title': 'Old Devotional',
          'subtitle': 'Test',
          'content': 'Test content',
          'verse': 'Test verse',
          'verse_reference': 'Test 1:1',
          'date': twoDaysAgo.millisecondsSinceEpoch,
          'reading_time': '1 min',
          'is_completed': 0,
        });

        // Complete the old devotional
        await progressService.markAsComplete(oldDevotionalId);

        // Streak should be 0 because the devotional was scheduled too long ago
        final streak = await progressService.getStreakCount();
        expect(streak, equals(0));
      });
    });

    group('Completion Percentage', () {
      test('should return 0% when no devotionals are completed', () async {
        final percentage = await progressService.getCompletionPercentage();
        expect(percentage, equals(0.0));
      });

      test('should return 100% when all devotionals are completed', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete all devotionals
        for (final devotional in devotionals) {
          await progressService.markAsComplete(devotional.id);
        }

        final percentage = await progressService.getCompletionPercentage();
        expect(percentage, equals(1.0));
      });

      test('should return correct percentage for partial completion', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete 3 out of 7 devotionals (approximately 42.86%)
        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[1].id);
        await progressService.markAsComplete(devotionals[2].id);

        final percentage = await progressService.getCompletionPercentage();
        expect(percentage, closeTo(3 / 7, 0.01));
      });
    });

    group('Completed Devotionals List', () {
      test('should return empty list when no devotionals are completed', () async {
        final completed = await progressService.getCompletedDevotionals();
        expect(completed, isEmpty);
      });

      test('should return only completed devotionals', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete 2 devotionals
        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[2].id);

        final completed = await progressService.getCompletedDevotionals();
        expect(completed.length, equals(2));
        expect(completed.every((d) => d.isCompleted), isTrue);
      });

      test('should return devotionals sorted by completion date (newest first)', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete devotionals in specific order
        await progressService.markAsComplete(devotionals[0].id);
        await Future.delayed(const Duration(milliseconds: 100));
        await progressService.markAsComplete(devotionals[1].id);
        await Future.delayed(const Duration(milliseconds: 100));
        await progressService.markAsComplete(devotionals[2].id);

        final completed = await progressService.getCompletedDevotionals();

        // Should be sorted newest first
        expect(completed.length, equals(3));
        expect(completed[0].id, equals(devotionals[2].id));
        expect(completed[1].id, equals(devotionals[1].id));
        expect(completed[2].id, equals(devotionals[0].id));
      });

      test('should have completion dates set for all completed devotionals', () async {
        final devotionals = await progressService.getAllDevotionals();

        await progressService.markAsComplete(devotionals[0].id);
        await progressService.markAsComplete(devotionals[1].id);

        final completed = await progressService.getCompletedDevotionals();

        expect(completed.every((d) => d.completedDate != null), isTrue);
        expect(completed.every((d) => d.completedDate!.isBefore(DateTime.now().add(const Duration(seconds: 1)))), isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle multiple completions of same devotional', () async {
        final devotionals = await progressService.getAllDevotionals();
        final firstDevotional = devotionals.first;

        // Mark as complete multiple times
        await progressService.markAsComplete(firstDevotional.id);
        final firstCompletionDate = (await progressService.getAllDevotionals())
            .firstWhere((d) => d.id == firstDevotional.id)
            .completedDate;

        await Future.delayed(const Duration(milliseconds: 100));
        await progressService.markAsComplete(firstDevotional.id);
        final secondCompletionDate = (await progressService.getAllDevotionals())
            .firstWhere((d) => d.id == firstDevotional.id)
            .completedDate;

        // Should still be completed with updated date
        expect(await progressService.getCompletionStatus(firstDevotional.id), isTrue);
        expect(secondCompletionDate!.isAfter(firstCompletionDate!), isTrue);
      });

      test('should handle concurrent completion operations', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Complete multiple devotionals concurrently
        await Future.wait([
          progressService.markAsComplete(devotionals[0].id),
          progressService.markAsComplete(devotionals[1].id),
          progressService.markAsComplete(devotionals[2].id),
        ]);

        // Add small delay to ensure all database writes are committed
        await Future.delayed(const Duration(milliseconds: 50));

        // Verify all three devotionals were marked as complete
        final count = await progressService.getTotalCompleted();
        expect(count, equals(3));

        // Verify individual completion statuses
        expect(await progressService.getCompletionStatus(devotionals[0].id), isTrue);
        expect(await progressService.getCompletionStatus(devotionals[1].id), isTrue);
        expect(await progressService.getCompletionStatus(devotionals[2].id), isTrue);
      });

      test('should maintain data integrity across operations', () async {
        final devotionals = await progressService.getAllDevotionals();

        // Perform various operations sequentially with explicit awaits
        await progressService.markAsComplete(devotionals[0].id);
        // Ensure first operation completes
        await Future.delayed(const Duration(milliseconds: 10));

        await progressService.markAsComplete(devotionals[1].id);
        // Ensure second operation completes
        await Future.delayed(const Duration(milliseconds: 10));

        await progressService.markAsIncomplete(devotionals[0].id);
        // Ensure third operation completes
        await Future.delayed(const Duration(milliseconds: 10));

        await progressService.markAsComplete(devotionals[2].id);
        // Ensure final operation completes
        await Future.delayed(const Duration(milliseconds: 10));

        // Verify final state with individual checks
        final status0 = await progressService.getCompletionStatus(devotionals[0].id);
        expect(status0, isFalse, reason: 'Devotional 0 should be incomplete after being unmarked');

        final status1 = await progressService.getCompletionStatus(devotionals[1].id);
        expect(status1, isTrue, reason: 'Devotional 1 should be complete');

        final status2 = await progressService.getCompletionStatus(devotionals[2].id);
        expect(status2, isTrue, reason: 'Devotional 2 should be complete');

        // Verify total count
        final totalCompleted = await progressService.getTotalCompleted();
        expect(totalCompleted, equals(2), reason: 'Total completed should be 2 (devotionals 1 and 2)');

        // Double-check by querying the completed list
        final completedList = await progressService.getCompletedDevotionals();
        expect(completedList.length, equals(2), reason: 'Completed list should contain exactly 2 devotionals');
        expect(completedList.any((d) => d.id == devotionals[1].id), isTrue, reason: 'Devotional 1 should be in completed list');
        expect(completedList.any((d) => d.id == devotionals[2].id), isTrue, reason: 'Devotional 2 should be in completed list');
        expect(completedList.any((d) => d.id == devotionals[0].id), isFalse, reason: 'Devotional 0 should NOT be in completed list');
      });
    });

    group('Database Persistence', () {
      test('should persist completion status across service instances', () async {
        final devotionals = await progressService.getAllDevotionals();
        final firstDevotional = devotionals.first;

        // Mark as complete
        await progressService.markAsComplete(firstDevotional.id);

        // Create new service instance
        final newProgressService = DevotionalProgressService(databaseService);

        // Verify completion persisted
        final isCompleted = await newProgressService.getCompletionStatus(firstDevotional.id);
        expect(isCompleted, isTrue);
      });

      test('should persist completion dates correctly', () async {
        final devotionals = await progressService.getAllDevotionals();
        final now = DateTime.now();

        await progressService.markAsComplete(devotionals[0].id);

        // Retrieve and verify date
        final completed = await progressService.getCompletedDevotionals();
        expect(completed.first.completedDate, isNotNull);

        // Should be within a few seconds of now
        final diff = completed.first.completedDate!.difference(now).inSeconds.abs();
        expect(diff, lessThan(5));
      });
    });
  });
}
