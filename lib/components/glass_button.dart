import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'glass_card.dart';

/// Enhanced GlassButton with press animations and haptic feedback
///
/// Following Animation Enhancement Rules:
/// - Optional press animation (scale 0.95 default)
/// - Haptic feedback on press (medium impact default)
/// - Maintains all existing functionality
/// - Does not block touch events
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Widget? loadingWidget;
  final Color? borderColor;

  // ✅ NEW OPTIONAL PARAMETERS (with defaults - no breaking changes)
  final bool enablePressAnimation;
  final double pressScale;
  final bool enableHaptics;
  final HapticFeedbackType hapticType;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.loadingWidget,
    this.borderColor,
    // ✅ Optional animation parameters with safe defaults
    this.enablePressAnimation = true,
    this.pressScale = 0.95, // Rule: 0.90-0.98
    this.enableHaptics = true,
    this.hapticType = HapticFeedbackType.medium,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

/// Haptic feedback type enum
enum HapticFeedbackType {
  light,
  medium,
  heavy,
}

class _GlassButtonState extends State<GlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize animation controller with fast duration (< 100ms for visual feedback)
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 80), // Fast press animation
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ REQUIRED: Dispose animation controller to prevent memory leaks
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isLoading && widget.onPressed != null && widget.enablePressAnimation) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enablePressAnimation) {
      _scaleController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enablePressAnimation) {
      _scaleController.reverse();
    }
  }

  void _handleTap() {
    // ✅ Haptic feedback BEFORE calling onPressed (Rule: provide feedback within 100ms)
    if (widget.enableHaptics && widget.onPressed != null) {
      switch (widget.hapticType) {
        case HapticFeedbackType.light:
          HapticFeedback.lightImpact();
          break;
        case HapticFeedbackType.medium:
          HapticFeedback.mediumImpact();
          break;
        case HapticFeedbackType.heavy:
          HapticFeedback.heavyImpact();
          break;
      }
    }

    // ✅ PRESERVE EXISTING BEHAVIOR: Call original onPressed
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final responsiveHeight = ResponsiveUtils.scaleSize(
      context,
      widget.height,
      minScale: 0.8,
      maxScale: 1.5,
    );
    final responsiveBorderRadius = ResponsiveUtils.borderRadius(context, 28);

    // ✅ Wrap with ScaleTransition for press animation
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isLoading ? null : _handleTap,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: responsiveHeight,
          child: GlassContainer(
            borderRadius: responsiveBorderRadius,
            padding: const EdgeInsets.all(0),
            border: Border.all(
              color: widget.borderColor ?? AppTheme.primaryColor,
              width: 2,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null, // Handled by GestureDetector now
                borderRadius: BorderRadius.circular(responsiveBorderRadius),
                child: Center(
                  child: widget.isLoading
                    ? (widget.loadingWidget ?? SizedBox(
                        height: ResponsiveUtils.scaleSize(context, 20, minScale: 0.8, maxScale: 1.5),
                        width: ResponsiveUtils.scaleSize(context, 20, minScale: 0.8, maxScale: 1.5),
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AutoSizeText(
                          widget.text,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 14, maxSize: 27),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}