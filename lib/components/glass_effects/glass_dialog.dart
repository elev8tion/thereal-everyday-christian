import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../utils/responsive_utils.dart';

/// Shows a glass morphism style dialog
///
/// Uses the EXACT same animation pattern as the FAB menu:
/// - BackdropFilter with animated blur (sigmaX/Y: 0→8)
/// - Semi-transparent black overlay with animated opacity (0→0.3)
/// - Smooth reverse animation completion (waits before dismissing)
/// - Fade + Scale transition for dialog content
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration transitionDuration = const Duration(milliseconds: 700),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.transparent, // Make barrier transparent so blur shows
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
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
                  child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Glass morphism container widget for dialogs - uses main GlassContainer from glass_card.dart

/// Standard glass dialog button
class GlassDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  final bool isPrimary;

  const GlassDialogButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? (isPrimary ? AppTheme.primaryColor : AppTheme.secondaryColor);
    final responsivePaddingHorizontal = ResponsiveUtils.scaleSize(context, 24, minScale: 0.8, maxScale: 1.5);
    final responsivePaddingVertical = ResponsiveUtils.scaleSize(context, 12, minScale: 0.8, maxScale: 1.5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: responsivePaddingHorizontal, vertical: responsivePaddingVertical),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              buttonColor,
              buttonColor.withValues(alpha: 0.8),
              buttonColor,
            ],
            stops: const [0, 0.6, 1],
            begin: const AlignmentDirectional(-1, 0.5),
            end: const AlignmentDirectional(1, -0.5),
          ),
          borderRadius: AppRadius.largeCardRadius,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 5,
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(1, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 11, maxSize: 21),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}