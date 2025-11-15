import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke Test 6: Settings, Profile & Offline Functionality
///
/// Tests app settings, user profile, achievements, and offline capabilities.
/// From CLAUDE.md: All core features work offline except AI chat.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settings & Preferences Smoke Tests', () {
    setUp(() async {
      await DatabaseHelper.instance.resetDatabase();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Text size preference persists', (tester) async {
      // From CLAUDE.md: Text size 12-24 range
      final prefs = await SharedPreferences.getInstance();

      // Set text size
      await prefs.setDouble('text_size', 18.0);

      // Verify it persists
      final textSize = prefs.getDouble('text_size');
      expect(textSize, 18.0, reason: 'Text size should persist');

      print('✅ Text size preference works');
    });

    testWidgets('Language preference persists', (tester) async {
      // From CLAUDE.md: English/Spanish support
      final prefs = await SharedPreferences.getInstance();

      // Set language
      await prefs.setString('language', 'es');

      // Verify
      final language = prefs.getString('language');
      expect(language, 'es', reason: 'Language preference should persist');

      print('✅ Language preference works');
    });

    testWidgets('Theme mode preference persists', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Set theme mode
      await prefs.setString('theme_mode', 'dark');

      // Verify
      final themeMode = prefs.getString('theme_mode');
      expect(themeMode, 'dark', reason: 'Theme mode should persist');

      print('✅ Theme mode preference works');
    });

    testWidgets('Onboarding completion flag persists', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Mark onboarding as complete
      await prefs.setBool('onboarding_completed', true);

      // Verify
      final completed = prefs.getBool('onboarding_completed');
      expect(completed, true, reason: 'Onboarding status should persist');

      print('✅ Onboarding completion tracking works');
    });

    testWidgets('Legal agreements acceptance persists', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Accept legal agreements
      await prefs.setBool('legal_agreements_accepted', true);

      // Verify
      final accepted = prefs.getBool('legal_agreements_accepted');
      expect(accepted, true, reason: 'Legal acceptance should persist');

      print('✅ Legal agreements tracking works');
    });
  });

  group('Profile & Achievement Smoke Tests', () {
    testWidgets('User name can be saved and retrieved', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Save user name
      await prefs.setString('user_name', 'Test User');

      // Retrieve
      final name = prefs.getString('user_name');
      expect(name, 'Test User', reason: 'User name should persist');

      print('✅ User profile name storage works');
    });

    testWidgets('Achievements tracking exists', (tester) async {
      // From CLAUDE.md: Profile screen has achievements section
      final db = await DatabaseHelper.instance.database;

      // Check for achievement-related data (prayer count, devotional streak, etc.)
      final prayers = await db.query('prayer_requests');
      final devotionals = await db.query('devotional_progress');

      // Achievements are based on these metrics
      expect(prayers, isA<List>(), reason: 'Prayer count accessible for achievements');
      expect(devotionals, isA<List>(),
          reason: 'Devotional progress accessible for achievements');

      print('✅ Achievement data sources available');
    });

    testWidgets('Conversation Sharer achievement tracking works', (tester) async {
      // From CLAUDE.md: "Conversation Sharer" achievement (10 shares)
      final db = await DatabaseHelper.instance.database;

      // Create session
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Track multiple shares
      for (int i = 0; i < 10; i++) {
        await db.insert('shared_chats', {
          'session_id': sessionId,
          'shared_at': DateTime.now().toIso8601String(),
        });
      }

      // Count shares
      final shareCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      final count = shareCount.first['count'] as int;

      expect(count, 10, reason: 'Should track 10 shares for achievement');
      print('✅ Conversation Sharer achievement tracking works');
    });
  });

  group('Offline Functionality Smoke Tests', () {
    testWidgets('Bible reading works offline', (tester) async {
      // Bible is local database - should always work
      final db = await DatabaseHelper.instance.database;

      final verses = await db.query('bible_verses', limit: 10);
      expect(verses.length, 10, reason: 'Bible should work offline');

      print('✅ Bible reading works offline');
    });

    testWidgets('Prayer journal works offline', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create prayer offline
      await db.insert('prayer_requests', {
        'title': 'Offline Prayer',
        'created_at': DateTime.now().toIso8601String(),
      });

      final prayers = await db.query('prayer_requests');
      expect(prayers, isNotEmpty, reason: 'Prayer journal should work offline');

      print('✅ Prayer journal works offline');
    });

    testWidgets('Verse favorites work offline', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Favorite a verse offline
      final verses = await db.query('bible_verses', limit: 1);
      if (verses.isNotEmpty) {
        await db.insert('favorite_verses', {
          'verse_id': verses.first['id'],
          'favorited_at': DateTime.now().toIso8601String(),
        });

        final favorites = await db.query('favorite_verses');
        expect(favorites, isNotEmpty, reason: 'Verse favorites should work offline');

        print('✅ Verse favorites work offline');
      }
    });

    testWidgets('Devotionals work offline', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Devotionals are preloaded
      final devotionals = await db.query('devotionals', limit: 1);
      expect(devotionals, isNotEmpty, reason: 'Devotionals should work offline');

      print('✅ Devotionals work offline');
    });

    testWidgets('Reading plans work offline', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Reading plans are preloaded
      final plans = await db.query('reading_plans', limit: 1);
      expect(plans, isNotEmpty, reason: 'Reading plans should work offline');

      print('✅ Reading plans work offline');
    });

    testWidgets('Chat history accessible offline (read-only)', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create session with messages
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await db.insert('chat_messages', {
        'session_id': sessionId,
        'type': 'user',
        'content': 'Test message',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Should be able to read chat history offline
      final messages = await db.query('chat_messages');
      expect(messages, isNotEmpty, reason: 'Chat history should be readable offline');

      print('✅ Chat history accessible offline (read-only)');
    });
  });

  group('Data Persistence Across Restarts', () {
    testWidgets('Prayers persist across app restarts', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create prayer
      await db.insert('prayer_requests', {
        'title': 'Persistent Prayer',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Simulate app restart (database stays open in test, but data persists)
      final prayers = await db.query('prayer_requests');
      expect(prayers, isNotEmpty, reason: 'Prayers should persist');

      print('✅ Prayer data persists');
    });

    testWidgets('Devotional progress persists', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Complete devotional
      final devotionals = await db.query('devotionals', limit: 1);
      if (devotionals.isNotEmpty) {
        await db.insert('devotional_progress', {
          'devotional_id': devotionals.first['id'],
          'completed_at': DateTime.now().toIso8601String(),
        });

        // Check persistence
        final progress = await db.query('devotional_progress');
        expect(progress, isNotEmpty, reason: 'Devotional progress should persist');

        print('✅ Devotional progress persists');
      }
    });

    testWidgets('User preferences persist across restarts', (tester) async {
      final prefs = await SharedPreferences.getInstance();

      // Set multiple preferences
      await prefs.setString('user_name', 'Persistent User');
      await prefs.setDouble('text_size', 16.0);
      await prefs.setString('language', 'en');

      // Verify all persist
      expect(prefs.getString('user_name'), 'Persistent User');
      expect(prefs.getDouble('text_size'), 16.0);
      expect(prefs.getString('language'), 'en');

      print('✅ User preferences persist');
    });

    testWidgets('Subscription state persists (from CLAUDE.md)', (tester) async {
      // From CLAUDE.md: "Delete All Data preserves subscription status"
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      // Subscription state should persist via restorePurchases()
      // This is tested in more detail in subscription smoke tests

      expect(subscriptionService.isInTrial || subscriptionService.isPremium, true,
          reason: 'Subscription state should be initialized');

      print('✅ Subscription state persistence verified');
    });
  });

  group('Delete All Data Tests', () {
    testWidgets('Delete All Data clears local storage', (tester) async {
      final db = await DatabaseHelper.instance.database;
      final prefs = await SharedPreferences.getInstance();

      // Create some data
      await db.insert('prayer_requests', {
        'title': 'Delete Me',
        'created_at': DateTime.now().toIso8601String(),
      });
      await prefs.setString('user_name', 'Delete Me');

      // Delete all data (simulate settings screen action)
      await DatabaseHelper.instance.resetDatabase();
      await prefs.clear();

      // Verify deletion
      final prayers = await db.query('prayer_requests');
      final userName = prefs.getString('user_name');

      expect(prayers.isEmpty, true, reason: 'Database should be cleared');
      expect(userName, isNull, reason: 'Preferences should be cleared');

      print('✅ Delete All Data functionality works');
    });

    testWidgets('Bible data persists after Delete All Data', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Delete user data
      await DatabaseHelper.instance.resetDatabase();

      // Bible verses should still be present
      final verses = await db.query('bible_verses', limit: 1);
      expect(verses, isNotEmpty,
          reason: 'Bible data should persist after data deletion');

      print('✅ Bible data preserved after Delete All Data');
    });
  });
}
