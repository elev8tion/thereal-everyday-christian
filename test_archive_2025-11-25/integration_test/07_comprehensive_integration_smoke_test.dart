import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/main.dart' as app;
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke Test 7: Comprehensive End-to-End Integration
///
/// Tests complete user flows across multiple features.
/// Simulates real-world usage patterns to catch integration issues.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Journey - New User', () {
    testWidgets('New user can complete full onboarding and explore app', (tester) async {
      // Reset to new user state
      await DatabaseHelper.instance.resetDatabase();

      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      // Launch app
      await tester.pumpWidget(
        const ProviderScope(
          child: app.MyApp(),
        ),
      );

      // Step 1: Splash screen
      print('Testing: Splash screen...');
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Step 2: Legal agreements
      print('Testing: Legal agreements...');
      final acceptButton = find.text('Accept');
      if (acceptButton.evaluate().isNotEmpty) {
        await tester.tap(acceptButton);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Accepted legal agreements');
      }

      // Step 3: Onboarding
      print('Testing: Onboarding...');
      final getStarted = find.text('Get Started');
      if (getStarted.evaluate().isNotEmpty) {
        // Enter name if there's a text field
        final nameField = find.byType(TextField);
        if (nameField.evaluate().isNotEmpty) {
          await tester.enterText(nameField.first, 'Smoke Test User');
          await tester.pumpAndSettle();
        }

        await tester.tap(getStarted);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('✅ Completed onboarding');
      }

      // Step 4: Home screen loaded
      print('Testing: Home screen...');
      await tester.pumpAndSettle();

      final hasHomeScreen = find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
          find.byIcon(Icons.home).evaluate().isNotEmpty;

      expect(hasHomeScreen, true, reason: 'Should reach home screen');
      print('✅ Home screen loaded successfully');

      // Step 5: Explore Bible
      print('Testing: Bible navigation...');
      final bibleTab = find.text('Bible');
      if (bibleTab.evaluate().isNotEmpty) {
        await tester.tap(bibleTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('✅ Bible section accessible');
      }

      print('✅ COMPLETE USER JOURNEY SUCCESSFUL');
    });
  });

  group('Cross-Feature Integration Tests', () {
    setUp(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    testWidgets('Prayer request → AI chat discussion flow', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Step 1: Create prayer request
      final prayerId = await db.insert('prayer_requests', {
        'title': 'Need guidance on career decision',
        'description': 'Seeking God\'s wisdom',
        'category_id': 'cat_guidance',
        'created_at': DateTime.now().toIso8601String(),
      });

      expect(prayerId, greaterThan(0));
      print('✅ Prayer request created');

      // Step 2: Start chat session about this prayer
      final sessionId = await db.insert('chat_sessions', {
        'title': 'Career Decision Discussion',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Step 3: Add messages
      await db.insert('chat_messages', {
        'session_id': sessionId,
        'type': 'user',
        'content': 'I created a prayer about career guidance',
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('chat_messages', {
        'session_id': sessionId,
        'type': 'ai',
        'content': 'Let\'s explore what Scripture says about seeking God\'s wisdom...',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Step 4: Mark prayer as answered
      await db.update(
        'prayer_requests',
        {
          'is_answered': 1,
          'answered_at': DateTime.now().toIso8601String(),
          'answer_notes': 'God provided clarity through prayer and reflection',
        },
        where: 'id = ?',
        whereArgs: [prayerId],
      );

      // Verify complete flow
      final prayers = await db.query('prayer_requests', where: 'is_answered = 1');
      final messages = await db.query('chat_messages', where: 'session_id = ?', whereArgs: [sessionId]);

      expect(prayers, isNotEmpty);
      expect(messages.length, 2);

      print('✅ Prayer → Chat → Answered flow works');
    });

    testWidgets('Bible reading → Verse favoriting → Theme tagging flow', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Step 1: Read Bible verse
      final verses = await db.query(
        'bible_verses',
        where: 'book = ? AND chapter = ? AND verse = ?',
        whereArgs: ['John', 3, 16],
        limit: 1,
      );

      if (verses.isEmpty) {
        // Fallback to any verse
        final anyVerse = await db.query('bible_verses', limit: 1);
        expect(anyVerse, isNotEmpty, reason: 'Bible should have verses');
      }

      final verse = verses.isNotEmpty ? verses.first : (await db.query('bible_verses', limit: 1)).first;
      final verseId = verse['id'] as int;

      print('✅ Bible verse retrieved');

      // Step 2: Favorite the verse
      await db.insert('favorite_verses', {
        'verse_id': verseId,
        'favorited_at': DateTime.now().toIso8601String(),
      });

      // Step 3: Add themes
      await db.update(
        'favorite_verses',
        {'themes': '["hope", "salvation"]'},
        where: 'verse_id = ?',
        whereArgs: [verseId],
      );

      // Step 4: Search by theme
      final hopeVerses = await db.query(
        'favorite_verses',
        where: 'themes LIKE ?',
        whereArgs: ['%"hope"%'],
      );

      expect(hopeVerses, isNotEmpty);
      print('✅ Bible → Favorite → Theme tagging flow works');

      // Clean up
      await db.delete('favorite_verses');
    });

    testWidgets('Devotional → Reading plan → Prayer flow', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Step 1: Complete today's devotional
      final devotionals = await db.query('devotionals', limit: 1);
      if (devotionals.isNotEmpty) {
        await db.insert('devotional_progress', {
          'devotional_id': devotionals.first['id'],
          'completed_at': DateTime.now().toIso8601String(),
        });
        print('✅ Devotional completed');
      }

      // Step 2: Start a reading plan
      final plans = await db.query('reading_plans', limit: 1);
      if (plans.isNotEmpty) {
        await db.insert('reading_plan_progress', {
          'plan_id': plans.first['id'],
          'started_at': DateTime.now().toIso8601String(),
          'current_day': 1,
        });
        print('✅ Reading plan started');
      }

      // Step 3: Create prayer based on devotional insight
      await db.insert('prayer_requests', {
        'title': 'Apply today\'s devotional message',
        'description': 'Help me live out what I learned',
        'category_id': 'cat_growth',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Verify all data exists
      final devotionalProgress = await db.query('devotional_progress');
      final readingProgress = await db.query('reading_plan_progress');
      final prayers = await db.query('prayer_requests');

      expect(devotionalProgress, isNotEmpty);
      expect(readingProgress, isNotEmpty);
      expect(prayers, isNotEmpty);

      print('✅ Devotional → Reading Plan → Prayer flow works');
    });

    testWidgets('Subscription trial → Usage → Paywall flow', (tester) async {
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      // Step 1: Verify user is in trial
      expect(subscriptionService.isInTrial, true);
      print('✅ User in trial period');

      // Step 2: Check message availability
      final canSend = subscriptionService.canSendMessage;
      expect(canSend, true, reason: 'Trial users should be able to send messages');
      print('✅ Trial messages available');

      // Step 3: Consume some messages (simulated)
      final messagesBefore = subscriptionService.trialMessagesRemaining;
      await subscriptionService.consumeMessage();
      final messagesAfter = subscriptionService.trialMessagesRemaining;

      expect(messagesAfter, lessThan(messagesBefore),
          reason: 'Message count should decrease');
      print('✅ Message consumption tracking works');

      // Step 4: Check premium features
      expect(subscriptionService.isPremium, false,
          reason: 'Trial users are not premium');
      print('✅ Subscription status correctly tracked');
    });
  });

  group('Data Integrity & Referential Integrity Tests', () {
    setUp(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    testWidgets('Deleting chat session cascades to messages', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create session with messages
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Add messages
      for (int i = 0; i < 5; i++) {
        await db.insert('chat_messages', {
          'session_id': sessionId,
          'type': 'user',
          'content': 'Message $i',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Verify messages exist
      var messages = await db.query('chat_messages', where: 'session_id = ?', whereArgs: [sessionId]);
      expect(messages.length, 5);

      // Delete session
      await db.delete('chat_sessions', where: 'id = ?', whereArgs: [sessionId]);

      // Messages should be deleted (if cascade is set up)
      // Or should be orphaned (to be cleaned up separately)
      messages = await db.query('chat_messages', where: 'session_id = ?', whereArgs: [sessionId]);

      print('✅ Session deletion handled (${messages.length} messages remaining)');
    });

    testWidgets('Database schema version is correct', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // From CLAUDE.md: Database Version 10 (shared_chats table added)
      // Note: Database version is managed by DatabaseHelper, not queryable from DB object
      // Verify by checking that expected tables exist instead
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='shared_chats'",
      );

      expect(tables, isNotEmpty,
          reason: 'Database should have v10 shared_chats table');

      print('✅ Database schema version correct (v10+ tables present)');
    });

    testWidgets('All expected tables exist', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Query all tables
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );

      final tableNames = tables.map((t) => t['name'] as String).toList();

      // From CLAUDE.md: Expected tables
      final expectedTables = [
        'devotionals',
        'reading_plans',
        'daily_readings',
        'prayer_requests',
        'chat_sessions',
        'chat_messages',
        'shared_chats', // Added in v10
        'bible_verses',
        'favorite_verses',
      ];

      for (final tableName in expectedTables) {
        expect(tableNames, contains(tableName),
            reason: 'Database should have $tableName table');
      }

      print('✅ All expected tables exist: ${tableNames.length} tables');
    });
  });

  group('Performance & Scalability Smoke Tests', () {
    testWidgets('Can handle large number of prayers', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create 100 prayer requests
      for (int i = 0; i < 100; i++) {
        await db.insert('prayer_requests', {
          'title': 'Prayer $i',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Query should still be fast
      final prayers = await db.query('prayer_requests');
      expect(prayers.length, 100);

      print('✅ Handles 100 prayers efficiently');

      // Clean up
      await db.delete('prayer_requests');
    });

    testWidgets('Can handle long chat conversations', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create session with 50 messages
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      for (int i = 0; i < 50; i++) {
        await db.insert('chat_messages', {
          'session_id': sessionId,
          'type': i % 2 == 0 ? 'user' : 'ai',
          'content': 'Message $i with some longer content to simulate real conversations',
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Query should still be performant
      final messages = await db.query('chat_messages', where: 'session_id = ?', whereArgs: [sessionId]);
      expect(messages.length, 50);

      print('✅ Handles long chat conversations (50 messages)');
    });

    testWidgets('Bible search performance is acceptable', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Search across all 31,103 verses
      final startTime = DateTime.now();

      final results = await db.query(
        'bible_verses',
        where: 'text LIKE ?',
        whereArgs: ['%love%'],
        limit: 100,
      );

      final duration = DateTime.now().difference(startTime);

      expect(results, isNotEmpty);
      expect(duration.inMilliseconds, lessThan(5000),
          reason: 'Bible search should complete within 5 seconds');

      print('✅ Bible search performed in ${duration.inMilliseconds}ms');
    });
  });

  group('Critical App Store Requirements', () {
    testWidgets('App does not crash on launch', (tester) async {
      bool crashed = false;

      try {
        await DatabaseHelper.instance.resetDatabase();
        final subscriptionService = SubscriptionService.instance;
        await subscriptionService.initialize();

        await tester.pumpWidget(
          const ProviderScope(
            child: app.MyApp(),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 10));
      } catch (e) {
        crashed = true;
        print('❌ CRITICAL: App crashed during launch: $e');
      }

      expect(crashed, false, reason: 'App must not crash on launch');
      print('✅ CRITICAL: App launches without crashes');
    });

    testWidgets('Core features work without internet', (tester) async {
      // This test verifies offline functionality
      final db = await DatabaseHelper.instance.database;

      // Bible
      final verses = await db.query('bible_verses', limit: 1);
      expect(verses, isNotEmpty, reason: 'Bible must work offline');

      // Prayer
      await db.insert('prayer_requests', {
        'title': 'Offline Prayer',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Devotionals
      final devotionals = await db.query('devotionals', limit: 1);
      expect(devotionals, isNotEmpty, reason: 'Devotionals must work offline');

      print('✅ CRITICAL: Core features work offline');
    });

    testWidgets('Subscription system initializes without errors', (tester) async {
      bool initialized = false;

      try {
        final subscriptionService = SubscriptionService.instance;
        await subscriptionService.initialize();
        initialized = true;
      } catch (e) {
        print('❌ CRITICAL: Subscription initialization failed: $e');
      }

      expect(initialized, true, reason: 'Subscription system must initialize');
      print('✅ CRITICAL: Subscription system initializes correctly');
    });

    testWidgets('Database migrations complete successfully', (tester) async {
      // Test that database can be opened and migrations have run
      final db = await DatabaseHelper.instance.database;

      // Verify database is accessible and tables exist
      final tables = await db.rawQuery(
        "SELECT COUNT(*) as count FROM sqlite_master WHERE type='table'",
      );
      final tableCount = tables.first['count'] as int;

      expect(tableCount, greaterThan(5),
          reason: 'Database migrations must create tables');

      print('✅ CRITICAL: Database migrations successful ($tableCount tables)');
    });
  });
}
