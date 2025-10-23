import 'package:freezed_annotation/freezed_annotation.dart';

part 'reading_plan.freezed.dart';
part 'reading_plan.g.dart';

@freezed
class ReadingPlan with _$ReadingPlan {
  const factory ReadingPlan({
    required String id,
    required String title,
    required String description,
    required String duration,
    required PlanCategory category,
    required PlanDifficulty difficulty,
    required String estimatedTimePerDay,
    required int totalReadings,
    @Default(0) int completedReadings,
    @Default(false) bool isStarted,
    DateTime? startDate,
  }) = _ReadingPlan;

  factory ReadingPlan.fromJson(Map<String, dynamic> json) =>
      _$ReadingPlanFromJson(json);
}

@freezed
class DailyReading with _$DailyReading {
  const factory DailyReading({
    required String id,
    required String planId,
    required String title,
    required String description,
    required String book,
    required String chapters,
    required String estimatedTime,
    required DateTime date,
    @Default(false) bool isCompleted,
    DateTime? completedDate,
  }) = _DailyReading;

  factory DailyReading.fromJson(Map<String, dynamic> json) =>
      _$DailyReadingFromJson(json);
}

enum PlanCategory {
  completeBible,
  newTestament,
  oldTestament,
  gospels,
  psalms,
  proverbs,
  wisdom,
  prophecy,
}

enum PlanDifficulty {
  beginner,
  intermediate,
  advanced,
}

extension PlanCategoryExtension on PlanCategory {
  String get displayName {
    switch (this) {
      case PlanCategory.completeBible:
        return 'Complete Bible';
      case PlanCategory.newTestament:
        return 'New Testament';
      case PlanCategory.oldTestament:
        return 'Old Testament';
      case PlanCategory.gospels:
        return 'Gospels';
      case PlanCategory.psalms:
        return 'Psalms';
      case PlanCategory.proverbs:
        return 'Proverbs';
      case PlanCategory.wisdom:
        return 'Wisdom Literature';
      case PlanCategory.prophecy:
        return 'Prophecy';
    }
  }
}

extension PlanDifficultyExtension on PlanDifficulty {
  String get displayName {
    switch (this) {
      case PlanDifficulty.beginner:
        return 'Beginner';
      case PlanDifficulty.intermediate:
        return 'Intermediate';
      case PlanDifficulty.advanced:
        return 'Advanced';
    }
  }
}