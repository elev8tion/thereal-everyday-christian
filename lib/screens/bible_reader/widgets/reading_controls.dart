import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:everyday_christian/components/frosted_glass_card.dart';

class ReadingControls extends StatelessWidget {
  final double fontSize;
  final ValueChanged<double> onFontSizeChanged;
  final VoidCallback? onMarkComplete;
  final bool showMarkComplete;

  const ReadingControls({
    Key? key,
    required this.fontSize,
    required this.onFontSizeChanged,
    this.onMarkComplete,
    this.showMarkComplete = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildFontSizeControls(context),
            if (showMarkComplete && onMarkComplete != null) ...[
              const SizedBox(height: 12),
              _buildMarkCompleteButton(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeControls(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Decrease font size button
        _buildFontButton(
          context: context,
          label: 'A-',
          onPressed: fontSize > 12
              ? () {
                  HapticFeedback.selectionClick();
                  onFontSizeChanged(fontSize - 1);
                }
              : null,
        ),
        const SizedBox(width: 12),

        // Font size slider
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: theme.colorScheme.primary.withValues(
                    alpha: 0.8,
                  ),
                  inactiveTrackColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.2,
                  ),
                  thumbColor: theme.colorScheme.primary,
                  overlayColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                ),
                child: Slider(
                  value: fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    onFontSizeChanged(value);
                  },
                ),
              ),
              Text(
                '${fontSize.toInt()} pt',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Increase font size button
        _buildFontButton(
          context: context,
          label: 'A+',
          onPressed: fontSize < 24
              ? () {
                  HapticFeedback.selectionClick();
                  onFontSizeChanged(fontSize + 1);
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildFontButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(
              alpha: isEnabled ? 0.1 : 0.05,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(
                alpha: isEnabled ? 0.3 : 0.1,
              ),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary.withValues(
                  alpha: isEnabled ? 1.0 : 0.4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkCompleteButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onMarkComplete,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.2),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mark Complete',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
