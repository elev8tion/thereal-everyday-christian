import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:everyday_christian/components/gradient_background.dart';
import 'package:everyday_christian/components/frosted_glass_card.dart';
import 'package:everyday_christian/screens/bible_reader/widgets/chapter_navigation.dart';
import 'package:everyday_christian/screens/bible_reader/widgets/reading_controls.dart';
import 'package:everyday_christian/screens/bible_reader/providers/chapter_reader_providers.dart';
import 'package:everyday_christian/core/models/bible_verse.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';

/// Main screen for reading Bible chapters with glassmorphic design.
///
/// This screen provides a rich reading experience with:
/// - Swipe navigation between multiple chapters via PageView
/// - Font size controls for accessibility
/// - Chapter progress indicators
/// - Optional "Mark Complete" functionality for reading plans
/// - Loading and error states with retry capability
/// - Integration with existing design system (GradientBackground, FrostedGlassCard)
///
/// **Architecture Decisions:**
/// - Uses PageView for natural swipe navigation (memory efficient, familiar UX)
/// - Leverages Riverpod providers for state management (reactive, testable)
/// - Lazy loads verses per chapter (performance optimization for 31K+ verses)
/// - Conditional rendering based on readingId (handles both standalone & plan-driven flows)
///
/// **Integration Points:**
/// - BibleService: Fetches verse data from Supabase
/// - ReadingPlanService: Updates reading completion status
/// - StateProviders: Manages current chapter, font size (shared state)
/// - FutureProviders: Handles async verse loading with caching
class ChapterReadingScreen extends ConsumerStatefulWidget {
  /// Bible book name (e.g., "Genesis", "John")
  final String book;

  /// First chapter to display (1-indexed)
  final int startChapter;

  /// Last chapter to display (1-indexed, inclusive)
  final int endChapter;

  /// Optional reading plan ID for completion tracking
  /// If provided, enables "Mark Complete" button
  final String? readingId;

  const ChapterReadingScreen({
    Key? key,
    required this.book,
    required this.startChapter,
    required this.endChapter,
    this.readingId,
  }) : super(key: key);

  @override
  ConsumerState<ChapterReadingScreen> createState() =>
      _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends ConsumerState<ChapterReadingScreen> {
  late PageController _pageController;
  late int _totalChapters;
  bool _isMarkingComplete = false;

  @override
  void initState() {
    super.initState();
    _totalChapters = widget.endChapter - widget.startChapter + 1;
    _pageController = PageController(initialPage: 0);

    // Initialize current chapter in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentChapterProvider.notifier).state = widget.startChapter;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigates to the previous chapter if available.
  /// Updates the PageView and currentChapterProvider state.
  void _goToPreviousChapter() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage > 0) {
      HapticFeedback.lightImpact();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navigates to the next chapter if available.
  /// Updates the PageView and currentChapterProvider state.
  void _goToNextChapter() {
    final currentPage = _pageController.page?.round() ?? 0;
    if (currentPage < _totalChapters - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Marks the current reading as complete in the reading plan.
  ///
  /// **Flow:**
  /// 1. Shows loading state (prevents duplicate submissions)
  /// 2. Calls ReadingPlanService to update completion status
  /// 3. Shows success/error feedback via SnackBar
  /// 4. Navigates back on success
  ///
  /// **Error Handling:**
  /// - Network errors: Shows retry message
  /// - Service errors: Logs error and shows user-friendly message
  /// - Duplicate marking: Prevented by _isMarkingComplete flag
  Future<void> _markReadingComplete() async {
    if (_isMarkingComplete || widget.readingId == null) return;

    setState(() {
      _isMarkingComplete = true;
    });

    try {
      HapticFeedback.mediumImpact();
      final readingPlanService = ref.read(readingPlanServiceProvider);
      await readingPlanService.markReadingCompleted(widget.readingId!);

      if (!mounted) return;

      HapticFeedback.heavyImpact();
      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Reading marked as complete!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back after brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;

      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Failed to mark complete: ${error.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'RETRY',
            textColor: Colors.white,
            onPressed: _markReadingComplete,
          ),
        ),
      );

      setState(() {
        _isMarkingComplete = false;
      });
    }
  }

  /// Builds a single chapter page with verses.
  ///
  /// **Architecture:**
  /// - Uses FutureProvider for async verse loading
  /// - Handles three states: loading, error, data
  /// - Lazy loads only the current chapter's verses
  /// - Implements retry mechanism for failed loads
  ///
  /// **Performance:**
  /// - Provider caching prevents redundant API calls
  /// - ListView.builder for efficient rendering of many verses
  /// - FrostedGlassCard per verse (matches existing design)
  Widget _buildChapterPage(int chapterIndex) {
    final actualChapter = widget.startChapter + chapterIndex;

    // Watch the verse provider for this specific chapter
    final versesAsync = ref.watch(
      currentChapterVersesProvider(ChapterParams(widget.book, actualChapter)),
    );

    return versesAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stackTrace) => _buildErrorState(
        error: error,
        onRetry: () {
          // Invalidate the provider to trigger a refresh
          ref.invalidate(
            currentChapterVersesProvider(
              ChapterParams(widget.book, actualChapter),
            ),
          );
        },
      ),
      data: (verses) => _buildVerseList(verses, actualChapter),
    );
  }

