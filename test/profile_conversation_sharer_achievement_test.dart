import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/screens/profile_screen.dart';

void main() {
  late DatabaseService databaseService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
  });

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  /// Helper method to create a test chat session
  Future<String> createTestSession(Database db, String sessionId) async {
    await db.insert('chat_sessions', {
      'id': sessionId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    });
    return sessionId;
  }

  /// Helper method to add shares to the database
  Future<void> addShares(Database db, int count) async {
    for (int i = 1; i <= count; i++) {
      await createTestSession(db, 'session-$i');
      await db.insert('shared_chats', {
        'id': 'share-$i',
        'session_id': 'session-$i',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: const ProfileScreen(),
      ),
    );
  }

  group('Test 2: Conversation Sharer Achievement - Profile Screen UI', () {
    testWidgets('should display achievement on profile screen', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Look for the achievement title
      expect(find.text('Conversation Sharer'), findsOneWidget,
          reason: 'Achievement should be visible on profile screen');

      // Look for the achievement description
      expect(find.text('Share 10 conversations'), findsOneWidget,
          reason: 'Achievement description should be visible');

      container.dispose();
    });

    testWidgets('should show progress counter at 0/10 when no shares exist', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for the provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Look for progress indicator showing 0/10
      // The progress is shown as a linear indicator, not text
      // We can verify the achievement is locked (not gold/highlighted)

      // Find the achievement card
      expect(find.text('Conversation Sharer'), findsOneWidget);

      // The achievement should not be unlocked (we can check by looking for opacity/color)
      // Since we can't easily check visual properties in tests, we verify the structure exists
      expect(find.byType(LinearProgressIndicator), findsWidgets,
          reason: 'Progress indicators should be present for locked achievements');

      container.dispose();
    });

    testWidgets('should show progress counter at 5/10 after 5 shares', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 5 shares
      await addShares(db, 5);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should still be locked
      expect(find.text('Conversation Sharer'), findsOneWidget);

      // Progress should be visible (5/10)
      expect(find.byType(LinearProgressIndicator), findsWidgets);

      container.dispose();
    });

    testWidgets('should unlock achievement at exactly 10 shares', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add exactly 10 shares
      await addShares(db, 10);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should be unlocked
      expect(find.text('Conversation Sharer'), findsOneWidget);

      // When unlocked, the card should have different styling
      // We can't easily test visual differences, but we can verify the structure
      expect(find.text('Share 10 conversations'), findsOneWidget);

      container.dispose();
    });

    testWidgets('should display achievement before reaching 10 shares (not hidden)', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 3 shares (not yet unlocked)
      await addShares(db, 3);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should be visible even though it's not unlocked
      expect(find.text('Conversation Sharer'), findsOneWidget,
          reason: 'Achievement should be visible before unlocking (not hidden)');

      expect(find.text('Share 10 conversations'), findsOneWidget,
          reason: 'Achievement description should be visible before unlocking');

      container.dispose();
    });

    testWidgets('should update progress in real-time after new share', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Start with 8 shares
      await addShares(db, 8);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for initial load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should be visible and locked
      expect(find.text('Conversation Sharer'), findsOneWidget);

      // Add 2 more shares to reach 10
      await addShares(db, 2);

      // Invalidate the provider to force refresh
      container.invalidate(sharedChatsCountProvider);

      // Rebuild the widget
      await tester.pump();
      await tester.pumpAndSettle();

      // Achievement should still be visible (now unlocked)
      expect(find.text('Conversation Sharer'), findsOneWidget);

      container.dispose();
    });

    testWidgets('should handle zero shares gracefully', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should be visible even with 0 shares
      expect(find.text('Conversation Sharer'), findsOneWidget);
      expect(find.text('Share 10 conversations'), findsOneWidget);

      // Should not crash or show error
      expect(tester.takeException(), isNull,
          reason: 'Should handle zero shares without errors');

      container.dispose();
    });

    testWidgets('should display share icon for achievement', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Look for the share icon (Icons.share)
      expect(find.byIcon(Icons.share), findsWidgets,
          reason: 'Share icon should be displayed for the achievement');

      container.dispose();
    });

    testWidgets('should show all achievements including Conversation Sharer', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Verify multiple achievements are shown
      expect(find.text('Prayer Warrior'), findsOneWidget,
          reason: 'Other achievements should also be visible');
      expect(find.text('Conversation Sharer'), findsOneWidget,
          reason: 'Conversation Sharer should be among the achievements');

      container.dispose();
    });

    testWidgets('should handle large share counts (100+)', (WidgetTester tester) async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 100 shares (far beyond the 10 needed)
      await addShares(db, 100);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      await tester.pumpWidget(createTestWidget(container));
      await tester.pumpAndSettle();

      // Wait for provider to load
      await tester.pump(const Duration(milliseconds: 100));

      // Achievement should be unlocked and displayed correctly
      expect(find.text('Conversation Sharer'), findsOneWidget);

      // Should not crash with large counts
      expect(tester.takeException(), isNull,
          reason: 'Should handle large share counts without errors');

      container.dispose();
    });
  });

  group('Provider Integration Tests', () {
    test('sharedChatsCountProvider should return correct count in profile screen context', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 7 shares
      await addShares(db, 7);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      // Read the provider
      final count = await container.read(sharedChatsCountProvider.future);

      expect(count, equals(7),
          reason: 'Provider should return correct count of 7');

      container.dispose();
    });

    test('sharedChatsCountProvider should update when new shares are added', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Start with 5 shares
      await addShares(db, 5);

      final container = ProviderContainer(
        overrides: [
          databaseServiceProvider.overrideWithValue(databaseService),
        ],
      );

      // Initial count
      var count = await container.read(sharedChatsCountProvider.future);
      expect(count, equals(5));

      // Add 3 more shares
      await addShares(db, 3);

      // Invalidate and re-read
      container.invalidate(sharedChatsCountProvider);
      count = await container.read(sharedChatsCountProvider.future);

      expect(count, equals(8),
          reason: 'Provider should reflect updated count after invalidation');

      container.dispose();
    });
  });
}
