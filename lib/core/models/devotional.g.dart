// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devotional.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DevotionalImpl _$$DevotionalImplFromJson(Map<String, dynamic> json) =>
    _$DevotionalImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      content: json['content'] as String,
      verse: json['verse'] as String,
      verseReference: json['verseReference'] as String,
      date: DateTime.parse(json['date'] as String),
      readingTime: json['readingTime'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] == null
          ? null
          : DateTime.parse(json['completedDate'] as String),
    );

Map<String, dynamic> _$$DevotionalImplToJson(_$DevotionalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'content': instance.content,
      'verse': instance.verse,
      'verseReference': instance.verseReference,
      'date': instance.date.toIso8601String(),
      'readingTime': instance.readingTime,
      'isCompleted': instance.isCompleted,
      'completedDate': instance.completedDate?.toIso8601String(),
    };