  /// Builds the loading state with centered progress indicator.
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading verses...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the error state with retry button.
  ///
  /// **UX Considerations:**
  /// - Clear error messaging
  /// - Prominent retry button
  /// - Glassmorphic design consistency
  Widget _buildErrorState({
    required Object error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FrostedGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to Load Chapter',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the scrollable list of verses with glassmorphic cards.
  ///
  /// **Performance:**
  /// - ListView.builder for efficient rendering (only visible items)
  /// - Padding around list for breathing room
  /// - Verse cards with consistent spacing
  ///
  /// **Design:**
  /// - Each verse in a FrostedGlassCard (glassmorphic aesthetic)
  /// - Verse number prominently displayed
  /// - Responsive font sizing via provider
  Widget _buildVerseList(List<BibleVerse> verses, int chapter) {
    if (verses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No verses found for this chapter',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    final fontSize = ref.watch(readerFontSizeProvider);

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: verses.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final verse = verses[index];
        return RepaintBoundary(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: FrostedGlassCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verse number
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 12, top: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          verse.reference.split(':').last,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ),
                    // Verse text
                    Expanded(
                      child: Text(
                        verse.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: fontSize,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentChapter = ref.watch(currentChapterProvider);
    final fontSize = ref.watch(readerFontSizeProvider);

    return Stack(
      children: [
        const GradientBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              '${widget.book} $currentChapter',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Chapter navigation controls
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: ChapterNavigation(
                    book: widget.book,
                    currentChapter: currentChapter,
                    totalChapters: widget.endChapter,
                    onPreviousChapter: currentChapter > widget.startChapter
                        ? _goToPreviousChapter
                        : null,
                    onNextChapter: currentChapter < widget.endChapter
                        ? _goToNextChapter
                        : null,
                  ),
                ),

                // Main content area with PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _totalChapters,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (pageIndex) {
                      // Update current chapter in provider
                      ref.read(currentChapterProvider.notifier).state =
                          widget.startChapter + pageIndex;
                    },
                    itemBuilder: (context, pageIndex) {
                      return _buildChapterPage(pageIndex);
                    },
                  ),
                ),

                // Reading controls (font size, mark complete)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ReadingControls(
                    fontSize: fontSize,
                    onFontSizeChanged: (newSize) {
                      ref.read(readerFontSizeProvider.notifier).state = newSize;
                    },
                    showMarkComplete: widget.readingId != null,
                    onMarkComplete: _isMarkingComplete
                        ? null
                        : _markReadingComplete,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
