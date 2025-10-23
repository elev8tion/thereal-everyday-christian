import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/navigation/navigation_service.dart';
import 'package:everyday_christian/core/navigation/app_routes.dart';

void main() {
  group('NavigationService Static Properties', () {
    test('should have navigator key', () {
      expect(NavigationService.navigatorKey, isNotNull);
    });
  });

  group('AppRoutes', () {
    test('should define route constants', () {
      expect(AppRoutes.splash, equals('/splash'));
      expect(AppRoutes.auth, equals('/auth'));
      expect(AppRoutes.home, equals('/home'));
      expect(AppRoutes.chat, equals('/chat'));
      expect(AppRoutes.devotional, equals('/devotional'));
      expect(AppRoutes.prayerJournal, equals('/prayer-journal'));
      expect(AppRoutes.verseLibrary, equals('/verse-library'));
      expect(AppRoutes.settings, equals('/settings'));
      expect(AppRoutes.profile, equals('/profile'));
      expect(AppRoutes.readingPlan, equals('/reading-plan'));
    });

    test('should identify auth required routes', () {
      expect(AppRoutes.isAuthRequired(AppRoutes.home), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.chat), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.settings), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.prayerJournal), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.verseLibrary), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.profile), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.devotional), isTrue);
      expect(AppRoutes.isAuthRequired(AppRoutes.readingPlan), isTrue);
    });

    test('should identify public routes', () {
      expect(AppRoutes.isPublicRoute(AppRoutes.splash), isTrue);
      expect(AppRoutes.isPublicRoute(AppRoutes.auth), isTrue);
      expect(AppRoutes.isPublicRoute(AppRoutes.onboarding), isTrue);
    });

    test('should correctly categorize routes', () {
      expect(AppRoutes.isAuthRequired(AppRoutes.splash), isFalse);
      expect(AppRoutes.isAuthRequired(AppRoutes.auth), isFalse);
      expect(AppRoutes.isPublicRoute(AppRoutes.home), isFalse);
      expect(AppRoutes.isPublicRoute(AppRoutes.chat), isFalse);
    });
  });

  group('RouteGuard Mixin', () {
    test('should allow access to non-auth-required routes when not authenticated', () {
      final guard = _TestRouteGuard();
      expect(guard.canAccess('/some-public-route', isAuthenticated: false), isTrue);
    });

    test('should allow access when authenticated', () {
      final guard = _TestRouteGuard();
      expect(guard.canAccess(AppRoutes.home, isAuthenticated: true), isTrue);
      expect(guard.canAccess(AppRoutes.chat, isAuthenticated: true), isTrue);
      expect(guard.canAccess(AppRoutes.settings, isAuthenticated: true), isTrue);
    });
  });
}

class _TestRouteGuard with RouteGuard {}
