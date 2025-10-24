import 'package:flutter/material.dart';
import 'package:everyday_christian/components/frosted_glass_card.dart';

/// A glassmorphic navigation widget for chapter navigation in the Bible reader.
/// Provides previous/next chapter buttons and displays current chapter information.
class ChapterNavigation extends StatelessWidget {
  final String book;
  final int currentChapter;
  final int totalChapters;
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;

  const ChapterNavigation({
    Key? key,
    required this.book,
    required this.currentChapter,
    required this.totalChapters,
    this.onPreviousChapter,
    this.onNextChapter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FrostedGlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPreviousButton(context),
            _buildChapterIndicator(context),
            _buildNextButton(context),
          ],
        ),
      ),
    );
  }

  /// Builds the previous chapter button (left arrow).
  /// Disabled when on the first chapter.
  Widget _buildPreviousButton(BuildContext context) {
    final isDisabled = currentChapter <= 1;
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: isDisabled ? 0.8 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: isDisabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                : theme.colorScheme.primary,
          ),
          onPressed: isDisabled ? null : onPreviousChapter,
          splashRadius: 24,
          tooltip: isDisabled ? null : 'Previous Chapter',
          padding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }

  /// Builds the chapter indicator showing current chapter and total chapters.
  /// Format: "Book Chapter / Total"
  Widget _buildChapterIndicator(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Center(
        child: Text(
          '$book $currentChapter / $totalChapters',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  /// Builds the next chapter button (right arrow).
  /// Disabled when on the last chapter.
  Widget _buildNextButton(BuildContext context) {
    final isDisabled = currentChapter >= totalChapters;
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: isDisabled ? 0.8 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isDisabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
                : theme.colorScheme.primary,
          ),
          onPressed: isDisabled ? null : onNextChapter,
          splashRadius: 24,
          tooltip: isDisabled ? null : 'Next Chapter',
          padding: const EdgeInsets.all(8.0),
        ),
      ),
    );
  }
}
