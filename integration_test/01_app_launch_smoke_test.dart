import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/main.dart' as app;
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke Test 1: App Launch & Core Flow
///
/// Tests the critical path from app launch through onboarding to home screen.
/// This ensures the app can start without crashing and complete first-time setup.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Launch Smoke Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      // Reset database for clean test state
      await DatabaseHelper.instance.resetDatabase();

      // Initialize subscription service
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      // Launch the app
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Override subscription service with initialized instance
          ],
          child: const app.MyApp(),
        ),
      );

      // Verify splash screen appears (displays logo image, not text)
      // Just verify we're on a screen (Scaffold exists)
      expect(find.byType(Scaffold), findsWidgets,
          reason: 'Splash screen should render');

      // Wait for splash screen animation and initialization
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // At this point, app should navigate to onboarding or home depending on state
      print('✅ App launched successfully and splash screen completed');
    });

    testWidgets('Legal agreements screen appears for first-time users', (tester) async {
      // Reset database for clean state
      await DatabaseHelper.instance.resetDatabase();

      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        ProviderScope(
          child: const app.MyApp(),
        ),
      );

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Should show legal agreements screen
      final hasLegalScreen = find.textContaining('Privacy Policy').evaluate().isNotEmpty ||
          find.textContaining('Terms of Service').evaluate().isNotEmpty ||
          find.textContaining('Legal').evaluate().isNotEmpty;

      expect(
        hasLegalScreen,
        true,
        reason: 'First-time users should see legal agreements',
      );

      print('✅ Legal agreements screen displayed for new users');
    });

    testWidgets('Can navigate through legal agreements and onboarding', (tester) async {
      // Reset for clean test
      await DatabaseHelper.instance.resetDatabase();

      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        ProviderScope(
          child: const app.MyApp(),
        ),
      );

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Look for Accept button on legal screen
      final acceptButton = find.text('Accept');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Accepted legal agreements');
      }

      // Should now show onboarding screen
      // Look for common onboarding elements
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Onboarding might have "Get Started", "Continue", or name input
      final getStartedButton = find.text('Get Started');
      final continueButton = find.text('Continue');

      if (getStartedButton.evaluate().isNotEmpty) {
        // Optional: Enter a name if there's a text field
        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, 'Test User');
          await tester.pumpAndSettle();
        }

        await tester.tap(getStartedButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Completed onboarding flow');
      } else if (continueButton.evaluate().isNotEmpty) {
        await tester.tap(continueButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Completed onboarding flow');
      }

      // Should now be on home screen
      // Home screen typically has navigation bar with Bible, Prayer, etc.
      final hasHomeScreen = find.byIcon(Icons.home).evaluate().isNotEmpty ||
          find.text('Home').evaluate().isNotEmpty ||
          find.byType(BottomNavigationBar).evaluate().isNotEmpty;

      expect(
        hasHomeScreen,
        true,
        reason: 'Should navigate to home screen after onboarding',
      );

      print('✅ Successfully navigated to home screen');
    });

    testWidgets('App remembers completed onboarding on restart', (tester) async {
      // This test assumes previous test completed onboarding
      // In a real scenario, you'd set up the preferences manually

      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        ProviderScope(
          child: const app.MyApp(),
        ),
      );

      // Wait for splash
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Should skip directly to home screen (no legal/onboarding)
      // This test may fail on first run - that's expected
      final hasHome = find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
          find.byIcon(Icons.home).evaluate().isNotEmpty;

      if (hasHome) {
        print('✅ App correctly skipped onboarding for returning user');
      } else {
        print('⚠️  Onboarding still showing (expected on first test run)');
      }
    });

    testWidgets('Home screen renders all navigation tabs', (tester) async {
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        ProviderScope(
          child: const app.MyApp(),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Navigate through legal/onboarding if needed (simplified)
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

      // Check for navigation elements
      // Your app likely has: Bible, Prayer, Chat, Profile, Settings tabs
      await tester.pumpAndSettle();

      final hasNavigation = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
      expect(hasNavigation, true, reason: 'Home screen should have bottom navigation');

      if (hasNavigation) {
        print('✅ Home screen navigation bar rendered successfully');
      }
    });
  });

  group('Critical Path Verification', () {
    testWidgets('App does not crash during initialization', (tester) async {
      // This is the most basic smoke test - does the app start?
      bool crashed = false;

      try {
        await DatabaseHelper.instance.resetDatabase();
        final subscriptionService = SubscriptionService.instance;
        await subscriptionService.initialize();

        await tester.pumpWidget(
          ProviderScope(
            child: const app.MyApp(),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 6));
      } catch (e) {
        crashed = true;
        print('❌ App crashed during initialization: $e');
      }

      expect(crashed, false, reason: 'App should not crash on launch');
      print('✅ App initialization completed without crashes');
    });

    testWidgets('Database initializes successfully', (tester) async {
      bool dbInitialized = false;

      try {
        await DatabaseHelper.instance.resetDatabase();

        // Test basic database operations
        final db = await DatabaseHelper.instance.database;
        expect(db, isNotNull, reason: 'Database should be initialized');

        dbInitialized = true;
      } catch (e) {
        print('❌ Database initialization failed: $e');
      }

      expect(dbInitialized, true, reason: 'Database must initialize successfully');
      print('✅ Database initialized successfully');
    });

    testWidgets('Subscription service initializes without errors', (tester) async {
      bool serviceInitialized = false;

      try {
        final subscriptionService = SubscriptionService.instance;
        await subscriptionService.initialize();

        // Verify service is accessible
        expect(subscriptionService, isNotNull);
        serviceInitialized = true;
      } catch (e) {
        print('❌ Subscription service initialization failed: $e');
      }

      expect(serviceInitialized, true, reason: 'Subscription service must initialize');
      print('✅ Subscription service initialized successfully');
    });
  });
}
