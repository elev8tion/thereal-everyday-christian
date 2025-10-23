import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../core/providers/app_providers.dart';
import '../services/bible_chapter_service.dart';
import '../models/bible_verse.dart';
import '../utils/responsive_utils.dart';
import '../core/widgets/app_snackbar.dart';

/// Chapter Reading Screen - displays Bible chapters with verse-by-verse reading
class ChapterReadingScreen extends ConsumerStatefulWidget {
  final String book;
  final int startChapter;
  final int endChapter;
  final String? readingId;

  const ChapterReadingScreen({
    super.key,
    required this.book,
    required this.startChapter,
    required this.endChapter,
    this.readingId,
  });

  @override
  ConsumerState<ChapterReadingScreen> createState() => _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends ConsumerState<ChapterReadingScreen> {
  final BibleChapterService _chapterService = BibleChapterService();
  final PageController _pageController = PageController();

  late Future<Map<int, List<BibleVerse>>> _versesFuture;
  int _currentChapterIndex = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadVerses();
    _checkCompletion();
  }

  void _loadVerses() {
    _versesFuture = _chapterService.getChapterRange(
      widget.book,
      widget.startChapter,
      widget.endChapter,
    );
  }

  Future<void> _checkCompletion() async {
    if (widget.readingId != null) {
      final completed = await _chapterService.isReadingComplete(widget.readingId!);
      if (mounted) {
        setState(() => _isCompleted = completed);
      }
    }
  }

  Future<void> _markAsComplete() async {
    if (widget.readingId == null) return;

    try {
      await _chapterService.markReadingComplete(widget.readingId!);
      if (mounted) {
        setState(() => _isCompleted = true);
        AppSnackBar.show(
          context,
          message: 'Reading marked as complete!',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Error: $e',
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalChapters = widget.endChapter - widget.startChapter + 1;
    final currentChapter = widget.startChapter + _currentChapterIndex;

    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(currentChapter, totalChapters),

                // Chapter indicator
                _buildChapterIndicator(currentChapter, totalChapters),

                // Content
                Expanded(
                  child: FutureBuilder<Map<int, List<BibleVerse>>>(
                    future: _versesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoading();
                      }

                      if (snapshot.hasError) {
                        return _buildError(snapshot.error.toString());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildNoData();
                      }

                      final chaptersMap = snapshot.data!;
                      final chapters = List.generate(
                        totalChapters,
                        (i) => widget.startChapter + i,
                      );

                      return PageView.builder(
                        controller: _pageController,
                        itemCount: chapters.length,
                        onPageChanged: (index) {
                          setState(() => _currentChapterIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final chapterNum = chapters[index];
                          final verses = chaptersMap[chapterNum] ?? [];
                          return _buildChapterPage(chapterNum, verses);
                        },
                      );
                    },
                  ),
                ),

                // Mark as Complete button
                if (widget.readingId != null) _buildCompleteButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int currentChapter, int totalChapters) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
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
              icon: Icon(Icons.arrow_back, color: Colors.white, size: ResponsiveUtils.iconSize(context, 24)),
              onPressed: () => NavigationService.pop(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.book} $currentChapter',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      totalChapters > 1
                        ? 'Chapter ${_currentChapterIndex + 1} of $totalChapters'
                        : '1 chapter',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isCompleted) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: ResponsiveUtils.iconSize(context, 16),
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                          color: Colors.green.shade300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterIndicator(int currentChapter, int totalChapters) {
    if (totalChapters == 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: _currentChapterIndex > 0
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
            ),
            onPressed: _currentChapterIndex > 0
                ? () {
                    if (_pageController.hasClients) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                : null,
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xs / 4),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentChapterIndex + 1) / totalChapters,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xs / 4),
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.secondaryColor,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: _currentChapterIndex < totalChapters - 1
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
            ),
            onPressed: _currentChapterIndex < totalChapters - 1
                ? () {
                    if (_pageController.hasClients) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterPage(int chapterNum, List<BibleVerse> verses) {
    if (verses.isEmpty) {
      return Center(
        child: FrostedGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: ResponsiveUtils.iconSize(context, 48),
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'No verses found for ${widget.book} $chapterNum',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: FrostedGlassCard(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter title
              Text(
                '${widget.book} $chapterNum',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 28, minSize: 24, maxSize: 32),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Verses
              ...verses.map((verse) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verse number and favorite button column
                      Column(
                        children: [
                          // Verse number with glassmorphic style (matching FAB)
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.25),
                                  Colors.white.withValues(alpha: 0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: AppRadius.smallRadius,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${verse.verseNumber}',
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          // Favorite button
                          _buildFavoriteButton(verse),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Verse text with more room
                      Expanded(
                        child: Text(
                          verse.text,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                            height: 1.6,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton(BibleVerse verse) {
    if (verse.id == null) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: ref.read(unifiedVerseServiceProvider).isVerseFavorite(verse.id!),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;

        return Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isFavorite
                  ? [
                      Colors.red.withValues(alpha: 0.3),
                      Colors.red.withValues(alpha: 0.2),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.1),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.smallRadius,
            border: Border.all(
              color: isFavorite
                  ? Colors.red.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: ResponsiveUtils.iconSize(context, 18),
              color: isFavorite ? Colors.red : Colors.white.withValues(alpha: 0.7),
            ),
            onPressed: () => _toggleFavorite(verse),
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite(BibleVerse verse) async {
    if (verse.id == null) return;

    try {
      final verseService = ref.read(unifiedVerseServiceProvider);
      final wasFavorite = await verseService.isVerseFavorite(verse.id!);

      if (wasFavorite) {
        await verseService.removeFromFavorites(verse.id!);
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Removed from Verse Library',
          icon: Icons.heart_broken,
        );
      } else {
        // Add verse to favorites directly (no theme selection)
        await verseService.addToFavorites(
          verse.id!,
          text: verse.text,
          reference: verse.reference,
          category: verse.category,
        );

        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: 'Added to Verse Library!',
          icon: Icons.favorite,
        );
      }

      // Trigger UI update
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showError(
        context,
        message: 'Error: $e',
      );
    }
  }

  Widget _buildCompleteButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassButton(
        text: _isCompleted ? '✓ Reading Completed' : 'Mark as Complete',
        onPressed: _isCompleted ? null : _markAsComplete,
        height: 56,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FrostedGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtils.iconSize(context, 64),
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error loading chapter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _loadVerses();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
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

  Widget _buildNoData() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FrostedGlassCard(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: ResponsiveUtils.iconSize(context, 64),
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No verses available',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Could not find verses for ${widget.book} ${widget.startChapter}-${widget.endChapter}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
