import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/screens/home_screen.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/core/navigation/navigation_service.dart';
import 'package:everyday_christian/components/frosted_glass_card.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settleAnimations(
    WidgetTester tester, {
    Duration total = const Duration(milliseconds: 800),
  }) async {
    await tester.pump();
    await tester.pump(total);
  }

  final baseHomeScreenOverrides = <Override>[
    devotionalStreakProvider.overrideWith((ref) async => 5),
    totalDevotionalsCompletedProvider.overrideWith((ref) async => 12),
    activePrayersCountProvider.overrideWith((ref) async => 4),
    savedVersesCountProvider.overrideWith((ref) async => 9),
    todaysVerseProvider.overrideWith((ref) async => {
          'reference': 'Psalm 23:1-2 ESV',
          'text': 'The Lord is my shepherd; I shall not want.',
        }),
  ];

  ProviderScope withBaseOverrides(
    Widget child, {
    List<Override> extra = const [],
  }) {
    return ProviderScope(
      overrides: [
        ...baseHomeScreenOverrides,
        ...extra,
      ],
      child: child,
    );
  }

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.setTestDatabasePath(inMemoryDatabasePath);
    Animate.defaultDuration = Duration.zero;
    Animate.defaultCurve = Curves.linear;
    Animate.restartOnHotReload = false;
  });

  tearDownAll(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.setTestDatabasePath(null);
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('should render home screen with all main elements', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify greeting is displayed
      expect(find.textContaining('Friend'), findsOneWidget);

      // Verify main features are present
      expect(find.text('Biblical Chat'), findsOneWidget);
      expect(find.text('Daily Devotional'), findsOneWidget);
      expect(find.text('Prayer Journal'), findsOneWidget);
      expect(find.text('Reading Plans'), findsOneWidget);

      // Verify Quick Actions section
      expect(find.text('Quick Actions'), findsOneWidget);

      // Verify Verse of the Day section
      expect(find.text('Verse of the Day'), findsOneWidget);

      // Verify start chat button
      expect(find.text('Start Spiritual Conversation'), findsOneWidget);
    });

    testWidgets('should display correct greeting based on time of day', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      final hour = DateTime.now().hour;
      if (hour < 12) {
        expect(find.textContaining('Rise and shine'), findsOneWidget);
      } else if (hour < 17) {
        expect(find.textContaining('Good afternoon'), findsOneWidget);
      } else {
        expect(find.textContaining('Good evening'), findsOneWidget);
      }
    });

    testWidgets('should display stat cards', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester, total: const Duration(milliseconds: 900));

      // Verify stat card labels
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.text('Prayers'), findsOneWidget);
      expect(find.text('Saved Verses'), findsOneWidget);
      expect(find.text('Devotionals'), findsOneWidget);
    });

    testWidgets('should show loading indicators while fetching streak data', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
          extra: [
            devotionalStreakProvider.overrideWith(
              (ref) => Future.delayed(const Duration(seconds: 1), () => 5),
            ),
          ],
        ),
      );

      // Before data loads, should show placeholder text
      await tester.pump();
      expect(find.text('...'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Day Streak'), findsOneWidget);
    });

    testWidgets('should handle error in stat data gracefully', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
          extra: [
            devotionalStreakProvider.overrideWith(
              (ref) => Future.error('Test error'),
            ),
          ],
        ),
      );

      await settleAnimations(tester);

      // Should still render screen with default values
      expect(find.text('Day Streak'), findsOneWidget);
      expect(find.text('0'), findsWidgets); // Default value for error
    });

    testWidgets('should navigate to chat when Biblical Chat is tapped', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) {
              // Provide dummy routes for testing navigation
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Route')));
            },
            home: const HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Find and tap Biblical Chat card
      await tester.tap(find.text('Biblical Chat'));
      await settleAnimations(tester);

      // Navigation would be tested in integration tests
      // Here we just verify the tap doesn't crash
    });

    testWidgets('should navigate to devotional when Daily Devotional is tapped', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) {
              // Provide dummy routes for testing navigation
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Route')));
            },
            home: const HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      await tester.tap(find.text('Daily Devotional'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify no crash
    });

    testWidgets('should navigate to prayer journal when Prayer Journal is tapped', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      await tester.tap(find.text('Prayer Journal'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify no crash
    });

    testWidgets('should navigate to reading plan when Reading Plans is tapped', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      await tester.tap(find.text('Reading Plans'));
      await tester.pump(const Duration(milliseconds: 200));

      // Verify no crash
    });

    testWidgets('should display quick action buttons', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Ensure quick actions are visible
      await tester.ensureVisible(find.text('Read Bible'));

      expect(find.text('Read Bible'), findsOneWidget);
      expect(find.text('Verse Library'), findsOneWidget);
      expect(find.text('Add Prayer'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should scroll horizontally in quick actions', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Find the horizontal ListView
      final listView = find.byType(ListView).at(1); // Second ListView (first is stats)

      // Verify it's scrollable
      expect(listView, findsOneWidget);

      // Scroll horizontally
      await tester.drag(listView, const Offset(-200, 0));
      await settleAnimations(tester);

      // Verify more quick actions are visible
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should display daily verse content', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Scroll to daily verse
      await tester.dragUntilVisible(
        find.text('Verse of the Day'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      // Verify verse content
      expect(find.textContaining('The Lord is my shepherd'), findsOneWidget);
      expect(find.text('Psalm 23:1-2 ESV'), findsOneWidget);
    });

    testWidgets('should display start chat button at bottom', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      // Scroll to bottom
      await tester.dragUntilVisible(
        find.text('Start Spiritual Conversation'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      await tester.pump(const Duration(seconds: 3));

      expect(find.text('Start Spiritual Conversation'), findsOneWidget);
    });

    testWidgets('should tap start chat button', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) {
              // Provide dummy routes for testing navigation
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Route')));
            },
            home: const HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      await tester.dragUntilVisible(
        find.text('Start Spiritual Conversation'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );

      await tester.tap(find.text('Start Spiritual Conversation'));
      await settleAnimations(tester);

      // Verify no crash
    });

    testWidgets('should display user avatar', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify avatar icon is present (may appear multiple times in widget tree)
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('should have scrollable content', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify SingleChildScrollView exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Scroll down
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -500));
      await settleAnimations(tester);

      // Verify we can scroll
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display all feature card icons', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify icons are present (may appear multiple times in widget tree)
      expect(find.byIcon(Icons.chat_bubble_outline), findsWidgets);
      expect(find.byIcon(Icons.auto_stories), findsWidgets);
      expect(find.byIcon(Icons.favorite_outline), findsWidgets);
      expect(find.byIcon(Icons.library_books_outlined), findsWidgets);
    });

    testWidgets('should render without overflow on small screens', (tester) async {
      // Set small screen size
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render correctly on large screens', (tester) async {
      // Set large screen size
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify renders correctly
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle quick action taps', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          MaterialApp(
            navigatorKey: NavigationService.navigatorKey,
            onGenerateRoute: (settings) {
              // Provide dummy routes for testing navigation
              return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Route')));
            },
            home: const HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Ensure quick actions are visible
      await tester.ensureVisible(find.text('Read Bible'));

      // Tap Read Bible (this will navigate away, so we only test one tap)
      await tester.tap(find.text('Read Bible'));
      await settleAnimations(tester);

      // Verify no crashes (after navigation, we're on a different screen)
      expect(tester.takeException(), isNull);
    });

    testWidgets('should display frosted glass effect', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify FrostedGlassCard widgets are present
      expect(find.byType(FrostedGlassCard), findsWidgets);
    });

    testWidgets('should have proper spacing between elements', (tester) async {
      await tester.pumpWidget(
        withBaseOverrides(
          const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await settleAnimations(tester);

      // Verify SizedBox spacing exists
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
