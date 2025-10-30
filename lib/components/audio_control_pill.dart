import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';

/// Compact frosted glass audio control pill matching app aesthetic
class AudioControlPill extends StatelessWidget {
  final bool isPlaying;
  final bool isPaused;
  final String speedLabel;
  final int? currentVerse;
  final int? totalVerses;
  final VoidCallback onPlayPause;
  final VoidCallback onStop;
  final VoidCallback onSpeedTap;

  const AudioControlPill({
    super.key,
    required this.isPlaying,
    required this.isPaused,
    required this.speedLabel,
    this.currentVerse,
    this.totalVerses,
    required this.onPlayPause,
    required this.onStop,
    required this.onSpeedTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isPlaying && !isPaused;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Compact frosted glass pill
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.goldColor, // Gold border always visible
                width: isActive ? 2.0 : 1.5, // Thicker when playing
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Stop button (only when playing)
                if (isPlaying) ...[
                  _buildIconButton(
                    icon: Icons.stop_rounded,
                    onTap: onStop,
                  ),
                  const SizedBox(width: 4),
                ],

                // Play/Pause button
                _buildIconButton(
                  icon: isPlaying
                      ? (isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded)
                      : Icons.play_arrow_rounded,
                  onTap: onPlayPause,
                  isPrimary: true,
                  isActive: isActive,
                ),

                const SizedBox(width: 4),

                // Speed button
                _buildSpeedButton(
                  label: speedLabel,
                  onTap: onSpeedTap,
                ),
              ],
            ),
          ),

          // Verse progress (only when playing)
          if (isPlaying && currentVerse != null && totalVerses != null) ...[
            const SizedBox(height: 6),
            Text(
              'Verse $currentVerse of $totalVerses',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPrimary && isActive
              ? AppTheme.goldColor.withValues(alpha: 0.2)
              : Colors.transparent,
          border: isPrimary && isActive
              ? Border.all(
                  color: AppTheme.goldColor.withValues(alpha: 0.4),
                  width: 1,
                )
              : null,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: isPrimary ? 24 : 20,
        ),
      ),
    );
  }

  Widget _buildSpeedButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
