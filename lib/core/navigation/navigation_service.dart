import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../utils/blur_dialog_utils.dart';
import '../../components/base_bottom_sheet.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  static BuildContext? get context => navigator?.context;

  /// Navigate to a route and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Navigate to a route
  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushNamed(routeName, arguments: arguments);
  }

  /// Replace current route
  static Future<T?> pushReplacementNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigator!.pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Go back
  static void pop<T extends Object?>([T? result]) {
    return navigator!.pop(result);
  }

  /// Check if can go back
  static bool canPop() {
    return navigator!.canPop();
  }

  /// Navigate to home and clear stack
  static Future<void> goToHome() {
    return pushAndRemoveUntil(AppRoutes.home);
  }

  /// Navigate to auth and clear stack
  static Future<void> goToAuth() {
    return pushAndRemoveUntil(AppRoutes.auth);
  }

  /// Navigate to splash
  static Future<void> goToSplash() {
    return pushAndRemoveUntil(AppRoutes.splash);
  }

  // ============================================================================
  // Convenience navigation methods for common routes
  // ============================================================================

  /// Navigate to chat screen
  static Future<void> goToChat() {
    return pushNamed(AppRoutes.chat);
  }

  /// Navigate to devotional screen
  static Future<void> goToDevotional() {
    return pushNamed(AppRoutes.devotional);
  }

  /// Navigate to prayer journal screen
  static Future<void> goToPrayerJournal() {
    return pushNamed(AppRoutes.prayerJournal);
  }

  /// Navigate to verse library screen
  static Future<void> goToVerseLibrary() {
    return pushNamed(AppRoutes.verseLibrary);
  }

  /// Navigate to settings screen
  static Future<void> goToSettings() {
    return pushNamed(AppRoutes.settings);
  }

  /// Navigate to profile screen
  static Future<void> goToProfile() {
    return pushNamed(AppRoutes.profile);
  }

  /// Navigate to reading plan screen
  static Future<void> goToReadingPlan() {
    return pushNamed(AppRoutes.readingPlan);
  }

  /// Navigate to Bible browser screen
  static Future<void> goToBibleBrowser() {
    return pushNamed(AppRoutes.bibleBrowser);
  }

  /// Navigate to chapter reading screen with arguments
  /// Arguments should be a Map with: book, startChapter, endChapter, readingId (optional)
  static Future<void> goToChapterReading({
    required String book,
    required int startChapter,
    required int endChapter,
    String? readingId,
  }) {
    return pushNamed(
      AppRoutes.chapterReading,
      arguments: {
        'book': book,
        'startChapter': startChapter,
        'endChapter': endChapter,
        'readingId': readingId,
      },
    );
  }

  /// Show a dialog
  static Future<T?> showAppDialog<T>({
    required Widget dialog,
    bool barrierDismissible = true,
  }) {
    return showBlurredDialog<T>(
      context: context!,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
  }

  /// Show bottom sheet with dark gradient styling
  static Future<T?> showBottomSheet<T>({
    required Widget content,
    bool isScrollControlled = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showHandle = true,
  }) {
    return showCustomBottomSheet<T>(
      context: context!,
      child: content,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      showHandle: showHandle,
    );
  }
}

/// Route guard mixin for checking authentication
mixin RouteGuard {
  bool canAccess(String route, {bool isAuthenticated = false}) {
    if (AppRoutes.isAuthRequired(route) && !isAuthenticated) {
      NavigationService.goToAuth();
      return false;
    }
    return true;
  }
}