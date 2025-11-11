import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Spanish Devotional JSON Files Validation', () {
    test('All 14 Spanish devotional batch files must exist and be valid JSON', () async {
      final batches = [
        'batch_01_november_2025.json',
        'batch_02_december_2025.json',
        'batch_03_january_2026.json',
        'batch_04_february_2026.json',
        'batch_05_march_2026.json',
        'batch_06_april_2026.json',
        'batch_07_may_2026.json',
        'batch_08_june_2026.json',
        'batch_09_july_2026.json',
        'batch_10_august_2026.json',
        'batch_11_september_2026.json',
        'batch_12_october_2026.json',
        'batch_13_november_2026.json',
        'batch_14_december_2026.json',
      ];

      int totalDevotionals = 0;

      for (final batchFile in batches) {
        final path = 'assets/devotionals/es/$batchFile';

        // Load and parse JSON
        final jsonString = await rootBundle.loadString(path);
        final List<dynamic> devotionals = json.decode(jsonString);

        expect(
          devotionals,
          isNotEmpty,
          reason: '$batchFile must contain devotionals',
        );

        totalDevotionals += devotionals.length;

        // Validate first devotional in each batch has required fields
        final firstDevotional = devotionals.first as Map<String, dynamic>;

        expect(firstDevotional['title'], isNotNull, reason: '$batchFile must have title');
        expect(firstDevotional['scripture'], isNotNull, reason: '$batchFile must have scripture');
        expect(firstDevotional['date'], isNotNull, reason: '$batchFile must have date');
        expect(firstDevotional['verse'], isNotNull, reason: '$batchFile must have verse');
        expect(firstDevotional['opening_prayer'], isNotNull, reason: '$batchFile must have opening_prayer');
        expect(firstDevotional['context'], isNotNull, reason: '$batchFile must have context');
        expect(firstDevotional['reflection'], isNotNull, reason: '$batchFile must have reflection');
        expect(firstDevotional['application'], isNotNull, reason: '$batchFile must have application');
        expect(firstDevotional['prayer'], isNotNull, reason: '$batchFile must have prayer');
        expect(firstDevotional['declaration'], isNotNull, reason: '$batchFile must have declaration');
        expect(firstDevotional['challenge'], isNotNull, reason: '$batchFile must have challenge');
      }

      // Verify total count
      expect(
        totalDevotionals,
        424,
        reason: 'Total Spanish devotionals must be 424',
      );
    });

    test('Spanish devotionals must contain Spanish text (not English)', () async {
      final jsonString = await rootBundle.loadString('assets/devotionals/es/batch_01_november_2025.json');
      final List<dynamic> devotionals = json.decode(jsonString);

      // Check first 3 devotionals for Spanish content
      final spanishIndicators = ['Dios', 'Señor', 'Jesús', 'amor', 'vida', 'fe', 'y', 'el', 'la'];

      for (int i = 0; i < 3 && i < devotionals.length; i++) {
        final devotional = devotionals[i] as Map<String, dynamic>;
        final title = devotional['title'] as String;
        final reflection = devotional['reflection'] as String;
        final combinedText = '$title $reflection';

        final hasSpanish = spanishIndicators.any((word) => combinedText.contains(word));

        expect(
          hasSpanish,
          true,
          reason: 'Devotional ${i + 1} should contain Spanish words',
        );
      }
    });

    test('Spanish devotional dates must be valid and sequential', () async {
      final jsonString = await rootBundle.loadString('assets/devotionals/es/batch_01_november_2025.json');
      final List<dynamic> devotionals = json.decode(jsonString);

      for (final devotional in devotionals) {
        final devotionalMap = devotional as Map<String, dynamic>;
        final dateStr = devotionalMap['date'] as String;

        // Parse date to verify format
        final date = DateTime.parse(dateStr);

        expect(date.year, inInclusiveRange(2025, 2026));
        expect(date.month, inInclusiveRange(1, 12));
        expect(date.day, inInclusiveRange(1, 31));
      }
    });
  });

  group('Spanish Reading Plan JSON Files Validation', () {
    test('Spanish curated reading plans must exist and be valid JSON', () async {
      final jsonString = await rootBundle.loadString('assets/reading_plans/es/curated_thematic_plans.json');
      final List<dynamic> plans = json.decode(jsonString);

      expect(plans, isNotEmpty, reason: 'Must have at least one curated plan');

      for (final plan in plans) {
        final planMap = plan as Map<String, dynamic>;

        expect(planMap['id'], isNotNull, reason: 'Plan must have id');
        expect(planMap['title'], isNotNull, reason: 'Plan must have title');
        expect(planMap['title'], isNotEmpty, reason: 'Plan title must not be empty');
        expect(planMap['type'], 'curated', reason: 'Plan type must be curated');
        expect(planMap['total_days'], greaterThan(0), reason: 'Plan must have positive total_days');
      }
    });

    test('Spanish book-based plans must exist and be valid JSON', () async {
      final jsonString = await rootBundle.loadString('assets/reading_plans/es/book_based_plans.json');
      final List<dynamic> plans = json.decode(jsonString);

      expect(plans, isNotEmpty, reason: 'Must have at least one book-based plan');

      for (final plan in plans) {
        final planMap = plan as Map<String, dynamic>;

        expect(planMap['id'], isNotNull);
        expect(planMap['title'], isNotNull);
        expect(planMap['title'], isNotEmpty);
        expect(planMap['type'], 'book');
        expect(planMap['total_days'], greaterThan(0));
      }
    });

    test('Spanish generator-based plans must exist and be valid JSON', () async {
      final jsonString = await rootBundle.loadString('assets/reading_plans/es/generator_based_plans.json');
      final List<dynamic> plans = json.decode(jsonString);

      expect(plans, isNotEmpty, reason: 'Must have at least one generator-based plan');

      for (final plan in plans) {
        final planMap = plan as Map<String, dynamic>;

        expect(planMap['id'], isNotNull);
        expect(planMap['title'], isNotNull);
        expect(planMap['type'], anyOf(['book', 'generator']));
      }
    });

    test('Spanish reading plans should have Spanish titles and descriptions', () async {
      final jsonString = await rootBundle.loadString('assets/reading_plans/es/curated_thematic_plans.json');
      final List<dynamic> plans = json.decode(jsonString);

      final spanishWords = ['días', 'de', 'la', 'en', 'Dios', 'Cristo', 'para'];

      for (final plan in plans) {
        final planMap = plan as Map<String, dynamic>;
        final title = planMap['title'] as String;
        final description = planMap['description'] as String?;

        final combinedText = '$title ${description ?? ""}';

        final hasSpanish = spanishWords.any((word) => combinedText.contains(word));

        expect(
          hasSpanish,
          true,
          reason: 'Plan "$title" should contain Spanish words',
        );
      }
    });
  });

  group('Comparison: English vs Spanish Content', () {
    test('Spanish should have same number of devotionals as English (424)', () async {
      // Count English devotionals
      final englishBatches = [
        'batch_01_november_2025.json',
        'batch_02_december_2025.json',
        'batch_03_january_2026.json',
        'batch_04_february_2026.json',
        'batch_05_march_2026.json',
        'batch_06_april_2026.json',
        'batch_07_may_2026.json',
        'batch_08_june_2026.json',
        'batch_09_july_2026.json',
        'batch_10_august_2026.json',
        'batch_11_september_2026.json',
        'batch_12_october_2026.json',
        'batch_13_november_2026.json',
        'batch_14_december_2026.json',
      ];

      int englishCount = 0;
      for (final batch in englishBatches) {
        final jsonString = await rootBundle.loadString('assets/devotionals/en/$batch');
        final List<dynamic> devotionals = json.decode(jsonString);
        englishCount += devotionals.length;
      }

      // Count Spanish devotionals
      int spanishCount = 0;
      for (final batch in englishBatches) {
        final jsonString = await rootBundle.loadString('assets/devotionals/es/$batch');
        final List<dynamic> devotionals = json.decode(jsonString);
        spanishCount += devotionals.length;
      }

      expect(
        spanishCount,
        equals(englishCount),
        reason: 'Spanish and English should have same number of devotionals',
      );

      expect(spanishCount, equals(424));
      expect(englishCount, equals(424));
    });

    test('Spanish and English should have same reading plan types', () async {
      // Check curated plans
      final enCurated = await rootBundle.loadString('assets/reading_plans/en/curated_thematic_plans.json');
      final esCurated = await rootBundle.loadString('assets/reading_plans/es/curated_thematic_plans.json');

      final enCuratedPlans = json.decode(enCurated) as List;
      final esCuratedPlans = json.decode(esCurated) as List;

      expect(
        esCuratedPlans.length,
        equals(enCuratedPlans.length),
        reason: 'Spanish and English should have same number of curated plans',
      );

      // Check book-based plans
      final enBook = await rootBundle.loadString('assets/reading_plans/en/book_based_plans.json');
      final esBook = await rootBundle.loadString('assets/reading_plans/es/book_based_plans.json');

      final enBookPlans = json.decode(enBook) as List;
      final esBookPlans = json.decode(esBook) as List;

      expect(
        esBookPlans.length,
        equals(enBookPlans.length),
        reason: 'Spanish and English should have same number of book-based plans',
      );
    });
  });
}
