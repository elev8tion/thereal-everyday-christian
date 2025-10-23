import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/navigation/app_routes.dart';
import 'package:everyday_christian/core/navigation/navigation_service.dart';

void main() {
  group('AppRoutes', () {
    test('should have correct route constants', () {
      expect(AppRoutes.splash, equals('/splash'));
      expect(AppRoutes.onboarding, equals('/onboarding'));
      expect(AppRoutes.auth, equals('/auth'));
      expect(AppRoutes.home, equals('/home'));
      expect(AppRoutes.chat, equals('/chat'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.prayerJournal, equals('/prayer-journal'));
      expect(AppRoutes.verseLibrary, equals('/verse-library'));
      expect(AppRoutes.profile, equals('/profile'));
      expect(AppRoutes.devotional, equals('/devotional'));
      expect(AppRoutes.readingPlan, equals('/reading-plan'));
    });

    test('should have correct auth-required routes', () {
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.home));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.chat));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.settings));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.prayerJournal));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.verseLibrary));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.profile));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.devotional));
      expect(AppRoutes.authRequiredRoutes, contains(AppRoutes.readingPlan));
      expect(AppRoutes.authRequiredRoutes.length, equals(8));
    });

    test('should have correct public routes', () {
      expect(AppRoutes.publicRoutes, contains(AppRoutes.splash));
      expect(AppRoutes.publicRoutes, contains(AppRoutes.onboarding));
      expect(AppRoutes.publicRoutes, contains(AppRoutes.auth));
      expect(AppRoutes.publicRoutes.length, equals(3));
    });

    test('should correctly identify auth-required routes', () {
      expect(AppRoutes.isAuthRequired(AppRoutes.home), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.chat), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.settings), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.prayerJournal), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.verseLibrary), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.profile), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.devotional), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.readingPlan), isTrue);
    });

    test('should correctly identify public routes', () {
      expect(AppRoutes.isPublicRoute(AppRoutes.splash), isTrue);
      expect(AppRoutes.isPublicRoute(AppRoutes.onboarding), isTrue);
      expect(AppRoutes.isPublicRoute(AppRoutes.auth), isTrue);
    });

    test('should return false for non-auth routes in isAuthRequired', () {
      expect(AppRoutes.isAuthRequired(AppRoutes.splash), isFalse);
      expect(AppRoutes.isAuthRequired(AppRoutes.onboarding), isFalse);
      expect(AppRoutes.isAuthRequired(AppRoutes.auth), isFalse);
    });

    test('should return false for auth-required routes in isPublicRoute', () {
      expect(AppRoutes.isPublicRoute(AppRoutes.home), isFalse);
      expect(AppRoutes.isPublicRoute(AppRoutes.chat), isFalse);
      expect(AppRoutes.isPublicRoute(AppRoutes.settings), isFalse);
    });

    test('should handle unknown routes in isAuthRequired', () {
      expect(AppRoutes.isAuthRequired('/unknown-route'), isFalse);
      expect(AppRoutes.isAuthRequired(''), isFalse);
    });

    test('should handle unknown routes in isPublicRoute', () {
      expect(AppRoutes.isPublicRoute('/unknown-route'), isFalse);
      expect(AppRoutes.isPublicRoute(''), isFalse);
    });

    test('should not have overlapping routes', () {
      final authSet = Set<String>.from(AppRoutes.authRequiredRoutes);
      final publicSet = Set<String>.from(AppRoutes.publicRoutes);
      final intersection = authSet.intersection(publicSet);

      expect(intersection.isEmpty, isTrue);
    });

    test('should have all routes in either auth or public', () {
      final allRoutes = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.auth,
        AppRoutes.home,
        AppRoutes.chat,
        AppRoutes.settings,
        AppRoutes.prayerJournal,
        AppRoutes.verseLibrary,
        AppRoutes.profile,
        AppRoutes.devotional,
        AppRoutes.readingPlan,
      ];

      for (final route in allRoutes) {
        final isInAuth = AppRoutes.authRequiredRoutes.contains(route);
        final isInPublic = AppRoutes.publicRoutes.contains(route);

        expect(isInAuth || isInPublic, isTrue,
            reason: 'Route $route should be in either auth or public routes');
      }
    });
  });

  group('NavigationService', () {
    testWidgets('should have navigator key', (tester) async {
      expect(NavigationService.navigatorKey, isA<GlobalKey<NavigatorState>>());
    });

    testWidgets('should return null navigator when not attached',
        (tester) async {
      final key = GlobalKey<NavigatorState>();
      expect(key.currentState, isNull);
    });

    testWidgets('should navigate using pushNamed', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      String? navigatedRoute;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Text(settings.name ?? 'Unknown'),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to a route
      navigatorKey.currentState?.pushNamed('/test-route');
      await tester.pumpAndSettle();

      expect(navigatedRoute, equals('/test-route'));
    });

    testWidgets('should navigate using pushReplacementNamed', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final routeStack = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            routeStack.add(settings.name ?? 'Unknown');
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Text(settings.name ?? 'Unknown'),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to first route
      navigatorKey.currentState?.pushNamed('/route1');
      await tester.pumpAndSettle();

      // Replace with second route
      navigatorKey.currentState?.pushReplacementNamed('/route2');
      await tester.pumpAndSettle();

      expect(routeStack, contains('/route2'));
    });

    testWidgets('should navigate using pushAndRemoveUntil', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/route1': (_) => const Scaffold(body: Text('Route1')),
            '/route2': (_) => const Scaffold(body: Text('Route2')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to routes
      navigatorKey.currentState?.pushNamed('/route1');
      await tester.pumpAndSettle();

      navigatorKey.currentState?.pushNamed('/route2');
      await tester.pumpAndSettle();

      // Clear stack and go to home
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      await tester.pumpAndSettle();

      expect(navigatorKey.currentState?.canPop(), isFalse);
    });

    testWidgets('should pop navigation', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/route1': (_) => const Scaffold(body: Text('Route1')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to a route
      navigatorKey.currentState?.pushNamed('/route1');
      await tester.pumpAndSettle();

      expect(navigatorKey.currentState?.canPop(), isTrue);

      // Pop
      navigatorKey.currentState?.pop();
      await tester.pumpAndSettle();

      expect(navigatorKey.currentState?.canPop(), isFalse);
    });

    testWidgets('should check canPop correctly', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            '/route1': (_) => const Scaffold(body: Text('Route1')),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Initially can't pop
      expect(navigatorKey.currentState?.canPop(), isFalse);

      // Navigate to a route
      navigatorKey.currentState?.pushNamed('/route1');
      await tester.pumpAndSettle();

      // Now can pop
      expect(navigatorKey.currentState?.canPop(), isTrue);
    });

    testWidgets('should show dialog', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                      title: Text('Test Dialog'),
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('Test Dialog'), findsOneWidget);
    });

    testWidgets('should pass arguments when navigating', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      Object? receivedArguments;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            receivedArguments = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Text('Route: ${settings.name}'),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Navigate with arguments
      final args = {'key': 'value'};
      navigatorKey.currentState?.pushNamed('/test', arguments: args);
      await tester.pumpAndSettle();

      expect(receivedArguments, equals(args));
    });

    testWidgets('should handle pop with result', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        body: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop('test_result');
                          },
                          child: const Text('Pop with result'),
                        ),
                      ),
                    ),
                  );
                  // Result would be 'test_result'
                  expect(result, equals('test_result'));
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pop with result'));
      await tester.pumpAndSettle();
    });
  });

  group('RouteGuard Mixin', () {
    testWidgets('should allow access to public routes without authentication',
        (tester) async {
      final guard = _TestRouteGuard();

      expect(guard.canAccess(AppRoutes.splash, isAuthenticated: false), isTrue);
      expect(guard.canAccess(AppRoutes.onboarding, isAuthenticated: false),
          isTrue);
      expect(guard.canAccess(AppRoutes.auth, isAuthenticated: false), isTrue);
    });

    testWidgets(
        'should block access to auth-required routes without authentication',
        (tester) async {
      // Set up a navigator for NavigationService
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: NavigationService.navigatorKey,
          routes: {
            '/': (_) => const Scaffold(body: Text('Home')),
            AppRoutes.auth: (_) => const Scaffold(body: Text('Auth')),
            AppRoutes.home: (_) => const Scaffold(body: Text('Home Page')),
            AppRoutes.chat: (_) => const Scaffold(body: Text('Chat')),
          },
        ),
      );

      await tester.pumpAndSettle();

      final guard = _TestRouteGuard();

      expect(guard.canAccess(AppRoutes.home, isAuthenticated: false), isFalse);
      expect(guard.canAccess(AppRoutes.chat, isAuthenticated: false), isFalse);
      expect(guard.canAccess(AppRoutes.settings, isAuthenticated: false),
          isFalse);
      expect(guard.canAccess(AppRoutes.prayerJournal, isAuthenticated: false),
          isFalse);
      expect(guard.canAccess(AppRoutes.verseLibrary, isAuthenticated: false),
          isFalse);
      expect(guard.canAccess(AppRoutes.profile, isAuthenticated: false),
          isFalse);
      expect(guard.canAccess(AppRoutes.devotional, isAuthenticated: false),
          isFalse);
      expect(guard.canAccess(AppRoutes.readingPlan, isAuthenticated: false),
          isFalse);
    });

    testWidgets('should allow access to auth-required routes with authentication',
        (tester) async {
      final guard = _TestRouteGuard();

      expect(guard.canAccess(AppRoutes.home, isAuthenticated: true), isTrue);
      expect(guard.canAccess(AppRoutes.chat, isAuthenticated: true), isTrue);
      expect(guard.canAccess(AppRoutes.settings, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.prayerJournal, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.verseLibrary, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.profile, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.devotional, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.readingPlan, isAuthenticated: true),
          isTrue);
    });

    testWidgets('should allow access to public routes with authentication',
        (tester) async {
      final guard = _TestRouteGuard();

      expect(guard.canAccess(AppRoutes.splash, isAuthenticated: true), isTrue);
      expect(guard.canAccess(AppRoutes.onboarding, isAuthenticated: true),
          isTrue);
      expect(guard.canAccess(AppRoutes.auth, isAuthenticated: true), isTrue);
    });

    testWidgets('should handle unknown routes', (tester) async {
      final guard = _TestRouteGuard();

      // Unknown routes are not in authRequiredRoutes, so should return true
      expect(guard.canAccess('/unknown', isAuthenticated: false), isTrue);
      expect(guard.canAccess('', isAuthenticated: false), isTrue);
    });
  });

  group('NavigationService Convenience Methods', () {
    test('should have goToHome method', () {
      expect(NavigationService.goToHome, isA<Function>());
    });

    test('should have goToAuth method', () {
      expect(NavigationService.goToAuth, isA<Function>());
    });

    test('should have goToSplash method', () {
      expect(NavigationService.goToSplash, isA<Function>());
    });

    test('should have goToChat method', () {
      expect(NavigationService.goToChat, isA<Function>());
    });

    test('should have goToDevotional method', () {
      expect(NavigationService.goToDevotional, isA<Function>());
    });

    test('should have goToPrayerJournal method', () {
      expect(NavigationService.goToPrayerJournal, isA<Function>());
    });

    test('should have goToVerseLibrary method', () {
      expect(NavigationService.goToVerseLibrary, isA<Function>());
    });

    test('should have goToSettings method', () {
      expect(NavigationService.goToSettings, isA<Function>());
    });

    test('should have goToProfile method', () {
      expect(NavigationService.goToProfile, isA<Function>());
    });

    test('should have goToReadingPlan method', () {
      expect(NavigationService.goToReadingPlan, isA<Function>());
    });

    test('should have showAppDialog method', () {
      expect(NavigationService.showAppDialog, isA<Function>());
    });

    test('should have showBottomSheet method', () {
      expect(NavigationService.showBottomSheet, isA<Function>());
    });
  });
}

// Test implementation of RouteGuard mixin
class _TestRouteGuard with RouteGuard {}
