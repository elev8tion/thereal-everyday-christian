import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:everyday_christian/screens/settings_screen.dart';
import 'package:everyday_christian/core/services/prayer_service.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';

// Generate mocks
@GenerateMocks([PrayerService])
import 'settings_data_privacy_test.mocks.dart';

// Mock PathProviderPlatform
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '/tmp/test_temp';
  }

  @override
  Future<String?> getApplicationCachePath() async {
    return '/tmp/test_cache';
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '/tmp/test_docs';
  }
}

void main() {
  late MockPrayerService mockPrayerService;
  late MockPathProviderPlatform mockPathProvider;

  setUp(() {
    mockPrayerService = MockPrayerService();
    mockPathProvider = MockPathProviderPlatform();
    PathProviderPlatform.instance = mockPathProvider;
  });

  tearDown(() {
    // Clean up any test directories if they exist
    final tempDir = Directory('/tmp/test_temp');
    final cacheDir = Directory('/tmp/test_cache');
    try {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      if (cacheDir.existsSync()) cacheDir.deleteSync(recursive: true);
    } catch (e) {
      // Ignore cleanup errors
    }
  });

  group('Data & Privacy Settings Tests', () {
    testWidgets('Settings screen displays Data & Privacy section',
        (WidgetTester tester) async {
      // Set larger screen size to accommodate all content
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Data & Privacy section exists
      expect(find.text('Data & Privacy'), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
    });

    testWidgets('Data & Privacy section has correct subtitles',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify subtitles
      expect(find.text('Use app without internet connection'), findsOneWidget);
      expect(find.text('Free up storage space'), findsOneWidget);
      expect(find.text('Backup your prayers and notes'), findsOneWidget);
    });

    testWidgets('Settings screen renders without errors',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should build without crashing
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Data & Privacy UI elements are present',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all Data & Privacy UI elements exist
      expect(find.text('Data & Privacy'), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);
      expect(find.text('Use app without internet connection'), findsOneWidget);
      expect(find.text('Clear Cache'), findsOneWidget);
      expect(find.text('Free up storage space'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Backup your prayers and notes'), findsOneWidget);
    });

    test('PrayerService export method exists', () {
      // Verify the prayer service has the correct method
      expect(
        mockPrayerService.exportPrayerJournal,
        isA<Future<String> Function()>(),
      );
    });

    test('MockPathProviderPlatform returns correct paths', () async {
      final tempPath = await mockPathProvider.getTemporaryPath();
      final cachePath = await mockPathProvider.getApplicationCachePath();

      expect(tempPath, equals('/tmp/test_temp'));
      expect(cachePath, equals('/tmp/test_cache'));
    });

    test('Clear Cache directory operations', () {
      // Create test directories
      final tempDir = Directory('/tmp/test_temp');
      final cacheDir = Directory('/tmp/test_cache');

      if (!tempDir.existsSync()) {
        tempDir.createSync(recursive: true);
      }
      if (!cacheDir.existsSync()) {
        cacheDir.createSync(recursive: true);
      }

      // Verify directories exist
      expect(tempDir.existsSync(), isTrue);
      expect(cacheDir.existsSync(), isTrue);

      // Simulate clearing cache
      tempDir.deleteSync(recursive: true);
      cacheDir.deleteSync(recursive: true);

      // Verify directories are deleted
      expect(tempDir.existsSync(), isFalse);
      expect(cacheDir.existsSync(), isFalse);
    });

    test('Export Data with empty prayer journal', () async {
      when(mockPrayerService.exportPrayerJournal())
          .thenAnswer((_) async => '');

      final result = await mockPrayerService.exportPrayerJournal();

      expect(result, isEmpty);
      verify(mockPrayerService.exportPrayerJournal()).called(1);
    });

    test('Export Data with actual prayer data', () async {
      const mockData = '''
Prayer Journal Export
Date: 2025-10-17
Prayer 1: Test prayer
Status: Pending
      ''';

      when(mockPrayerService.exportPrayerJournal())
          .thenAnswer((_) async => mockData);

      final result = await mockPrayerService.exportPrayerJournal();

      expect(result, equals(mockData));
      expect(result.contains('Prayer Journal Export'), isTrue);
      expect(result.contains('Test prayer'), isTrue);
      verify(mockPrayerService.exportPrayerJournal()).called(1);
    });

    test('Export Data handles errors', () async {
      when(mockPrayerService.exportPrayerJournal())
          .thenThrow(Exception('Database error'));

      expect(
        () => mockPrayerService.exportPrayerJournal(),
        throwsException,
      );
    });

    testWidgets('Offline Mode switch is present',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Offline Mode switch exists
      expect(find.text('Offline Mode'), findsOneWidget);
      // Find any Switch widget in the Data & Privacy section
      expect(find.byType(Switch), findsWidgets);
    });

    test('Path provider mock integration', () async {
      PathProviderPlatform.instance = mockPathProvider;

      final tempPath = await PathProviderPlatform.instance.getTemporaryPath();
      final cachePath =
          await PathProviderPlatform.instance.getApplicationCachePath();

      expect(tempPath, isNotNull);
      expect(cachePath, isNotNull);
      expect(tempPath, equals('/tmp/test_temp'));
      expect(cachePath, equals('/tmp/test_cache'));
    });

    test('Multiple export calls are handled correctly', () async {
      when(mockPrayerService.exportPrayerJournal())
          .thenAnswer((_) async => 'test data');

      // Call multiple times
      await mockPrayerService.exportPrayerJournal();
      await mockPrayerService.exportPrayerJournal();
      await mockPrayerService.exportPrayerJournal();

      // Verify called 3 times
      verify(mockPrayerService.exportPrayerJournal()).called(3);
    });

    test('PrayerService mock can be configured with different responses', () async {
      // Test empty response
      when(mockPrayerService.exportPrayerJournal())
          .thenAnswer((_) async => '');
      expect(await mockPrayerService.exportPrayerJournal(), isEmpty);

      // Test with data
      when(mockPrayerService.exportPrayerJournal())
          .thenAnswer((_) async => 'prayer data');
      expect(await mockPrayerService.exportPrayerJournal(), equals('prayer data'));

      // Test error
      when(mockPrayerService.exportPrayerJournal())
          .thenThrow(Exception('error'));
      expect(() => mockPrayerService.exportPrayerJournal(), throwsException);
    });
  });

  group('Settings Screen Integration', () {
    testWidgets('Settings screen has all major sections',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify major sections exist
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Data & Privacy'), findsOneWidget);
    });

    testWidgets('Settings screen is scrollable',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            prayerServiceProvider.overrideWithValue(mockPrayerService),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify scrollable widget exists
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
