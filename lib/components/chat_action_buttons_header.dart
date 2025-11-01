import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import 'glassmorphic_fab_menu.dart';

/// Persistent header delegate for chat action buttons that sticks to the top
class ChatActionButtonsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  ChatActionButtonsDelegate({
    required this.child,
    this.height = 60.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: height,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant ChatActionButtonsDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

/// Reusable chat action buttons row component with FAB menu
class ChatActionButtons extends StatelessWidget {
  final VoidCallback onMorePressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onNewPressed;

  const ChatActionButtons({
    super.key,
    required this.onMorePressed,
    required this.onHistoryPressed,
    required this.onNewPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const GlassmorphicFABMenu(),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.white, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: onMorePressed,
              tooltip: 'Chat Options',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.history, color: Colors.white, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: onHistoryPressed,
              tooltip: 'Conversation History',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldColor.withValues(alpha: 0.3),
                  AppTheme.goldColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: AppTheme.goldColor.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: AppColors.primaryText, size: ResponsiveUtils.iconSize(context, 20)),
              onPressed: onNewPressed,
              tooltip: 'New Conversation',
            ),
          ),
        ],
      ),
    );
  }
}
