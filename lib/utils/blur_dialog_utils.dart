import 'dart:ui';
import 'package:flutter/material.dart';

/// Utility functions for showing dialogs and bottom sheets with blurred backdrops
/// (EXACT same animation as the FAB navigation menu)

/// Shows a dialog with a blurred backdrop behind it
///
/// Uses the EXACT same animation pattern as the FAB menu:
/// - BackdropFilter with animated blur (sigmaX/Y: 0→8)
/// - Semi-transparent black overlay with animated opacity (0→0.3)
/// - Smooth reverse animation completion (waits before dismissing)
/// - Fade + Scale transition for dialog content
///
/// All parameters are passed through to showGeneralDialog unchanged.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ?? 'Dismiss',
    barrierColor: Colors.transparent, // Make barrier transparent so blur shows
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    transitionDuration: const Duration(milliseconds: 700), // Same as FAB menu
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // EXACT same animation pattern as FAB menu (glassmorphic_fab_menu.dart:138-165)
      return GestureDetector(
        onTap: barrierDismissible ? () => Navigator.of(context).pop() : null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Animated blurred backdrop - EXACT same as FAB menu
            Positioned.fill(
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: animation.value * 8, // 0→8 during open, 8→0 during close
                      sigmaY: animation.value * 8,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3 * animation.value), // 0→0.3
                    ),
                  );
                },
              ),
            ),
            // Dialog content with fade + scale animation (like FAB menu items)
            Center(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastEaseInToSlowEaseOut, // Same curve as FAB menu
                ),
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.fastEaseInToSlowEaseOut,
                  ),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Shows a bottom sheet with a blurred backdrop behind it
///
/// Uses the EXACT same animation pattern as the FAB menu:
/// - BackdropFilter with animated blur (sigmaX/Y: 0→8)
/// - Semi-transparent black overlay with animated opacity (0→0.3)
/// - Smooth reverse animation completion (waits before dismissing)
/// - SlideTransition for bottom sheet content
///
/// All parameters are passed through to showGeneralDialog unchanged.
Future<T?> showBlurredBottomSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: isDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 700), // Same as FAB menu
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: builder(context),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // EXACT same animation pattern as FAB menu
      return Stack(
        children: [
          // Animated blurred backdrop - EXACT same as FAB menu
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible ? () => Navigator.of(context).pop() : null,
              behavior: HitTestBehavior.opaque,
              child: AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: animation.value * 8, // 0→8 during open, 8→0 during close
                      sigmaY: animation.value * 8,
                    ),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.3 * animation.value), // 0→0.3
                    ),
                  );
                },
              ),
            ),
          ),
          // Bottom sheet slides up from bottom with smooth curve
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastEaseInToSlowEaseOut, // Same curve as FAB menu
            )),
            child: child,
          ),
        ],
      );
    },
  );
}
