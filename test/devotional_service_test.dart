import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/devotional_service.dart';

void main() {
  late DatabaseService databaseService;
  late DevotionalService devotionalService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    devotionalService = DevotionalService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  // Helper function to insert test devotionals
  Future<void> insertTestDevotional({
    required String id,
    required String title,
    required DateTime date,
    bool isCompleted = false,
    DateTime? completedDate,
  }) async {
    final db = await databaseService.database;
    await db.insert('devotionals', {
      'id': id,
      'title': title,
      'subtitle': 'Test subtitle',
      'content': 'Test content',
      'verse': 'For God so loved the world...',
      'verse_reference': 'John 3:16',
      'date': date.millisecondsSinceEpoch,
      'reading_time': '5 min read',
      'is_completed': isCompleted ? 1 : 0,
      'completed_date': completedDate?.millisecondsSinceEpoch,
    });
  }

  group('Devotional Retrieval', () {
    test('should get all devotionals ordered by date', () async {
      final date1 = DateTime(2025, 1, 1);
      final date2 = DateTime(2025, 1, 2);
      final date3 = DateTime(2025, 1, 3);

      await insertTestDevotional(id: 'dev3', title: 'Day 3', date: date3);
      await insertTestDevotional(id: 'dev1', title: 'Day 1', date: date1);
      await insertTestDevotional(id: 'dev2', title: 'Day 2', date: date2);

      final devotionals = await devotionalService.getAllDevotionals();

      expect(devotionals.length, equals(3));
      expect(devotionals[0].title, equals('Day 1')); // Earliest first
      expect(devotionals[1].title, equals('Day 2'));
      expect(devotionals[2].title, equals('Day 3'));
    });

    test('should return empty list when no devotionals exist', () async {
      final devotionals = await devotionalService.getAllDevotionals();
      expect(devotionals, isEmpty);
    });

    test('should get today\'s devotional', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final tomorrow = today.add(const Duration(days: 1));

      await insertTestDevotional(
        id: 'yesterday',
        title: 'Yesterday',
        date: yesterday,
      );
      await insertTestDevotional(
        id: 'today',
        title: 'Today\'s Devotional',
        date: today,
      );
      await insertTestDevotional(
        id: 'tomorrow',
        title: 'Tomorrow',
        date: tomorrow,
      );

      final todaysDevotional = await devotionalService.getTodaysDevotional();

      expect(todaysDevotional, isNotNull);
      expect(todaysDevotional!.title, equals('Today\'s Devotional'));
      expect(todaysDevotional.id, equals('today'));
    });

    test('should return null when no devotional for today', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      await insertTestDevotional(
        id: 'yesterday',
        title: 'Yesterday',
        date: yesterday,
      );

      final todaysDevotional = await devotionalService.getTodaysDevotional();
      expect(todaysDevotional, isNull);
    });

    test('should handle devotional at start of day', () async {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day, 0, 0, 0);

      await insertTestDevotional(
        id: 'start',
        title: 'Start of Day',
        date: startOfDay,
      );

      final todaysDevotional = await devotionalService.getTodaysDevotional();
      expect(todaysDevotional, isNotNull);
      expect(todaysDevotional!.title, equals('Start of Day'));
    });

    test('should handle devotional at end of day', () async {
      final today = DateTime.now();
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      await insertTestDevotional(
        id: 'end',
        title: 'End of Day',
        date: endOfDay,
      );

      final todaysDevotional = await devotionalService.getTodaysDevotional();
      expect(todaysDevotional, isNotNull);
      expect(todaysDevotional!.title, equals('End of Day'));
    });
  });

  group('Devotional Completion', () {
    test('should mark devotional as completed', () async {
      final today = DateTime.now();
      await insertTestDevotional(
        id: 'test',
        title: 'Test',
        date: today,
        isCompleted: false,
      );

      await devotionalService.markDevotionalCompleted('test');

      final devotionals = await devotionalService.getAllDevotionals();
      final completed = devotionals.firstWhere((d) => d.id == 'test');

      expect(completed.isCompleted, isTrue);
      expect(completed.completedDate, isNotNull);
      expect(
        completed.completedDate!.difference(DateTime.now()).inSeconds,
        lessThan(2),
      );
    });

    test('should mark devotional as incomplete', () async {
      final today = DateTime.now();
      await insertTestDevotional(
        id: 'test',
        title: 'Test',
        date: today,
        isCompleted: true,
        completedDate: DateTime.now(),
      );

      await devotionalService.markDevotionalIncomplete('test');

      final devotionals = await devotionalService.getAllDevotionals();
      final incomplete = devotionals.firstWhere((d) => d.id == 'test');

      expect(incomplete.isCompleted, isFalse);
      expect(incomplete.completedDate, isNull);
    });

    test('should toggle completion status', () async {
      final today = DateTime.now();
      await insertTestDevotional(
        id: 'toggle',
        title: 'Toggle Test',
        date: today,
      );

      // Mark completed
      await devotionalService.markDevotionalCompleted('toggle');
      var devotionals = await devotionalService.getAllDevotionals();
      var devotional = devotionals.firstWhere((d) => d.id == 'toggle');
      expect(devotional.isCompleted, isTrue);

      // Mark incomplete
      await devotionalService.markDevotionalIncomplete('toggle');
      devotionals = await devotionalService.getAllDevotionals();
      devotional = devotionals.firstWhere((d) => d.id == 'toggle');
      expect(devotional.isCompleted, isFalse);
    });

    test('should get completed devotionals only', () async {
      final today = DateTime.now();

      await insertTestDevotional(
        id: 'completed1',
        title: 'Completed 1',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      await insertTestDevotional(
        id: 'incomplete',
        title: 'Incomplete',
        date: today,
        isCompleted: false,
      );

      await insertTestDevotional(
        id: 'completed2',
        title: 'Completed 2',
        date: today.subtract(const Duration(days: 1)),
        isCompleted: true,
        completedDate: today.subtract(const Duration(days: 1)),
      );

      final completed = await devotionalService.getCompletedDevotionals();

      expect(completed.length, equals(2));
      expect(completed.every((d) => d.isCompleted), isTrue);
      expect(completed[0].title, equals('Completed 1')); // Most recent first
      expect(completed[1].title, equals('Completed 2'));
    });

    test('should order completed devotionals by completion date descending', () async {
      final date1 = DateTime(2025, 1, 1);
      final date2 = DateTime(2025, 1, 2);
      final date3 = DateTime(2025, 1, 3);

      await insertTestDevotional(
        id: 'first',
        title: 'First',
        date: date1,
        isCompleted: true,
        completedDate: date1,
      );

      await insertTestDevotional(
        id: 'third',
        title: 'Third',
        date: date3,
        isCompleted: true,
        completedDate: date3,
      );

      await insertTestDevotional(
        id: 'second',
        title: 'Second',
        date: date2,
        isCompleted: true,
        completedDate: date2,
      );

      final completed = await devotionalService.getCompletedDevotionals();

      expect(completed[0].title, equals('Third')); // Most recent first
      expect(completed[1].title, equals('Second'));
      expect(completed[2].title, equals('First'));
    });
  });

  group('Devotional Statistics', () {
    test('should count completed devotionals', () async {
      final today = DateTime.now();

      await insertTestDevotional(
        id: 'c1',
        title: 'Completed 1',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      await insertTestDevotional(
        id: 'c2',
        title: 'Completed 2',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      await insertTestDevotional(
        id: 'inc',
        title: 'Incomplete',
        date: today,
        isCompleted: false,
      );

      final count = await devotionalService.getCompletedCount();
      expect(count, equals(2));
    });

    test('should return 0 count when no completed devotionals', () async {
      final count = await devotionalService.getCompletedCount();
      expect(count, equals(0));
    });

    test('should calculate streak for consecutive days', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      final twoDaysAgo = today.subtract(const Duration(days: 2));

      // Complete devotionals for 3 consecutive days
      await insertTestDevotional(
        id: 'day3',
        title: 'Today',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      await insertTestDevotional(
        id: 'day2',
        title: 'Yesterday',
        date: yesterday,
        isCompleted: true,
        completedDate: yesterday,
      );

      await insertTestDevotional(
        id: 'day1',
        title: 'Two Days Ago',
        date: twoDaysAgo,
        isCompleted: true,
        completedDate: twoDaysAgo,
      );

      final streak = await devotionalService.getCurrentStreak();
      expect(streak, equals(3));
    });

    test('should return 0 streak when no completed devotionals', () async {
      final streak = await devotionalService.getCurrentStreak();
      expect(streak, equals(0));
    });

    test('should return 1 streak for single completed devotional', () async {
      final today = DateTime.now();

      await insertTestDevotional(
        id: 'single',
        title: 'Single',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      final streak = await devotionalService.getCurrentStreak();
      expect(streak, equals(1));
    });

    test('should break streak on non-consecutive days', () async {
      final today = DateTime.now();
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final threeDaysAgo = today.subtract(const Duration(days: 3));

      // Complete today and 2 days ago (gap of 1 day)
      await insertTestDevotional(
        id: 'today',
        title: 'Today',
        date: today,
        isCompleted: true,
        completedDate: today,
      );

      await insertTestDevotional(
        id: 'gap',
        title: 'Two Days Ago',
        date: twoDaysAgo,
        isCompleted: true,
        completedDate: twoDaysAgo,
      );

      await insertTestDevotional(
        id: 'old',
        title: 'Three Days Ago',
        date: threeDaysAgo,
        isCompleted: true,
        completedDate: threeDaysAgo,
      );

      final streak = await devotionalService.getCurrentStreak();
      expect(streak, equals(1)); // Only counts today
    });

    test('should handle streak with completed devotional without completed_date', () async {
      final today = DateTime.now();
      final db = await databaseService.database;

      await db.insert('devotionals', {
        'id': 'no-date',
        'title': 'No Date',
        'subtitle': 'Test',
        'content': 'Test',
        'verse': 'Test',
        'verse_reference': 'Test 1:1',
        'date': today.millisecondsSinceEpoch,
        'reading_time': '5 min',
        'is_completed': 1,
        'completed_date': null, // Completed but no date
      });

      final streak = await devotionalService.getCurrentStreak();
      expect(streak, equals(0)); // Should skip entries without completed_date
    });
  });

  group('Devotional Model Serialization', () {
    test('should deserialize devotional from database correctly', () async {
      final testDate = DateTime(2025, 1, 15, 8, 30);

      await insertTestDevotional(
        id: 'serialize-test',
        title: 'Serialization Test',
        date: testDate,
        isCompleted: false,
      );

      final devotionals = await devotionalService.getAllDevotionals();
      final devotional = devotionals.first;

      expect(devotional.id, equals('serialize-test'));
      expect(devotional.title, equals('Serialization Test'));
      expect(devotional.subtitle, equals('Test subtitle'));
      expect(devotional.content, equals('Test content'));
      expect(devotional.verse, equals('For God so loved the world...'));
      expect(devotional.verseReference, equals('John 3:16'));
      expect(devotional.readingTime, equals('5 min read'));
      expect(devotional.isCompleted, isFalse);
      expect(devotional.completedDate, isNull);
    });

    test('should deserialize completed devotional with date', () async {
      final testDate = DateTime(2025, 1, 15);
      final completedDate = DateTime(2025, 1, 15, 18, 30);

      await insertTestDevotional(
        id: 'completed-test',
        title: 'Completed Test',
        date: testDate,
        isCompleted: true,
        completedDate: completedDate,
      );

      final devotionals = await devotionalService.getCompletedDevotionals();
      final devotional = devotionals.first;

      expect(devotional.isCompleted, isTrue);
      expect(devotional.completedDate, isNotNull);
      expect(devotional.completedDate!.year, equals(2025));
      expect(devotional.completedDate!.month, equals(1));
      expect(devotional.completedDate!.day, equals(15));
    });
  });

  group('Edge Cases', () {
    test('should handle empty titles and content', () async {
      final today = DateTime.now();
      final db = await databaseService.database;

      await db.insert('devotionals', {
        'id': 'empty',
        'title': '',
        'subtitle': '',
        'content': '',
        'verse': '',
        'verse_reference': '',
        'date': today.millisecondsSinceEpoch,
        'reading_time': '',
        'is_completed': 0,
        'completed_date': null,
      });

      final devotionals = await devotionalService.getAllDevotionals();
      final devotional = devotionals.first;

      expect(devotional.title, equals(''));
      expect(devotional.content, equals(''));
      expect(devotional.verse, equals(''));
    });

    test('should handle very long content', () async {
      final longContent = 'A' * 10000;
      final today = DateTime.now();
      final db = await databaseService.database;

      await db.insert('devotionals', {
        'id': 'long',
        'title': 'Long Content',
        'subtitle': 'Test',
        'content': longContent,
        'verse': 'Test verse',
        'verse_reference': 'Test 1:1',
        'date': today.millisecondsSinceEpoch,
        'reading_time': '30 min',
        'is_completed': 0,
        'completed_date': null,
      });

      final devotionals = await devotionalService.getAllDevotionals();
      final devotional = devotionals.first;

      expect(devotional.content.length, equals(10000));
      expect(devotional.content, equals(longContent));
    });

    test('should handle special characters in content', () async {
      final today = DateTime.now();
      final db = await databaseService.database;

      await db.insert('devotionals', {
        'id': 'special',
        'title': 'Title with "quotes" and \'apostrophes\'',
        'subtitle': 'Subtitle with émojis 🙏',
        'content': 'Content with special chars: @#\$%^&*()',
        'verse': 'Test verse',
        'verse_reference': 'Test 1:1',
        'date': today.millisecondsSinceEpoch,
        'reading_time': '5 min',
        'is_completed': 0,
        'completed_date': null,
      });

      final devotionals = await devotionalService.getAllDevotionals();
      final devotional = devotionals.first;

      expect(devotional.title, contains('quotes'));
      expect(devotional.subtitle, contains('🙏'));
      expect(devotional.content, contains('@#\$%'));
    });

    test('should handle multiple completions and incompletions', () async {
      final today = DateTime.now();
      await insertTestDevotional(
        id: 'multi',
        title: 'Multi Toggle',
        date: today,
      );

      // Complete
      await devotionalService.markDevotionalCompleted('multi');
      var devotionals = await devotionalService.getAllDevotionals();
      expect(devotionals.first.isCompleted, isTrue);

      // Incomplete
      await devotionalService.markDevotionalIncomplete('multi');
      devotionals = await devotionalService.getAllDevotionals();
      expect(devotionals.first.isCompleted, isFalse);

      // Complete again
      await devotionalService.markDevotionalCompleted('multi');
      devotionals = await devotionalService.getAllDevotionals();
      expect(devotionals.first.isCompleted, isTrue);
    });

    test('should handle devotionals at exact midnight boundaries', () async {
      final today = DateTime.now();
      final midnight = DateTime(today.year, today.month, today.day, 0, 0, 0);
      final nextMidnight = midnight.add(const Duration(days: 1));

      // Just before midnight (should be today)
      await insertTestDevotional(
        id: 'before',
        title: 'Before Midnight',
        date: nextMidnight.subtract(const Duration(seconds: 1)),
      );

      // Exactly at next midnight (should be tomorrow)
      await insertTestDevotional(
        id: 'after',
        title: 'After Midnight',
        date: nextMidnight,
      );

      final todaysDevotional = await devotionalService.getTodaysDevotional();

      expect(todaysDevotional, isNotNull);
      expect(todaysDevotional!.title, equals('Before Midnight'));
    });
  });
}
