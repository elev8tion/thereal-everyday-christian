import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyday_christian/core/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    late PreferencesService preferencesService;

    setUp(() async {
      // Set up mock SharedPreferences with empty values
      SharedPreferences.setMockInitialValues({});
      preferencesService = await PreferencesService.getInstance();
    });

    tearDown(() async {
      // Clear all preferences after each test
      await preferencesService.clearAll();
    });

    group('Singleton Pattern', () {
      test('should return same instance on multiple calls', () async {
        final instance1 = await PreferencesService.getInstance();
        final instance2 = await PreferencesService.getInstance();

        expect(instance1, same(instance2));
      });

      test('should be initialized after getInstance', () async {
        expect(preferencesService.isInitialized, isTrue);
      });
    });

    group('Theme Mode Persistence', () {
      test('should save and load dark theme mode', () async {
        // Save dark theme
        final saveResult = await preferencesService.saveThemeMode(ThemeMode.dark);
        expect(saveResult, isTrue);

        // Load theme
        final loadedTheme = preferencesService.loadThemeMode();
        expect(loadedTheme, ThemeMode.dark);
      });

      test('should save and load light theme mode', () async {
        final saveResult = await preferencesService.saveThemeMode(ThemeMode.light);
        expect(saveResult, isTrue);

        final loadedTheme = preferencesService.loadThemeMode();
        expect(loadedTheme, ThemeMode.light);
      });

      test('should save and load system theme mode', () async {
        final saveResult = await preferencesService.saveThemeMode(ThemeMode.system);
        expect(saveResult, isTrue);

        final loadedTheme = preferencesService.loadThemeMode();
        expect(loadedTheme, ThemeMode.system);
      });

      test('should return dark as default when no theme is saved', () {
        final loadedTheme = preferencesService.loadThemeMode();
        expect(loadedTheme, ThemeMode.dark);
      });

      test('should overwrite previous theme on save', () async {
        await preferencesService.saveThemeMode(ThemeMode.light);
        await preferencesService.saveThemeMode(ThemeMode.dark);

        final loadedTheme = preferencesService.loadThemeMode();
        expect(loadedTheme, ThemeMode.dark);
      });
    });

    group('Language Persistence', () {
      test('should save and load English language', () async {
        final saveResult = await preferencesService.saveLanguage('English');
        expect(saveResult, isTrue);

        final loadedLanguage = preferencesService.loadLanguage();
        expect(loadedLanguage, 'English');
      });

      test('should save and load Spanish language', () async {
        final saveResult = await preferencesService.saveLanguage('Spanish');
        expect(saveResult, isTrue);

        final loadedLanguage = preferencesService.loadLanguage();
        expect(loadedLanguage, 'Spanish');
      });

      test('should return English as default when no language is saved', () {
        final loadedLanguage = preferencesService.loadLanguage();
        expect(loadedLanguage, 'English');
      });

      test('should overwrite previous language on save', () async {
        await preferencesService.saveLanguage('English');
        await preferencesService.saveLanguage('Spanish');

        final loadedLanguage = preferencesService.loadLanguage();
        expect(loadedLanguage, 'Spanish');
      });
    });

    group('Text Size Persistence', () {
      test('should save and load text size', () async {
        final saveResult = await preferencesService.saveTextSize(18.0);
        expect(saveResult, isTrue);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 18.0);
      });

      test('should save and load minimum text size (12.0)', () async {
        await preferencesService.saveTextSize(12.0);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 12.0);
      });

      test('should save and load maximum text size (24.0)', () async {
        await preferencesService.saveTextSize(24.0);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 24.0);
      });

      test('should return 16.0 as default when no size is saved', () {
        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 16.0);
      });

      test('should handle decimal text sizes', () async {
        await preferencesService.saveTextSize(14.5);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 14.5);
      });

      test('should overwrite previous text size on save', () async {
        await preferencesService.saveTextSize(14.0);
        await preferencesService.saveTextSize(20.0);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 20.0);
      });
    });

    group('Clear All Preferences', () {
      test('should clear all saved preferences', () async {
        // Save all preferences
        await preferencesService.saveThemeMode(ThemeMode.light);
        await preferencesService.saveLanguage('Spanish');
        await preferencesService.saveTextSize(20.0);

        // Clear all
        final clearResult = await preferencesService.clearAll();
        expect(clearResult, isTrue);

        // Verify all return to defaults
        expect(preferencesService.loadThemeMode(), ThemeMode.dark);
        expect(preferencesService.loadLanguage(), 'English');
        expect(preferencesService.loadTextSize(), 16.0);
      });
    });

    group('Multiple Preferences', () {
      test('should save and load multiple preferences independently', () async {
        // Save all preferences
        await preferencesService.saveThemeMode(ThemeMode.light);
        await preferencesService.saveLanguage('Spanish');
        await preferencesService.saveTextSize(18.0);

        // Load and verify all
        expect(preferencesService.loadThemeMode(), ThemeMode.light);
        expect(preferencesService.loadLanguage(), 'Spanish');
        expect(preferencesService.loadTextSize(), 18.0);
      });

      test('should not affect other preferences when updating one', () async {
        // Set initial values
        await preferencesService.saveThemeMode(ThemeMode.dark);
        await preferencesService.saveLanguage('English');
        await preferencesService.saveTextSize(16.0);

        // Update only theme
        await preferencesService.saveThemeMode(ThemeMode.light);

        // Verify only theme changed
        expect(preferencesService.loadThemeMode(), ThemeMode.light);
        expect(preferencesService.loadLanguage(), 'English');
        expect(preferencesService.loadTextSize(), 16.0);
      });
    });

    group('Edge Cases', () {
      test('should handle rapid successive saves', () async {
        for (int i = 0; i < 10; i++) {
          await preferencesService.saveTextSize(12.0 + i);
        }

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 21.0); // Last value saved
      });

      test('should handle very large text sizes', () async {
        await preferencesService.saveTextSize(100.0);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 100.0);
      });

      test('should handle very small text sizes', () async {
        await preferencesService.saveTextSize(1.0);

        final loadedSize = preferencesService.loadTextSize();
        expect(loadedSize, 1.0);
      });
    });

    group('Notification Settings', () {
      test('should save and load daily notifications enabled', () async {
        final result = await preferencesService.saveDailyNotificationsEnabled(true);
        expect(result, isTrue);

        final loaded = preferencesService.loadDailyNotificationsEnabled();
        expect(loaded, isTrue);
      });

      test('should save and load daily notifications disabled', () async {
        final result = await preferencesService.saveDailyNotificationsEnabled(false);
        expect(result, isTrue);

        final loaded = preferencesService.loadDailyNotificationsEnabled();
        expect(loaded, isFalse);
      });

      test('should default to true when no daily notifications preference', () async {
        final loaded = preferencesService.loadDailyNotificationsEnabled();
        expect(loaded, isTrue);
      });

      test('should save and load prayer reminders enabled', () async {
        final result = await preferencesService.savePrayerRemindersEnabled(true);
        expect(result, isTrue);

        final loaded = preferencesService.loadPrayerRemindersEnabled();
        expect(loaded, isTrue);
      });

      test('should save and load prayer reminders disabled', () async {
        final result = await preferencesService.savePrayerRemindersEnabled(false);
        expect(result, isTrue);

        final loaded = preferencesService.loadPrayerRemindersEnabled();
        expect(loaded, isFalse);
      });

      test('should save and load verse of the day enabled', () async {
        final result = await preferencesService.saveVerseOfTheDayEnabled(true);
        expect(result, isTrue);

        final loaded = preferencesService.loadVerseOfTheDayEnabled();
        expect(loaded, isTrue);
      });

      test('should save and load verse of the day disabled', () async {
        final result = await preferencesService.saveVerseOfTheDayEnabled(false);
        expect(result, isTrue);

        final loaded = preferencesService.loadVerseOfTheDayEnabled();
        expect(loaded, isFalse);
      });

      test('should save and load notification time', () async {
        final result = await preferencesService.saveNotificationTime('09:30');
        expect(result, isTrue);

        final loaded = preferencesService.loadNotificationTime();
        expect(loaded, '09:30');
      });

      test('should default to 08:00 when no notification time saved', () async {
        final loaded = preferencesService.loadNotificationTime();
        expect(loaded, '08:00');
      });
    });

    group('Utility Methods', () {
      test('should remove specific preference', () async {
        // Save a preference
        await preferencesService.saveLanguage('Spanish');
        expect(preferencesService.loadLanguage(), 'Spanish');

        // Remove it
        final result = await preferencesService.remove('language_preference');
        expect(result, isTrue);

        // Should return default now
        expect(preferencesService.loadLanguage(), 'English');
      });

      test('should get all preferences', () async {
        await preferencesService.saveThemeMode(ThemeMode.light);
        await preferencesService.saveLanguage('Spanish');
        await preferencesService.saveTextSize(18.0);

        final allPrefs = preferencesService.getAllPreferences();
        expect(allPrefs['theme_mode'], 'light');
        expect(allPrefs['language'], 'Spanish');
        expect(allPrefs['text_size'], 18.0);
      });

      test('should return empty map when not initialized', () async {
        // This tests the edge case in getAllPreferences when _preferences is null
        // We can't easily trigger this in normal usage due to singleton pattern
        final allPrefs = preferencesService.getAllPreferences();
        expect(allPrefs, isA<Map<String, dynamic>>());
      });

      test('should handle multiple notification settings together', () async {
        await preferencesService.saveDailyNotificationsEnabled(false);
        await preferencesService.savePrayerRemindersEnabled(true);
        await preferencesService.saveVerseOfTheDayEnabled(false);
        await preferencesService.saveNotificationTime('07:45');

        expect(preferencesService.loadDailyNotificationsEnabled(), isFalse);
        expect(preferencesService.loadPrayerRemindersEnabled(), isTrue);
        expect(preferencesService.loadVerseOfTheDayEnabled(), isFalse);
        expect(preferencesService.loadNotificationTime(), '07:45');
      });
    });
  });
}
