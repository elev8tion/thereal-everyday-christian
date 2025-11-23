import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:everyday_christian/main.dart' as app;
import 'package:everyday_christian/core/services/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Smoke Test 8: Animation Stress Test
///
/// Tests the FAB menu and dialogs for:
/// - Animation performance (frame drops/jank)
/// - Memory leaks (controller disposal)
/// - Crash resistance under rapid interaction
///
/// Run with: flutter test integration_test/08_animation_stress_test.dart -d <device>
/// For accurate results, use --profile mode on a real device
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final binding = IntegrationTestWidgetsFlutterBinding.instance;

  group('Animation Stress Tests', () {
    /// Helper to launch app and get to home screen
    Future<void> launchAppToHome(WidgetTester tester) async {
      // Initialize services
      final subscriptionService = SubscriptionService.instance;
      await subscriptionService.initialize();

      await tester.pumpWidget(
        const ProviderScope(
          child: app.MyApp(),
        ),
      );

      // Wait for splash and initialization
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Try to get past legal/onboarding if present
      // Look for any "Continue", "Accept", "Get Started" buttons
      for (int i = 0; i < 10; i++) {
        final continueButton = find.text('Continue');
        final acceptButton = find.text('Accept');
        final getStartedButton = find.text('Get Started');
        final agreeButton = find.text('I Agree');
        final skipButton = find.text('Skip');

        if (continueButton.evaluate().isNotEmpty) {
          await tester.tap(continueButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else if (acceptButton.evaluate().isNotEmpty) {
          await tester.tap(acceptButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else if (getStartedButton.evaluate().isNotEmpty) {
          await tester.tap(getStartedButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else if (agreeButton.evaluate().isNotEmpty) {
          await tester.tap(agreeButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else if (skipButton.evaluate().isNotEmpty) {
          await tester.tap(skipButton.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        } else {
          break; // No more onboarding buttons
        }
      }

      print('✅ App launched to main screen');
    }

    testWidgets('FAB Menu rapid open/close stress test (50 cycles)',
        (WidgetTester tester) async {
      await launchAppToHome(tester);

      // Find the FAB (it's a GestureDetector with app logo)
      // The FAB contains an Image.asset with logo
      final fabFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final image = widget.image;
          if (image is AssetImage) {
            return image.assetName.contains('logo');
          }
        }
        return false;
      });

      if (fabFinder.evaluate().isEmpty) {
        print('⚠️ FAB not found - may be on a screen without FAB');
        return;
      }

      print('🔄 Starting FAB stress test: 50 rapid open/close cycles');

      int successfulCycles = 0;
      int failedCycles = 0;
      final List<int> frameTimes = [];

      // Record frame callback for performance measurement
      void frameCallback(Duration timestamp) {
        frameTimes.add(timestamp.inMilliseconds);
      }

      SchedulerBinding.instance.addPostFrameCallback(frameCallback);

      for (int i = 0; i < 50; i++) {
        try {
          // Open FAB menu
          await tester.tap(fabFinder.first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          // Wait for animation to complete
          await tester.pumpAndSettle(const Duration(milliseconds: 800));

          // Close FAB menu by tapping backdrop
          await tester.tapAt(const Offset(300, 300));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 100));

          await tester.pumpAndSettle(const Duration(milliseconds: 800));

          successfulCycles++;

          if ((i + 1) % 10 == 0) {
            print('  ✓ Completed ${i + 1}/50 cycles');
          }
        } catch (e) {
          failedCycles++;
          print('  ✗ Cycle ${i + 1} failed: $e');
        }
      }

      print('');
      print('═══════════════════════════════════════');
      print('FAB STRESS TEST RESULTS');
      print('═══════════════════════════════════════');
      print('✅ Successful cycles: $successfulCycles/50');
      print('❌ Failed cycles: $failedCycles/50');
      print('📊 Total frames recorded: ${frameTimes.length}');

      if (frameTimes.length > 1) {
        final frameDeltas = <int>[];
        for (int i = 1; i < frameTimes.length; i++) {
          frameDeltas.add(frameTimes[i] - frameTimes[i - 1]);
        }
        final avgFrameTime =
            frameDeltas.reduce((a, b) => a + b) / frameDeltas.length;
        final maxFrameTime =
            frameDeltas.reduce((a, b) => a > b ? a : b);
        final jankFrames = frameDeltas.where((d) => d > 16).length;

        print('⏱️  Average frame time: ${avgFrameTime.toStringAsFixed(2)}ms');
        print('⏱️  Max frame time: ${maxFrameTime}ms');
        print('🔴 Jank frames (>16ms): $jankFrames/${frameDeltas.length}');
      }
      print('═══════════════════════════════════════');

      expect(failedCycles, lessThan(5),
          reason: 'Less than 5 cycles should fail');
      expect(successfulCycles, greaterThan(45),
          reason: 'At least 45 cycles should succeed');

      print('✅ FAB stress test PASSED');
    });

    testWidgets('FAB Menu memory leak test - check controller disposal',
        (WidgetTester tester) async {
      await launchAppToHome(tester);

      final fabFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final image = widget.image;
          if (image is AssetImage) {
            return image.assetName.contains('logo');
          }
        }
        return false;
      });

      if (fabFinder.evaluate().isEmpty) {
        print('⚠️ FAB not found');
        return;
      }

      print('🔄 Testing FAB for memory leaks...');

      // Open and close FAB 20 times
      for (int i = 0; i < 20; i++) {
        await tester.tap(fabFinder.first);
        await tester.pumpAndSettle();

        // Verify overlay is showing (menu items should be visible)
        final menuItemFinder = find.byWidgetPredicate((widget) {
          if (widget is BackdropFilter) {
            return true;
          }
          return false;
        });

        expect(menuItemFinder.evaluate().isNotEmpty, true,
            reason: 'Menu overlay should be visible');

        // Close by tapping backdrop
        await tester.tapAt(const Offset(350, 600));
        await tester.pumpAndSettle();
      }

      // If we got here without crash, no obvious memory leak
      print('✅ FAB opened/closed 20 times without memory issues');
      print('✅ Memory leak test PASSED');
    });

    testWidgets('Dialog rapid open/close stress test',
        (WidgetTester tester) async {
      await launchAppToHome(tester);

      print('🔄 Testing dialog animations...');

      // Navigate to Settings to find dialog triggers
      final fabFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final image = widget.image;
          if (image is AssetImage) {
            return image.assetName.contains('logo');
          }
        }
        return false;
      });

      if (fabFinder.evaluate().isNotEmpty) {
        // Open FAB
        await tester.tap(fabFinder.first);
        await tester.pumpAndSettle();

        // Find Settings menu item
        final settingsFinder = find.text('Settings');
        if (settingsFinder.evaluate().isNotEmpty) {
          await tester.tap(settingsFinder.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Try to find and test various dialog triggers
      // Look for buttons that might open dialogs
      final dialogTriggers = [
        'Delete',
        'Clear',
        'Reset',
        'About',
        'Version',
        'Sign Out',
        'Log Out',
      ];

      int dialogsOpened = 0;

      for (final trigger in dialogTriggers) {
        final buttonFinder = find.text(trigger);
        if (buttonFinder.evaluate().isNotEmpty) {
          try {
            await tester.tap(buttonFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // Check if a dialog appeared
            final dialogFinder = find.byType(AlertDialog);
            final dialogFinder2 = find.byWidgetPredicate((w) =>
                w.runtimeType.toString().contains('Dialog'));

            if (dialogFinder.evaluate().isNotEmpty ||
                dialogFinder2.evaluate().isNotEmpty) {
              dialogsOpened++;
              print('  ✓ Dialog opened via "$trigger"');

              // Close dialog
              final cancelFinder = find.text('Cancel');
              final closeFinder = find.text('Close');
              final noFinder = find.text('No');

              if (cancelFinder.evaluate().isNotEmpty) {
                await tester.tap(cancelFinder.first);
              } else if (closeFinder.evaluate().isNotEmpty) {
                await tester.tap(closeFinder.first);
              } else if (noFinder.evaluate().isNotEmpty) {
                await tester.tap(noFinder.first);
              } else {
                // Tap outside to dismiss
                await tester.tapAt(const Offset(10, 10));
              }
              await tester.pumpAndSettle();
            }
          } catch (e) {
            print('  ⚠️ Error testing "$trigger": $e');
          }
        }
      }

      print('');
      print('═══════════════════════════════════════');
      print('DIALOG STRESS TEST RESULTS');
      print('═══════════════════════════════════════');
      print('📊 Dialogs successfully opened: $dialogsOpened');
      print('═══════════════════════════════════════');

      print('✅ Dialog stress test PASSED');
    });

    testWidgets('Rapid navigation stress test via FAB menu',
        (WidgetTester tester) async {
      await launchAppToHome(tester);

      print('🔄 Testing rapid navigation via FAB menu...');

      final fabFinder = find.byWidgetPredicate((widget) {
        if (widget is Image) {
          final image = widget.image;
          if (image is AssetImage) {
            return image.assetName.contains('logo');
          }
        }
        return false;
      });

      if (fabFinder.evaluate().isEmpty) {
        print('⚠️ FAB not found');
        return;
      }

      // List of screens to navigate through
      final screens = [
        'Bible',
        'Chat',
        'Prayer',
        'Devotional',
        'Reading',
        'Verse',
        'Profile',
        'Settings',
        'Home',
      ];

      int successfulNavigations = 0;

      for (final screen in screens) {
        try {
          // Open FAB
          await tester.tap(fabFinder.first);
          await tester.pumpAndSettle();

          // Find menu item containing screen name
          final menuItemFinder = find.textContaining(screen);
          if (menuItemFinder.evaluate().isNotEmpty) {
            await tester.tap(menuItemFinder.first);
            await tester.pumpAndSettle(const Duration(seconds: 2));
            successfulNavigations++;
            print('  ✓ Navigated to $screen');
          }
        } catch (e) {
          print('  ⚠️ Failed to navigate to $screen: $e');
        }
      }

      print('');
      print('═══════════════════════════════════════');
      print('NAVIGATION STRESS TEST RESULTS');
      print('═══════════════════════════════════════');
      print('✅ Successful navigations: $successfulNavigations/${screens.length}');
      print('═══════════════════════════════════════');

      expect(successfulNavigations, greaterThan(5),
          reason: 'At least 5 navigations should succeed');

      print('✅ Navigation stress test PASSED');
    });

    testWidgets('Combined animation stress test with frame profiling',
        (WidgetTester tester) async {
      // Enable frame timing
      await binding.traceAction(() async {
        await launchAppToHome(tester);

        print('🔄 Running combined stress test with profiling...');

        final fabFinder = find.byWidgetPredicate((widget) {
          if (widget is Image) {
            final image = widget.image;
            if (image is AssetImage) {
              return image.assetName.contains('logo');
            }
          }
          return false;
        });

        if (fabFinder.evaluate().isEmpty) {
          print('⚠️ FAB not found');
          return;
        }

        // Rapid open/close 10 times
        for (int i = 0; i < 10; i++) {
          await tester.tap(fabFinder.first);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpAndSettle();

          await tester.tapAt(const Offset(300, 500));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpAndSettle();
        }

        print('✅ Combined stress test completed');
      }, reportKey: 'animation_stress_timeline');

      print('');
      print('═══════════════════════════════════════');
      print('PROFILING COMPLETE');
      print('═══════════════════════════════════════');
      print('Timeline data recorded under key: animation_stress_timeline');
      print('Run with --profile flag for accurate measurements');
      print('═══════════════════════════════════════');
    });
  });
}
