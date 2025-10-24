import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:everyday_christian/core/models/bible_verse.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';

// ==============================================================================
// CHAPTER READER STATE PROVIDERS
// ==============================================================================
// These providers manage state for the Bible Chapter Reading experience.
// They handle current chapter tracking, font preferences, verse loading,
// and chapter metadata for navigation.
// ==============================================================================

// ------------------------------------------------------------------------------
// 1. CURRENT CHAPTER TRACKING
// ------------------------------------------------------------------------------
// Tracks which chapter is currently being viewed within a book.
// Uses autoDispose to clean up when the reader screen is closed.
// ------------------------------------------------------------------------------

/// Provider for tracking the current chapter number being read
///
/// This state persists while the reader screen is active but disposes
/// when the user navigates away to conserve memory.
final currentChapterProvider = StateProvider.autoDispose<int>((ref) => 1);

// ------------------------------------------------------------------------------
// 2. FONT SIZE PREFERENCE
// ------------------------------------------------------------------------------
// Manages the reader's font size preference for better readability.
// This should persist across app sessions (not auto-disposed).
// Default is 16.0 but can be adjusted by the user.
// ------------------------------------------------------------------------------

/// Provider for managing text font size in the chapter reader
///
/// Range: 12.0 - 24.0 (recommended)
/// Default: 16.0
///
/// Future enhancement: Load from SharedPreferences on init
final readerFontSizeProvider = StateProvider<double>((ref) {
  // TODO: Load saved preference from SharedPreferences
  // final prefs = ref.read(sharedPreferencesProvider);
  // return prefs.getDouble('reader_font_size') ?? 16.0;
  return 16.0; // Default font size
});

// ------------------------------------------------------------------------------
// 3. VERSES LOADING
// ------------------------------------------------------------------------------
// Loads Bible verses for a specific book and chapter combination.
// Uses FutureProvider with family modifier for parameterized loading.
// Auto-disposes when the chapter changes to prevent memory leaks.
// ------------------------------------------------------------------------------

/// Provider for loading verses for a specific chapter
///
/// Usage:
/// ```dart
/// final verses = ref.watch(currentChapterVersesProvider(
///   ChapterParams('Genesis', 1)
/// ));
/// ```
///
/// Returns:
/// - AsyncValue<List<BibleVerse>> containing all verses in the chapter
/// - Loading state while fetching from database
/// - Error state if fetch fails
final currentChapterVersesProvider = FutureProvider.autoDispose
    .family<List<BibleVerse>, ChapterParams>((ref, params) async {
      // Get the Bible service from app providers
      final service = ref.read(bibleServiceProvider);

      // Fetch verses for the requested book and chapter
      return await service.getChapter(book: params.book, chapter: params.chapter);
    });

// ------------------------------------------------------------------------------
// 4. CHAPTER METADATA
// ------------------------------------------------------------------------------
// Provides metadata about a book including total chapter count.
// Used for navigation controls and chapter validation.
// Auto-disposes when switching books.
// ------------------------------------------------------------------------------

/// Provider for chapter metadata (total chapters in book, etc.)
///
/// Usage:
/// ```dart
/// final metadata = ref.watch(chapterMetadataProvider('Genesis'));
/// print('Total chapters: ${metadata.totalChapters}');
/// ```
final chapterMetadataProvider = Provider.autoDispose
    .family<ChapterMetadata, String>((ref, book) {
      return ChapterMetadata(
        book: book,
        totalChapters: _getBookChapterCount(book),
      );
    });

// ------------------------------------------------------------------------------
// 5. NAVIGATION STATE
// ------------------------------------------------------------------------------
// Tracks whether the user can navigate to previous/next chapters
// Used to enable/disable navigation buttons
// ------------------------------------------------------------------------------

/// Provider to check if user can navigate to previous chapter
final canNavigatePreviousProvider = Provider.autoDispose<bool>((ref) {
  final currentChapter = ref.watch(currentChapterProvider);
  return currentChapter > 1;
});

/// Provider to check if user can navigate to next chapter
/// Requires book name to check against total chapters
final canNavigateNextProvider = Provider.autoDispose.family<bool, String>((
  ref,
  book,
) {
  final currentChapter = ref.watch(currentChapterProvider);
  final metadata = ref.watch(chapterMetadataProvider(book));
  return currentChapter < metadata.totalChapters;
});

// ==============================================================================
// HELPER CLASSES
// ==============================================================================

/// Parameters for loading a specific chapter
///
/// Used with family providers to ensure proper equality checks
/// and caching behavior.
class ChapterParams {
  final String book;
  final int chapter;

