import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Glass style variants for different visual effects
enum GlassStyle {
  /// Frosted glass with medium opacity and gold border (default)
  frosted,

  /// Clear glass with subtle opacity and thin border
  clear,

  /// Elevated glass with strong blur and shadow
  elevated,
}

/// Unified glass card component that consolidates all glass effect variations.
///
/// This component replaces:
/// - FrostedGlassCard
/// - ClearGlassCard
/// - GlassCard
/// - GlassContainer
/// - FrostedGlass
/// - ClearGlass
///
/// Usage:
/// ```dart
/// UnifiedGlassCard(
///   child: Text('Hello'),
/// )
///
/// UnifiedGlassCard.frosted(
///   child: Text('Frosted effect'),
/// )
///
/// UnifiedGlassCard.clear(
///   child: Text('Clear effect'),
/// )
///
/// UnifiedGlassCard.elevated(
///   child: Text('Elevated with shadow'),
/// )
/// ```
class UnifiedGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final GlassStyle style;
  final double? borderRadius;
  final double? blurStrength;
  final Color? borderColor;
  final double? borderWidth;
  final bool showInnerBorder;
  final List<BoxShadow>? boxShadow;

  const UnifiedGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.width,
    this.height,
    this.style = GlassStyle.frosted,
    this.borderRadius,
    this.blurStrength,
    this.borderColor,
    this.borderWidth,
    this.showInnerBorder = true,
    this.boxShadow,
  });

  /// Factory constructor for frosted glass effect (default style)
  /// Medium opacity, gold border, moderate blur
  factory UnifiedGlassCard.frosted({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding = AppSpacing.cardPadding,
    double? width,
    double? height,
    double borderRadius = AppRadius.lg,
    double blurStrength = AppBlur.strong,
    Color? borderColor,
    bool showInnerBorder = true,
  }) {
    return UnifiedGlassCard(
      key: key,
      style: GlassStyle.frosted,
      onTap: onTap,
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      blurStrength: blurStrength,
      borderColor: borderColor,
      showInnerBorder: showInnerBorder,
      child: child,
    );
  }

  /// Factory constructor for clear glass effect
  /// Very subtle opacity, thin border, light blur
  factory UnifiedGlassCard.clear({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding = AppSpacing.cardPadding,
    double? width,
    double? height,
    double borderRadius = AppRadius.sm,
    double blurStrength = AppBlur.light,
    Color? borderColor,
  }) {
    return UnifiedGlassCard(
      key: key,
      style: GlassStyle.clear,
      onTap: onTap,
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      blurStrength: blurStrength,
      borderColor: borderColor,
      showInnerBorder: false,
      child: child,
    );
  }

  /// Factory constructor for elevated glass effect
  /// Strong blur, prominent shadow, theme-aware colors
  factory UnifiedGlassCard.elevated({
    Key? key,
    required Widget child,
    VoidCallback? onTap,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding = AppSpacing.cardPaddingLarge,
    double? width,
    double? height,
    double borderRadius = AppRadius.xl,
    double blurStrength = AppBlur.strong,
    Color? borderColor,
    bool showInnerBorder = true,
  }) {
    return UnifiedGlassCard(
      key: key,
      style: GlassStyle.elevated,
      onTap: onTap,
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      borderRadius: borderRadius,
      blurStrength: blurStrength,
      borderColor: borderColor,
      boxShadow: AppTheme.elevatedShadow,
      showInnerBorder: showInnerBorder,
      child: child,
    );
  }

  /// Get gradient colors based on glass style
  List<Color> _getGradientColors(bool isDark) {
    switch (style) {
      case GlassStyle.frosted:
        return [
          AppColors.glassOverlayLight,
          AppColors.glassOverlayMedium,
        ];
      case GlassStyle.clear:
        return [
          AppColors.glassOverlaySubtle,
          AppColors.glassOverlaySubtle.withValues(alpha: 0.02),
        ];
      case GlassStyle.elevated:
        return isDark
            ? [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.05),
              ]
            : [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.1),
              ];
    }
  }

  /// Get border configuration based on glass style
  Border _getBorder(bool isDark) {
    if (borderColor != null && borderWidth != null) {
      return Border.all(color: borderColor!, width: borderWidth!);
    }

    switch (style) {
      case GlassStyle.frosted:
        return AppBorders.primaryGlass;
      case GlassStyle.clear:
        return AppBorders.primaryGlassThin;
      case GlassStyle.elevated:
        return isDark ? AppBorders.subtle : AppBorders.subtleThick;
    }
  }

  /// Get blur strength based on glass style
  double _getBlurStrength() {
    if (blurStrength != null) return blurStrength!;

    switch (style) {
      case GlassStyle.frosted:
        return AppBlur.strong;
      case GlassStyle.clear:
        return AppBlur.light;
      case GlassStyle.elevated:
        return AppBlur.strong;
    }
  }

  /// Get border radius value
  double _getBorderRadius() {
    if (borderRadius != null) return borderRadius!;

    switch (style) {
      case GlassStyle.frosted:
        return AppRadius.lg;
      case GlassStyle.clear:
        return AppRadius.sm;
      case GlassStyle.elevated:
        return AppRadius.xl;
    }
  }

  /// Get default padding based on style
  EdgeInsetsGeometry _getDefaultPadding() {
    if (padding != null) return padding!;

    switch (style) {
      case GlassStyle.frosted:
        return AppSpacing.cardPadding;
      case GlassStyle.clear:
        return AppSpacing.cardPadding;
      case GlassStyle.elevated:
        return AppSpacing.cardPaddingLarge;
    }
  }

  /// Get box shadow
  List<BoxShadow>? _getBoxShadow() {
    if (boxShadow != null) return boxShadow;

    switch (style) {
      case GlassStyle.frosted:
        return AppTheme.elevatedShadow;
      case GlassStyle.clear:
        return null;
      case GlassStyle.elevated:
        return AppTheme.elevatedShadow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderRadius = _getBorderRadius();
    final effectiveBlur = _getBlurStrength();
    final effectivePadding = _getDefaultPadding();

    Widget cardWidget = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        border: _getBorder(isDark),
        boxShadow: _getBoxShadow(),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(effectiveBorderRadius - 2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(effectiveBorderRadius - 2),
              gradient: LinearGradient(
                colors: _getGradientColors(isDark),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // Add subtle inner border for depth
              border: showInnerBorder
                  ? Border.all(
                      color: AppColors.primaryBorder,
                      width: 1,
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

/// Glass bottom sheet component for modal presentations
class UnifiedGlassBottomSheet extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurStrength;

  const UnifiedGlassBottomSheet({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.xl,
    this.blurStrength = AppBlur.strong,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(borderRadius)),
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.primaryBorder, width: 2),
          ),
          child: child,
        ),
      ),
    );
  }
}
