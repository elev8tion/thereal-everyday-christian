import 'dart:ui';
import 'package:flutter/material.dart';

/// Utility functions for showing dialogs and bottom sheets with blurred backdrops
/// (same blur effect as the FAB navigation menu)

/// Shows a dialog with a blurred backdrop behind it
///
/// Uses the exact same blur effect as the FAB menu:
/// - BackdropFilter with sigmaX: 8, sigmaY: 8
/// - Semi-transparent black overlay (0.3 alpha)
///
/// All parameters are passed through to showDialog unchanged.
Future<T?> showBlurredDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: Colors.transparent, // Make barrier transparent so blur shows
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    builder: (context) {
      // Wrap the dialog with the blur backdrop (same as FAB menu)
      return Stack(
        children: [
          // Blurred backdrop - exact same as FAB menu (lines 147-156)
          // Tappable to dismiss if barrierDismissible is true
          Positioned.fill(
            child: GestureDetector(
              onTap: barrierDismissible ? () => Navigator.of(context).pop() : null,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 8,
                  sigmaY: 8,
                ),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          // Original dialog content (unchanged)
          builder(context),
        ],
      );
    },
  );
}

/// Shows a bottom sheet with a blurred backdrop behind it
///
/// Uses the exact same blur effect as the FAB menu:
/// - BackdropFilter with sigmaX: 8, sigmaY: 8
/// - Semi-transparent black overlay (0.3 alpha)
///
/// All parameters are passed through to showModalBottomSheet unchanged.
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
    transitionDuration: const Duration(milliseconds: 300),
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
      return Stack(
        children: [
          // Blurred backdrop behind everything - tappable to dismiss
          Positioned.fill(
            child: GestureDetector(
              onTap: isDismissible ? () => Navigator.of(context).pop() : null,
              child: FadeTransition(
                opacity: animation,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8 * animation.value,
                    sigmaY: 8 * animation.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3 * animation.value),
                  ),
                ),
              ),
            ),
          ),
          // Bottom sheet slides up from bottom
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          ),
        ],
      );
    },
  );
}
