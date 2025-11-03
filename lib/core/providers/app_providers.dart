import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity_service.dart';
import '../services/database_service.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../services/prayer_service.dart';
import '../services/prayer_streak_service.dart';
import '../services/verse_service.dart';
import '../services/devotional_service.dart';
import '../services/devotional_progress_service.dart';
import '../services/reading_plan_service.dart';
import '../services/reading_plan_progress_service.dart';
import '../services/curated_reading_plan_loader.dart';
import '../services/bible_loader_service.dart';
import '../services/devotional_content_loader.dart';
import '../services/preferences_service.dart';
import '../models/devotional.dart';
import '../models/reading_plan.dart';
import '../../services/unified_verse_service.dart';
import '../../models/bible_verse.dart';
import '../../models/shared_verse_entry.dart';

// Import and export subscription providers
import 'subscription_providers.dart';
export 'subscription_providers.dart';

// Core Services
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// Connectivity Status Stream Provider
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return NotificationService(database);
});

final preferencesServiceProvider = FutureProvider<PreferencesService>((ref) async {
  return await PreferencesService.getInstance();
});

// Daily Verse Provider (queries database schedule)
final todaysVerseProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final db = ref.watch(databaseServiceProvider);

  // Get today's date
  final now = DateTime.now();
  final month = now.month;
  final day = now.day;

  // Query daily_verse_schedule JOIN bible_verses
  final results = await db.database.then((database) => database.rawQuery('''
    SELECT
      v.book || ' ' || v.chapter || ':' || v.verse as reference,
      v.text
    FROM daily_verse_schedule s
    JOIN bible_verses v ON s.verse_id = v.id
    WHERE s.month = ? AND s.day = ?
    LIMIT 1
  ''', [month, day]));

  if (results.isEmpty) return null;

  return {
    'reference': results.first['reference'] as String,
    'text': results.first['text'] as String,
  };
});

// Feature Services
final prayerServiceProvider = Provider<PrayerService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return PrayerService(database);
});

// TODO: REFACTOR - Multiple verse services exist with overlapping functionality
// - core/services/verse_service.dart (legacy, used by verse_preferences_widget, daily_verse_screen)
// - services/verse_service.dart (legacy, used by verse_context_service)
// - services/unified_verse_service.dart (modern, feature-complete, preferred)
// RECOMMENDATION: Migrate all functionality to UnifiedVerseService and deprecate legacy services
final verseServiceProvider = Provider<VerseService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return VerseService(database);
});

// Bible Service Provider (alias for VerseService for compatibility)
/// Used by bible_reader screens for chapter reading functionality
final bibleServiceProvider = Provider<VerseService>((ref) {
  return ref.read(verseServiceProvider);
});

// Unified Verse Service (modern, feature-complete - USE THIS for new features)
final unifiedVerseServiceProvider = Provider<UnifiedVerseService>((ref) {
  return UnifiedVerseService();
});

// Verse Library Providers

/// Provider for getting all verses
final allVersesProvider = FutureProvider.autoDispose<List<BibleVerse>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getAllVerses(limit: 100);
});

/// Provider for getting favorite verses
final favoriteVersesProvider = FutureProvider.autoDispose<List<BibleVerse>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getFavoriteVerses();
});

/// Provider for searching verses (family provider with query parameter)
final searchVersesProvider = FutureProvider.autoDispose.family<List<BibleVerse>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];

  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.searchVerses(query, limit: 50);
});

/// Provider for getting verses by theme
final versesByThemeProvider = FutureProvider.autoDispose.family<List<BibleVerse>, String>((ref, theme) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.searchByTheme(theme, limit: 50);
});

/// Provider for getting all available themes
final availableThemesProvider = FutureProvider<List<String>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getAllThemes();
});

/// Provider for verse statistics
final verseStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getVerseStats();
});

/// Provider for recently shared verses
final sharedVersesProvider = FutureProvider.autoDispose<List<SharedVerseEntry>>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getSharedVerses();
});

/// Provider for count of shared verses
final sharedVersesCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  return await service.getSharedVerseCount();
});

/// Provider for count of saved/favorite verses
final savedVersesCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(unifiedVerseServiceProvider);
  final verses = await service.getFavoriteVerses();
  return verses.length;
});

/// Provider for count of active prayers
final activePrayersCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(prayerServiceProvider);
  return await service.getPrayerCount();
});

