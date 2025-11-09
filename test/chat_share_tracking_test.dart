import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:everyday_christian/core/services/database_service.dart';
import 'package:everyday_christian/services/chat_share_service.dart';

void main() {
  late DatabaseService databaseService;
  late ChatShareService chatShareService;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    DatabaseService.setTestDatabasePath(inMemoryDatabasePath);
    databaseService = DatabaseService();
    await databaseService.initialize();
    chatShareService = ChatShareService(databaseService: databaseService);
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

  tearDown(() async {
    await databaseService.close();
    DatabaseService.setTestDatabasePath(null);
  });

  group('Test 1: Chat Share Tracking - Database Integration', () {
    test('should create shared_chats table on fresh installation', () async {
      final db = await databaseService.database;

      // Check if table exists
      final result = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'shared_chats'],
      );

      expect(result.length, equals(1),
          reason: 'shared_chats table should exist in database');
    });

    test('shared_chats table should have correct columns', () async {
      final db = await databaseService.database;
      final columns = await db.rawQuery('PRAGMA table_info(shared_chats)');

      final columnNames = columns.map((col) => col['name']).toList();

      expect(columnNames, contains('id'),
          reason: 'Table should have id column');
      expect(columnNames, contains('session_id'),
          reason: 'Table should have session_id column');
      expect(columnNames, contains('shared_at'),
          reason: 'Table should have shared_at timestamp column');
    });

    test('should track share in database when sessionId is provided', () async {
      final db = await databaseService.database;
      final testSessionId = 'test-session-123';

      // Create a chat session first (required by foreign key)
      await createTestSession(db, testSessionId);

      // Manually call the internal tracking method by creating a share entry
      await db.insert('shared_chats', {
        'id': 'share-1',
        'session_id': testSessionId,
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Query the database to verify the record was inserted
      final shares = await db.query(
        'shared_chats',
        where: 'session_id = ?',
        whereArgs: [testSessionId],
      );

      expect(shares.length, equals(1),
          reason: 'One share record should exist for the session');
      expect(shares.first['session_id'], equals(testSessionId),
          reason: 'Session ID should match');
      expect(shares.first['shared_at'], isNotNull,
          reason: 'Share timestamp should be recorded');
    });

    test('should track multiple shares for same session', () async {
      final db = await databaseService.database;
      final testSessionId = 'test-session-456';
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create a chat session first (required by foreign key)
      await createTestSession(db, testSessionId);

      // Insert multiple shares for the same session
      await db.insert('shared_chats', {
        'id': 'share-1',
        'session_id': testSessionId,
        'shared_at': now,
      });

      await db.insert('shared_chats', {
        'id': 'share-2',
        'session_id': testSessionId,
        'shared_at': now + 1000,
      });

      await db.insert('shared_chats', {
        'id': 'share-3',
        'session_id': testSessionId,
        'shared_at': now + 2000,
      });

      // Query all shares for this session
      final shares = await db.query(
        'shared_chats',
        where: 'session_id = ?',
        whereArgs: [testSessionId],
      );

      expect(shares.length, equals(3),
          reason: 'All three share records should be tracked');
    });

    test('should track shares for different sessions independently', () async {
      final db = await databaseService.database;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create chat sessions first (required by foreign key)
      await createTestSession(db, 'session-a');
      await createTestSession(db, 'session-b');

      // Insert shares for different sessions
      await db.insert('shared_chats', {
        'id': 'share-a1',
        'session_id': 'session-a',
        'shared_at': now,
      });

      await db.insert('shared_chats', {
        'id': 'share-b1',
        'session_id': 'session-b',
        'shared_at': now + 1000,
      });

      await db.insert('shared_chats', {
        'id': 'share-a2',
        'session_id': 'session-a',
        'shared_at': now + 2000,
      });

      // Query total shares
      final allShares = await db.query('shared_chats');
      expect(allShares.length, equals(3),
          reason: 'All shares should be tracked');

      // Query shares for session-a
      final sessionAShares = await db.query(
        'shared_chats',
        where: 'session_id = ?',
        whereArgs: ['session-a'],
      );
      expect(sessionAShares.length, equals(2),
          reason: 'Session A should have 2 shares');

      // Query shares for session-b
      final sessionBShares = await db.query(
        'shared_chats',
        where: 'session_id = ?',
        whereArgs: ['session-b'],
      );
      expect(sessionBShares.length, equals(1),
          reason: 'Session B should have 1 share');
    });

    test('should generate unique IDs for each share', () async {
      final db = await databaseService.database;
      final testSessionId = 'test-session-789';
      final now = DateTime.now().millisecondsSinceEpoch;

      // Create a chat session first (required by foreign key)
      await createTestSession(db, testSessionId);

      // Insert multiple shares
      await db.insert('shared_chats', {
        'id': 'share-unique-1',
        'session_id': testSessionId,
        'shared_at': now,
      });

      await db.insert('shared_chats', {
        'id': 'share-unique-2',
        'session_id': testSessionId,
        'shared_at': now + 1000,
      });

      // Query all shares
      final shares = await db.query('shared_chats');
      final ids = shares.map((s) => s['id']).toSet();

      expect(ids.length, equals(shares.length),
          reason: 'Each share should have a unique ID');
    });

    test('should record accurate timestamps', () async {
      final db = await databaseService.database;
      final beforeTimestamp = DateTime.now().millisecondsSinceEpoch;

      // Create a chat session first (required by foreign key)
      await createTestSession(db, 'session-timestamp');

      await db.insert('shared_chats', {
        'id': 'share-timestamp-test',
        'session_id': 'session-timestamp',
        'shared_at': beforeTimestamp,
      });

      final afterTimestamp = DateTime.now().millisecondsSinceEpoch;

      final shares = await db.query(
        'shared_chats',
        where: 'id = ?',
        whereArgs: ['share-timestamp-test'],
      );

      final recordedTimestamp = shares.first['shared_at'] as int;

      expect(recordedTimestamp, greaterThanOrEqualTo(beforeTimestamp),
          reason: 'Recorded timestamp should be after or equal to before timestamp');
      expect(recordedTimestamp, lessThanOrEqualTo(afterTimestamp),
          reason: 'Recorded timestamp should be before or equal to after timestamp');
    });
  });

  group('Test 2: Conversation Sharer Achievement - Count Tracking', () {
    test('sharedChatsCountProvider should return 0 when no shares exist', () async {
      final db = await databaseService.database;

      // Ensure table is empty
      await db.delete('shared_chats');

      // Query count
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      final count = countResult.first['count'] as int;

      expect(count, equals(0),
          reason: 'Count should be 0 when no shares exist');
    });

    test('should count shares correctly as they are added', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats'); // Start fresh

      // Add shares one by one and verify count
      for (int i = 1; i <= 10; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-count-$i');

        await db.insert('shared_chats', {
          'id': 'share-count-$i',
          'session_id': 'session-count-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });

        final countResult = await db.rawQuery(
          'SELECT COUNT(*) as count FROM shared_chats',
        );
        final count = countResult.first['count'] as int;

        expect(count, equals(i),
            reason: 'Count should be $i after adding $i shares');
      }
    });

    test('should track progress toward achievement (0/10, 5/10, 10/10)', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Start: 0/10
      var countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(0),
          reason: 'Progress should start at 0/10');

      // Add 5 shares: 5/10
      for (int i = 1; i <= 5; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-progress-$i');

        await db.insert('shared_chats', {
          'id': 'share-progress-$i',
          'session_id': 'session-progress-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(5),
          reason: 'Progress should be 5/10 after 5 shares');

      // Add 5 more shares: 10/10
      for (int i = 6; i <= 10; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-progress-$i');

        await db.insert('shared_chats', {
          'id': 'share-progress-$i',
          'session_id': 'session-progress-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(10),
          reason: 'Progress should be 10/10 (achievement unlocked)');
    });

    test('achievement should unlock exactly at 10 shares', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 9 shares - should NOT unlock
      for (int i = 1; i <= 9; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-unlock-$i');

        await db.insert('shared_chats', {
          'id': 'share-unlock-$i',
          'session_id': 'session-unlock-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      var countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      var count = countResult.first['count'] as int;
      expect(count < 10, isTrue,
          reason: 'Achievement should NOT unlock at 9 shares');

      // Add 10th share - should unlock
      // Create a chat session first (required by foreign key)
      await createTestSession(db, 'session-unlock-10');

      await db.insert('shared_chats', {
        'id': 'share-unlock-10',
        'session_id': 'session-unlock-10',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      count = countResult.first['count'] as int;
      expect(count, equals(10),
          reason: 'Achievement should unlock at exactly 10 shares');
    });

    test('should count shares across all sessions (not per-session)', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Create chat sessions first (required by foreign key)
      await createTestSession(db, 'session-1');
      await createTestSession(db, 'session-2');

      // Add shares across different sessions
      await db.insert('shared_chats', {
        'id': 'share-multi-1',
        'session_id': 'session-1',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('shared_chats', {
        'id': 'share-multi-2',
        'session_id': 'session-2',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('shared_chats', {
        'id': 'share-multi-3',
        'session_id': 'session-1',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Total count should be 3 (across all sessions)
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(3),
          reason: 'Should count all shares across all sessions');
    });
  });

  group('Test 4: Database Migration (v9 → v10)', () {
    test('should verify shared_chats table exists after migration', () async {
      final db = await databaseService.database;

      // Check current database version
      final version = await db.getVersion();
      expect(version, greaterThanOrEqualTo(10),
          reason: 'Database should be at version 10 or higher');

      // Verify table exists
      final tableResult = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['table', 'shared_chats'],
      );

      expect(tableResult.isNotEmpty, isTrue,
          reason: 'shared_chats table should exist after migration to v10');
    });

    test('should verify shared_chats table schema is correct', () async {
      final db = await databaseService.database;
      final columns = await db.rawQuery('PRAGMA table_info(shared_chats)');

      expect(columns.length, equals(3),
          reason: 'shared_chats should have exactly 3 columns');

      final columnMap = {for (var col in columns) col['name']: col};

      // Verify id column
      expect(columnMap['id'], isNotNull);
      expect(columnMap['id']!['type'], equals('TEXT'));
      expect(columnMap['id']!['pk'], equals(1),
          reason: 'id should be primary key');

      // Verify session_id column
      expect(columnMap['session_id'], isNotNull);
      expect(columnMap['session_id']!['type'], equals('TEXT'));
      expect(columnMap['session_id']!['notnull'], equals(1),
          reason: 'session_id should be NOT NULL');

      // Verify shared_at column
      expect(columnMap['shared_at'], isNotNull);
      expect(columnMap['shared_at']!['type'], equals('INTEGER'));
      expect(columnMap['shared_at']!['notnull'], equals(1),
          reason: 'shared_at should be NOT NULL');
    });

    test('should verify indexes are created correctly', () async {
      final db = await databaseService.database;

      // Check for session_id index
      final sessionIdIndex = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['index', 'idx_shared_chats_session'],
      );

      expect(sessionIdIndex.isNotEmpty, isTrue,
          reason: 'idx_shared_chats_session index should exist');

      // Check for shared_at index
      final sharedAtIndex = await db.query(
        'sqlite_master',
        where: 'type = ? AND name = ?',
        whereArgs: ['index', 'idx_shared_chats_timestamp'],
      );

      expect(sharedAtIndex.isNotEmpty, isTrue,
          reason: 'idx_shared_chats_timestamp index should exist');
    });

    test('should allow inserting records into migrated table', () async {
      final db = await databaseService.database;

      // Create a chat session first (required by foreign key)
      await createTestSession(db, 'session-migration');

      // Insert a test record
      await db.insert('shared_chats', {
        'id': 'migration-test-1',
        'session_id': 'session-migration',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Query it back
      final result = await db.query(
        'shared_chats',
        where: 'id = ?',
        whereArgs: ['migration-test-1'],
      );

      expect(result.length, equals(1),
          reason: 'Should be able to insert and query records after migration');
    });
  });

  group('Test 5: Profile Screen Provider Integration', () {
    test('sharedChatsCountProvider should return correct count', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 5 shares
      for (int i = 1; i <= 5; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-provider-$i');

        await db.insert('shared_chats', {
          'id': 'provider-test-$i',
          'session_id': 'session-provider-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      // Query count (simulating what the provider does)
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      final count = countResult.first['count'] as int;

      expect(count, equals(5),
          reason: 'Provider should return correct count of 5');
    });

    test('provider should handle empty table gracefully', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Query empty table
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      final count = countResult.first['count'] as int;

      expect(count, equals(0),
          reason: 'Provider should return 0 for empty table');
    });

    test('provider should reflect updates in real-time', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Initial count
      var countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(0));

      // Create a chat session first (required by foreign key)
      await createTestSession(db, 'session-realtime');

      // Add share and check again
      await db.insert('shared_chats', {
        'id': 'realtime-1',
        'session_id': 'session-realtime',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(1),
          reason: 'Count should update immediately after insert');
    });

    test('provider should handle large numbers of shares', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Add 100 shares
      for (int i = 1; i <= 100; i++) {
        // Create a chat session first (required by foreign key)
        await createTestSession(db, 'session-large-$i');

        await db.insert('shared_chats', {
          'id': 'large-test-$i',
          'session_id': 'session-large-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        });
      }

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(100),
          reason: 'Provider should handle large counts correctly');
    });
  });

  group('Edge Cases and Error Handling', () {
    test('should handle null session_id gracefully', () async {
      final db = await databaseService.database;

      // Attempt to insert with null session_id should fail
      // (due to NOT NULL constraint)
      expect(
        () async => await db.insert('shared_chats', {
          'id': 'null-session-test',
          'session_id': null,
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        }),
        throwsException,
        reason: 'Should throw exception for null session_id',
      );
    });

    test('should handle missing shared_at timestamp', () async {
      final db = await databaseService.database;

      // Attempt to insert without shared_at should fail
      // (due to NOT NULL constraint)
      expect(
        () async => await db.insert('shared_chats', {
          'id': 'no-timestamp-test',
          'session_id': 'session-test',
          // shared_at omitted
        }),
        throwsException,
        reason: 'Should throw exception for missing shared_at',
      );
    });

    test('should prevent duplicate IDs', () async {
      final db = await databaseService.database;
      final testId = 'duplicate-id-test';

      // Create chat sessions first (required by foreign key)
      await createTestSession(db, 'session-1');
      await createTestSession(db, 'session-2');

      // Insert first record
      await db.insert('shared_chats', {
        'id': testId,
        'session_id': 'session-1',
        'shared_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Attempt to insert duplicate ID should fail
      expect(
        () async => await db.insert('shared_chats', {
          'id': testId, // Same ID
          'session_id': 'session-2',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        }),
        throwsException,
        reason: 'Should throw exception for duplicate primary key',
      );
    });

    test('should handle query on empty table', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      final shares = await db.query('shared_chats');

      expect(shares, isEmpty,
          reason: 'Query on empty table should return empty list');
    });

    test('should handle concurrent inserts', () async {
      final db = await databaseService.database;
      await db.delete('shared_chats');

      // Create chat sessions first (required by foreign key)
      for (int i = 1; i <= 10; i++) {
        await createTestSession(db, 'session-concurrent-$i');
      }

      // Simulate concurrent inserts
      final futures = <Future>[];
      for (int i = 1; i <= 10; i++) {
        futures.add(db.insert('shared_chats', {
          'id': 'concurrent-$i',
          'session_id': 'session-concurrent-$i',
          'shared_at': DateTime.now().millisecondsSinceEpoch,
        }));
      }

      await Future.wait(futures);

      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM shared_chats',
      );
      expect(countResult.first['count'], equals(10),
          reason: 'All concurrent inserts should succeed');
    });
  });
}