  const ChapterParams(this.book, this.chapter);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterParams &&
          runtimeType == other.runtimeType &&
          book == other.book &&
          chapter == other.chapter;

  @override
  int get hashCode => book.hashCode ^ chapter.hashCode;

  @override
  String toString() => 'ChapterParams(book: $book, chapter: $chapter)';
}

/// Metadata about a Bible book
///
/// Contains information needed for chapter navigation and validation
class ChapterMetadata {
  final String book;
  final int totalChapters;

  const ChapterMetadata({required this.book, required this.totalChapters});

  /// Check if a chapter number is valid for this book
  bool isValidChapter(int chapter) {
    return chapter >= 1 && chapter <= totalChapters;
  }

  @override
  String toString() =>
      'ChapterMetadata(book: $book, totalChapters: $totalChapters)';
}

// ==============================================================================
// BIBLE BOOK CHAPTER COUNTS
// ==============================================================================
// Reference data for chapter counts in each book of the Bible
// ==============================================================================

/// Get the total number of chapters in a Bible book
///
/// Returns the chapter count for the given book name.
/// Returns 1 if the book is not found (for safety).
int _getBookChapterCount(String book) {
  return _bibleBookChapters[book] ?? 1;
}

/// Complete chapter counts for all 66 books of the Bible
///
/// Organized by Testament for clarity
const Map<String, int> _bibleBookChapters = {
  // OLD TESTAMENT - Torah (5 books)
  'Genesis': 50,
  'Exodus': 40,
  'Leviticus': 27,
  'Numbers': 36,
  'Deuteronomy': 34,

  // OLD TESTAMENT - Historical Books (12 books)
  'Joshua': 24,
  'Judges': 21,
  'Ruth': 4,
  '1 Samuel': 31,
  '2 Samuel': 24,
  '1 Kings': 22,
  '2 Kings': 25,
  '1 Chronicles': 29,
  '2 Chronicles': 36,
  'Ezra': 10,
  'Nehemiah': 13,
  'Esther': 10,

  // OLD TESTAMENT - Wisdom Literature (5 books)
  'Job': 42,
  'Psalms': 150,
  'Proverbs': 31,
  'Ecclesiastes': 12,
  'Song of Solomon': 8,

  // OLD TESTAMENT - Major Prophets (5 books)
  'Isaiah': 66,
  'Jeremiah': 52,
  'Lamentations': 5,
  'Ezekiel': 48,
  'Daniel': 12,

  // OLD TESTAMENT - Minor Prophets (12 books)
  'Hosea': 14,
  'Joel': 3,
  'Amos': 9,
  'Obadiah': 1,
  'Jonah': 4,
  'Micah': 7,
  'Nahum': 3,
  'Habakkuk': 3,
  'Zephaniah': 3,
  'Haggai': 2,
  'Zechariah': 14,
  'Malachi': 4,

  // NEW TESTAMENT - Gospels (4 books)
  'Matthew': 28,
  'Mark': 16,
  'Luke': 24,
  'John': 21,

  // NEW TESTAMENT - History (1 book)
  'Acts': 28,

  // NEW TESTAMENT - Pauline Epistles (13 books)
  'Romans': 16,
  '1 Corinthians': 16,
  '2 Corinthians': 13,
  'Galatians': 6,
  'Ephesians': 6,
  'Philippians': 4,
  'Colossians': 4,
  '1 Thessalonians': 5,
  '2 Thessalonians': 3,
  '1 Timothy': 6,
  '2 Timothy': 4,
  'Titus': 3,
  'Philemon': 1,

  // NEW TESTAMENT - General Epistles (8 books)
  'Hebrews': 13,
  'James': 5,
  '1 Peter': 5,
  '2 Peter': 3,
  '1 John': 5,
  '2 John': 1,
  '3 John': 1,
  'Jude': 1,

  // NEW TESTAMENT - Apocalyptic (1 book)
  'Revelation': 22,
};

// ==============================================================================
// UTILITY PROVIDERS
// ==============================================================================

/// Provider to get all Bible book names (for book selection UI)
final bibleBookNamesProvider = Provider<List<String>>((ref) {
  return _bibleBookChapters.keys.toList();
});

/// Provider to get book names by testament
enum Testament { oldTestament, newTestament }

final booksByTestamentProvider = Provider.family<List<String>, Testament>((
  ref,
  testament,
) {
  final allBooks = _bibleBookChapters.keys.toList();
  switch (testament) {
    case Testament.oldTestament:
      // First 39 books are Old Testament
      return allBooks.sublist(0, 39);
    case Testament.newTestament:
      // Last 27 books are New Testament
      return allBooks.sublist(39);
  }
});
