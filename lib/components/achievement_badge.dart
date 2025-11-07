import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Achievement badge widget that displays an earned achievement icon
/// with an optional count badge showing how many times it was earned
class AchievementBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int completionCount;
  final String title;

  const AchievementBadge({
    super.key,
    required this.icon,
    required this.color,
    required this.completionCount,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$title${completionCount > 1 ? ' (×$completionCount)' : ''}',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badge circle (original size)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.3),
                  color.withValues(alpha: 0.15),
                ],
              ),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),

          // Completion count badge (frosted glass style, only if earned more than once)
          if (completionCount > 1)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '×$completionCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Container for displaying multiple achievement badges in a row
class AchievementBadgeRow extends StatelessWidget {
  final List<AchievementBadgeData> badges;

  const AchievementBadgeRow({
    super.key,
    required this.badges,
  });

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: badges.map((badge) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AchievementBadge(
              icon: badge.icon,
              color: badge.color,
              completionCount: badge.completionCount,
              title: badge.title,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Data class for achievement badge information
class AchievementBadgeData {
  final IconData icon;
  final Color color;
  final int completionCount;
  final String title;

  const AchievementBadgeData({
    required this.icon,
    required this.color,
    required this.completionCount,
    required this.title,
  });
}
