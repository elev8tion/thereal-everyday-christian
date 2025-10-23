import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/prayer_service.dart';
import 'package:everyday_christian/core/models/prayer_request.dart';

void main() {
  late DatabaseService databaseService;
  late PrayerService prayerService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    prayerService = PrayerService(databaseService);
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Prayer CRUD Operations', () {
    test('should create prayer with all fields', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test Prayer',
        description: 'Please help me with this test',
        categoryId: 'cat_general',
      );

      expect(prayer.id, isNotEmpty);
      expect(prayer.title, equals('Test Prayer'));
      expect(prayer.description, equals('Please help me with this test'));
      expect(prayer.categoryId, equals('cat_general'));
      expect(prayer.isAnswered, isFalse);
      expect(prayer.dateAnswered, isNull);
    });

    test('should create prayers with different categories', () async {
      final categories = [
        'cat_health',
        'cat_family',
        'cat_work',
        'cat_protection',
        'cat_guidance',
        'cat_gratitude',
      ];

      for (final categoryId in categories) {
        final prayer = await prayerService.createPrayer(
          title: 'Prayer for $categoryId',
          description: 'Test prayer',
          categoryId: categoryId,
        );
        expect(prayer.categoryId, equals(categoryId));
      }
    });

    test('should add prayer manually', () async {
      final prayer = PrayerRequest(
        id: 'test-id',
        title: 'Manual Prayer',
        description: 'Added manually',
        categoryId: 'cat_family',
        dateCreated: DateTime.now(),
        isAnswered: false,
      );

      await prayerService.addPrayer(prayer);
      final prayers = await prayerService.getAllPrayers();
      expect(prayers.any((p) => p.id == 'test-id'), isTrue);
    });

    test('should update prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Original Title',
        description: 'Original description',
        categoryId: 'cat_general',
      );

      final updated = prayer.copyWith(
        title: 'Updated Title',
        description: 'Updated description',
      );

      await prayerService.updatePrayer(updated);
      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);

      expect(found.title, equals('Updated Title'));
      expect(found.description, equals('Updated description'));
    });

    test('should delete prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'To Delete',
        description: 'This will be deleted',
        categoryId: 'cat_general',
      );

      await prayerService.deletePrayer(prayer.id);
      final prayers = await prayerService.getAllPrayers();
      expect(prayers.any((p) => p.id == prayer.id), isFalse);
    });
  });

  group('Prayer Answered Operations', () {
    test('should mark prayer as answered', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Prayer to Answer',
        description: 'Waiting for answer',
        categoryId: 'cat_health',
      );

      await prayerService.markPrayerAnswered(
        prayer.id,
        'God answered with healing',
      );

      final answered = await prayerService.getAnsweredPrayers();
      final found = answered.firstWhere((p) => p.id == prayer.id);

      expect(found.isAnswered, isTrue);
      expect(found.answerDescription, equals('God answered with healing'));
      expect(found.dateAnswered, isNotNull);
    });

    test('should get only answered prayers', () async {
      await prayerService.createPrayer(
        title: 'Active Prayer',
        description: 'Still waiting',
        categoryId: 'cat_general',
      );

      final answered = await prayerService.createPrayer(
        title: 'Will be answered',
        description: 'Answer coming',
        categoryId: 'cat_guidance',
      );

      await prayerService.markPrayerAnswered(
        answered.id,
        'Answered!',
      );

      final answeredPrayers = await prayerService.getAnsweredPrayers();
      expect(answeredPrayers.length, equals(1));
      expect(answeredPrayers.first.id, equals(answered.id));
    });

    test('should get only active prayers', () async {
      final active = await prayerService.createPrayer(
        title: 'Active Prayer',
        description: 'Still praying',
        categoryId: 'cat_protection',
      );

      final toAnswer = await prayerService.createPrayer(
        title: 'To Answer',
        description: 'Will be answered',
        categoryId: 'cat_general',
      );

      await prayerService.markPrayerAnswered(toAnswer.id, 'Done');

      final activePrayers = await prayerService.getActivePrayers();
      expect(activePrayers.length, equals(1));
      expect(activePrayers.first.id, equals(active.id));
    });

    test('should order answered prayers by date answered', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'First',
        description: 'First prayer',
        categoryId: 'cat_general',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final prayer2 = await prayerService.createPrayer(
        title: 'Second',
        description: 'Second prayer',
        categoryId: 'cat_general',
      );

      await prayerService.markPrayerAnswered(prayer1.id, 'First answer');
      await Future.delayed(const Duration(milliseconds: 10));
      await prayerService.markPrayerAnswered(prayer2.id, 'Second answer');

      final answered = await prayerService.getAnsweredPrayers();
      expect(answered.first.id, equals(prayer2.id)); // Most recent first
    });
  });

  group('Prayer Queries', () {
    test('should get all prayers', () async {
      await prayerService.createPrayer(
        title: 'Prayer 1',
        description: 'First prayer',
        categoryId: 'cat_general',
      );

      await prayerService.createPrayer(
        title: 'Prayer 2',
        description: 'Second prayer',
        categoryId: 'cat_family',
      );

      final all = await prayerService.getAllPrayers();
      expect(all.length, greaterThanOrEqualTo(2));
    });

    test('should order all prayers by creation date descending', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'Old Prayer',
        description: 'Created first',
        categoryId: 'cat_general',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final prayer2 = await prayerService.createPrayer(
        title: 'New Prayer',
        description: 'Created second',
        categoryId: 'cat_general',
      );

      final all = await prayerService.getAllPrayers();
      expect(all.first.id, equals(prayer2.id)); // Most recent first
      expect(all.last.id, equals(prayer1.id));
    });

    test('should get prayer count', () async {
      final initialCount = await prayerService.getPrayerCount();

      await prayerService.createPrayer(
        title: 'Test',
        description: 'Count test',
        categoryId: 'cat_general',
      );

      final newCount = await prayerService.getPrayerCount();
      expect(newCount, equals(initialCount + 1));
    });

    test('should get answered prayer count', () async {
      final prayer1 = await prayerService.createPrayer(
        title: 'Prayer 1',
        description: 'First',
        categoryId: 'cat_general',
      );

      await prayerService.createPrayer(
        title: 'Prayer 2',
        description: 'Second',
        categoryId: 'cat_general',
      );

      await prayerService.markPrayerAnswered(prayer1.id, 'Answered');

      final count = await prayerService.getAnsweredPrayerCount();
      expect(count, equals(1));
    });

    test('should return empty list when no prayers exist', () async {
      final active = await prayerService.getActivePrayers();
      final answered = await prayerService.getAnsweredPrayers();

      expect(active, isEmpty);
      expect(answered, isEmpty);
    });
  });

  group('Prayer Categories', () {
    test('should handle all prayer categories', () async {
      final categories = [
        'cat_general',
        'cat_health',
        'cat_family',
        'cat_work',
        'cat_protection',
        'cat_guidance',
        'cat_gratitude',
      ];

      for (final categoryId in categories) {
        final prayer = await prayerService.createPrayer(
          title: 'Test $categoryId',
          description: 'Testing category',
          categoryId: categoryId,
        );

        expect(prayer.categoryId, equals(categoryId));
      }

      final all = await prayerService.getAllPrayers();
      expect(all.length, equals(categories.length));
    });

    test('should preserve category through update', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test',
        description: 'Test',
        categoryId: 'cat_health',
      );

      final updated = prayer.copyWith(description: 'Updated');
      await prayerService.updatePrayer(updated);

      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);
      expect(found.categoryId, equals('cat_health'));
    });
  });

  group('Prayer Model Serialization', () {
    test('should serialize and deserialize prayer correctly', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Serialization Test',
        description: 'Testing serialization',
        categoryId: 'cat_guidance',
      );

      await prayerService.markPrayerAnswered(prayer.id, 'Test answer');

      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == prayer.id);

      expect(found.title, equals(prayer.title));
      expect(found.description, equals(prayer.description));
      expect(found.categoryId, equals(prayer.categoryId));
      expect(found.isAnswered, isTrue);
      expect(found.answerDescription, equals('Test answer'));
    });

    test('should handle null optional fields', () async {
      final prayer = PrayerRequest(
        id: 'null-test',
        title: 'Null Test',
        description: 'Testing nulls',
        categoryId: 'cat_general',
        dateCreated: DateTime.now(),
        isAnswered: false,
        dateAnswered: null,
        answerDescription: null,
      );

      await prayerService.addPrayer(prayer);
      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == 'null-test');

      expect(found.dateAnswered, isNull);
      expect(found.answerDescription, isNull);
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle empty title and description', () async {
      final prayer = await prayerService.createPrayer(
        title: '',
        description: '',
        categoryId: 'cat_general',
      );

      expect(prayer.title, equals(''));
      expect(prayer.description, equals(''));
    });

    test('should handle very long title and description', () async {
      final longText = 'A' * 1000;
      final prayer = await prayerService.createPrayer(
        title: longText,
        description: longText,
        categoryId: 'cat_general',
      );

      expect(prayer.title, equals(longText));
      expect(prayer.description, equals(longText));
    });

    test('should handle special characters', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Prayer with "quotes" and \'apostrophes\'',
        description: 'Special chars: @#\$%^&*()',
        categoryId: 'cat_general',
      );

      final retrieved = await prayerService.getAllPrayers();
      final found = retrieved.firstWhere((p) => p.id == prayer.id);
      expect(found.title, contains('quotes'));
      expect(found.description, contains('@#\$%'));
    });

    test('should handle multiple updates to same prayer', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Original',
        description: 'Original',
        categoryId: 'cat_general',
      );

      for (int i = 1; i <= 5; i++) {
        final updated = prayer.copyWith(
          title: 'Update $i',
          description: 'Description $i',
        );
        await prayerService.updatePrayer(updated);
      }

      final prayers = await prayerService.getAllPrayers();
      final found = prayers.firstWhere((p) => p.id == prayer.id);
      expect(found.title, equals('Update 5'));
    });

    test('should handle marking already answered prayer as answered again', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Test',
        description: 'Test',
        categoryId: 'cat_general',
      );

      await prayerService.markPrayerAnswered(prayer.id, 'First answer');
      await prayerService.markPrayerAnswered(prayer.id, 'Second answer');

      final answered = await prayerService.getAnsweredPrayers();
      final found = answered.firstWhere((p) => p.id == prayer.id);
      expect(found.answerDescription, equals('Second answer'));
    });

    test('should handle concurrent prayer creation', () async {
      final futures = List.generate(
        10,
        (i) => prayerService.createPrayer(
          title: 'Prayer $i',
          description: 'Description $i',
          categoryId: 'cat_general',
        ),
      );

      final prayers = await Future.wait(futures);
      expect(prayers.length, equals(10));

      final allIds = prayers.map((p) => p.id).toSet();
      expect(allIds.length, equals(10)); // All unique IDs
    });
  });

  group('Prayer Statistics', () {
    test('should calculate prayer statistics correctly', () async {
      // Create 5 prayers
      for (int i = 1; i <= 5; i++) {
        await prayerService.createPrayer(
          title: 'Prayer $i',
          description: 'Test prayer',
          categoryId: 'cat_general',
        );
      }

      // Answer 2 of them
      final all = await prayerService.getAllPrayers();
      await prayerService.markPrayerAnswered(all[0].id, 'Answered 1');
      await prayerService.markPrayerAnswered(all[1].id, 'Answered 2');

      expect(await prayerService.getPrayerCount(), equals(5));
      expect(await prayerService.getAnsweredPrayerCount(), equals(2));
      expect((await prayerService.getActivePrayers()).length, equals(3));
    });

    test('should track prayer lifecycle', () async {
      final prayer = await prayerService.createPrayer(
        title: 'Lifecycle Test',
        description: 'Testing full lifecycle',
        categoryId: 'cat_guidance',
      );

      // Initially active
      var active = await prayerService.getActivePrayers();
      expect(active.any((p) => p.id == prayer.id), isTrue);

      // Mark as answered
      await prayerService.markPrayerAnswered(prayer.id, 'Guidance received');

      // Now in answered
      var answered = await prayerService.getAnsweredPrayers();
      expect(answered.any((p) => p.id == prayer.id), isTrue);

      // Not in active anymore
      active = await prayerService.getActivePrayers();
      expect(active.any((p) => p.id == prayer.id), isFalse);
    });
  });
}