/// Provider for count of answered prayers
final answeredPrayersCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(prayerServiceProvider);
  return await service.getAnsweredPrayerCount();
});

/// Provider for count of active reading plans
final activeReadingPlansCountProvider = FutureProvider<int>((ref) async {
  final plans = await ref.watch(activeReadingPlansProvider.future);
  return plans.length;
});

final devotionalServiceProvider = Provider<DevotionalService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalService(database);
});

final readingPlanServiceProvider = Provider<ReadingPlanService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return ReadingPlanService(database);
});

final bibleLoaderServiceProvider = Provider<BibleLoaderService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return BibleLoaderService(database);
});

final devotionalContentLoaderProvider = Provider<DevotionalContentLoader>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalContentLoader(database);
});

final devotionalProgressServiceProvider = Provider<DevotionalProgressService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return DevotionalProgressService(database);
});

final readingPlanProgressServiceProvider = Provider<ReadingPlanProgressService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return ReadingPlanProgressService(database);
});

final curatedReadingPlanLoaderProvider = Provider<CuratedReadingPlanLoader>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return CuratedReadingPlanLoader(database);
});

final prayerStreakServiceProvider = Provider<PrayerStreakService>((ref) {
  final database = ref.watch(databaseServiceProvider);
  return PrayerStreakService(database);
});

// State Providers
final connectivityStateProvider = StreamProvider.autoDispose<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final database = ref.read(databaseServiceProvider);
  final notifications = ref.read(notificationServiceProvider);
  final subscription = ref.read(subscriptionServiceProvider);
  final bibleLoader = ref.read(bibleLoaderServiceProvider);
  final devotionalLoader = ref.read(devotionalContentLoaderProvider);
  final curatedPlanLoader = ref.read(curatedReadingPlanLoaderProvider);

  await database.initialize();
  await notifications.initialize();
  await subscription.initialize();

  // Automatic cleanup: Remove old chat messages (60+ days OR keep only 100 most recent)
  try {
    final dbHelper = DatabaseHelper.instance;
    final cleanup = await dbHelper.autoCleanupChatMessages();
    if (cleanup['total_deleted']! > 0) {
      print('🧹 Auto-cleanup: Removed ${cleanup['total_deleted']} old chat messages');
    }
  } catch (e) {
    // Don't block app initialization if cleanup fails
    print('⚠️ Auto-cleanup failed: $e');
  }

  // Load Bible on first launch
  final isWEBLoaded = await bibleLoader.isBibleLoaded('WEB');
  if (!isWEBLoaded) {
    await bibleLoader.loadAllBibles();
  } else {
  }

  // Load devotional content on first launch
  await devotionalLoader.loadDevotionals();

  // Load curated reading plans on first launch (idempotent)
  await curatedPlanLoader.ensureCuratedPlansLoaded();
});

// Devotional Progress Providers

/// Provider for getting all devotionals
final allDevotionalsProvider = FutureProvider<List<Devotional>>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getAllDevotionals();
});

/// Provider for getting today's devotional
final todaysDevotionalProvider = FutureProvider<Devotional?>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getTodaysDevotional();
});

/// Provider for getting completion status of a specific devotional
final devotionalCompletionStatusProvider = FutureProvider.family<bool, String>((ref, devotionalId) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletionStatus(devotionalId);
});

/// Provider for getting the current devotional streak
final devotionalStreakProvider = FutureProvider<int>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getStreakCount();
});

/// Provider for getting total number of completed devotionals
final totalDevotionalsCompletedProvider = FutureProvider<int>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getTotalCompleted();
});

/// Provider for getting completion percentage
final devotionalCompletionPercentageProvider = FutureProvider<double>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletionPercentage();
});

/// Provider for getting all completed devotionals
final completedDevotionalsProvider = FutureProvider<List<Devotional>>((ref) async {
  final progressService = ref.watch(devotionalProgressServiceProvider);
  return await progressService.getCompletedDevotionals();
});

// Reading Plan Progress Providers

/// Provider for getting all reading plans
final allReadingPlansProvider = FutureProvider<List<ReadingPlan>>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getAllPlans();
});

/// Provider for getting active reading plans
final activeReadingPlansProvider = FutureProvider<List<ReadingPlan>>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getActivePlans();
});

