import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Glassmorphic streaming message widget for real-time AI responses
/// Matches the everyday-christian design system with glass effects
class GlassStreamingMessage extends StatefulWidget {
  final String streamedText;
  final bool isComplete;
  final VoidCallback? onComplete;

  const GlassStreamingMessage({
    super.key,
    required this.streamedText,
    this.isComplete = false,
    this.onComplete,
  });

  @override
  State<GlassStreamingMessage> createState() => _GlassStreamingMessageState();
}

class _GlassStreamingMessageState extends State<GlassStreamingMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;
  bool _wasComplete = false;

  @override
  void initState() {
    super.initState();

    // Shimmer animation for loading state
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isComplete) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(GlassStreamingMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Stop shimmer when streaming completes
    if (widget.isComplete && !_wasComplete) {
      _shimmerController.stop();
      _wasComplete = true;
      widget.onComplete?.call();
    } else if (!widget.isComplete && _wasComplete) {
      _shimmerController.repeat();
      _wasComplete = false;
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI Avatar with glass effect
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.3),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primaryText,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Streaming message content
          Flexible(
            child: AnimatedBuilder(
              animation: _shimmerAnimation,
              builder: (context, child) {
                return Container(
                  padding: AppSpacing.cardPadding,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.2),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.xs),
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: Radius.circular(AppRadius.lg),
                      bottomRight: Radius.circular(AppRadius.lg),
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      // Shimmer overlay when streaming
                      if (!widget.isComplete)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(AppRadius.xs),
                              topRight: Radius.circular(AppRadius.lg),
                              bottomLeft: Radius.circular(AppRadius.lg),
                              bottomRight: Radius.circular(AppRadius.lg),
                            ),
                            child: Transform.translate(
                              offset: Offset(_shimmerAnimation.value * 100, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.primaryColor.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Text content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Streamed text with typing effect
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: Text(
                              widget.streamedText.isEmpty
                                  ? 'Thinking...'
                                  : widget.streamedText,
                              key: ValueKey(widget.streamedText.length),
                              style: TextStyle(
                                fontSize: 15,
                                color: widget.streamedText.isEmpty
                                    ? AppColors.tertiaryText
                                    : AppColors.primaryText,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                fontStyle: widget.streamedText.isEmpty
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                shadows: AppTheme.textShadowSubtle,
                              ),
                            ),
                          ),

                          // Cursor indicator when streaming
                          if (!widget.isComplete && widget.streamedText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Container(
                                width: 2,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(AppRadius.xs / 8),
                                ),
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .fadeIn(duration: 500.ms)
                                  .then()
                                  .fadeOut(duration: 500.ms),
                            ),

                          // Status indicator
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              if (!widget.isComplete) ...[
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Streaming response...',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  _formatTime(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: AppAnimations.normal)
        .slideX(begin: -0.3);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}
