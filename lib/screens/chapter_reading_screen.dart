import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glass_button.dart';
import '../components/audio_control_pill.dart';
import '../theme/app_theme.dart';
import '../core/navigation/navigation_service.dart';
import '../core/providers/app_providers.dart';
import '../services/bible_chapter_service.dart';
import '../models/bible_verse.dart';
import '../utils/responsive_utils.dart';
import '../core/widgets/app_snackbar.dart';
import '../core/services/tts_service.dart';

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
  final ScrollController _scrollController = ScrollController();
  final TtsService _ttsService = TtsService();

  late Future<Map<int, List<BibleVerse>>> _versesFuture;
  int _currentChapterIndex = 0;
  bool _isCompleted = false;

  // TTS state
  bool _isAudioPlaying = false;
  int _currentPlayingVerseIndex = -1;

  // Keys for verse widgets (for auto-scroll)
  final Map<int, GlobalKey> _verseKeys = {};

  @override
  void initState() {
    super.initState();
    _loadVerses();
    _checkCompletion();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _ttsService.initialize();

    // Set up TTS callbacks
    _ttsService.onVerseChanged = (verseIndex) {
      if (mounted) {
        setState(() => _currentPlayingVerseIndex = verseIndex);
        _scrollToVerse(verseIndex);
      }
    };

    _ttsService.onPlayStateChanged = (isPlaying) {
      if (mounted) {
        setState(() => _isAudioPlaying = isPlaying);
      }
    };

    _ttsService.onPlaybackComplete = () {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Chapter playback complete',
          icon: Icons.check_circle,
        );
      }
    };
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

      // Refresh all plan-related providers to update progress
      ref.invalidate(currentReadingPlanProvider);
      ref.invalidate(activeReadingPlansProvider);
      ref.invalidate(allReadingPlansProvider);

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

  // TTS Controls
  Future<void> _playAudio(List<BibleVerse> verses) async {
    try {
      await _ttsService.playChapter(verses);
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          message: 'Audio playback error',
        );
      }
    }
  }

  Future<void> _pauseAudio() async {
    await _ttsService.pause();
  }

  Future<void> _resumeAudio() async {
    await _ttsService.resume();
  }

  Future<void> _stopAudio() async {
    await _ttsService.stop();
    setState(() {
      _currentPlayingVerseIndex = -1;
    });
  }

  Future<void> _cycleSpeed() async {
    await _ttsService.cycleSpeed();
    setState(() {}); // Refresh UI to show new speed
  }

  /// Auto-scroll to current verse during playback
  void _scrollToVerse(int verseIndex) {
    final key = _verseKeys[verseIndex];
    if (key == null || key.currentContext == null) return;

    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.2, // Keep verse near top of viewport
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _ttsService.stop(); // Stop audio when leaving screen
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
            child: FutureBuilder<Map<int, List<BibleVerse>>>(
              future: _versesFuture,
              builder: (context, snapshot) {
                final currentChapterNum = widget.startChapter + _currentChapterIndex;
                final currentVerses = (snapshot.hasData)
                    ? (snapshot.data![currentChapterNum] ?? <BibleVerse>[])
                    : <BibleVerse>[];

                return Column(
                  children: [
                    // Header with integrated audio player
                    _buildHeader(currentChapter, totalChapters, currentVerses),

                    // Chapter indicator
                    _buildChapterIndicator(currentChapter, totalChapters),

                    // Content
                    Expanded(
                      child: Builder(builder: (context) {
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

                        // Chapter content with PageView
                        return PageView.builder(
                          controller: _pageController,
                          itemCount: chapters.length,
                          onPageChanged: (index) {
                            setState(() => _currentChapterIndex = index);
                            // Auto-stop audio when user swipes to different chapter
                            if (_isAudioPlaying) {
                              _stopAudio();
                            }
                          },
                          itemBuilder: (context, index) {
                            final chapterNum = chapters[index];
                            final verses = chaptersMap[chapterNum] ?? [];
                            return _buildChapterPage(chapterNum, verses, chaptersMap);
                          },
                        );
                      }),
                    ),

                    // Mark as Complete button
                    if (widget.readingId != null) _buildCompleteButton(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int currentChapter, int totalChapters, List<BibleVerse> currentVerses) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
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
          const SizedBox(width: 12),

          // Title and subtitle stacked (compact)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${widget.book} $currentChapter',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 22),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        totalChapters > 1
                          ? 'Chapter ${_currentChapterIndex + 1} of $totalChapters'
                          : '1 chapter',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 11, maxSize: 13),
                          color: Colors.white.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_isCompleted) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green.shade300,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Audio player on the right side with max width constraint
          if (currentVerses.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: AudioControlPill(
                isPlaying: _isAudioPlaying,
                isPaused: _ttsService.isPaused,
                speedLabel: _ttsService.speedLabel,
                currentVerse: _currentPlayingVerseIndex >= 0 ? _currentPlayingVerseIndex + 1 : null,
                totalVerses: currentVerses.length,
                onPlayPause: () {
                  if (!_isAudioPlaying) {
                    _playAudio(currentVerses);
                  } else if (_ttsService.isPaused) {
                    _resumeAudio();
                  } else {
                    _pauseAudio();
                  }
                },
                onStop: _stopAudio,
                onSpeedTap: _cycleSpeed,
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

  Widget _buildChapterPage(int chapterNum, List<BibleVerse> verses, Map<int, List<BibleVerse>> chaptersMap) {
    // Generate keys for verses (for auto-scroll)
    _verseKeys.clear();
    for (int i = 0; i < verses.length; i++) {
      _verseKeys[i] = GlobalKey();
    }

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
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: FrostedGlassCard(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 4.0,
            top: 20.0,
            bottom: 20.0,
            right: 8.0,
          ),
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
              ...verses.asMap().entries.map((entry) {
                final verseIndex = entry.key;
                final verse = entry.value;
                final isCurrentVerse = _isAudioPlaying && verseIndex == _currentPlayingVerseIndex;

                return Padding(
                  key: _verseKeys[verseIndex],
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: isCurrentVerse
                        ? BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                                AppTheme.primaryColor.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    padding: isCurrentVerse ? const EdgeInsets.all(8.0) : EdgeInsets.zero,
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

      // CRITICAL FIX: Invalidate providers to refresh saved verses count
      // This ensures the verse library and profile screens show accurate counts
      if (mounted) {
        ref.invalidate(savedVersesCountProvider);
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