/// Provider for getting the current active plan
final currentReadingPlanProvider = FutureProvider<ReadingPlan?>((ref) async {
  final planService = ref.watch(readingPlanServiceProvider);
  return await planService.getCurrentPlan();
});

/// Provider for getting progress percentage for a specific plan
final planProgressPercentageProvider = FutureProvider.family<double, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getProgressPercentage(planId);
});

/// Provider for getting current day number in a plan
final planCurrentDayProvider = FutureProvider.family<int, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCurrentDay(planId);
});

/// Provider for getting today's readings for a plan
final todaysReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getTodaysReadings(planId);
});

/// Provider for getting incomplete readings for a plan
final incompleteReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getIncompleteReadings(planId);
});

/// Provider for getting completed readings for a plan
final completedReadingsProvider = FutureProvider.family<List<DailyReading>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCompletedReadings(planId);
});

/// Provider for getting reading streak for a plan
final planStreakProvider = FutureProvider.family<int, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getStreak(planId);
});

/// Provider for getting calendar heatmap data for a plan
final planHeatmapDataProvider = FutureProvider.family<Map<DateTime, int>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCalendarHeatmapData(planId, days: 90);
});

/// Provider for getting completion statistics for a plan
final planCompletionStatsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getCompletionStats(planId);
});

/// Provider for getting missed days for a plan
final planMissedDaysProvider = FutureProvider.family<List<DateTime>, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getMissedDays(planId);
});

/// Provider for getting weekly completion rate for a plan
final planWeeklyCompletionRateProvider = FutureProvider.family<double, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getWeeklyCompletionRate(planId);
});

/// Provider for getting estimated completion date for a plan
final planEstimatedCompletionDateProvider = FutureProvider.family<DateTime?, String>((ref, planId) async {
  final progressService = ref.watch(readingPlanProgressServiceProvider);
  return await progressService.getEstimatedCompletionDate(planId);
});

// Prayer Streak Providers

/// Provider for getting the current prayer streak
final currentPrayerStreakProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getCurrentStreak();
});

/// Provider for getting the longest prayer streak ever achieved
final longestPrayerStreakProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getLongestStreak();
});

/// Provider for checking if user has prayed today
final prayedTodayProvider = FutureProvider<bool>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.hasPrayedToday();
});

/// Provider for getting total days prayed (not consecutive)
final totalDaysPrayedProvider = FutureProvider<int>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getTotalDaysPrayed();
});

/// Provider for getting all prayer activity dates
final prayerActivityDatesProvider = FutureProvider<List<DateTime>>((ref) async {
  final streakService = ref.watch(prayerStreakServiceProvider);
  return await streakService.getAllActivityDates();
});

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return ThemeModeNotifier(preferencesAsync);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  ThemeModeNotifier(this._preferencesAsync) : super(ThemeMode.dark) {
    _initializeTheme();
  }

  /// Initialize theme from saved preferences
  Future<void> _initializeTheme() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadThemeMode();
    });
  }

  /// Toggle between light and dark theme
  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _setThemeAndSave(newMode);
  }

  /// Set specific theme mode
  void setTheme(ThemeMode mode) {
    _setThemeAndSave(mode);
  }

  /// Internal method to set theme and save to preferences
  Future<void> _setThemeAndSave(ThemeMode mode) async {
    state = mode;

    if (_preferences == null) {
      developer.log(
        'Theme preferences not yet loaded; skipping persistence.',
        name: 'AppProviders.theme',
      );
      return;
    }

    final success = await _preferences!.saveThemeMode(mode);
    if (!success) {
      developer.log(
        'Failed to persist theme mode $mode',
        name: 'AppProviders.theme',
        level: 900,
      );
    }
  }
}

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return LanguageNotifier(preferencesAsync);
});

class LanguageNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  LanguageNotifier(this._preferencesAsync) : super('English') {
    _initializeLanguage();
  }

  /// Initialize language from saved preferences
  Future<void> _initializeLanguage() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadLanguage();
    });
  }

  /// Set language preference
  Future<void> setLanguage(String language) async {
    state = language;

    if (_preferences == null) {
      developer.log(
        'Language preferences not yet loaded; skipping persistence.',
        name: 'AppProviders.language',
      );
      return;
    }

    final success = await _preferences!.saveLanguage(language);
    if (!success) {
      developer.log(
        'Failed to persist language preference: $language',
        name: 'AppProviders.language',
        level: 900,
      );
    }
  }
}

