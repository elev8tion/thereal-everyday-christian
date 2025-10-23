import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../components/gradient_background.dart';
import '../components/frosted_glass_card.dart';
import '../components/glassmorphic_fab_menu.dart';
import '../core/navigation/navigation_service.dart';
import '../services/bible_chapter_service.dart';
import '../models/bible_verse.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_utils.dart';
import '../utils/bible_reference_parser.dart';

/// Free Bible Browser - allows users to browse and read any Bible chapter
class BibleBrowserScreen extends ConsumerStatefulWidget {
  const BibleBrowserScreen({super.key});

  @override
  ConsumerState<BibleBrowserScreen> createState() => _BibleBrowserScreenState();
}

class _BibleBrowserScreenState extends ConsumerState<BibleBrowserScreen> with TickerProviderStateMixin {
  final BibleChapterService _bibleService = BibleChapterService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  Timer? _debounceTimer;

  List<String> _allBooks = [];
  List<String> _filteredBooks = [];
  List<BibleVerse> _verseSearchResults = [];
  bool _isLoading = true;
  bool _isSearchingVerses = false;
  String _searchQuery = '';

  // Bible structure - maps book names to testament
  static const Map<String, String> _bookTestaments = {
    // Old Testament
    'Genesis': 'Old Testament',
    'Exodus': 'Old Testament',
    'Leviticus': 'Old Testament',
    'Numbers': 'Old Testament',
    'Deuteronomy': 'Old Testament',
    'Joshua': 'Old Testament',
    'Judges': 'Old Testament',
    'Ruth': 'Old Testament',
    '1 Samuel': 'Old Testament',
    '2 Samuel': 'Old Testament',
    '1 Kings': 'Old Testament',
    '2 Kings': 'Old Testament',
    '1 Chronicles': 'Old Testament',
    '2 Chronicles': 'Old Testament',
    'Ezra': 'Old Testament',
    'Nehemiah': 'Old Testament',
    'Esther': 'Old Testament',
    'Job': 'Old Testament',
    'Psalms': 'Old Testament',
    'Proverbs': 'Old Testament',
    'Ecclesiastes': 'Old Testament',
    'Song of Solomon': 'Old Testament',
    'Isaiah': 'Old Testament',
    'Jeremiah': 'Old Testament',
    'Lamentations': 'Old Testament',
    'Ezekiel': 'Old Testament',
    'Daniel': 'Old Testament',
    'Hosea': 'Old Testament',
    'Joel': 'Old Testament',
    'Amos': 'Old Testament',
    'Obadiah': 'Old Testament',
    'Jonah': 'Old Testament',
    'Micah': 'Old Testament',
    'Nahum': 'Old Testament',
    'Habakkuk': 'Old Testament',
    'Zephaniah': 'Old Testament',
    'Haggai': 'Old Testament',
    'Zechariah': 'Old Testament',
    'Malachi': 'Old Testament',
    // New Testament
    'Matthew': 'New Testament',
    'Mark': 'New Testament',
    'Luke': 'New Testament',
    'John': 'New Testament',
    'Acts': 'New Testament',
    'Romans': 'New Testament',
    '1 Corinthians': 'New Testament',
    '2 Corinthians': 'New Testament',
    'Galatians': 'New Testament',
    'Ephesians': 'New Testament',
    'Philippians': 'New Testament',
    'Colossians': 'New Testament',
    '1 Thessalonians': 'New Testament',
    '2 Thessalonians': 'New Testament',
    '1 Timothy': 'New Testament',
    '2 Timothy': 'New Testament',
    'Titus': 'New Testament',
    'Philemon': 'New Testament',
    'Hebrews': 'New Testament',
    'James': 'New Testament',
    '1 Peter': 'New Testament',
    '2 Peter': 'New Testament',
    '1 John': 'New Testament',
    '2 John': 'New Testament',
    '3 John': 'New Testament',
    'Jude': 'New Testament',
    'Revelation': 'New Testament',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBooks();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final books = await _bibleService.getAllBooks();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _filteredBooks = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterBooks(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    setState(() {
      _searchQuery = query;

      if (query.isEmpty) {
        _filteredBooks = _allBooks;
        _verseSearchResults = [];
        _isSearchingVerses = false;
        return;
      }

      // Step 1: Check if input looks like a Bible reference
      if (BibleReferenceParser.looksLikeReference(query)) {
        final parsed = BibleReferenceParser.parse(query);

        if (parsed != null) {
          // Direct reference lookup - instant results
          _isSearchingVerses = true;
          _filteredBooks = [];

          _bibleService
              .getVersesByReference(
            parsed.book,
            parsed.chapter,
            parsed.startVerse,
            endVerse: parsed.endVerse,
          )
              .then((verses) {
            if (mounted) {
              setState(() {
                _verseSearchResults = verses;
                _isSearchingVerses = false;
              });
            }
          }).catchError((e) {
            if (mounted) {
              setState(() {
                _verseSearchResults = [];
                _isSearchingVerses = false;
              });
            }
          });
          return;
        }
      }

      // Step 2: Filter books (existing logic)
      _filteredBooks = _allBooks
          .where((book) => book.toLowerCase().contains(query.toLowerCase()))
          .toList();

      // Step 3: If no books match, fall back to FTS5 verse search
      if (_filteredBooks.isEmpty) {
        _isSearchingVerses = true;
        _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
          try {
            final verses = await _bibleService.searchVerses(query, limit: 50);
            if (mounted) {
              setState(() {
                _verseSearchResults = verses;
                _isSearchingVerses = false;
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isSearchingVerses = false;
              });
            }
          }
        });
      } else {
        _verseSearchResults = [];
        _isSearchingVerses = false;
      }
    });
  }

  List<String> _getOldTestamentBooks() {
    return _filteredBooks
        .where((book) => _bookTestaments[book] == 'Old Testament')
        .toList();
  }

  List<String> _getNewTestamentBooks() {
    return _filteredBooks
        .where((book) => _bookTestaments[book] == 'New Testament')
        .toList();
  }

  /// Check if we should show search overlay
  bool get _showSearchOverlay {
    return _searchQuery.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                // TabBar always visible
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Stack(
                          children: [
                            // Background: TabBarView always rendered
                            TabBarView(
                              controller: _tabController,
                              children: [
                                _buildTestamentView(_getOldTestamentBooks()),
                                _buildTestamentView(_getNewTestamentBooks()),
                              ],
                            ),

                            // Foreground: Search overlay (when active)
                            if (_showSearchOverlay)
                              _buildSearchOverlay(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build search overlay that covers TabBarView
  Widget _buildSearchOverlay() {
    return Positioned.fill(
      child: _isSearchingVerses
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Searching verses...',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            )
          : (_filteredBooks.isNotEmpty
              ? _buildFilteredBooks()
              : _buildVerseResults()),
    );
  }

  /// Build filtered books list (shown when books match search)
  Widget _buildFilteredBooks() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredBooks.length,
      itemBuilder: (context, index) => _buildBookCard(_filteredBooks[index]),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const GlassmorphicFABMenu(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Bible Browser',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 24, minSize: 20, maxSize: 28),
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  'Read any chapter freely',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl + 1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterBooks,
                textCapitalization: TextCapitalization.none,
                autocorrect: false,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                ),
                decoration: InputDecoration(
                  hintText: 'Search books...',
                  hintStyle: TextStyle(
                    color: AppColors.tertiaryText,
                    fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                  ),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.xl + 1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.clear, color: AppColors.primaryText),
                onPressed: () {
                  _searchController.clear();
                  _filterBooks('');
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: AppSpacing.horizontalXl,
      child: FrostedGlassCard(
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 1,
            ),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
          ),
          tabs: const [
            Tab(text: 'Old Testament'),
            Tab(text: 'New Testament'),
          ],
        ),
      ),
    );
  }

  Widget _buildTestamentView(List<String> books) {
    if (books.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: ResponsiveUtils.iconSize(context, 64),
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No books found',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: books.length,
      itemBuilder: (context, index) => _buildBookCard(books[index]),
    );
  }

  Widget _buildBookCard(String book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showChapterSelector(book),
        child: FrostedGlassCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: AppRadius.mediumRadius,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: ResponsiveUtils.iconSize(context, 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AutoSizeText(
                  book,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showChapterSelector(String book) async {
    final chapterCount = await _bibleService.getChapterCount(book);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E293B).withValues(alpha: 0.95), // Standard slate-800
                const Color(0xFF0F172A).withValues(alpha: 0.98), // Standard slate-900
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.xs / 4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Chapter - $book',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 18, maxSize: 24),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: chapterCount,
                  itemBuilder: (context, index) {
                    final chapterNum = index + 1;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        NavigationService.goToChapterReading(
                          book: book,
                          startChapter: chapterNum,
                          endChapter: chapterNum,
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: AppRadius.mediumRadius,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$chapterNum',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 18),
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerseResults() {
    if (_verseSearchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: ResponsiveUtils.iconSize(context, 64),
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No verses found',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18, minSize: 16, maxSize: 20),
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '${_verseSearchResults.length} verses found',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 16),
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _verseSearchResults.length,
            itemBuilder: (context, index) => _buildVerseCard(_verseSearchResults[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildVerseCard(BibleVerse verse) {
    final reference = '${verse.book} ${verse.chapter}:${verse.verseNumber}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          NavigationService.goToChapterReading(
            book: verse.book,
            startChapter: verse.chapter,
            endChapter: verse.chapter,
          );
        },
        child: FrostedGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.goldColor.withValues(alpha: 0.3),
                          AppTheme.goldColor.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: AppRadius.smallRadius,
                      border: Border.all(
                        color: AppTheme.goldColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      reference,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 12, minSize: 10, maxSize: 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                verse.text,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 15, minSize: 13, maxSize: 17),
                  color: AppColors.primaryText,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
