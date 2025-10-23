import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/models/bible_verse.dart';

void main() {
  group('BibleVerse Model', () {
    test('should create BibleVerse with required fields', () {
      const verse = BibleVerse(
        id: '1',
        text: 'For God so loved the world...',
        reference: 'John 3:16',
        category: VerseCategory.love,
      );

      expect(verse.id, equals('1'));
      expect(verse.text, equals('For God so loved the world...'));
      expect(verse.reference, equals('John 3:16'));
      expect(verse.category, equals(VerseCategory.love));
      expect(verse.isFavorite, isFalse);
      expect(verse.dateAdded, isNull);
    });

    test('should create BibleVerse with all fields', () {
      final now = DateTime.now();
      final verse = BibleVerse(
        id: '1',
        text: 'Test verse',
        reference: 'Test 1:1',
        category: VerseCategory.faith,
        isFavorite: true,
        dateAdded: now,
      );

      expect(verse.id, equals('1'));
      expect(verse.isFavorite, isTrue);
      expect(verse.dateAdded, equals(now));
    });

    test('should serialize to JSON', () {
      const verse = BibleVerse(
        id: '1',
        text: 'Test',
        reference: 'Test 1:1',
        category: VerseCategory.hope,
        isFavorite: true,
      );

      final json = verse.toJson();

      expect(json['id'], equals('1'));
      expect(json['text'], equals('Test'));
      expect(json['reference'], equals('Test 1:1'));
      expect(json['category'], equals('hope'));
      expect(json['isFavorite'], isTrue);
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'text': 'Test verse',
        'reference': 'Test 1:1',
        'category': 'peace',
        'isFavorite': true,
      };

      final verse = BibleVerse.fromJson(json);

      expect(verse.id, equals('1'));
      expect(verse.text, equals('Test verse'));
      expect(verse.reference, equals('Test 1:1'));
      expect(verse.category, equals(VerseCategory.peace));
      expect(verse.isFavorite, isTrue);
    });

    test('should handle copyWith', () {
      const verse = BibleVerse(
        id: '1',
        text: 'Original',
        reference: 'Test 1:1',
        category: VerseCategory.faith,
      );

      final updated = verse.copyWith(
        text: 'Updated',
        isFavorite: true,
      );

      expect(updated.id, equals('1'));
      expect(updated.text, equals('Updated'));
      expect(updated.reference, equals('Test 1:1'));
      expect(updated.isFavorite, isTrue);
    });

    test('should support equality', () {
      const verse1 = BibleVerse(
        id: '1',
        text: 'Test',
        reference: 'Test 1:1',
        category: VerseCategory.love,
      );

      const verse2 = BibleVerse(
        id: '1',
        text: 'Test',
        reference: 'Test 1:1',
        category: VerseCategory.love,
      );

      expect(verse1, equals(verse2));
    });
  });

  group('VerseCategory Enum', () {
    test('should have all categories', () {
      expect(VerseCategory.values.length, equals(12));
      expect(VerseCategory.values, contains(VerseCategory.faith));
      expect(VerseCategory.values, contains(VerseCategory.hope));
      expect(VerseCategory.values, contains(VerseCategory.love));
      expect(VerseCategory.values, contains(VerseCategory.peace));
      expect(VerseCategory.values, contains(VerseCategory.strength));
      expect(VerseCategory.values, contains(VerseCategory.comfort));
      expect(VerseCategory.values, contains(VerseCategory.guidance));
      expect(VerseCategory.values, contains(VerseCategory.wisdom));
      expect(VerseCategory.values, contains(VerseCategory.forgiveness));
      expect(VerseCategory.values, contains(VerseCategory.joy));
      expect(VerseCategory.values, contains(VerseCategory.courage));
      expect(VerseCategory.values, contains(VerseCategory.patience));
    });
  });

  group('VerseCategoryExtension', () {
    test('should return correct display name for faith', () {
      expect(VerseCategory.faith.displayName, equals('Faith'));
    });

    test('should return correct display name for hope', () {
      expect(VerseCategory.hope.displayName, equals('Hope'));
    });

    test('should return correct display name for love', () {
      expect(VerseCategory.love.displayName, equals('Love'));
    });

    test('should return correct display name for peace', () {
      expect(VerseCategory.peace.displayName, equals('Peace'));
    });

    test('should return correct display name for strength', () {
      expect(VerseCategory.strength.displayName, equals('Strength'));
    });

    test('should return correct display name for comfort', () {
      expect(VerseCategory.comfort.displayName, equals('Comfort'));
    });

    test('should return correct display name for guidance', () {
      expect(VerseCategory.guidance.displayName, equals('Guidance'));
    });

    test('should return correct display name for wisdom', () {
      expect(VerseCategory.wisdom.displayName, equals('Wisdom'));
    });

    test('should return correct display name for forgiveness', () {
      expect(VerseCategory.forgiveness.displayName, equals('Forgiveness'));
    });

    test('should return correct display name for joy', () {
      expect(VerseCategory.joy.displayName, equals('Joy'));
    });

    test('should return correct display name for courage', () {
      expect(VerseCategory.courage.displayName, equals('Courage'));
    });

    test('should return correct display name for patience', () {
      expect(VerseCategory.patience.displayName, equals('Patience'));
    });
  });
}
