import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

/// Smoke Test 5: Prayer Journal, Verse Library & AI Chat
///
/// Tests prayer requests, verse favorites, and AI chat functionality.
/// Prayer and verses are offline features, chat requires subscription.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Prayer Journal Smoke Tests', () {
    setUp(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    testWidgets('Can create prayer request', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create a prayer request
      await db.insert('prayer_requests', {
        'title': 'Test Prayer',
        'description': 'Please pray for this test',
        'category_id': 'cat_health',
        'created_at': DateTime.now().toIso8601String(),
        'is_answered': 0,
      });

      // Verify it was saved
      final prayers = await db.query('prayer_requests');
      expect(prayers, isNotEmpty, reason: 'Should be able to create prayers');
      expect(prayers.first['title'], 'Test Prayer');

      print('✅ Prayer creation works');
    });

    testWidgets('Can mark prayer as answered', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create prayer
      final prayerId = await db.insert('prayer_requests', {
        'title': 'Test Prayer',
        'description': 'Prayer description',
        'category_id': 'cat_family',
        'created_at': DateTime.now().toIso8601String(),
        'is_answered': 0,
      });

      // Mark as answered
      await db.update(
        'prayer_requests',
        {
          'is_answered': 1,
          'answered_at': DateTime.now().toIso8601String(),
          'answer_notes': 'God answered my prayer!',
        },
        where: 'id = ?',
        whereArgs: [prayerId],
      );

      // Verify update
      final answered = await db.query(
        'prayer_requests',
        where: 'is_answered = 1',
      );

      expect(answered, isNotEmpty, reason: 'Should track answered prayers');
      print('✅ Prayer answering functionality works');
    });

    testWidgets('Prayer categories work', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create prayers in different categories
      await db.insert('prayer_requests', {
        'title': 'Health Prayer',
        'category_id': 'cat_health',
        'created_at': DateTime.now().toIso8601String(),
      });

      await db.insert('prayer_requests', {
        'title': 'Family Prayer',
        'category_id': 'cat_family',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Query by category
      final healthPrayers = await db.query(
        'prayer_requests',
        where: 'category_id = ?',
        whereArgs: ['cat_health'],
      );

      expect(healthPrayers, isNotEmpty, reason: 'Should filter by category');
      print('✅ Prayer category filtering works');
    });

    testWidgets('Can delete prayer requests', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create prayer
      final prayerId = await db.insert('prayer_requests', {
        'title': 'Delete Me',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Delete it
      await db.delete('prayer_requests', where: 'id = ?', whereArgs: [prayerId]);

      // Verify deletion
      final prayers = await db.query('prayer_requests');
      expect(prayers.isEmpty, true, reason: 'Should be able to delete prayers');

      print('✅ Prayer deletion works');
    });
  });

  group('Verse Library Smoke Tests', () {
    testWidgets('Can favorite a verse', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Get a Bible verse
      final verses = await db.query('bible_verses', limit: 1);
      if (verses.isNotEmpty) {
        final verseId = verses.first['id'] as int;

        // Favorite it
        await db.insert('favorite_verses', {
          'verse_id': verseId,
          'favorited_at': DateTime.now().toIso8601String(),
        });

        // Verify
        final favorites = await db.query('favorite_verses');
        expect(favorites, isNotEmpty, reason: 'Should be able to favorite verses');

        print('✅ Verse favoriting works');

        // Clean up
        await db.delete('favorite_verses');
      }
    });

    testWidgets('Can tag verses with themes', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Get a verse
      final verses = await db.query('bible_verses', limit: 1);
      if (verses.isNotEmpty) {
        final verseId = verses.first['id'] as int;

        // Favorite with themes (from CLAUDE.md work log)
        await db.insert('favorite_verses', {
          'verse_id': verseId,
          'favorited_at': DateTime.now().toIso8601String(),
          'themes': '["hope", "faith"]', // JSON array
        });

        // Verify themes were saved
        final favorites = await db.query('favorite_verses');
        final themes = favorites.first['themes'] as String?;

        expect(themes, isNotNull, reason: 'Themes should be stored');
        expect(themes, contains('hope'), reason: 'Should contain selected theme');

        print('✅ Verse theme tagging works');

        // Clean up
        await db.delete('favorite_verses');
      }
    });

    testWidgets('Can search verses by theme', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create favorite verse with theme
      final verses = await db.query('bible_verses', limit: 1);
      if (verses.isNotEmpty) {
        final verseId = verses.first['id'] as int;

        await db.insert('favorite_verses', {
          'verse_id': verseId,
          'themes': '["hope"]',
          'favorited_at': DateTime.now().toIso8601String(),
        });

        // Search by theme (from CLAUDE.md: fixed to use JSON field)
        final hopeVerses = await db.query(
          'favorite_verses',
          where: 'themes LIKE ?',
          whereArgs: ['%"hope"%'],
        );

        expect(hopeVerses, isNotEmpty, reason: 'Should search by theme');
        print('✅ Verse theme search works');

        // Clean up
        await db.delete('favorite_verses');
      }
    });
  });

  group('AI Chat Smoke Tests', () {
    testWidgets('Chat sessions can be created', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create a chat session
      final sessionId = await db.insert('chat_sessions', {
        'title': 'Test Conversation',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      expect(sessionId, greaterThan(0), reason: 'Should create chat session');

      // Verify
      final sessions = await db.query('chat_sessions');
      expect(sessions, isNotEmpty, reason: 'Chat sessions should be saved');

      print('✅ Chat session creation works');
    });

    testWidgets('Chat messages can be saved', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create session
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Save user message
      await db.insert('chat_messages', {
        'session_id': sessionId,
        'type': 'user',
        'content': 'How can I grow in faith?',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Save AI response
      await db.insert('chat_messages', {
        'session_id': sessionId,
        'type': 'ai',
        'content': 'Growing in faith involves prayer and scripture...',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Verify messages
      final messages = await db.query(
        'chat_messages',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );

      expect(messages.length, 2, reason: 'Should save user and AI messages');
      print('✅ Chat message persistence works');
    });

    testWidgets('Chat sessions can be archived', (tester) async {
      final db = await DatabaseHelper.instance.database;

      // Create session
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'is_archived': 0,
      });

      // Archive it
      await db.update(
        'chat_sessions',
        {'is_archived': 1},
        where: 'id = ?',
        whereArgs: [sessionId],
      );

      // Verify
      final archived = await db.query(
        'chat_sessions',
        where: 'is_archived = 1',
      );

      expect(archived, isNotEmpty, reason: 'Should be able to archive chats');
      print('✅ Chat archiving works');
    });

    testWidgets('Conversation sharing tracking works', (tester) async {
      // From CLAUDE.md: Database v10 added shared_chats table
      final db = await DatabaseHelper.instance.database;

      // Create session
      final sessionId = await db.insert('chat_sessions', {
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Track share
      await db.insert('shared_chats', {
        'session_id': sessionId,
        'shared_at': DateTime.now().toIso8601String(),
      });

      // Verify tracking
      final shares = await db.query('shared_chats');
      expect(shares, isNotEmpty, reason: 'Should track conversation shares');

      print('✅ Conversation sharing tracking works');
    });
  });
}
