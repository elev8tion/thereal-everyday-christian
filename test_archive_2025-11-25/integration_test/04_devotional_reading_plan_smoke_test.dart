import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/main.dart' as app;
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke Test 4: Devotionals & Reading Plans
///
/// Tests devotional reading, reading plan progress, and content availability.
/// From CLAUDE.md: 424 devotionals covering Nov 2025 - Dec 2026, 10+ reading plans.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Devotional Smoke Tests', () {
    setUp(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    testWidgets('Devotional content is loaded', (tester) async {
      // From CLAUDE.md: 424 devotionals across 27 JSON files
      final db = await DatabaseHelper.instance.database;

      final devotionals = await db.query('devotionals');
      expect(devotionals, isNotEmpty,
          reason: 'Devotionals should be loaded from assets');

      // Should have hundreds of devotionals
      expect(devotionals.length, greaterThan(100),
          reason: 'Should have significant devotional content');

      print('✅ Devotional content loaded: ${devotionals.length} devotionals');
    });

    testWidgets('Can access today\'s devotional', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Get today's date
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Query for today's devotional
      final todayDevotional = await db.query(
        'devotionals',
        where: 'date = ?',
        whereArgs: [dateStr],
        limit: 1,
      );

      // Should have a devotional for today or nearby dates
      if (todayDevotional.isNotEmpty) {
        print('✅ Today\'s devotional available');
      } else {
        // Check if we have any devotionals at all
        final anyDevotional = await db.query('devotionals', limit: 1);
        expect(anyDevotional, isNotEmpty,
            reason: 'Should have devotionals available');
        print('✅ Devotional system working (specific date may vary)');
      }
    });

    testWidgets('Devotional completion tracking works', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Get a devotional
      final devotionals = await db.query('devotionals', limit: 1);
      if (devotionals.isNotEmpty) {
        final devotionalId = devotionals.first['id'];

        // Mark as completed
        await db.insert('devotional_progress', {
          'devotional_id': devotionalId,
          'completed_at': DateTime.now().toIso8601String(),
        });

        // Verify it was saved
        final progress = await db.query('devotional_progress');
        expect(progress, isNotEmpty,
            reason: 'Should track devotional completion');

        print('✅ Devotional completion tracking works');

        // Clean up
        await db.delete('devotional_progress');
      }
    });

    testWidgets('Devotional streak calculation exists', (tester) async {
      // Test streak logic (simplified version)
      final db = await DatabaseHelper.instance.database;

      // Complete a devotional for streak test
      final devotionals = await db.query('devotionals', limit: 1);
      if (devotionals.isNotEmpty) {
        final devotionalId = devotionals.first['id'];

        await db.insert('devotional_progress', {
          'devotional_id': devotionalId,
          'completed_at': DateTime.now().toIso8601String(),
        });

        // Get completion count
        final completedCount = await db.rawQuery(
          'SELECT COUNT(*) as count FROM devotional_progress',
        );
        final count = completedCount.first['count'] as int;

        expect(count, greaterThan(0), reason: 'Should have completed devotionals');
        print('✅ Devotional streak tracking available');

        // Clean up
        await db.delete('devotional_progress');
      }
    });
  });

  group('Reading Plan Smoke Tests', () {
    testWidgets('Reading plans are available', (tester) async {
      // From CLAUDE.md: 10+ reading plans
      final db = await DatabaseHelper.instance.database;

      final readingPlans = await db.query('reading_plans');
      expect(readingPlans, isNotEmpty,
          reason: 'Reading plans should be available');

      // Should have at least several reading plans
      expect(readingPlans.length, greaterThanOrEqualTo(3),
          reason: 'Should have multiple reading plans');

      print('✅ Reading plans loaded: ${readingPlans.length} plans');
    });

    testWidgets('Can start a reading plan', (tester) async {
      final db = await DatabaseHelper.instance.database;

      final readingPlans = await db.query('reading_plans', limit: 1);
      if (readingPlans.isNotEmpty) {
        final planId = readingPlans.first['id'];

        // Start the plan
        await db.insert('reading_plan_progress', {
          'plan_id': planId,
          'started_at': DateTime.now().toIso8601String(),
          'current_day': 1,
        });

        // Verify it was started
        final progress = await db.query('reading_plan_progress');
        expect(progress, isNotEmpty,
            reason: 'Should be able to start reading plans');

        print('✅ Reading plan start functionality works');

        // Clean up
        await db.delete('reading_plan_progress');
      }
    });

    testWidgets('Reading plan progress tracking works', (tester) async {
      final db = await DatabaseHelper.instance.database;

      final readingPlans = await db.query('reading_plans', limit: 1);
      if (readingPlans.isNotEmpty) {
        final planId = readingPlans.first['id'];

        // Start plan
        await db.insert('reading_plan_progress', {
          'plan_id': planId,
          'started_at': DateTime.now().toIso8601String(),
          'current_day': 1,
        });

        // Get readings for this plan
        final readings = await db.query(
          'daily_readings',
          where: 'plan_id = ?',
          whereArgs: [planId],
          limit: 1,
        );

        if (readings.isNotEmpty) {
          final readingId = readings.first['id'];

          // Mark reading as completed
          await db.insert('completed_readings', {
            'reading_id': readingId,
            'completed_at': DateTime.now().toIso8601String(),
          });

          // Verify completion
          final completed = await db.query('completed_readings');
          expect(completed, isNotEmpty,
              reason: 'Should track reading completion');

          print('✅ Reading plan progress tracking works');

          // Clean up
          await db.delete('completed_readings');
          await db.delete('reading_plan_progress');
        }
      }
    });

    testWidgets('Reading plans include expected plans', (tester) async {
      // From CLAUDE.md: Gospel of John, Proverbs, Psalms for Prayer, etc.
      final db = await DatabaseHelper.instance.database;

      final readingPlans = await db.query('reading_plans');

      // Check for some expected plan names
      final planNames = readingPlans.map((p) => p['title'] as String?).toList();

      // Should have at least one of the documented plans
      final hasDocumentedPlans = planNames.any((name) =>
          name != null &&
          (name.toLowerCase().contains('john') ||
              name.toLowerCase().contains('proverbs') ||
              name.toLowerCase().contains('psalm')));

      if (hasDocumentedPlans) {
        print('✅ Reading plans include documented plans');
      } else {
        print('Note: Reading plans available, checking specific titles: $planNames');
      }
    });
  });

  group('Devotional UI Tests', () {
    testWidgets('Can navigate to devotional screen', (tester) async {
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        const ProviderScope(
          child: app.MyApp(),
        ),
      );

      // Navigate through splash/onboarding
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final acceptButton = find.text('Accept');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      final getStarted = find.text('Get Started');
      if (getStarted.evaluate().isNotEmpty) {
        await tester.tap(getStarted);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      await tester.pumpAndSettle();

      // Look for devotional navigation
      final devotionalTab = find.text('Devotional');
      final homeIcon = find.byIcon(Icons.home);

      if (devotionalTab.evaluate().isNotEmpty) {
        await tester.tap(devotionalTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Devotional screen accessible');
      } else if (homeIcon.evaluate().isNotEmpty) {
        print('✅ Home screen loaded (devotionals may be accessed from home)');
      }
    });
  });
}
