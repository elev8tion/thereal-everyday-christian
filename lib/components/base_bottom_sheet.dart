import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Base bottom sheet widget with consistent dark gradient styling
///
/// This is the UNIVERSAL bottom sheet style used throughout the app.
/// Provides:
/// - Dark gradient background for maximum content readability
/// - Consistent rounded corners and drag handle
/// - Optional title header
/// - Better performance (no backdrop blur)
class BaseBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showHandle;
  final double? height;

  const BaseBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1E293B).withValues(alpha: 0.95), // Slate-800
            const Color(0xFF0F172A).withValues(alpha: 0.98), // Slate-900
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.xs / 4),
              ),
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Universal helper function for showing standardized dark gradient bottom sheets
///
/// This is the RECOMMENDED way to show bottom sheets throughout the app.
/// Provides consistent dark gradient styling for all bottom sheets.
Future<T?> showCustomBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  bool showHandle = true,
  double? height,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    enableDrag: enableDrag,
    isDismissible: isDismissible,
    builder: (context) => BaseBottomSheet(
      title: title,
      showHandle: showHandle,
      height: height,
      child: child,
    ),
  );
}
