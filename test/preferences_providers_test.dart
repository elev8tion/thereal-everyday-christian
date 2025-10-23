import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';

void main() {
  group('Preferences Providers', () {
    late ProviderContainer container;

    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});

      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('PreferencesService Provider', () {
      test('should provide initialized PreferencesService', () async {
        final preferencesAsync = await container.read(preferencesServiceProvider.future);
        expect(preferencesAsync.isInitialized, isTrue);
      });

      test('should provide same instance on multiple reads', () async {
        final instance1 = await container.read(preferencesServiceProvider.future);
        final instance2 = await container.read(preferencesServiceProvider.future);

        expect(instance1, same(instance2));
      });
    });

    group('ThemeModeNotifier', () {
      test('should initialize with dark theme as default', () {
        final theme = container.read(themeModeProvider);
        expect(theme, ThemeMode.dark);
      });

      test('should toggle between dark and light themes', () async {
        // Wait for preferences to load
        await container.read(preferencesServiceProvider.future);

        final notifier = container.read(themeModeProvider.notifier);

        // Initial state should be dark
        expect(container.read(themeModeProvider), ThemeMode.dark);

        // Toggle to light
        notifier.toggleTheme();
        expect(container.read(themeModeProvider), ThemeMode.light);

        // Toggle back to dark
        notifier.toggleTheme();
        expect(container.read(themeModeProvider), ThemeMode.dark);
      });

      test('should set specific theme mode', () async {
        await container.read(preferencesServiceProvider.future);

        final notifier = container.read(themeModeProvider.notifier);

        notifier.setTheme(ThemeMode.light);
        expect(container.read(themeModeProvider), ThemeMode.light);

        notifier.setTheme(ThemeMode.system);
        expect(container.read(themeModeProvider), ThemeMode.system);

        notifier.setTheme(ThemeMode.dark);
        expect(container.read(themeModeProvider), ThemeMode.dark);
      });

      test('should persist theme across container restarts', () async {
        // Set theme in first container
        await container.read(preferencesServiceProvider.future);
        container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);

        // Wait for async save
        await Future.delayed(const Duration(milliseconds: 100));

        // Create new container (simulating app restart)
        final newContainer = ProviderContainer();
        await newContainer.read(preferencesServiceProvider.future);

        // Theme should be persisted
        await Future.delayed(const Duration(milliseconds: 100));
        expect(newContainer.read(themeModeProvider), ThemeMode.light);

        newContainer.dispose();
      });
    });

    group('LanguageNotifier', () {
      test('should initialize with English as default', () {
        final language = container.read(languageProvider);
        expect(language, 'English');
      });

      test('should set language', () async {
        await container.read(preferencesServiceProvider.future);

        final notifier = container.read(languageProvider.notifier);

        await notifier.setLanguage('Spanish');
        expect(container.read(languageProvider), 'Spanish');

        await notifier.setLanguage('English');
        expect(container.read(languageProvider), 'English');
      });

      test('should persist language across container restarts', () async {
        // Set language in first container
        await container.read(preferencesServiceProvider.future);
        await container.read(languageProvider.notifier).setLanguage('Spanish');

        // Wait for async save
        await Future.delayed(const Duration(milliseconds: 100));

        // Create new container (simulating app restart)
        final newContainer = ProviderContainer();
        await newContainer.read(preferencesServiceProvider.future);

        // Language should be persisted
        await Future.delayed(const Duration(milliseconds: 100));
        expect(newContainer.read(languageProvider), 'Spanish');

        newContainer.dispose();
      });
    });

    group('TextSizeNotifier', () {
      test('should initialize with 16.0 as default', () {
        final textSize = container.read(textSizeProvider);
        expect(textSize, 16.0);
      });

      test('should set text size', () async {
        await container.read(preferencesServiceProvider.future);

        final notifier = container.read(textSizeProvider.notifier);

        await notifier.setTextSize(18.0);
        expect(container.read(textSizeProvider), 18.0);

        await notifier.setTextSize(14.0);
        expect(container.read(textSizeProvider), 14.0);
      });

      test('should clamp text size to valid range (12-24)', () async {
        await container.read(preferencesServiceProvider.future);

        final notifier = container.read(textSizeProvider.notifier);

        // Too small - should clamp to 12
        await notifier.setTextSize(8.0);
        expect(container.read(textSizeProvider), 12.0);

        // Too large - should clamp to 24
        await notifier.setTextSize(30.0);
        expect(container.read(textSizeProvider), 24.0);

        // Within range - should work normally
        await notifier.setTextSize(18.0);
        expect(container.read(textSizeProvider), 18.0);
      });

      test('should persist text size across container restarts', () async {
        // Set text size in first container
        await container.read(preferencesServiceProvider.future);
        await container.read(textSizeProvider.notifier).setTextSize(20.0);

        // Wait for async save
        await Future.delayed(const Duration(milliseconds: 100));

        // Create new container (simulating app restart)
        final newContainer = ProviderContainer();
        await newContainer.read(preferencesServiceProvider.future);

        // Text size should be persisted
        await Future.delayed(const Duration(milliseconds: 100));
        expect(newContainer.read(textSizeProvider), 20.0);

        newContainer.dispose();
      });
    });

    group('Multiple Providers Integration', () {
      test('should handle all preferences independently', () async {
        await container.read(preferencesServiceProvider.future);

        // Set all preferences
        container.read(themeModeProvider.notifier).setTheme(ThemeMode.light);
        await container.read(languageProvider.notifier).setLanguage('Spanish');
        await container.read(textSizeProvider.notifier).setTextSize(18.0);

        // Verify all are set correctly
        expect(container.read(themeModeProvider), ThemeMode.light);
        expect(container.read(languageProvider), 'Spanish');
        expect(container.read(textSizeProvider), 18.0);
      });

      test('should persist all preferences across restart', () async {
        // Set all preferences
        await container.read(preferencesServiceProvider.future);
        container.read(themeModeProvider.notifier).setTheme(ThemeMode.system);
        await container.read(languageProvider.notifier).setLanguage('Spanish');
        await container.read(textSizeProvider.notifier).setTextSize(20.0);

        // Wait for async saves
        await Future.delayed(const Duration(milliseconds: 100));

        // Restart
        final newContainer = ProviderContainer();
        await newContainer.read(preferencesServiceProvider.future);
        await Future.delayed(const Duration(milliseconds: 100));

        // All should be persisted
        expect(newContainer.read(themeModeProvider), ThemeMode.system);
        expect(newContainer.read(languageProvider), 'Spanish');
        expect(newContainer.read(textSizeProvider), 20.0);

        newContainer.dispose();
      });
    });
  });
}
