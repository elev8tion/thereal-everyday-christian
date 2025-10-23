import 'package:freezed_annotation/freezed_annotation.dart';

part 'devotional.freezed.dart';
part 'devotional.g.dart';

@freezed
class Devotional with _$Devotional {
  const factory Devotional({
    required String id,
    required String title,
    required String subtitle,
    required String content,
    required String verse,
    required String verseReference,
    required DateTime date,
    required String readingTime,
    @Default(false) bool isCompleted,
    DateTime? completedDate,
  }) = _Devotional;

  factory Devotional.fromJson(Map<String, dynamic> json) =>
      _$DevotionalFromJson(json);
}