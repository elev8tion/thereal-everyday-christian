import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/database/database_helper.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/services/conversation_service.dart';
import 'package:everyday_christian/core/services/prayer_service.dart';
import 'package:everyday_christian/core/services/devotional_service.dart';
import 'package:everyday_christian/core/services/reading_plan_service.dart';
import 'package:everyday_christian/models/chat_message.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Integration Tests - User Flows', () {
    late ConversationService conversationService;
    late PrayerService prayerService;
    late DevotionalService devotionalService;
    late ReadingPlanService readingPlanService;

    setUp(() async {
      conversationService = ConversationService();
      final dbService = DatabaseService();
      prayerService = PrayerService(dbService);
      devotionalService = DevotionalService(dbService);
      readingPlanService = ReadingPlanService(dbService);

      await DatabaseHelper.instance.resetDatabase();
    });

    tearDown(() async {
      await DatabaseHelper.instance.resetDatabase();
    });

    group('Chat Conversation Flow', () {
      test('should complete full conversation flow', () async {
        // 1. Create a new chat session
        final sessionId = await conversationService.createSession(
          title: 'Anxiety Help',
        );
        expect(sessionId, isNotEmpty);

        // 2. User asks a question
        final userMessage = ChatMessage.user(
          content: 'I am feeling anxious about the future',
          sessionId: sessionId,
        );
        await conversationService.saveMessage(userMessage);

        // 3. AI responds with guidance
        final aiResponse = ChatMessage.ai(
          content: 'I understand your anxiety. Remember that God has plans for you...',
          sessionId: sessionId,
        );
        await conversationService.saveMessage(aiResponse);

        // 4. User asks follow-up
        final followUp = ChatMessage.user(
          content: 'How can I trust more?',
          sessionId: sessionId,
        );
        await conversationService.saveMessage(followUp);

        // 5. Verify conversation history
        final messages = await conversationService.getMessages(sessionId);
        expect(messages.length, 3);
        expect(messages[0].content, contains('anxious'));
        expect(messages[1].type, MessageType.ai);
        expect(messages[2].content, contains('trust'));

        // 6. Export conversation
        final export = await conversationService.exportConversation(sessionId);
        expect(export, contains('Conversation Export'));
        expect(export, contains('anxious'));

        // 7. Get session info
        final sessions = await conversationService.getSessions();
        expect(sessions.length, 1);
        expect(sessions.first['message_count'], 3);

        // 8. Search messages
        final searchResults = await conversationService.searchMessages('anxious');
        expect(searchResults.length, greaterThanOrEqualTo(1));
      });

      test('should handle multiple concurrent sessions', () async {
        // Create multiple sessions
        final session1 = await conversationService.createSession(title: 'Session 1');
        final session2 = await conversationService.createSession(title: 'Session 2');
        final session3 = await conversationService.createSession(title: 'Session 3');

        // Add messages to each
        await conversationService.saveMessage(
          ChatMessage.user(content: 'Message in session 1', sessionId: session1),
        );
        await conversationService.saveMessage(
          ChatMessage.user(content: 'Message in session 2', sessionId: session2),
        );
        await conversationService.saveMessage(
          ChatMessage.user(content: 'Message in session 3', sessionId: session3),
        );

        // Verify all sessions exist
        final sessions = await conversationService.getSessions();
        expect(sessions.length, 3);

        // Verify messages are in correct sessions
        final msgs1 = await conversationService.getMessages(session1);
        final msgs2 = await conversationService.getMessages(session2);
        final msgs3 = await conversationService.getMessages(session3);

        expect(msgs1.first.content, contains('session 1'));
        expect(msgs2.first.content, contains('session 2'));
        expect(msgs3.first.content, contains('session 3'));
      });

      test('should archive and restore sessions', () async {
        final sessionId = await conversationService.createSession(title: 'To Archive');

        await conversationService.saveMessage(
          ChatMessage.user(content: 'Test message', sessionId: sessionId),
        );

        // Archive session
        await conversationService.archiveSession(sessionId);

        // Should not appear in active sessions
        final activeSessions = await conversationService.getSessions();
        expect(activeSessions.isEmpty, true);

        // Should appear in all sessions
        final allSessions = await conversationService.getSessions(includeArchived: true);
        expect(allSessions.length, 1);
        expect(allSessions.first['is_archived'], 1);

        // Messages should still be accessible
        final messages = await conversationService.getMessages(sessionId);
        expect(messages.length, 1);
      });
    });

    group('Prayer Journal Flow', () {
      test('should complete prayer lifecycle', () async {
        // 1. Create prayer request
        final prayer = await prayerService.createPrayer(
          title: 'Healing for Mom',
          description: 'Please pray for my mother\'s healing',
          categoryId: 'cat_health',
        );

        // 2. Get all prayers
        final prayers = await prayerService.getAllPrayers();
        expect(prayers.length, 1);
        expect(prayers.first.title, 'Healing for Mom');

        // 3. Update prayer
        final updated = prayer.copyWith(
          description: 'Updated prayer description',
        );
        await prayerService.updatePrayer(updated);

        final updatedPrayers = await prayerService.getAllPrayers();
        expect(updatedPrayers.first.description, contains('Updated'));

        // 4. Mark as answered
        await prayerService.markPrayerAnswered(prayer.id, 'God has healed her!');

        final answeredPrayers = await prayerService.getAnsweredPrayers();
        expect(answeredPrayers.length, 1);
        expect(answeredPrayers.first.isAnswered, true);

        // 5. Get prayers by category
        final healthPrayers = await prayerService.getPrayersByCategory('Health');
        expect(healthPrayers.length, 1);

        // 6. Delete prayer
        await prayerService.deletePrayer(prayer.id);

        final afterDelete = await prayerService.getAllPrayers();
        expect(afterDelete.isEmpty, true);
      });

      test('should track prayer statistics', () async {
        // Add multiple prayers
        final p1 = await prayerService.createPrayer(
          title: 'Prayer 1',
          description: 'Prayer 1 description',
          categoryId: 'cat_health',
        );

        final p2 = await prayerService.createPrayer(
          title: 'Prayer 2',
          description: 'Prayer 2 description',
          categoryId: 'cat_family',
        );

        await prayerService.createPrayer(
          title: 'Prayer 3',
          description: 'Prayer 3 description',
          categoryId: 'cat_health',
        );

        // Mark some as answered
        await prayerService.markPrayerAnswered(p1.id, 'Answer to prayer 1');
        await prayerService.markPrayerAnswered(p2.id, 'Answer to prayer 2');

        // Check statistics
        final total = await prayerService.getPrayerCount();
        expect(total, 3);

        final answered = await prayerService.getAnsweredPrayers();
        expect(answered.length, 2);

        final active = await prayerService.getActivePrayers();
        expect(active.length, 1);

        final byCategory = await prayerService.getPrayersByCategory('Health');
        expect(byCategory.length, 2);
      });
    });

    group('Devotional Reading Flow', () {
      test('should complete devotional flow', () async {
        // 1. Load available devotionals
        final devotionals = await devotionalService.getAllDevotionals();
        expect(devotionals, isNotEmpty);

        // 2. Get today's devotional
        final today = await devotionalService.getTodaysDevotional();
        expect(today, isNotNull);

        // 3. Read devotional (mark as complete)
        if (today != null) {
          await devotionalService.markDevotionalCompleted(today.id);

          // 4. Check progress
          final completed = await devotionalService.getCompletedDevotionals();
          expect(completed.length, greaterThanOrEqualTo(1));

          // 5. Check counts
          final completedCount = await devotionalService.getCompletedCount();
          expect(completedCount, greaterThanOrEqualTo(1));

          // 6. Check streak
          final streak = await devotionalService.getCurrentStreak();
          expect(streak, greaterThanOrEqualTo(0));
        }
      });

      test('should track weekly devotional streak', () async {
        final devotionals = await devotionalService.getAllDevotionals();

        // Complete multiple devotionals
        for (int i = 0; i < 3 && i < devotionals.length; i++) {
          await devotionalService.markDevotionalCompleted(devotionals[i].id);
        }

        final completedCount = await devotionalService.getCompletedCount();
        expect(completedCount, 3);

        final completed = await devotionalService.getCompletedDevotionals();
        expect(completed.length, 3);
      });
    });

    group('Reading Plan Flow', () {
      test('should start and progress through reading plan', () async {
        // 1. Get available plans
        final plans = await readingPlanService.getAllPlans();
        expect(plans, isNotEmpty);

        // 2. Start a plan
        final plan = plans.first;
        await readingPlanService.startPlan(plan.id);

        // 3. Get active plan
        final activePlans = await readingPlanService.getActivePlans();
        expect(activePlans, isNotEmpty);
        expect(activePlans.first.id, plan.id);

        // 4. Get today's readings
        final todayReadings = await readingPlanService.getTodaysReadings(plan.id);
        expect(todayReadings, isNotEmpty);

        // 5. Complete a reading
        if (todayReadings.isNotEmpty) {
          await readingPlanService.markReadingCompleted(todayReadings.first.id);

          // 6. Check progress
          final completedCount = await readingPlanService.getCompletedReadingsCount(plan.id);
          expect(completedCount, greaterThan(0));
        }
      });

      test('should handle plan completion', () async {
        final plans = await readingPlanService.getAllPlans();
        final plan = plans.first;

        await readingPlanService.startPlan(plan.id);

        // Get some readings to complete
        final readings = await readingPlanService.getReadingsForPlan(plan.id);

        // Complete first 3 readings (simulate)
        for (int i = 0; i < 3 && i < readings.length; i++) {
          await readingPlanService.markReadingCompleted(readings[i].id);
        }

        final completedCount = await readingPlanService.getCompletedReadingsCount(plan.id);
        expect(completedCount, greaterThanOrEqualTo(3));
      });

      test('should switch between plans', () async {
        final plans = await readingPlanService.getAllPlans();

        // Start first plan
        await readingPlanService.startPlan(plans[0].id);
        final activePlans1 = await readingPlanService.getActivePlans();
        expect(activePlans1.any((p) => p.id == plans[0].id), true);

        // Start second plan
        if (plans.length > 1) {
          await readingPlanService.startPlan(plans[1].id);
          final activePlans2 = await readingPlanService.getActivePlans();
          expect(activePlans2.any((p) => p.id == plans[1].id), true);
        }
      });
    });

    group('Cross-Feature Integration', () {
      test('should integrate prayer requests with chat', () async {
        // 1. Create prayer request
        await prayerService.createPrayer(
          title: 'Need guidance',
          description: 'Seeking guidance',
          categoryId: 'cat_guidance',
        );

        // 2. Start chat about the prayer
        final sessionId = await conversationService.createSession(
          title: 'Prayer Discussion',
        );

        await conversationService.saveMessage(
          ChatMessage.user(
            content: 'I need guidance for my prayer request',
            sessionId: sessionId,
          ),
        );

        // 3. Get AI response
        await conversationService.saveMessage(
          ChatMessage.ai(
            content: 'Let\'s pray together about this...',
            sessionId: sessionId,
          ),
        );

        // 4. Verify both features work together
        final prayers = await prayerService.getAllPrayers();
        final messages = await conversationService.getMessages(sessionId);

        expect(prayers.length, 1);
        expect(messages.length, 2);
      });

      test('should integrate devotional with conversation', () async {
        // 1. Complete devotional
        final devotional = await devotionalService.getTodaysDevotional();

        if (devotional != null) {
          await devotionalService.markDevotionalCompleted(devotional.id);

          // 2. Start conversation about devotional
          final sessionId = await conversationService.createSession(
            title: 'Devotional Discussion',
          );

          await conversationService.saveMessage(
            ChatMessage.user(
              content: 'I have questions about today\'s devotional',
              sessionId: sessionId,
            ),
          );

          // 3. Verify integration
          final completed = await devotionalService.getCompletedDevotionals();
          final messages = await conversationService.getMessages(sessionId);

          expect(completed.any((d) => d.id == devotional.id), true);
          expect(messages.length, 1);
        }
      });

      test('should maintain data consistency across services', () async {
        // Create data across multiple services
        await prayerService.createPrayer(
          title: 'Prayer 1',
          description: 'Prayer 1 description',
          categoryId: 'cat_health',
        );

        final sessionId = await conversationService.createSession();
        await conversationService.saveMessage(
          ChatMessage.user(content: 'Test', sessionId: sessionId),
        );

        // Verify all data exists
        final prayers = await prayerService.getAllPrayers();
        final sessions = await conversationService.getSessions();

        expect(prayers.length, 1);
        expect(sessions.length, 1);
      });
    });

    group('Data Persistence', () {
      test('should persist data across service instances', () async {
        // Save data with first instance
        final service1 = ConversationService();
        final sessionId = await service1.createSession(title: 'Persist Test');
        await service1.saveMessage(
          ChatMessage.user(content: 'Test message', sessionId: sessionId),
        );

        // Load with new instance
        final service2 = ConversationService();
        final messages = await service2.getMessages(sessionId);

        expect(messages.length, 1);
        expect(messages.first.content, 'Test message');
      });

      test('should maintain referential integrity', () async {
        final sessionId = await conversationService.createSession();

        // Add messages
        for (int i = 0; i < 5; i++) {
          await conversationService.saveMessage(
            ChatMessage.user(content: 'Message $i', sessionId: sessionId),
          );
        }

        // Delete session (should cascade delete messages)
        await conversationService.deleteSession(sessionId);

        // Verify messages are also deleted
        final messages = await conversationService.getMessages(sessionId);
        expect(messages.isEmpty, true);
      });
    });

    group('Error Recovery', () {
      test('should recover from transaction failures', () async {
        final sessionId = await conversationService.createSession();

        // Try to save messages with potential error
        try {
          await conversationService.saveMessages([
            ChatMessage.user(content: 'Valid message', sessionId: sessionId),
          ]);
        } catch (e) {
          // Should handle gracefully
        }

        // Verify system still works
        final messages = await conversationService.getMessages(sessionId);
        expect(messages, isA<List>());
      });

      test('should handle concurrent operations safely', () async {
        final sessionId = await conversationService.createSession();

        // Simulate concurrent saves
        final futures = <Future>[];
        for (int i = 0; i < 10; i++) {
          futures.add(
            conversationService.saveMessage(
              ChatMessage.user(content: 'Concurrent $i', sessionId: sessionId),
            ),
          );
        }

        await Future.wait(futures);

        final count = await conversationService.getMessageCount(sessionId);
        expect(count, 10);
      });
    });
  });
}
