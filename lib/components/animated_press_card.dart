import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated press wrapper for interactive cards
///
/// Following Animation Enhancement Rules:
/// - Press animation with scale (0.90-0.98)
/// - Optional haptic feedback
/// - Fast visual feedback (< 100ms)
/// - Does not block touch events
/// - Properly disposes animation controller
///
/// Usage:
/// ```dart
/// AnimatedPressCard(
///   onTap: () => print('Tapped!'),
///   child: YourCard(),
/// )
/// ```
class AnimatedPressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScale;
  final bool enableHaptics;
  final bool enableAnimation;
  final Duration duration;
  final Curve curve;

  const AnimatedPressCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.96, // Rule: 0.90-0.98
    this.enableHaptics = true,
    this.enableAnimation = true,
    this.duration = const Duration(milliseconds: 80),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedPressCard> createState() => _AnimatedPressCardState();
}

class _AnimatedPressCardState extends State<AnimatedPressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ REQUIRED: Dispose animation controller
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableAnimation && (widget.onTap != null || widget.onLongPress != null)) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableAnimation) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enableAnimation) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.onTap != null) {
      // ✅ Haptic feedback before action (Rule: provide feedback within 100ms)
      if (widget.enableHaptics) {
        HapticFeedback.mediumImpact();
      }
      widget.onTap!();
    }
  }

  void _handleLongPress() {
    if (widget.onLongPress != null) {
      // ✅ Haptic feedback for long press
      if (widget.enableHaptics) {
        HapticFeedback.heavyImpact();
      }
      widget.onLongPress!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap != null ? _handleTap : null,
        onLongPress: widget.onLongPress != null ? _handleLongPress : null,
        child: widget.child,
      ),
    );
  }
}
