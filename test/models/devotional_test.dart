import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/models/devotional.dart';

void main() {
  group('Devotional Model', () {
    test('should create Devotional with required fields', () {
      final now = DateTime.now();
      final devotional = Devotional(
        id: '1',
        title: 'Walking in Faith',
        subtitle: 'Trust in the Lord',
        content: 'Today we explore...',
        verse: 'Trust in the Lord with all your heart',
        verseReference: 'Proverbs 3:5',
        date: now,
        readingTime: '5 min',
      );

      expect(devotional.id, equals('1'));
      expect(devotional.title, equals('Walking in Faith'));
      expect(devotional.subtitle, equals('Trust in the Lord'));
      expect(devotional.content, equals('Today we explore...'));
      expect(devotional.verse, equals('Trust in the Lord with all your heart'));
      expect(devotional.verseReference, equals('Proverbs 3:5'));
      expect(devotional.date, equals(now));
      expect(devotional.readingTime, equals('5 min'));
      expect(devotional.isCompleted, isFalse);
      expect(devotional.completedDate, isNull);
    });

    test('should create Devotional with all fields', () {
      final now = DateTime.now();
      final completed = now.add(const Duration(hours: 1));

      final devotional = Devotional(
        id: '1',
        title: 'Test',
        subtitle: 'Subtitle',
        content: 'Content',
        verse: 'Verse',
        verseReference: 'Ref',
        date: now,
        readingTime: '3 min',
        isCompleted: true,
        completedDate: completed,
      );

      expect(devotional.isCompleted, isTrue);
      expect(devotional.completedDate, equals(completed));
    });

    test('should serialize to JSON', () {
      final now = DateTime.now();
      final devotional = Devotional(
        id: '1',
        title: 'Test',
        subtitle: 'Sub',
        content: 'Content',
        verse: 'Verse',
        verseReference: 'John 3:16',
        date: now,
        readingTime: '5 min',
        isCompleted: true,
      );

      final json = devotional.toJson();

      expect(json['id'], equals('1'));
      expect(json['title'], equals('Test'));
      expect(json['verseReference'], equals('John 3:16'));
      expect(json['isCompleted'], isTrue);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Devotional',
        'subtitle': 'Test Sub',
        'content': 'Test Content',
        'verse': 'Test Verse',
        'verseReference': 'Psalms 23:1',
        'date': DateTime.now().toIso8601String(),
        'readingTime': '7 min',
        'isCompleted': false,
      };

      final devotional = Devotional.fromJson(json);

      expect(devotional.id, equals('1'));
      expect(devotional.title, equals('Test Devotional'));
      expect(devotional.verseReference, equals('Psalms 23:1'));
      expect(devotional.readingTime, equals('7 min'));
      expect(devotional.isCompleted, isFalse);
    });

    test('should handle copyWith', () {
      final now = DateTime.now();
      final devotional = Devotional(
        id: '1',
        title: 'Original',
        subtitle: 'Sub',
        content: 'Content',
        verse: 'Verse',
        verseReference: 'Ref',
        date: now,
        readingTime: '5 min',
      );

      final updated = devotional.copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('Original'));
      expect(updated.isCompleted, isTrue);
      expect(updated.completedDate, isNotNull);
    });

    test('should support equality', () {
      final now = DateTime.now();
      final devotional1 = Devotional(
        id: '1',
        title: 'Test',
        subtitle: 'Sub',
        content: 'Content',
        verse: 'Verse',
        verseReference: 'Ref',
        date: now,
        readingTime: '5 min',
      );

      final devotional2 = Devotional(
        id: '1',
        title: 'Test',
        subtitle: 'Sub',
        content: 'Content',
        verse: 'Verse',
        verseReference: 'Ref',
        date: now,
        readingTime: '5 min',
      );

      expect(devotional1, equals(devotional2));
    });
  });
}
