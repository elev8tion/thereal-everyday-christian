import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final double borderWidth;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 24,
    this.blurSigma = 40,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: borderColor ?? (isDark ? Colors.white24 : Colors.white54),
                width: borderWidth,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blurStrength;
  final List<Color>? gradientColors;
  final List<double>? gradientStops;
  final Border? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 24,
    this.blurStrength = 4.0,
    this.gradientColors,
    this.gradientStops,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors = [
      Colors.white.withValues(alpha: 0.15),
      Colors.white.withValues(alpha: 0.05),
    ];

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? defaultGradientColors,
          stops: gradientStops ?? const [0.0, 1.0],
          begin: const AlignmentDirectional(0.98, -1.0),
          end: const AlignmentDirectional(-0.98, 1.0),
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

class GlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;

  const GlassBottomSheet({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.blurSigma = 40,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Helper to show bottom sheet with full-screen backdrop blur
///
/// DEPRECATED: Use `showCustomBottomSheet` from `base_bottom_sheet.dart` instead
/// for consistent dark gradient styling across the app.
@Deprecated('Use showCustomBottomSheet from base_bottom_sheet.dart instead')
Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: child,
    ),
  );
}