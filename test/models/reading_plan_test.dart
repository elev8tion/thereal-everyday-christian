import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/models/reading_plan.dart';

void main() {
  group('ReadingPlan Model', () {
    test('should create ReadingPlan with required fields', () {
      const plan = ReadingPlan(
        id: '1',
        title: 'Bible in a Year',
        description: 'Read the entire Bible in 365 days',
        duration: '365 days',
        category: PlanCategory.completeBible,
        difficulty: PlanDifficulty.intermediate,
        estimatedTimePerDay: '15-20 min',
        totalReadings: 365,
      );

      expect(plan.id, equals('1'));
      expect(plan.title, equals('Bible in a Year'));
      expect(plan.description, equals('Read the entire Bible in 365 days'));
      expect(plan.duration, equals('365 days'));
      expect(plan.category, equals(PlanCategory.completeBible));
      expect(plan.difficulty, equals(PlanDifficulty.intermediate));
      expect(plan.estimatedTimePerDay, equals('15-20 min'));
      expect(plan.totalReadings, equals(365));
      expect(plan.completedReadings, equals(0));
      expect(plan.isStarted, isFalse);
      expect(plan.startDate, isNull);
    });

    test('should create ReadingPlan with all fields', () {
      final now = DateTime.now();
      final plan = ReadingPlan(
        id: '1',
        title: 'Test',
        description: 'Test plan',
        duration: '30 days',
        category: PlanCategory.gospels,
        difficulty: PlanDifficulty.beginner,
        estimatedTimePerDay: '10 min',
        totalReadings: 30,
        completedReadings: 15,
        isStarted: true,
        startDate: now,
      );

      expect(plan.completedReadings, equals(15));
      expect(plan.isStarted, isTrue);
      expect(plan.startDate, equals(now));
    });

    test('should serialize to JSON', () {
      const plan = ReadingPlan(
        id: '1',
        title: 'Test Plan',
        description: 'Test',
        duration: '7 days',
        category: PlanCategory.newTestament,
        difficulty: PlanDifficulty.advanced,
        estimatedTimePerDay: '20 min',
        totalReadings: 7,
        completedReadings: 3,
        isStarted: true,
      );

      final json = plan.toJson();

      expect(json['id'], equals('1'));
      expect(json['title'], equals('Test Plan'));
      expect(json['category'], equals('newTestament'));
      expect(json['difficulty'], equals('advanced'));
      expect(json['completedReadings'], equals(3));
      expect(json['isStarted'], isTrue);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'description': 'Description',
        'duration': '30 days',
        'category': 'psalms',
        'difficulty': 'intermediate',
        'estimatedTimePerDay': '15 min',
        'totalReadings': 30,
        'completedReadings': 10,
        'isStarted': true,
      };

      final plan = ReadingPlan.fromJson(json);

      expect(plan.id, equals('1'));
      expect(plan.category, equals(PlanCategory.psalms));
      expect(plan.difficulty, equals(PlanDifficulty.intermediate));
      expect(plan.completedReadings, equals(10));
    });

    test('should handle copyWith', () {
      const plan = ReadingPlan(
        id: '1',
        title: 'Original',
        description: 'Test',
        duration: '7 days',
        category: PlanCategory.gospels,
        difficulty: PlanDifficulty.beginner,
        estimatedTimePerDay: '10 min',
        totalReadings: 7,
      );

      final updated = plan.copyWith(
        completedReadings: 5,
        isStarted: true,
        startDate: DateTime.now(),
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('Original'));
      expect(updated.completedReadings, equals(5));
      expect(updated.isStarted, isTrue);
      expect(updated.startDate, isNotNull);
    });

    test('should support equality', () {
      const plan1 = ReadingPlan(
        id: '1',
        title: 'Test',
        description: 'Test',
        duration: '7 days',
        category: PlanCategory.gospels,
        difficulty: PlanDifficulty.beginner,
        estimatedTimePerDay: '10 min',
        totalReadings: 7,
      );

      const plan2 = ReadingPlan(
        id: '1',
        title: 'Test',
        description: 'Test',
        duration: '7 days',
        category: PlanCategory.gospels,
        difficulty: PlanDifficulty.beginner,
        estimatedTimePerDay: '10 min',
        totalReadings: 7,
      );

      expect(plan1, equals(plan2));
    });
  });

  group('DailyReading Model', () {
    test('should create DailyReading with required fields', () {
      final now = DateTime.now();
      final reading = DailyReading(
        id: '1',
        planId: 'plan1',
        title: 'Day 1',
        description: 'Genesis 1-2',
        book: 'Genesis',
        chapters: '1-2',
        estimatedTime: '15 min',
        date: now,
      );

      expect(reading.id, equals('1'));
      expect(reading.planId, equals('plan1'));
      expect(reading.title, equals('Day 1'));
      expect(reading.book, equals('Genesis'));
      expect(reading.chapters, equals('1-2'));
      expect(reading.isCompleted, isFalse);
      expect(reading.completedDate, isNull);
    });

    test('should create DailyReading with completion', () {
      final now = DateTime.now();
      final completed = now.add(const Duration(hours: 1));

      final reading = DailyReading(
        id: '1',
        planId: 'plan1',
        title: 'Day 1',
        description: 'Test',
        book: 'John',
        chapters: '1',
        estimatedTime: '10 min',
        date: now,
        isCompleted: true,
        completedDate: completed,
      );

      expect(reading.isCompleted, isTrue);
      expect(reading.completedDate, equals(completed));
    });

    test('should serialize DailyReading to JSON', () {
      final now = DateTime.now();
      final reading = DailyReading(
        id: '1',
        planId: 'plan1',
        title: 'Day 1',
        description: 'Test',
        book: 'Matthew',
        chapters: '1-5',
        estimatedTime: '20 min',
        date: now,
        isCompleted: true,
      );

      final json = reading.toJson();

      expect(json['id'], equals('1'));
      expect(json['planId'], equals('plan1'));
      expect(json['book'], equals('Matthew'));
      expect(json['isCompleted'], isTrue);
    });

    test('should deserialize DailyReading from JSON', () {
      final json = {
        'id': '1',
        'planId': 'plan1',
        'title': 'Day 1',
        'description': 'Read',
        'book': 'Luke',
        'chapters': '1-3',
        'estimatedTime': '15 min',
        'date': DateTime.now().toIso8601String(),
        'isCompleted': false,
      };

      final reading = DailyReading.fromJson(json);

      expect(reading.id, equals('1'));
      expect(reading.book, equals('Luke'));
      expect(reading.isCompleted, isFalse);
    });
  });

  group('PlanCategory Enum', () {
    test('should have all categories', () {
      expect(PlanCategory.values.length, equals(8));
      expect(PlanCategory.values, contains(PlanCategory.completeBible));
      expect(PlanCategory.values, contains(PlanCategory.newTestament));
      expect(PlanCategory.values, contains(PlanCategory.oldTestament));
      expect(PlanCategory.values, contains(PlanCategory.gospels));
      expect(PlanCategory.values, contains(PlanCategory.psalms));
      expect(PlanCategory.values, contains(PlanCategory.proverbs));
      expect(PlanCategory.values, contains(PlanCategory.wisdom));
      expect(PlanCategory.values, contains(PlanCategory.prophecy));
    });
  });

  group('PlanDifficulty Enum', () {
    test('should have all difficulties', () {
      expect(PlanDifficulty.values.length, equals(3));
      expect(PlanDifficulty.values, contains(PlanDifficulty.beginner));
      expect(PlanDifficulty.values, contains(PlanDifficulty.intermediate));
      expect(PlanDifficulty.values, contains(PlanDifficulty.advanced));
    });
  });

  group('PlanCategoryExtension', () {
    test('should return correct display names', () {
      expect(PlanCategory.completeBible.displayName, equals('Complete Bible'));
      expect(PlanCategory.newTestament.displayName, equals('New Testament'));
      expect(PlanCategory.oldTestament.displayName, equals('Old Testament'));
      expect(PlanCategory.gospels.displayName, equals('Gospels'));
      expect(PlanCategory.psalms.displayName, equals('Psalms'));
      expect(PlanCategory.proverbs.displayName, equals('Proverbs'));
      expect(PlanCategory.wisdom.displayName, equals('Wisdom Literature'));
      expect(PlanCategory.prophecy.displayName, equals('Prophecy'));
    });
  });

  group('PlanDifficultyExtension', () {
    test('should return correct display names', () {
      expect(PlanDifficulty.beginner.displayName, equals('Beginner'));
      expect(PlanDifficulty.intermediate.displayName, equals('Intermediate'));
      expect(PlanDifficulty.advanced.displayName, equals('Advanced'));
    });
  });
}
