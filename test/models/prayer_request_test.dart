import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/models/prayer_request.dart';

void main() {
  group('PrayerRequest Model', () {
    test('should create PrayerRequest with required fields', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Test Prayer',
        description: 'Please pray for...',
        categoryId: 'cat_general',
        dateCreated: now,
        isAnswered: false,
      );

      expect(prayer.id, equals('1'));
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.description, equals('Please pray for...'));
      expect(prayer.categoryId, equals('cat_general'));
      expect(prayer.dateCreated, equals(now));
      expect(prayer.isAnswered, isFalse);
      expect(prayer.dateAnswered, isNull);
      expect(prayer.answerDescription, isNull);
    });

    test('should create PrayerRequest with all fields', () {
      final created = DateTime.now();
      final answered = created.add(const Duration(days: 7));

      final prayer = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test description',
        categoryId: 'cat_health',
        dateCreated: created,
        isAnswered: true,
        dateAnswered: answered,
        answerDescription: 'Prayer answered!',
      );

      expect(prayer.isAnswered, isTrue);
      expect(prayer.dateAnswered, equals(answered));
      expect(prayer.answerDescription, equals('Prayer answered!'));
    });

    test('should serialize to JSON', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Description',
        categoryId: 'cat_family',
        dateCreated: now,
        isAnswered: true,
      );

      final json = prayer.toJson();

      expect(json['id'], equals('1'));
      expect(json['title'], equals('Test'));
      expect(json['categoryId'], equals('cat_family'));
      expect(json['isAnswered'], isTrue);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'title': 'Test Prayer',
        'description': 'Test',
        'categoryId': 'cat_work',
        'dateCreated': DateTime.now().toIso8601String(),
        'isAnswered': false,
      };

      final prayer = PrayerRequest.fromJson(json);

      expect(prayer.id, equals('1'));
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.categoryId, equals('cat_work'));
      expect(prayer.isAnswered, isFalse);
    });

    test('should handle copyWith', () {
      final now = DateTime.now();
      final prayer = PrayerRequest(
        id: '1',
        title: 'Original',
        description: 'Original description',
        categoryId: 'cat_general',
        dateCreated: now,
        isAnswered: false,
      );

      final updated = prayer.copyWith(
        isAnswered: true,
        answerDescription: 'Answered!',
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('Original'));
      expect(updated.isAnswered, isTrue);
      expect(updated.answerDescription, equals('Answered!'));
    });

    test('should support equality', () {
      final now = DateTime.now();
      final prayer1 = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test',
        categoryId: 'cat_general',
        dateCreated: now,
        isAnswered: false,
      );

      final prayer2 = PrayerRequest(
        id: '1',
        title: 'Test',
        description: 'Test',
        categoryId: 'cat_general',
        dateCreated: now,
        isAnswered: false,
      );

      expect(prayer1, equals(prayer2));
    });
  });
}