// Text Size Provider
final textSizeProvider = StateNotifierProvider<TextSizeNotifier, double>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return TextSizeNotifier(preferencesAsync);
});

// Notification Settings Providers
final dailyNotificationsProvider = StateNotifierProvider<DailyNotificationsNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return DailyNotificationsNotifier(preferencesAsync, ref);
});

final prayerRemindersProvider = StateNotifierProvider<PrayerRemindersNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return PrayerRemindersNotifier(preferencesAsync, ref);
});

final verseOfTheDayProvider = StateNotifierProvider<VerseOfTheDayNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return VerseOfTheDayNotifier(preferencesAsync, ref);
});

final readingPlanRemindersProvider = StateNotifierProvider<ReadingPlanRemindersNotifier, bool>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return ReadingPlanRemindersNotifier(preferencesAsync, ref);
});

// Individual notification time providers
final devotionalTimeProvider = StateNotifierProvider<DevotionalTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return DevotionalTimeNotifier(preferencesAsync, ref);
});

final prayerTimeProvider = StateNotifierProvider<PrayerTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return PrayerTimeNotifier(preferencesAsync, ref);
});

final verseTimeProvider = StateNotifierProvider<VerseTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return VerseTimeNotifier(preferencesAsync, ref);
});

final readingPlanTimeProvider = StateNotifierProvider<ReadingPlanTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return ReadingPlanTimeNotifier(preferencesAsync, ref);
});

// Legacy single time provider - kept for migration purposes
final notificationTimeProvider = StateNotifierProvider<NotificationTimeNotifier, String>((ref) {
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  return NotificationTimeNotifier(preferencesAsync, ref);
});

class TextSizeNotifier extends StateNotifier<double> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  PreferencesService? _preferences;

  TextSizeNotifier(this._preferencesAsync) : super(1.0) { // Default 1.0 = 100% scale
    _initializeTextSize();
  }

  /// Initialize text size from saved preferences
  Future<void> _initializeTextSize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      final savedSize = prefs.loadTextSize();
      final scaleFactor = _migrateToScaleFactor(savedSize);
      state = scaleFactor;
    });
  }

  /// Migrate old pixel-based text sizes (12-24) to scale factors (0.8-1.5)
  double _migrateToScaleFactor(double value) {
    // If value is in old range (12-24), convert to scale factor
    if (value >= 12.0 && value <= 24.0) {
      // Map 12-24 range to 0.8-1.5 range
      // 16 (middle) → 1.0, 12 (min) → 0.8, 24 (max) → 1.5
      return 0.8 + ((value - 12.0) / 12.0) * 0.7;
    }
    // Already a scale factor, return as-is
    return value.clamp(0.8, 1.5);
  }

  /// Set text size (scale factor from 0.8 to 1.5)
  Future<void> setTextSize(double size) async {
    // Validate size is within scale factor bounds (0.8-1.5)
    if (size < 0.8 || size > 1.5) {
      size = size.clamp(0.8, 1.5);
    }

    state = size;

    if (_preferences == null) {
      developer.log(
        'Text size preferences not yet loaded; skipping persistence.',
        name: 'AppProviders.textSize',
      );
      return;
    }

    final success = await _preferences!.saveTextSize(size);
    if (!success) {
      developer.log(
        'Failed to persist text size $size',
        name: 'AppProviders.textSize',
        level: 900,
      );
    }
  }
}

