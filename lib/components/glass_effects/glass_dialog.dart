import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Shows a glass morphism style dialog
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration transitionDuration = const Duration(milliseconds: 300),
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.5),
    transitionDuration: transitionDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return child;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}