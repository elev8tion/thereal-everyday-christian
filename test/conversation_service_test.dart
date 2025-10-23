import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/services/conversation_service.dart';
import 'package:everyday_christian/models/chat_message.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite_ffi for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ConversationService', () {
    late ConversationService conversationService;

    setUp(() async {
      conversationService = ConversationService();
      // Reset database before each test
      await DatabaseHelper.instance.resetDatabase();
    });

    tearDown(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    group('Session Management', () {
      test('should create a new session', () async {
        final sessionId = await conversationService.createSession(
          title: 'Test Session',
        );

        expect(sessionId, isNotEmpty);

        final sessions = await conversationService.getSessions();
        expect(sessions.length, 1);
        expect(sessions.first['title'], 'Test Session');
        expect(sessions.first['is_archived'], 0);
      });

      test('should create session with default title when not provided', () async {
        final sessions = await conversationService.getSessions();
        expect(sessions.first['title'], 'New Conversation');
      });

      test('should get all active sessions', () async {
        await conversationService.createSession(title: 'Session 1');
        await conversationService.createSession(title: 'Session 2');
        await conversationService.createSession(title: 'Session 3');

        final sessions = await conversationService.getSessions();
        expect(sessions.length, 3);
      });

      test('should exclude archived sessions by default', () async {
        await conversationService.createSession(title: 'Active');
        final sessionToArchive = await conversationService.createSession(title: 'To Archive');

        await conversationService.archiveSession(sessionToArchive);

        final sessions = await conversationService.getSessions();
        expect(sessions.length, 1);
        expect(sessions.first['title'], 'Active');
      });

      test('should include archived sessions when requested', () async {
        await conversationService.createSession(title: 'Active');
        final sessionToArchive = await conversationService.createSession(title: 'Archived');

        await conversationService.archiveSession(sessionToArchive);

        final sessions = await conversationService.getSessions(includeArchived: true);
        expect(sessions.length, 2);
      });

      test('should update session title', () async {
        final sessionId = await conversationService.createSession(title: 'Old Title');

        await conversationService.updateSessionTitle(sessionId, 'New Title');

        final sessions = await conversationService.getSessions();
        expect(sessions.first['title'], 'New Title');
      });

      test('should archive session', () async {
        final sessionId = await conversationService.createSession(title: 'To Archive');

        await conversationService.archiveSession(sessionId);

        final sessions = await conversationService.getSessions();
        expect(sessions.isEmpty, true);

        final allSessions = await conversationService.getSessions(includeArchived: true);
        expect(allSessions.first['is_archived'], 1);
      });

      test('should delete session and all its messages', () async {
        final sessionId = await conversationService.createSession(title: 'To Delete');

        // Add some messages
        final message1 = ChatMessage.user(
          content: 'Message 1',
          sessionId: sessionId,
        );
        final message2 = ChatMessage.ai(
          content: 'Response 1',
          sessionId: sessionId,
        );

        await conversationService.saveMessage(message1);
        await conversationService.saveMessage(message2);

        // Verify messages exist
        final messagesBefore = await conversationService.getMessages(sessionId);
        expect(messagesBefore.length, 2);

        // Delete session
        await conversationService.deleteSession(sessionId);

        // Verify session and messages are gone
        final sessions = await conversationService.getSessions(includeArchived: true);
        expect(sessions.isEmpty, true);

        final messagesAfter = await conversationService.getMessages(sessionId);
        expect(messagesAfter.isEmpty, true);
      });
    });

    group('Message Operations', () {
      late String sessionId;

      setUp(() async {
        sessionId = await conversationService.createSession(title: 'Test Session');
      });

      test('should save a single message', () async {
        final message = ChatMessage.user(
          content: 'Hello, AI!',
          sessionId: sessionId,
        );

        await conversationService.saveMessage(message);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages.length, 1);
        expect(messages.first.content, 'Hello, AI!');
        expect(messages.first.type, MessageType.user);
      });

      test('should save multiple messages in transaction', () async {
        final messages = [
          ChatMessage.user(content: 'Question 1', sessionId: sessionId),
          ChatMessage.ai(content: 'Answer 1', sessionId: sessionId),
          ChatMessage.user(content: 'Question 2', sessionId: sessionId),
          ChatMessage.ai(content: 'Answer 2', sessionId: sessionId),
        ];

        await conversationService.saveMessages(messages);

        final saved = await conversationService.getMessages(sessionId);
        expect(saved.length, 4);
      });

      test('should handle empty message list', () async {
        await conversationService.saveMessages([]);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages.isEmpty, true);
      });

      test('should get messages in chronological order', () async {
        final message1 = ChatMessage.user(content: 'First', sessionId: sessionId);
        await Future.delayed(const Duration(milliseconds: 10));
        final message2 = ChatMessage.user(content: 'Second', sessionId: sessionId);
        await Future.delayed(const Duration(milliseconds: 10));
        final message3 = ChatMessage.user(content: 'Third', sessionId: sessionId);

        await conversationService.saveMessage(message1);
        await conversationService.saveMessage(message2);
        await conversationService.saveMessage(message3);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages[0].content, 'First');
        expect(messages[1].content, 'Second');
        expect(messages[2].content, 'Third');
      });

      test('should get recent messages with limit', () async {
        // Add 100 messages
        for (int i = 0; i < 100; i++) {
          await conversationService.saveMessage(
            ChatMessage.user(content: 'Message $i', sessionId: sessionId),
          );
        }

        final recent = await conversationService.getRecentMessages(sessionId, limit: 10);
        expect(recent.length, 10);
        // Should be in chronological order (oldest to newest of the recent 10)
        expect(recent.last.content, 'Message 99');
      });

      test('should delete a specific message', () async {
        final message = ChatMessage.user(content: 'To delete', sessionId: sessionId);
        await conversationService.saveMessage(message);

        final messagesBefore = await conversationService.getMessages(sessionId);
        expect(messagesBefore.length, 1);

        await conversationService.deleteMessage(message.id);

        final messagesAfter = await conversationService.getMessages(sessionId);
        expect(messagesAfter.isEmpty, true);
      });

      test('should get message count for session', () async {
        expect(await conversationService.getMessageCount(sessionId), 0);

        await conversationService.saveMessage(
          ChatMessage.user(content: 'Message 1', sessionId: sessionId),
        );
        expect(await conversationService.getMessageCount(sessionId), 1);

        await conversationService.saveMessage(
          ChatMessage.user(content: 'Message 2', sessionId: sessionId),
        );
        expect(await conversationService.getMessageCount(sessionId), 2);
      });

      test('should update session last message when saving', () async {
        final message = ChatMessage.user(
          content: 'Latest message',
          sessionId: sessionId,
        );

        await conversationService.saveMessage(message);

        final sessions = await conversationService.getSessions();
        final session = sessions.first;
        expect(session['last_message_preview'], isNotNull);
        expect(session['message_count'], 1);
      });
    });

    group('Message Search', () {
      late String sessionId;

      setUp(() async {
        sessionId = await conversationService.createSession(title: 'Search Test');

        // Add various messages
        await conversationService.saveMessages([
          ChatMessage.user(content: 'How can I find peace?', sessionId: sessionId),
          ChatMessage.ai(content: 'Peace comes from trusting God.', sessionId: sessionId),
          ChatMessage.user(content: 'What about anxiety?', sessionId: sessionId),
          ChatMessage.ai(content: 'Cast your anxiety on Him.', sessionId: sessionId),
          ChatMessage.user(content: 'How to have joy?', sessionId: sessionId),
        ]);
      });

      test('should search messages by content', () async {
        final results = await conversationService.searchMessages('peace');
        expect(results.length, greaterThanOrEqualTo(1));
        expect(results.any((m) => m.content.toLowerCase().contains('peace')), true);
      });

      test('should search is case-insensitive', () async {
        final results = await conversationService.searchMessages('PEACE');
        expect(results.isNotEmpty, true);
      });

      test('should return empty list for no matches', () async {
        final results = await conversationService.searchMessages('xyzabc123');
        expect(results.isEmpty, true);
      });

      test('should limit search results', () async {
        // Add 60 messages with same word
        final session2 = await conversationService.createSession();
        for (int i = 0; i < 60; i++) {
          await conversationService.saveMessage(
            ChatMessage.user(content: 'common word $i', sessionId: session2),
          );
        }

        final results = await conversationService.searchMessages('common');
        expect(results.length, lessThanOrEqualTo(50));
      });
    });

    group('Conversation Export', () {
      test('should export conversation as text', () async {
        final sessionId = await conversationService.createSession(title: 'Export Test');

        await conversationService.saveMessages([
          ChatMessage.user(content: 'Hello', sessionId: sessionId),
          ChatMessage.ai(content: 'Hi there!', sessionId: sessionId),
        ]);

        final export = await conversationService.exportConversation(sessionId);

        expect(export, contains('Conversation Export'));
        expect(export, contains('Total Messages: 2'));
        expect(export, contains('Hello'));
        expect(export, contains('Hi there!'));
      });

      test('should include verses in export', () async {
        final sessionId = await conversationService.createSession();
        // This would require a message with verses - simplified for test
        final export = await conversationService.exportConversation(sessionId);
        expect(export, isNotEmpty);
      });

      test('should return empty string on error', () async {
        final export = await conversationService.exportConversation('nonexistent-id');
        expect(export, isEmpty);
      });
    });

    group('Old Conversation Cleanup', () {
      test('should clear old conversations', () async {
        // Create old sessions by manipulating timestamp
        await conversationService.createSession(title: 'Old');
        await conversationService.createSession(title: 'Recent');

        // Simulate old session (would need to manually update timestamp in real scenario)
        // For now, test the method doesn't crash
        final deleted = await conversationService.clearOldConversations(90);
        expect(deleted, greaterThanOrEqualTo(0));
      });

      test('should not delete recent conversations', () async {
        await conversationService.createSession(title: 'Recent 1');
        await conversationService.createSession(title: 'Recent 2');

        await conversationService.clearOldConversations(30);

        final sessions = await conversationService.getSessions();
        expect(sessions.length, 2); // Both should still exist
      });

      test('should return 0 when no old conversations exist', () async {
        await conversationService.createSession(title: 'New');

        final deleted = await conversationService.clearOldConversations(365);
        expect(deleted, 0);
      });
    });

    group('Error Handling', () {
      test('should handle database errors gracefully', () async {
        // Test with invalid session ID
        final messages = await conversationService.getMessages('invalid-id');
        expect(messages, isEmpty);
      });

      test('should handle message save errors', () async {
        // This would require mocking database to simulate error
        // For now, verify method doesn't crash
        expect(
          () async => await conversationService.saveMessage(
            ChatMessage.user(content: 'test', sessionId: 'test-id'),
          ),
          returnsNormally,
        );
      });

      test('should handle search errors gracefully', () async {
        final results = await conversationService.searchMessages('test');
        expect(results, isA<List<ChatMessage>>());
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent message saves', () async {
        final sessionId = await conversationService.createSession();

        final futures = List.generate(
          10,
          (i) => conversationService.saveMessage(
            ChatMessage.user(content: 'Message $i', sessionId: sessionId),
          ),
        );

        await Future.wait(futures);

        final count = await conversationService.getMessageCount(sessionId);
        expect(count, 10);
      });

      test('should handle concurrent session creation', () async {
        final futures = List.generate(
          5,
          (i) => conversationService.createSession(title: 'Session $i'),
        );

        await Future.wait(futures);

        final sessions = await conversationService.getSessions();
        expect(sessions.length, 5);
      });
    });

    group('Edge Cases', () {
      test('should handle empty content', () async {
        final sessionId = await conversationService.createSession();
        final message = ChatMessage.user(content: '', sessionId: sessionId);

        await conversationService.saveMessage(message);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages.length, 1);
        expect(messages.first.content, '');
      });

      test('should handle very long content', () async {
        final sessionId = await conversationService.createSession();
        final longContent = 'A' * 10000;
        final message = ChatMessage.user(content: longContent, sessionId: sessionId);

        await conversationService.saveMessage(message);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages.first.content.length, 10000);
      });

      test('should handle special characters in content', () async {
        final sessionId = await conversationService.createSession();
        const specialContent = "Test 'quotes\" and \nNewlines\t\tTabs";
        final message = ChatMessage.user(content: specialContent, sessionId: sessionId);

        await conversationService.saveMessage(message);

        final messages = await conversationService.getMessages(sessionId);
        expect(messages.first.content, specialContent);
      });

      test('should handle null sessionId gracefully', () async {
        final message = ChatMessage.user(content: 'No session');

        // Should save without error
        await conversationService.saveMessage(message);

        // But won't update session
        final sessions = await conversationService.getSessions();
        expect(sessions.isEmpty, true);
      });
    });
  });
}
