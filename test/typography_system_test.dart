import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyday_christian/core/services/preferences_service.dart';
import 'package:everyday_christian/core/providers/app_providers.dart';
import 'package:everyday_christian/utils/responsive_utils.dart';

void main() {
  group('Typography System Integration Tests', () {
    // =========================================================================
    // TEST GROUP 1: PreferencesService Text Size Storage
    // =========================================================================

    group('PreferencesService Text Size', () {
      late SharedPreferences prefs;

      setUp(() async {
        // Reset singleton state to prevent test pollution
        PreferencesService.resetForTesting();

        // Initialize SharedPreferences with in-memory implementation
        SharedPreferences.setMockInitialValues({});
        prefs = await SharedPreferences.getInstance();
      });

      tearDown(() async {
        // Clean up after each test
        await prefs.clear();
      });
      test('loads default text size of 1.0 when no preference is saved', () async {
        final prefsService = await PreferencesService.getInstance();
        final textSize = prefsService.loadTextSize();

        expect(textSize, equals(1.0), reason: 'Default text size should be 1.0 (100% scale)');
      });

      test('saves and loads text size correctly', () async {
        final prefsService = await PreferencesService.getInstance();

        // Save a custom text size
        final saveSuccess = await prefsService.saveTextSize(1.2);
        expect(saveSuccess, isTrue, reason: 'saveTextSize should return true on success');

        // Load the saved value
        final loadedSize = prefsService.loadTextSize();
        expect(loadedSize, equals(1.2), reason: 'Loaded text size should match saved value');
      });

      test('handles boundary values correctly', () async {
        final prefsService = await PreferencesService.getInstance();

        // Test minimum boundary (0.8x)
        await prefsService.saveTextSize(0.8);
        expect(prefsService.loadTextSize(), equals(0.8));

        // Test maximum boundary (1.5x)
        await prefsService.saveTextSize(1.5);
        expect(prefsService.loadTextSize(), equals(1.5));

        // Test midpoint (1.0x)
        await prefsService.saveTextSize(1.0);
        expect(prefsService.loadTextSize(), equals(1.0));
      });

      test('persists text size across service instances', () async {
        // Save with first instance
        final prefsService1 = await PreferencesService.getInstance();
        await prefsService1.saveTextSize(1.3);

        // Load with second instance (simulates app restart)
        final prefsService2 = await PreferencesService.getInstance();
        final loadedSize = prefsService2.loadTextSize();

        expect(loadedSize, equals(1.3),
          reason: 'Text size should persist across service instances');
      });
    });

    // =========================================================================
    // TEST GROUP 2: TextSizeProvider Integration
    // =========================================================================

    group('TextSizeProvider', () {
      setUp(() {
        // Reset singleton state before each test
        PreferencesService.resetForTesting();
      });

      test('initializes with default value of 1.0', () async {
        // Completely reset SharedPreferences for this test
        SharedPreferences.setMockInitialValues({});

        // Create container - it will create its own provider instances
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Wait for async provider initialization
        await container.read(preferencesServiceProvider.future);

        // The textSizeProvider should have initialized by now
        final textSize = container.read(textSizeProvider);
        expect(textSize, equals(1.0),
          reason: 'TextSizeProvider should initialize to 1.0');
      });

      test('loads saved text size from preferences', () async {
        // Reset with pre-saved value
        SharedPreferences.setMockInitialValues({'text_size': 1.4});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(preferencesServiceProvider.future);

        final textSize = container.read(textSizeProvider);
        expect(textSize, equals(1.4),
          reason: 'TextSizeProvider should load saved preference');
      });

      test('updates state when setTextSize is called', () async {
        SharedPreferences.setMockInitialValues({});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(preferencesServiceProvider.future);

        // Change text size
        await container.read(textSizeProvider.notifier).setTextSize(1.2);

        // Verify provider state updated
        expect(container.read(textSizeProvider), equals(1.2));
      });

      test('persists changes to SharedPreferences', () async {
        SharedPreferences.setMockInitialValues({});
        final testPrefs = await SharedPreferences.getInstance();

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(preferencesServiceProvider.future);

        // Change text size
        await container.read(textSizeProvider.notifier).setTextSize(1.2);

        // Verify persistence
        final savedValue = testPrefs.getDouble('text_size') ?? 1.0;
        expect(savedValue, equals(1.2));
      });

      test('handles boundary values correctly', () async {
        SharedPreferences.setMockInitialValues({});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(preferencesServiceProvider.future);

        // Test value below minimum
        await container.read(textSizeProvider.notifier).setTextSize(0.5);
        expect(container.read(textSizeProvider), equals(0.8),
          reason: 'Values below 0.8 should be clamped to 0.8');

        // Test value above maximum
        await container.read(textSizeProvider.notifier).setTextSize(2.0);
        expect(container.read(textSizeProvider), equals(1.5),
          reason: 'Values above 1.5 should be clamped to 1.5');
      });

      test('migrates old pixel-based text sizes to scale factors', () async {
        // Reset with old pixel-based value
        SharedPreferences.setMockInitialValues({'text_size': 16.0});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        await container.read(preferencesServiceProvider.future);

        final textSize = container.read(textSizeProvider);

        // 16.0 should map to 1.0 (middle of 0.8-1.5 range)
        expect(textSize, closeTo(1.0, 0.05),
          reason: 'Old pixel size 16.0 should migrate to scale factor ~1.0');
      });
    });

    // =========================================================================
    // TEST GROUP 3: ResponsiveUtils.fontSize() Integration
    // =========================================================================

    group('ResponsiveUtils.fontSize()', () {
      // Helper to create a text size notifier with a fixed value
      TextSizeNotifier createNotifierWithValue(double value) {
        final notifier = TextSizeNotifier(const AsyncValue.loading());
        notifier.state = value;
        return notifier;
      }

      Widget buildTestApp({
        required double textScale,
        required double screenWidth,
        required Widget child,
      }) {
        return ProviderScope(
          overrides: [
            textSizeProvider.overrideWith((ref) => createNotifierWithValue(textScale)),
          ],
          child: MediaQuery(
            data: MediaQueryData(
              size: Size(screenWidth, 800),
              textScaler: TextScaler.linear(textScale),
            ),
            child: MaterialApp(
              home: Scaffold(body: child),
            ),
          ),
        );
      }

      testWidgets('calculates base font size correctly for iPhone SE (375px)', (tester) async {
        late double calculatedSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.0,
            screenWidth: 375,
            child: Builder(
              builder: (context) {
                calculatedSize = ResponsiveUtils.fontSize(context, 16);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // At 1.0 scale, 375px width → scale factor = 1.0
        // fontSize = 16 * 1.0 * 1.0 = 16.0
        expect(calculatedSize, closeTo(16.0, 0.1),
          reason: 'Font size should be 16.0 at baseline (iPhone SE, 1.0x scale)');
      });

      testWidgets('scales font size with screen width (iPad 1024px)', (tester) async {
        late double calculatedSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.0,
            screenWidth: 1024,
            child: Builder(
              builder: (context) {
                calculatedSize = ResponsiveUtils.fontSize(context, 16);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // At 1.0 text scale, 1024px width → screen scale = 1024/375 = 2.73
        // fontSize = 16 * 2.73 * 1.0 = 43.68
        expect(calculatedSize, closeTo(43.7, 0.5),
          reason: 'Font size should scale proportionally with screen width');
      });

      testWidgets('applies user text scale multiplier correctly', (tester) async {
        late double size80Percent;
        late double size100Percent;
        late double size150Percent;

        // Test 0.8x scale (80%)
        await tester.pumpWidget(
          buildTestApp(
            textScale: 0.8,
            screenWidth: 375,
            child: Builder(
              builder: (context) {
                size80Percent = ResponsiveUtils.fontSize(context, 16);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Test 1.0x scale (100%)
        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.0,
            screenWidth: 375,
            child: Builder(
              builder: (context) {
                size100Percent = ResponsiveUtils.fontSize(context, 16);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Test 1.5x scale (150%)
        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.5,
            screenWidth: 375,
            child: Builder(
              builder: (context) {
                size150Percent = ResponsiveUtils.fontSize(context, 16);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Verify scaling relationships
        expect(size80Percent, closeTo(16.0 * 0.8, 0.1),
          reason: '0.8x scale should result in 80% of base size');
        expect(size100Percent, closeTo(16.0 * 1.0, 0.1),
          reason: '1.0x scale should result in 100% of base size');
        expect(size150Percent, closeTo(16.0 * 1.5, 0.1),
          reason: '1.5x scale should result in 150% of base size');

        // Verify relative scaling
        expect(size150Percent / size80Percent, closeTo(1.875, 0.05),
          reason: '1.5x scale should be 1.875x larger than 0.8x scale');
      });

      testWidgets('respects minSize constraint', (tester) async {
        late double calculatedSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 0.8, // Try to make it smaller
            screenWidth: 320, // Small screen
            child: Builder(
              builder: (context) {
                calculatedSize = ResponsiveUtils.fontSize(
                  context,
                  16,
                  minSize: 14, // Enforce minimum
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(calculatedSize, greaterThanOrEqualTo(14.0),
          reason: 'Font size should not go below minSize constraint');
      });

      testWidgets('respects maxSize constraint', (tester) async {
        late double calculatedSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.5, // Try to make it larger
            screenWidth: 1200, // Large screen
            child: Builder(
              builder: (context) {
                calculatedSize = ResponsiveUtils.fontSize(
                  context,
                  16,
                  maxSize: 24, // Enforce maximum
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(calculatedSize, lessThanOrEqualTo(24.0),
          reason: 'Font size should not exceed maxSize constraint');
      });

      testWidgets('handles combined screen and text scaling', (tester) async {
        // Test extreme case: large screen + large text scale
        late double largeSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 1.5,
            screenWidth: 1024,
            child: Builder(
              builder: (context) {
                largeSize = ResponsiveUtils.fontSize(context, 16, maxSize: 50);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // Should apply both screen scale (1024/375 = 2.73) and text scale (1.5)
        // 16 * 2.73 * 1.5 = 65.52, but clamped to maxSize 50
        expect(largeSize, equals(50.0),
          reason: 'Should apply both scaling factors and respect maxSize');

        // Test extreme case: small screen + small text scale
        late double smallSize;

        await tester.pumpWidget(
          buildTestApp(
            textScale: 0.8,
            screenWidth: 320,
            child: Builder(
              builder: (context) {
                smallSize = ResponsiveUtils.fontSize(context, 16, minSize: 12);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        // 16 * (320/375) * 0.8 = 10.92, should be clamped to minSize 12
        expect(smallSize, equals(12.0),
          reason: 'Should apply both scaling factors and respect minSize');
      });
    });

    // =========================================================================
    // TEST GROUP 4: Settings Screen Integration
    // =========================================================================

    group('Settings Screen Text Size Slider', () {
      testWidgets('displays current text size percentage', (tester) async {
        // Reset for this test
        SharedPreferences.setMockInitialValues({});

        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Wait for provider initialization
        await container.read(preferencesServiceProvider.future);

        // Set text size to 1.2 (120%)
        await container.read(textSizeProvider.notifier).setTextSize(1.2);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final textSize = ref.watch(textSizeProvider);
                    return Text('${(textSize * 100).round()}%');
                  },
                ),
              ),
            ),
          ),
        );

        // Wait for widget tree to build completely
        await tester.pumpAndSettle();

        expect(find.text('120%'), findsOneWidget,
          reason: 'Should display text size as percentage');
      });

      testWidgets('slider changes text size immediately', (tester) async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: Consumer(
                  builder: (context, ref, _) {
                    final textSize = ref.watch(textSizeProvider);
                    return Column(
                      children: [
                        Text('Size: ${(textSize * 100).round()}%'),
                        Slider(
                          value: textSize,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7,
                          onChanged: (value) {
                            ref.read(textSizeProvider.notifier).setTextSize(value);
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );

        // Find and drag the slider
        await tester.drag(find.byType(Slider), const Offset(100, 0));
        await tester.pump();

        // Text size should have changed
        final newSize = container.read(textSizeProvider);
        expect(newSize, isNot(equals(1.0)),
          reason: 'Slider interaction should change text size');
      });
    });

    // =========================================================================
    // TEST GROUP 5: Visual Regression Tests (Text Widget Scaling)
    // =========================================================================

    group('Visual Text Scaling', () {
      // Helper to create a text size notifier with a fixed value
      TextSizeNotifier createNotifierWithValue(double value) {
        final notifier = TextSizeNotifier(const AsyncValue.loading());
        notifier.state = value;
        return notifier;
      }

      testWidgets('Text widgets scale correctly across different text sizes', (tester) async {
        Widget buildTextWithScale(double textScale) {
          return ProviderScope(
            overrides: [
              textSizeProvider.overrideWith((ref) => createNotifierWithValue(textScale)),
            ],
            child: MediaQuery(
              data: MediaQueryData(
                size: const Size(375, 800),
                textScaler: TextScaler.linear(textScale),
              ),
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return Text(
                        'Test Text',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }

        // Test 0.8x scale
        await tester.pumpWidget(buildTextWithScale(0.8));
        final small = tester.widget<Text>(find.text('Test Text'));
        final smallSize = small.style!.fontSize!;

        // Test 1.0x scale
        await tester.pumpWidget(buildTextWithScale(1.0));
        final medium = tester.widget<Text>(find.text('Test Text'));
        final mediumSize = medium.style!.fontSize!;

        // Test 1.5x scale
        await tester.pumpWidget(buildTextWithScale(1.5));
        final large = tester.widget<Text>(find.text('Test Text'));
        final largeSize = large.style!.fontSize!;

        // Verify sizes are proportional
        expect(smallSize, lessThan(mediumSize),
          reason: '0.8x scale should be smaller than 1.0x');
        expect(mediumSize, lessThan(largeSize),
          reason: '1.0x scale should be smaller than 1.5x');

        // Verify exact ratios
        expect(mediumSize / smallSize, closeTo(1.25, 0.05),
          reason: 'Ratio between 1.0x and 0.8x should be 1.25');
        expect(largeSize / mediumSize, closeTo(1.5, 0.05),
          reason: 'Ratio between 1.5x and 1.0x should be 1.5');
      });

      testWidgets('layout does not break at extreme scales', (tester) async {
        Widget buildLayoutTest(double textScale) {
          return ProviderScope(
            overrides: [
              textSizeProvider.overrideWith((ref) => createNotifierWithValue(textScale)),
            ],
            child: MediaQuery(
              data: MediaQueryData(
                size: const Size(375, 800),
                textScaler: TextScaler.linear(textScale),
              ),
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      return Column(
                        children: [
                          Text(
                            'Title',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 20, minSize: 16, maxSize: 28),
                            ),
                          ),
                          Text(
                            'Subtitle',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 16, minSize: 14, maxSize: 20),
                            ),
                          ),
                          Text(
                            'Body text goes here',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 14, minSize: 12, maxSize: 18),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        }

        // Test minimum scale (0.8x)
        await tester.pumpWidget(buildLayoutTest(0.8));
        await tester.pumpAndSettle();

        // Should not throw layout errors
        expect(tester.takeException(), isNull,
          reason: 'No layout errors at 0.8x scale');

        // Test maximum scale (1.5x)
        await tester.pumpWidget(buildLayoutTest(1.5));
        await tester.pumpAndSettle();

        // Should not throw layout errors
        expect(tester.takeException(), isNull,
          reason: 'No layout errors at 1.5x scale');
      });
    });

    // =========================================================================
    // TEST GROUP 6: Cross-Device Consistency
    // =========================================================================

    group('Cross-Device Text Scaling', () {
      // Helper to create a text size notifier with a fixed value
      TextSizeNotifier createNotifierWithValue(double value) {
        final notifier = TextSizeNotifier(const AsyncValue.loading());
        notifier.state = value;
        return notifier;
      }

      testWidgets('maintains relative scaling across different screen sizes', (tester) async {
        Future<double> getFontSizeForDevice(double screenWidth, double textScale) async {
          late double fontSize;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                textSizeProvider.overrideWith((ref) => createNotifierWithValue(textScale)),
              ],
              child: MediaQuery(
                data: MediaQueryData(
                  size: Size(screenWidth, 800),
                  textScaler: TextScaler.linear(textScale),
                ),
                child: MaterialApp(
                  home: Scaffold(
                    body: Builder(
                      builder: (context) {
                        fontSize = ResponsiveUtils.fontSize(context, 16);
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ),
            ),
          );

          return fontSize;
        }

        // Test on iPhone SE (320px)
        final iphoneSE100 = await getFontSizeForDevice(320, 1.0);
        final iphoneSE150 = await getFontSizeForDevice(320, 1.5);

        // Test on iPhone 14 (390px)
        final iphone14_100 = await getFontSizeForDevice(390, 1.0);
        final iphone14_150 = await getFontSizeForDevice(390, 1.5);

        // Test on iPad (1024px)
        final ipad100 = await getFontSizeForDevice(1024, 1.0);
        final ipad150 = await getFontSizeForDevice(1024, 1.5);

        // Verify text scale multiplier is consistent across devices
        expect(iphoneSE150 / iphoneSE100, closeTo(1.5, 0.05),
          reason: '1.5x text scale should be consistent on iPhone SE');
        expect(iphone14_150 / iphone14_100, closeTo(1.5, 0.05),
          reason: '1.5x text scale should be consistent on iPhone 14');
        expect(ipad150 / ipad100, closeTo(1.5, 0.05),
          reason: '1.5x text scale should be consistent on iPad');
      });

      testWidgets('screen scaling is independent of text scaling', (tester) async {
        // Get base size on small screen
        late double smallScreen80;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textSizeProvider.overrideWith((ref) => createNotifierWithValue(0.8)),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(375, 800),
                textScaler: TextScaler.linear(0.8),
              ),
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      smallScreen80 = ResponsiveUtils.fontSize(context, 16);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Get size on large screen with same text scale
        late double largeScreen80;
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              textSizeProvider.overrideWith((ref) => createNotifierWithValue(0.8)),
            ],
            child: MediaQuery(
              data: const MediaQueryData(
                size: Size(1024, 800),
                textScaler: TextScaler.linear(0.8),
              ),
              child: MaterialApp(
                home: Scaffold(
                  body: Builder(
                    builder: (context) {
                      largeScreen80 = ResponsiveUtils.fontSize(context, 16);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        // Screen scaling should still apply
        const screenScaleRatio = 1024 / 375; // ~2.73
        expect(largeScreen80 / smallScreen80, closeTo(screenScaleRatio, 0.1),
          reason: 'Screen scaling should be independent of text scaling');
      });
    });
  });
}
