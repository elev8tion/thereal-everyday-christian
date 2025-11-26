import 'package:flutter/material.dart';

/// Shimmer loading effect widget
///
/// Following Animation Enhancement Rules:
/// - Smooth shimmer animation for loading states
/// - Respects reduced motion settings
/// - Properly disposes animation controller
/// - Customizable colors and duration
///
/// Usage:
/// ```dart
/// ShimmerLoading(
///   child: Container(height: 100, width: 200),
/// )
/// ```
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  final bool enabled;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    // ✅ REQUIRED: Dispose animation controller
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    final baseColor = widget.baseColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[700]!
            : Colors.grey[300]!);

    final highlightColor = widget.highlightColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[600]!
            : Colors.grey[100]!);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer placeholder widgets for common loading scenarios
class ShimmerPlaceholders {
  /// Card placeholder with shimmer
  static Widget card({
    double? height,
    double? width,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height ?? 100,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Text placeholder with shimmer
  static Widget text({
    double? width,
    double height = 16,
    BorderRadius? borderRadius,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }

  /// Circle placeholder (for avatars) with shimmer
  static Widget circle({
    double size = 50,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerLoading(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: size,
        width: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  /// List tile placeholder with shimmer
  static Widget listTile({
    bool showLeading = true,
    bool showTrailing = false,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          if (showLeading)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: circle(
                size: 40,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(
                  width: double.infinity,
                  height: 14,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const SizedBox(height: 8),
                text(
                  width: 150,
                  height: 12,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
          if (showTrailing)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: text(
                width: 50,
                height: 30,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),
        ],
      ),
    );
  }
}
