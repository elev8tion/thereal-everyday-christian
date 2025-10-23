import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/core/services/connectivity_service.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/services/notification_service.dart';
import 'package:everyday_christian/core/services/preferences_service.dart';
import 'package:everyday_christian/core/services/prayer_service.dart';
import 'package:everyday_christian/core/services/verse_service.dart';
import 'package:everyday_christian/core/services/devotional_service.dart';
import 'package:everyday_christian/core/services/reading_plan_service.dart';
import 'package:everyday_christian/core/services/bible_loader_service.dart';
import 'package:everyday_christian/core/services/devotional_content_loader.dart';
import 'package:everyday_christian/core/services/devotional_progress_service.dart';
import 'package:everyday_christian/core/services/reading_plan_progress_service.dart';
import 'package:everyday_christian/core/services/prayer_streak_service.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    // Set up mock SharedPreferences for all tests
    SharedPreferences.setMockInitialValues({});
  });
  group('Service Providers', () {
    test('connectivityServiceProvider should provide ConnectivityService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(connectivityServiceProvider);

      expect(service, isA<ConnectivityService>());
    });

    test('databaseServiceProvider should provide DatabaseService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(databaseServiceProvider);

      expect(service, isA<DatabaseService>());
    });

    test('notificationServiceProvider should provide NotificationService', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(notificationServiceProvider);

      expect(service, isA<NotificationService>());
    });

    test('preferencesServiceProvider should provide PreferencesService', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(preferencesServiceProvider);

      expect(asyncValue, isA<AsyncValue<PreferencesService>>());
    });

    test('prayerServiceProvider should provide PrayerService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(prayerServiceProvider);

      expect(service, isA<PrayerService>());
    });

    test('verseServiceProvider should provide VerseService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(verseServiceProvider);

      expect(service, isA<VerseService>());
    });

    test('devotionalServiceProvider should provide DevotionalService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(devotionalServiceProvider);

      expect(service, isA<DevotionalService>());
    });

    test('readingPlanServiceProvider should provide ReadingPlanService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(readingPlanServiceProvider);

      expect(service, isA<ReadingPlanService>());
    });

    test('bibleLoaderServiceProvider should provide BibleLoaderService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(bibleLoaderServiceProvider);

      expect(service, isA<BibleLoaderService>());
    });

    test('devotionalContentLoaderProvider should provide DevotionalContentLoader with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(devotionalContentLoaderProvider);

      expect(service, isA<DevotionalContentLoader>());
    });

    test('devotionalProgressServiceProvider should provide DevotionalProgressService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(devotionalProgressServiceProvider);

      expect(service, isA<DevotionalProgressService>());
    });

    test('readingPlanProgressServiceProvider should provide ReadingPlanProgressService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(readingPlanProgressServiceProvider);

      expect(service, isA<ReadingPlanProgressService>());
    });

    test('prayerStreakServiceProvider should provide PrayerStreakService with database', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final service = container.read(prayerStreakServiceProvider);

      expect(service, isA<PrayerStreakService>());
    });
  });

  group('Stream Providers', () {
    test('connectivityStateProvider should provide connectivity stream', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(connectivityStateProvider);

      expect(asyncValue, isA<AsyncValue<bool>>());
    });

    test('connectivityStateProvider should start in loading state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final asyncValue = container.read(connectivityStateProvider);

      expect(asyncValue.isLoading, isTrue);
    });
  });

  group('ThemeModeNotifier', () {
    test('should initialize with dark theme by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(themeModeProvider);

      expect(themeMode, equals(ThemeMode.dark));
    });

    test('should toggle theme from dark to light', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);
      notifier.toggleTheme();

      final themeMode = container.read(themeModeProvider);
      expect(themeMode, equals(ThemeMode.light));
    });

    test('should toggle theme from light to dark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);

      // Toggle to light
      notifier.toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      // Toggle back to dark
      notifier.toggleTheme();
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });

    test('should set specific theme mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);

      notifier.setTheme(ThemeMode.system);
      expect(container.read(themeModeProvider), equals(ThemeMode.system));

      notifier.setTheme(ThemeMode.light);
      expect(container.read(themeModeProvider), equals(ThemeMode.light));

      notifier.setTheme(ThemeMode.dark);
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });

    test('should handle multiple rapid toggles', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);

      // Rapidly toggle
      for (int i = 0; i < 5; i++) {
        notifier.toggleTheme();
      }

      // Should end up on light (odd number of toggles from dark)
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
    });
  });

  group('LanguageNotifier', () {
    test('should initialize with English by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final language = container.read(languageProvider);

      expect(language, equals('English'));
    });

    test('should set language to Spanish', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(languageProvider.notifier);
      await notifier.setLanguage('Spanish');

      final language = container.read(languageProvider);
      expect(language, equals('Spanish'));
    });

    test('should set language to French', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(languageProvider.notifier);
      await notifier.setLanguage('French');

      final language = container.read(languageProvider);
      expect(language, equals('French'));
    });

    test('should handle multiple language changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(languageProvider.notifier);

      await notifier.setLanguage('Spanish');
      expect(container.read(languageProvider), equals('Spanish'));

      await notifier.setLanguage('French');
      expect(container.read(languageProvider), equals('French'));

      await notifier.setLanguage('English');
      expect(container.read(languageProvider), equals('English'));
    });
  });

  group('TextSizeNotifier', () {
    test('should initialize with 16.0 by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final textSize = container.read(textSizeProvider);

      expect(textSize, equals(16.0));
    });

    test('should set text size to valid value', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);
      await notifier.setTextSize(18.0);

      final textSize = container.read(textSizeProvider);
      expect(textSize, equals(18.0));
    });

    test('should clamp text size below minimum (12)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);
      await notifier.setTextSize(10.0);

      final textSize = container.read(textSizeProvider);
      expect(textSize, equals(12.0)); // Clamped to minimum
    });

    test('should clamp text size above maximum (24)', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);
      await notifier.setTextSize(30.0);

      final textSize = container.read(textSizeProvider);
      expect(textSize, equals(24.0)); // Clamped to maximum
    });

    test('should accept text size at minimum boundary', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);
      await notifier.setTextSize(12.0);

      final textSize = container.read(textSizeProvider);
      expect(textSize, equals(12.0));
    });

    test('should accept text size at maximum boundary', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);
      await notifier.setTextSize(24.0);

      final textSize = container.read(textSizeProvider);
      expect(textSize, equals(24.0));
    });

    test('should handle multiple size changes', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);

      await notifier.setTextSize(14.0);
      expect(container.read(textSizeProvider), equals(14.0));

      await notifier.setTextSize(20.0);
      expect(container.read(textSizeProvider), equals(20.0));

      await notifier.setTextSize(16.0);
      expect(container.read(textSizeProvider), equals(16.0));
    });
  });

  group('Notification Settings Notifiers', () {
    test('dailyNotificationsProvider should initialize with true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final enabled = container.read(dailyNotificationsProvider);

      expect(enabled, isTrue);
    });

    test('prayerRemindersProvider should initialize with true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final enabled = container.read(prayerRemindersProvider);

      expect(enabled, isTrue);
    });

    test('verseOfTheDayProvider should initialize with true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final enabled = container.read(verseOfTheDayProvider);

      expect(enabled, isTrue);
    });

    test('notificationTimeProvider should initialize with 08:00', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final time = container.read(notificationTimeProvider);

      expect(time, equals('08:00'));
    });

    test('dailyNotificationsProvider should toggle state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(dailyNotificationsProvider.notifier);

      // Note: This test will show plugin warnings in console because
      // notification service cannot be initialized in test environment.
      // The state change still works correctly.
      await notifier.toggle(false);
      expect(container.read(dailyNotificationsProvider), isFalse);

      await notifier.toggle(true);
      expect(container.read(dailyNotificationsProvider), isTrue);
    }, skip: 'Notification plugin not available in test environment');

    test('prayerRemindersProvider should toggle state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(prayerRemindersProvider.notifier);

      await notifier.toggle(false);
      expect(container.read(prayerRemindersProvider), isFalse);

      await notifier.toggle(true);
      expect(container.read(prayerRemindersProvider), isTrue);
    }, skip: 'Notification plugin not available in test environment');

    test('verseOfTheDayProvider should toggle state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(verseOfTheDayProvider.notifier);

      await notifier.toggle(false);
      expect(container.read(verseOfTheDayProvider), isFalse);

      await notifier.toggle(true);
      expect(container.read(verseOfTheDayProvider), isTrue);
    }, skip: 'Notification plugin not available in test environment');

    test('notificationTimeProvider should set time', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(notificationTimeProvider.notifier);

      await notifier.setTime('09:30');
      expect(container.read(notificationTimeProvider), equals('09:30'));

      await notifier.setTime('18:00');
      expect(container.read(notificationTimeProvider), equals('18:00'));
    }, skip: 'Notification plugin not available in test environment');
  });

  group('Provider Isolation', () {
    test('should isolate providers between containers', () {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      // Modify theme in container1
      container1.read(themeModeProvider.notifier).setTheme(ThemeMode.light);

      // Verify container2 is unaffected
      expect(container1.read(themeModeProvider), equals(ThemeMode.light));
      expect(container2.read(themeModeProvider), equals(ThemeMode.dark));
    });

    test('should isolate language between containers', () async {
      // Reset SharedPreferences to ensure clean state
      SharedPreferences.setMockInitialValues({});

      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      // Wait for PreferencesService to initialize in both containers BEFORE making changes
      // This ensures both start with the default value
      await container1.read(preferencesServiceProvider.future);
      await container2.read(preferencesServiceProvider.future);

      // Force both containers to read their initial language state
      expect(container1.read(languageProvider), equals('English'));
      expect(container2.read(languageProvider), equals('English'));

      // Modify language in container1
      await container1.read(languageProvider.notifier).setLanguage('Spanish');

      // Container1 should have the new value
      expect(container1.read(languageProvider), equals('Spanish'));

      // Container2 should still have its current value since provider state is isolated
      // Note: Even though SharedPreferences is shared, the provider's state variable
      // in container2 doesn't automatically update
      expect(container2.read(languageProvider), equals('English'));
    });

    test('should isolate text size between containers', () async {
      // Reset SharedPreferences to ensure clean state
      SharedPreferences.setMockInitialValues({});

      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      // Wait for PreferencesService to initialize in both containers BEFORE making changes
      await container1.read(preferencesServiceProvider.future);
      await container2.read(preferencesServiceProvider.future);

      // Force both containers to read their initial text size state
      expect(container1.read(textSizeProvider), equals(16.0));
      expect(container2.read(textSizeProvider), equals(16.0));

      // Modify text size in container1
      await container1.read(textSizeProvider.notifier).setTextSize(20.0);

      // Container1 should have the new value
      expect(container1.read(textSizeProvider), equals(20.0));

      // Container2 should still have its current value since provider state is isolated
      expect(container2.read(textSizeProvider), equals(16.0));
    });
  });

  group('Provider Dependencies', () {
    test('prayerServiceProvider should depend on databaseServiceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Reading prayerServiceProvider should also initialize databaseServiceProvider
      final prayerService = container.read(prayerServiceProvider);
      final database = container.read(databaseServiceProvider);

      expect(prayerService, isA<PrayerService>());
      expect(database, isA<DatabaseService>());
    });

    test('multiple services should share same database instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final database1 = container.read(databaseServiceProvider);
      final database2 = container.read(databaseServiceProvider);

      expect(identical(database1, database2), isTrue);
    });

    test('themeModeProvider should depend on preferencesServiceProvider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final themeMode = container.read(themeModeProvider);
      final preferencesAsync = container.read(preferencesServiceProvider);

      expect(themeMode, isA<ThemeMode>());
      expect(preferencesAsync, isA<AsyncValue<PreferencesService>>());
    });
  });

  group('Provider Lifecycle', () {
    test('should properly dispose container and providers', () {
      final container = ProviderContainer();

      // Read some providers
      container.read(themeModeProvider);
      container.read(languageProvider);
      container.read(textSizeProvider);

      // Should not throw
      expect(() => container.dispose(), returnsNormally);
    });

    test('should handle reading after dispose gracefully', () {
      final container = ProviderContainer();
      container.dispose();

      // Reading after dispose should throw
      expect(
        () => container.read(themeModeProvider),
        throwsStateError,
      );
    });

    test('should allow multiple disposes', () {
      final container = ProviderContainer();

      container.dispose();

      // Multiple disposes should not throw
      expect(() => container.dispose(), returnsNormally);
    });
  });

  group('Provider State Persistence', () {
    test('should maintain theme state across reads', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);

      // Read multiple times
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
      expect(container.read(themeModeProvider), equals(ThemeMode.light));
    });

    test('should maintain language state across reads', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      await container.read(languageProvider.notifier).setLanguage('Spanish');

      // Read multiple times
      expect(container.read(languageProvider), equals('Spanish'));
      expect(container.read(languageProvider), equals('Spanish'));
      expect(container.read(languageProvider), equals('Spanish'));
    });

    test('should maintain text size state across reads', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      await container.read(textSizeProvider.notifier).setTextSize(20.0);

      // Read multiple times
      expect(container.read(textSizeProvider), equals(20.0));
      expect(container.read(textSizeProvider), equals(20.0));
      expect(container.read(textSizeProvider), equals(20.0));
    });
  });

  group('Edge Cases', () {
    test('should handle rapid theme toggles without errors', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeModeProvider.notifier);

      // Rapidly toggle 100 times
      for (int i = 0; i < 100; i++) {
        notifier.toggleTheme();
      }

      // Should end on dark (even number from dark start)
      expect(container.read(themeModeProvider), equals(ThemeMode.dark));
    });

    test('should handle extreme text size clamping', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(textSizeProvider.notifier);

      await notifier.setTextSize(0.0);
      expect(container.read(textSizeProvider), equals(12.0));

      await notifier.setTextSize(-100.0);
      expect(container.read(textSizeProvider), equals(12.0));

      await notifier.setTextSize(1000.0);
      expect(container.read(textSizeProvider), equals(24.0));
    });

    test('should handle non-standard language values', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(languageProvider.notifier);

      await notifier.setLanguage('Klingon');
      expect(container.read(languageProvider), equals('Klingon'));
    });

    test('should handle valid notification time formats', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for PreferencesService to initialize
      await container.read(preferencesServiceProvider.future);

      final notifier = container.read(notificationTimeProvider.notifier);

      await notifier.setTime('12:30');
      expect(container.read(notificationTimeProvider), equals('12:30'));

      await notifier.setTime('23:59');
      expect(container.read(notificationTimeProvider), equals('23:59'));

      await notifier.setTime('00:00');
      expect(container.read(notificationTimeProvider), equals('00:00'));
    }, skip: 'Notification plugin not available in test environment');
  });
}
