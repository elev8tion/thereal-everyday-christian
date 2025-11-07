import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/achievement_service.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AchievementService Tests', () {
    late DatabaseService databaseService;
    late AchievementService achievementService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
      databaseService = DatabaseService();
      achievementService = AchievementService(databaseService);

      // Initialize database
      await databaseService.database;
    });

    tearDown(() async {
      await databaseService.close();
      DatabaseHelper.setTestDatabasePath(null);
    });

    test('Initial completion count should be 0', () async {
      final count = await achievementService.getCompletionCount(AchievementType.relentless);
      expect(count, 0);
    });

    test('Record completion should increment count', () async {
      // First completion
      await achievementService.recordCompletion(
        type: AchievementType.relentless,
        progressValue: 50,
      );

      final count1 = await achievementService.getCompletionCount(AchievementType.relentless);
      expect(count1, 1);

      // Second completion
      await achievementService.recordCompletion(
        type: AchievementType.relentless,
        progressValue: 50,
      );

      final count2 = await achievementService.getCompletionCount(AchievementType.relentless);
      expect(count2, 2);
    });

    test('Different achievement types should have separate counts', () async {
      await achievementService.recordCompletion(
        type: AchievementType.relentless,
        progressValue: 50,
      );

      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      final relentlessCount = await achievementService.getCompletionCount(AchievementType.relentless);
      final curatorCount = await achievementService.getCompletionCount(AchievementType.curator);

      expect(relentlessCount, 1);
      expect(curatorCount, 1);
    });

    test('Completion history should be retrievable', () async {
      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      final history = await achievementService.getCompletionHistory(AchievementType.curator);

      expect(history.length, 2);
      expect(history[0].achievementType, AchievementType.curator);

      // History is ordered by completed_at DESC (most recent first)
      // The second completion should be first in the list
      expect(history[0].completionCount, 2); // Most recent (second completion)
      expect(history[1].completionCount, 1); // Older (first completion)
    });

    test('getTotalAchievementsEarned should count all completions', () async {
      await achievementService.recordCompletion(
        type: AchievementType.relentless,
        progressValue: 50,
      );

      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      await achievementService.recordCompletion(
        type: AchievementType.disciple,
        progressValue: 10,
      );

      final total = await achievementService.getTotalAchievementsEarned();
      expect(total, 3);
    });

    test('wasDailyBreadCompletedThisMonth should return false initially', () async {
      final completed = await achievementService.wasDailyBreadCompletedThisMonth();
      expect(completed, false);
    });

    test('wasDailyBreadCompletedThisMonth should return true after completion', () async {
      await achievementService.recordCompletion(
        type: AchievementType.dailyBread,
        progressValue: 30,
      );

      final completed = await achievementService.wasDailyBreadCompletedThisMonth();
      expect(completed, true);
    });

    test('clearAllCompletions should remove all data', () async {
      await achievementService.recordCompletion(
        type: AchievementType.relentless,
        progressValue: 50,
      );

      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      await achievementService.clearAllCompletions();

      final relentlessCount = await achievementService.getCompletionCount(AchievementType.relentless);
      final curatorCount = await achievementService.getCompletionCount(AchievementType.curator);
      final total = await achievementService.getTotalAchievementsEarned();

      expect(relentlessCount, 0);
      expect(curatorCount, 0);
      expect(total, 0);
    });

    test('Completion records should have proper timestamps', () async {
      // Get time before recording with a 1 second buffer
      final beforeTime = DateTime.now().subtract(const Duration(seconds: 1));

      await achievementService.recordCompletion(
        type: AchievementType.deepDiver,
        progressValue: 5,
      );

      // Get time after recording with a 1 second buffer
      final afterTime = DateTime.now().add(const Duration(seconds: 1));

      final history = await achievementService.getCompletionHistory(AchievementType.deepDiver);
      expect(history.length, 1);

      final completion = history.first;

      // Timestamp should be between our buffered time range
      expect(completion.completedAt.isAfter(beforeTime), true, reason: 'Timestamp should be after beforeTime');
      expect(completion.completedAt.isBefore(afterTime), true, reason: 'Timestamp should be before afterTime');
    });

    test('Progress value should be stored correctly', () async {
      await achievementService.recordCompletion(
        type: AchievementType.curator,
        progressValue: 100,
      );

      final history = await achievementService.getCompletionHistory(AchievementType.curator);
      expect(history.first.progressAtCompletion, 100);
    });

    test('Multiple completions should have incrementing counts', () async {
      for (int i = 1; i <= 5; i++) {
        await achievementService.recordCompletion(
          type: AchievementType.unbroken,
          progressValue: 7,
        );

        // Add small delay to ensure different timestamps
        await Future.delayed(const Duration(milliseconds: 1));

        final count = await achievementService.getCompletionCount(AchievementType.unbroken);
        expect(count, i);
      }

      final history = await achievementService.getCompletionHistory(AchievementType.unbroken);
      expect(history.length, 5);

      // History is ordered by completed_at DESC (most recent first)
      expect(history[0].completionCount, 5); // Most recent (5th completion)
      expect(history[4].completionCount, 1); // Oldest (1st completion)
    });

    test('resetAfterCelebration for disciple should clear shared_chats', () async {
      // First, create a chat_session (parent record required by foreign key)
      final db = await databaseService.database;
      await db.insert('chat_sessions', {
        'id': 'session-123',
        'title': 'Test Session',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Then create a shared_chats entry
      await db.insert('shared_chats', {
        'id': 'test-123',
        'session_id': 'session-123',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Verify it exists
      final beforeReset = await db.query('shared_chats');
      expect(beforeReset.length, 1);

      // Reset
      await achievementService.resetAfterCelebration(AchievementType.disciple);

      // Verify it's deleted
      final afterReset = await db.query('shared_chats');
      expect(afterReset.length, 0);
    });
  });

  group('Database Migration v14 Tests', () {
    late DatabaseService databaseService;

    setUp(() async {
      // Use in-memory database for testing
      DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
      databaseService = DatabaseService();

      // Initialize database (will run onCreate with v14)
      await databaseService.database;
    });

    tearDown(() async {
      await databaseService.close();
      DatabaseHelper.setTestDatabasePath(null);
    });

    test('achievement_completions table should exist', () async {
      final db = await databaseService.database;

      // Query table info
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='achievement_completions'",
      );

      expect(tables.isNotEmpty, true);
      expect(tables.first['name'], 'achievement_completions');
    });

    test('achievement_completions table should have correct columns', () async {
      final db = await databaseService.database;

      final columns = await db.rawQuery('PRAGMA table_info(achievement_completions)');

      final columnNames = columns.map((col) => col['name'] as String).toList();

      expect(columnNames.contains('id'), true);
      expect(columnNames.contains('achievement_type'), true);
      expect(columnNames.contains('completed_at'), true);
      expect(columnNames.contains('completion_count'), true);
      expect(columnNames.contains('progress_at_completion'), true);
    });

    test('achievement_completions indexes should exist', () async {
      final db = await databaseService.database;

      final indexes = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='achievement_completions'",
      );

      final indexNames = indexes.map((idx) => idx['name'] as String).toList();

      expect(indexNames.contains('idx_achievement_completions_type'), true);
      expect(indexNames.contains('idx_achievement_completions_timestamp'), true);
    });

    test('Can insert and query achievement_completions table', () async {
      final db = await databaseService.database;

      await db.insert('achievement_completions', {
        'id': 'test-uuid-123',
        'achievement_type': 'relentless',
        'completed_at': DateTime.now().millisecondsSinceEpoch,
        'completion_count': 1,
        'progress_at_completion': 50,
      });

      final results = await db.query('achievement_completions');
      expect(results.length, 1);
      expect(results.first['achievement_type'], 'relentless');
      expect(results.first['completion_count'], 1);
      expect(results.first['progress_at_completion'], 50);
    });
  });
}