// Notification Settings Notifiers
class DailyNotificationsNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  DailyNotificationsNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadDailyNotificationsEnabled();
    });
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.saveDailyNotificationsEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(1);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(devotionalTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).scheduleDailyDevotional(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class PrayerRemindersNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  PrayerRemindersNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadPrayerRemindersEnabled();
    });
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.savePrayerRemindersEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(2);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(prayerTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).schedulePrayerReminder(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class VerseOfTheDayNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  VerseOfTheDayNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadVerseOfTheDayEnabled();
    });
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.saveVerseOfTheDayEnabled(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(3);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(verseTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).scheduleDailyVerse(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class ReadingPlanRemindersNotifier extends StateNotifier<bool> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  ReadingPlanRemindersNotifier(this._preferencesAsync, this._ref) : super(true) {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadReadingPlanReminders();
    });
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _preferences?.saveReadingPlanReminders(enabled);
    if (enabled) {
      await _scheduleNotifications();
    } else {
      await _ref.read(notificationServiceProvider).cancel(4);
    }
  }

  Future<void> _scheduleNotifications() async {
    final time = _ref.read(readingPlanTimeProvider);
    final parts = time.split(':');
    await _ref.read(notificationServiceProvider).scheduleReadingPlanReminder(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class NotificationTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  NotificationTimeNotifier(this._preferencesAsync, this._ref) : super('08:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadNotificationTime();
    });
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.saveNotificationTime(time);
    // Reschedule all enabled notifications with new time
    await _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    final parts = state.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    if (_ref.read(dailyNotificationsProvider)) {
      await _ref.read(notificationServiceProvider).scheduleDailyDevotional(
        hour: hour,
        minute: minute,
      );
    }

    if (_ref.read(prayerRemindersProvider)) {
      await _ref.read(notificationServiceProvider).schedulePrayerReminder(
        hour: hour,
        minute: minute,
      );
    }

    if (_ref.read(verseOfTheDayProvider)) {
      await _ref.read(notificationServiceProvider).scheduleReadingPlanReminder(
        hour: hour,
        minute: minute,
      );
    }
  }
}

// Individual Time Notifiers
class DevotionalTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  DevotionalTimeNotifier(this._preferencesAsync, this._ref) : super('07:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadDevotionalTime();
    });
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.saveDevotionalTime(time);
    // Reschedule devotional notification if enabled
    if (_ref.read(dailyNotificationsProvider)) {
      final parts = time.split(':');
      await _ref.read(notificationServiceProvider).scheduleDailyDevotional(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }
}

class PrayerTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  PrayerTimeNotifier(this._preferencesAsync, this._ref) : super('12:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadPrayerTime();
    });
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.savePrayerTime(time);
    // Reschedule prayer notification if enabled
    if (_ref.read(prayerRemindersProvider)) {
      final parts = time.split(':');
      await _ref.read(notificationServiceProvider).schedulePrayerReminder(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }
}

class VerseTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  VerseTimeNotifier(this._preferencesAsync, this._ref) : super('09:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadVerseTime();
    });
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.saveVerseTime(time);
    // Reschedule verse notification if enabled
    if (_ref.read(verseOfTheDayProvider)) {
      final parts = time.split(':');
      await _ref.read(notificationServiceProvider).scheduleDailyVerse(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }
}

class ReadingPlanTimeNotifier extends StateNotifier<String> {
  final AsyncValue<PreferencesService> _preferencesAsync;
  final Ref _ref;
  PreferencesService? _preferences;

  ReadingPlanTimeNotifier(this._preferencesAsync, this._ref) : super('20:00') {
    _initialize();
  }

  Future<void> _initialize() async {
    _preferencesAsync.whenData((prefs) {
      _preferences = prefs;
      state = prefs.loadReadingPlanTime();
    });
  }

  Future<void> setTime(String time) async {
    state = time;
    await _preferences?.saveReadingPlanTime(time);
    // Reschedule reading plan notification if enabled
    if (_ref.read(readingPlanRemindersProvider)) {
      final parts = time.split(':');
      await _ref.read(notificationServiceProvider).scheduleReadingPlanReminder(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }
}

// App Initialization Provider
// Initializes notification service and schedules notifications on app startup
final initializeAppProvider = FutureProvider<void>((ref) async {
  // Initialize notification service
  final notifications = ref.read(notificationServiceProvider);
  await notifications.initialize();

  // Wait for preferences to load
  final preferencesAsync = ref.watch(preferencesServiceProvider);
  await preferencesAsync.when(
    data: (prefs) async {
      // Schedule notifications if enabled
      final notificationTime = prefs.loadNotificationTime();
      final parts = notificationTime.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (prefs.loadDailyNotificationsEnabled()) {
        await notifications.scheduleDailyDevotional(
          hour: hour,
          minute: minute,
        );
      }

      if (prefs.loadPrayerRemindersEnabled()) {
        await notifications.schedulePrayerReminder(
          hour: hour,
          minute: minute,
        );
      }

      if (prefs.loadVerseOfTheDayEnabled()) {
        await notifications.scheduleReadingPlanReminder(
          hour: hour,
          minute: minute,
        );
      }
    },
    loading: () => null,
    error: (error, _) {
      developer.log(
        'Failed to initialize notifications: $error',
        name: 'AppProviders.notifications',
        level: 900,
      );
    },
  );
});
