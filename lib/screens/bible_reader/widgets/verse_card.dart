import 'package:flutter/material.dart';
import 'package:everyday_christian/components/frosted_glass.dart';
import 'package:everyday_christian/models/bible_verse.dart';
import 'package:everyday_christian/theme/app_theme.dart';

/// A reusable card widget for displaying individual Bible verses
/// with glassmorphic design and adjustable typography
class VerseCard extends StatelessWidget {
  /// The Bible verse to display
  final BibleVerse verse;

  /// Font size for verse text (default: 16.0)
  final double fontSize;

  /// Whether to show the verse number badge (default: true)
  final bool showVerseNumber;

  /// Optional callback when verse is tapped (future: highlighting/notes)
  final VoidCallback? onTap;

  /// Optional margin around the card
  final EdgeInsetsGeometry? margin;

  const VerseCard({
    super.key,
    required this.verse,
    this.fontSize = 16.0,
    this.showVerseNumber = true,
    this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(bottom: AppSpacing.md),
      child: FrostedGlass(
        isNested: true,
        borderRadius: AppRadius.md,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showVerseNumber) ...[
                _buildVerseNumberBadge(),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: _buildVerseText(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the circular badge displaying the verse number
  Widget _buildVerseNumberBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.goldColor.withValues(alpha: 0.8),
            AppTheme.goldColor.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.goldColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.goldColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${verse.verseNumber}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: AppTheme.textShadowSubtle,
          ),
        ),
      ),
    );
  }

  /// Builds the verse text with proper styling and line height
  Widget _buildVerseText(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);

    return Text(
      verse.text,
      style: TextStyle(
        fontSize: fontSize,
        height: 1.6, // Increased line height for better readability
        fontWeight: FontWeight.w400,
        color: textColor,
        letterSpacing: 0.3,
        shadows: AppTheme.textShadowSubtle,
      ),
      textAlign: TextAlign.left,
    );
  }
}

/// A compact version of VerseCard for use in lists or sidebars
class CompactVerseCard extends StatelessWidget {
  final BibleVerse verse;
  final VoidCallback? onTap;

  const CompactVerseCard({
    super.key,
    required this.verse,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return VerseCard(
      verse: verse,
      fontSize: 14.0,
      showVerseNumber: true,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
    );
  }
}

/// A card showing verse with reference header
class VerseCardWithReference extends StatelessWidget {
  final BibleVerse verse;
  final double fontSize;
  final bool showVerseNumber;
  final VoidCallback? onTap;

  const VerseCardWithReference({
    super.key,
    required this.verse,
    this.fontSize = 16.0,
    this.showVerseNumber = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: FrostedGlass(
        isNested: true,
        borderRadius: AppRadius.lg,
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.goldColor.withValues(alpha: 0.3),
                      AppTheme.goldColor.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark_outline,
                      size: AppSizes.iconSm,
                      color: AppTheme.goldColor,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        verse.reference,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.95),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      verse.translation,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Verse text
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  verse.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.7,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.3,
                    shadows: AppTheme.textShadowSubtle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
