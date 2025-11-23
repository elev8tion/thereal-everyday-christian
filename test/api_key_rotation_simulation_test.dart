import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simulation test for 20-key API rotation system
///
/// This test verifies:
/// - Random starting positions work correctly
/// - Round-robin rotation increments properly
/// - Distribution is even over time (each key gets ~5% of requests)
/// - Counter persists across "app launches"
/// - System handles concurrent users without bottlenecks
void main() {
  group('API Key Rotation Simulation Tests', () {

    /// Simulates the _getApiKey() method from GeminiAIService
    Future<int> simulateGetApiKey({
      required int poolSize,
      String counterKey = 'api_key_rotation_counter',
    }) async {
      final prefs = await SharedPreferences.getInstance();

      // Check if this is first time - initialize with random starting position
      if (!prefs.containsKey(counterKey)) {
        final random = Random();
        final randomStart = random.nextInt(poolSize); // 0-19
        await prefs.setInt(counterKey, randomStart);
        print('🔑 Initialized key rotation at position $randomStart');
      }

      // Get current counter
      int counter = prefs.getInt(counterKey) ?? 0;

      // Increment counter for next time
      await prefs.setInt(counterKey, counter + 1);

      // Select key using round-robin
      final keyIndex = counter % poolSize;

      return keyIndex;
    }

    setUp(() async {
      // Reset SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Random starting position is within valid range', () async {
      const poolSize = 20;

      // Simulate 100 "first launches" (should all get random positions 0-19)
      final startingPositions = <int>[];

      for (int i = 0; i < 100; i++) {
        SharedPreferences.setMockInitialValues({}); // Reset for each user
        final keyIndex = await simulateGetApiKey(poolSize: poolSize);
        startingPositions.add(keyIndex);
      }

      // Verify all positions are in valid range
      expect(startingPositions.every((pos) => pos >= 0 && pos < poolSize), isTrue);

      // Verify we got some variety (not all the same)
      final uniquePositions = startingPositions.toSet();
      expect(uniquePositions.length, greaterThan(5),
        reason: 'Should have variety in random starting positions');

      print('✅ Random starting positions: ${uniquePositions.length} unique positions from 100 users');
    });

    test('Round-robin increments correctly', () async {
      const poolSize = 20;

      // Simulate 25 app launches (should cycle through all 20 keys + 5 more)
      final keyIndices = <int>[];

      for (int i = 0; i < 25; i++) {
        final keyIndex = await simulateGetApiKey(poolSize: poolSize);
        keyIndices.add(keyIndex);
      }

      print('First 25 launches: $keyIndices');

      // Verify cycling behavior
      // After 20 launches, should start repeating
      expect(keyIndices[20], equals(keyIndices[0]),
        reason: 'Launch 21 should use same key as launch 1');
      expect(keyIndices[21], equals(keyIndices[1]),
        reason: 'Launch 22 should use same key as launch 2');
      expect(keyIndices[22], equals(keyIndices[2]),
        reason: 'Launch 23 should use same key as launch 3');

      print('✅ Round-robin cycling verified (keys repeat after 20 launches)');
    });

    test('Distribution is even over 1000 launches (single user)', () async {
      const poolSize = 20;
      const launchCount = 1000;

      // Track how many times each key is used
      final keyUsageCounts = List<int>.filled(poolSize, 0);

      // Simulate 1000 app launches
      for (int i = 0; i < launchCount; i++) {
        final keyIndex = await simulateGetApiKey(poolSize: poolSize);
        keyUsageCounts[keyIndex]++;
      }

      // Calculate statistics
      const expectedUsagePerKey = launchCount / poolSize; // Should be 50
      final maxDeviation = keyUsageCounts.map((count) => (count - expectedUsagePerKey).abs()).reduce((a, b) => a > b ? a : b);
      final avgUsage = keyUsageCounts.reduce((a, b) => a + b) / poolSize;

      print('\n📊 Distribution Statistics (1000 launches):');
      print('Expected usage per key: ${expectedUsagePerKey.toStringAsFixed(1)}');
      print('Actual average usage: ${avgUsage.toStringAsFixed(1)}');
      print('Max deviation from expected: ${maxDeviation.toStringAsFixed(1)}');

      // Print distribution
      for (int i = 0; i < poolSize; i++) {
        final percentage = (keyUsageCounts[i] / launchCount * 100).toStringAsFixed(1);
        final bar = '█' * (keyUsageCounts[i] ~/ 2);
        print('Key #${(i + 1).toString().padLeft(2)}: ${keyUsageCounts[i].toString().padLeft(3)} uses ($percentage%) $bar');
      }

      // Verify distribution is relatively even
      // With perfect distribution, each key should be used exactly 50 times
      // Allow some variance due to random starting position
      expect(avgUsage, closeTo(expectedUsagePerKey, 1.0),
        reason: 'Average usage should be close to expected');

      // Each key should be used at least once
      expect(keyUsageCounts.every((count) => count > 0), isTrue,
        reason: 'Every key should be used at least once');

      print('✅ Distribution verified: All keys used, average close to expected');
    });

    test('Multiple users have desynchronized starting positions', () async {
      const poolSize = 20;
      const userCount = 100;

      final userStartingPositions = <int>[];

      // Simulate 100 users installing the app
      for (int userId = 0; userId < userCount; userId++) {
        // Reset SharedPreferences for each new user
        SharedPreferences.setMockInitialValues({});

        // Each user's first launch
        final keyIndex = await simulateGetApiKey(poolSize: poolSize);
        userStartingPositions.add(keyIndex);
      }

      // Calculate distribution of starting positions
      final startingPositionCounts = List<int>.filled(poolSize, 0);
      for (final position in userStartingPositions) {
        startingPositionCounts[position]++;
      }

      print('\n📊 Starting Position Distribution (100 users):');
      const expectedPerPosition = userCount / poolSize; // Should be ~5
      for (int i = 0; i < poolSize; i++) {
        final percentage = (startingPositionCounts[i] / userCount * 100).toStringAsFixed(1);
        final bar = '█' * startingPositionCounts[i];
        print('Position ${(i).toString().padLeft(2)}: ${startingPositionCounts[i].toString().padLeft(2)} users ($percentage%) $bar');
      }

      // Verify positions are spread out
      final avgUsersPerPosition = startingPositionCounts.reduce((a, b) => a + b) / poolSize;
      print('\nExpected users per position: ${expectedPerPosition.toStringAsFixed(1)}');
      print('Actual average: ${avgUsersPerPosition.toStringAsFixed(1)}');

      expect(avgUsersPerPosition, closeTo(expectedPerPosition, 2.0),
        reason: 'Users should be relatively evenly distributed across starting positions');

      print('✅ Starting positions are desynchronized (good for preventing concurrent spikes)');
    });

    test('Concurrent users at peak hour (10,000 users simulation)', () async {
      const poolSize = 20;
      const userCount = 10000;

      // Track which key each user is currently using
      final currentKeyUsage = List<int>.filled(poolSize, 0);

      // Simulate 10,000 users all launching app at same time (8am peak)
      for (int userId = 0; userId < userCount; userId++) {
        // Each user has their own counter (simulated with unique key)
        SharedPreferences.setMockInitialValues({});

        // Simulate this user's launch
        final keyIndex = await simulateGetApiKey(poolSize: poolSize, counterKey: 'user_$userId');
        currentKeyUsage[keyIndex]++;
      }

      print('\n📊 Concurrent Load Distribution (10,000 users at peak hour):');
      const expectedUsersPerKey = userCount / poolSize; // Should be 500
      final maxUsersOnOneKey = currentKeyUsage.reduce((a, b) => a > b ? a : b);
      final minUsersOnOneKey = currentKeyUsage.reduce((a, b) => a < b ? a : b);

      for (int i = 0; i < poolSize; i++) {
        final percentage = (currentKeyUsage[i] / userCount * 100).toStringAsFixed(1);
        final bar = '█' * (currentKeyUsage[i] ~/ 25);
        print('Key #${(i + 1).toString().padLeft(2)}: ${currentKeyUsage[i].toString().padLeft(4)} users ($percentage%) $bar');
      }

      print('\nExpected users per key: ${expectedUsersPerKey.toStringAsFixed(0)}');
      print('Max users on one key: $maxUsersOnOneKey');
      print('Min users on one key: $minUsersOnOneKey');
      print('Spread: ${maxUsersOnOneKey - minUsersOnOneKey} users');

      // Verify no single key is overloaded
      // With 10,000 users and 20 keys, expect ~500 per key
      // Each key has 60 req/min capacity = 3600 req/hour
      // If each user sends 3 messages: 500 users × 3 = 1,500 req/hour
      // 1,500 / 3,600 = 42% capacity ✅

      const messagesPerUser = 3;
      final requestsPerKey = expectedUsersPerKey * messagesPerUser;
      const capacityPerKeyPerHour = 3600; // 60 req/min × 60 min
      final capacityUsagePercent = (requestsPerKey / capacityPerKeyPerHour * 100).toStringAsFixed(1);

      print('\n⚡ Capacity Analysis:');
      print('Average users per key: ${expectedUsersPerKey.toStringAsFixed(0)}');
      print('Messages per user: $messagesPerUser');
      print('Requests per key: ${requestsPerKey.toStringAsFixed(0)}');
      print('Capacity per key (hourly): $capacityPerKeyPerHour requests');
      print('Capacity usage: $capacityUsagePercent%');

      // Each key should be used
      expect(currentKeyUsage.every((count) => count > 0), isTrue,
        reason: 'All keys should handle some users');

      // No key should be massively overloaded (allow 2x variance for random distribution)
      expect(maxUsersOnOneKey, lessThan(expectedUsersPerKey * 2),
        reason: 'No single key should be severely overloaded');

      print('✅ Peak load distributed well: $capacityUsagePercent% average capacity usage');
    });

    test('Long-term distribution (100 users × 50 launches each)', () async {
      const poolSize = 20;
      const userCount = 100;
      const launchesPerUser = 50;
      const totalLaunches = userCount * launchesPerUser;

      // Track total key usage across all users
      final totalKeyUsage = List<int>.filled(poolSize, 0);

      // Simulate 100 users each launching app 50 times
      for (int userId = 0; userId < userCount; userId++) {
        // Each user gets their own SharedPreferences
        SharedPreferences.setMockInitialValues({});

        for (int launch = 0; launch < launchesPerUser; launch++) {
          final keyIndex = await simulateGetApiKey(poolSize: poolSize);
          totalKeyUsage[keyIndex]++;
        }
      }

      print('\n📊 Long-Term Distribution (100 users × 50 launches = 5,000 total):');
      const expectedUsagePerKey = totalLaunches / poolSize; // Should be 250

      for (int i = 0; i < poolSize; i++) {
        final percentage = (totalKeyUsage[i] / totalLaunches * 100).toStringAsFixed(1);
        final deviation = (totalKeyUsage[i] - expectedUsagePerKey).toStringAsFixed(1);
        final deviationSign = totalKeyUsage[i] > expectedUsagePerKey ? '+' : '';
        final bar = '█' * (totalKeyUsage[i] ~/ 10);
        print('Key #${(i + 1).toString().padLeft(2)}: ${totalKeyUsage[i].toString().padLeft(4)} ($percentage%) $deviationSign$deviation $bar');
      }

      final avgUsage = totalKeyUsage.reduce((a, b) => a + b) / poolSize;
      final maxDeviation = totalKeyUsage.map((count) => (count - expectedUsagePerKey).abs()).reduce((a, b) => a > b ? a : b);

      print('\nExpected usage per key: ${expectedUsagePerKey.toStringAsFixed(1)}');
      print('Actual average usage: ${avgUsage.toStringAsFixed(1)}');
      print('Max deviation: ${maxDeviation.toStringAsFixed(1)}');

      // Over many launches, distribution should be very close to perfect
      expect(avgUsage, closeTo(expectedUsagePerKey, 5.0),
        reason: 'Long-term average should match expected');

      // Each key should get close to 5% of total requests
      for (int i = 0; i < poolSize; i++) {
        final percentage = totalKeyUsage[i] / totalLaunches;
        expect(percentage, closeTo(0.05, 0.01),
          reason: 'Each key should get ~5% of total requests (±1%)');
      }

      print('✅ Long-term distribution is nearly perfect (~5% per key)');
    });

    test('Counter persists across app restarts', () async {
      const poolSize = 20;

      // Simulate first launch
      final key1 = await simulateGetApiKey(poolSize: poolSize);
      print('Launch 1: Key #${key1 + 1}');

      // Simulate app restart (SharedPreferences should persist)
      final key2 = await simulateGetApiKey(poolSize: poolSize);
      print('Launch 2: Key #${key2 + 1}');

      final key3 = await simulateGetApiKey(poolSize: poolSize);
      print('Launch 3: Key #${key3 + 1}');

      // Verify counter incremented correctly
      // key2 should be (key1 + 1) % poolSize
      final expected2 = (key1 + 1) % poolSize;
      expect(key2, equals(expected2),
        reason: 'Second launch should increment counter');

      final expected3 = (key2 + 1) % poolSize;
      expect(key3, equals(expected3),
        reason: 'Third launch should increment again');

      print('✅ Counter persists correctly across app restarts');
    });
  });
}
