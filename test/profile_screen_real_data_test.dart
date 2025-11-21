import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:everyday_christian/screens/profile_screen.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('Profile Screen Real Data Integration', () {
    testWidgets('Profile screen uses real devotional streak provider',
        (WidgetTester tester) async {
      // Set larger screen size
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Mock providers with real data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 5),
            activePrayersCountProvider.overrideWith((ref) async => 10),
            answeredPrayersCountProvider.overrideWith((ref) async => 3),
            savedVersesCountProvider.overrideWith((ref) async => 25),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 15),
            currentPrayerStreakProvider.overrideWith((ref) async => 4),
            activeReadingPlansCountProvider.overrideWith((ref) async => 2),
            totalSharesCountProvider.overrideWith((ref) async => 5),
            discipleCompletionCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Wait for async data to load
      await tester.pumpAndSettle();

      // Verify devotional streak displays real data
      expect(find.textContaining('5 days'), findsOneWidget);
    });

    testWidgets('Profile screen displays real prayer count',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 42),
            answeredPrayersCountProvider.overrideWith((ref) async => 12),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify prayer count displays real data
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('Profile screen displays real saved verses count',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 99),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify verses saved count
      expect(find.text('99'), findsOneWidget);
    });

    testWidgets('Profile screen displays real devotionals completed',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 28),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify devotionals completed count
      expect(find.text('28'), findsOneWidget);
    });

    testWidgets('Profile screen handles loading state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Create a completer to control async loading
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async {
              // Simulate slow loading
              await Future.delayed(const Duration(milliseconds: 100));
              return 7;
            }),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      // Pump once to start loading
      await tester.pump();

      // Should show loading state
      expect(find.text('...'), findsAtLeastNWidgets(1));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should now show actual data
      expect(find.textContaining('7 days'), findsOneWidget);
    });

    testWidgets('Profile screen handles error state',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async {
              throw Exception('Failed to load');
            }),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error state (0 days)
      expect(find.textContaining('0 days'), findsOneWidget);
    });

    testWidgets('Achievements unlock based on real prayer streak',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Prayer streak = 7 should unlock Prayer Warrior
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 7),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Prayer Warrior achievement is visible
      expect(find.text('Prayer Warrior'), findsOneWidget);
      expect(find.textContaining('Prayed for 7 days'), findsOneWidget);
    });

    testWidgets('Achievements update with partial progress',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 50 verses saved (progress toward 100)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 50),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Bible Scholar achievement is visible
      expect(find.text('Bible Scholar'), findsOneWidget);
      expect(find.text('Read 100 verses'), findsOneWidget);
    });

    testWidgets('All stats update together when data changes',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 3),
            activePrayersCountProvider.overrideWith((ref) async => 8),
            answeredPrayersCountProvider.overrideWith((ref) async => 2),
            savedVersesCountProvider.overrideWith((ref) async => 15),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 12),
            currentPrayerStreakProvider.overrideWith((ref) async => 3),
            activeReadingPlansCountProvider.overrideWith((ref) async => 1),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all stats are present
      expect(find.textContaining('3 days'), findsOneWidget); // Devotional streak
      expect(find.text('8'), findsOneWidget); // Total prayers
      expect(find.text('15'), findsOneWidget); // Verses saved
      expect(find.text('12'), findsOneWidget); // Devotionals completed
    });

    testWidgets('Profile screen shows zero stats for new user',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // New user with no data
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Achievement progress bar updates with real data',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 20 devotionals completed (progress toward 30)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 20),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Faithful Friend achievement is visible with progress
      expect(find.text('Faithful Friend'), findsOneWidget);
      expect(find.text('Complete 30 devotionals'), findsOneWidget);
    });

    testWidgets('Profile screen header renders correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Your spiritual journey and achievements'), findsOneWidget);
    });

    testWidgets('Stats section has correct title',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 0),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
            totalSharesCountProvider.overrideWith((ref) async => 0),
            discipleCompletionCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('es'),
            ],
            locale: Locale('en'),
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify section titles
      expect(find.text('Your Spiritual Journey'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
    });

    testWidgets('High streak value displays correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Test with high streak value
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            devotionalStreakProvider.overrideWith((ref) async => 365),
            activePrayersCountProvider.overrideWith((ref) async => 0),
            answeredPrayersCountProvider.overrideWith((ref) async => 0),
            savedVersesCountProvider.overrideWith((ref) async => 0),
            totalDevotionalsCompletedProvider.overrideWith((ref) async => 0),
            currentPrayerStreakProvider.overrideWith((ref) async => 0),
            activeReadingPlansCountProvider.overrideWith((ref) async => 0),
            totalSharesCountProvider.overrideWith((ref) async => 0),
            discipleCompletionCountProvider.overrideWith((ref) async => 0),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('es'),
            ],
            locale: Locale('en'),
            home: ProfileScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      // Verify high streak displays
      final textWidgets = find.byType(Text);
      print('Found ${textWidgets.evaluate().length} Text widgets');
      for (final widget in textWidgets.evaluate()) {
        print('Text: ${(widget.widget as Text).data}');
      }
      expect(find.textContaining('365 days'), findsOneWidget);
    });
  });
}
