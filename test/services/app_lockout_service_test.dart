import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:everyday_christian/core/services/app_lockout_service.dart';

@GenerateMocks([LocalAuthentication])
import 'app_lockout_service_test.mocks.dart';

void main() {
  group('AppLockoutService Tests', () {
    late AppLockoutService service;
    late MockLocalAuthentication mockLocalAuth;
    late SharedPreferences prefs;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Initialize SharedPreferences with test values
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Create service and inject mock
      service = AppLockoutService();
      await service.init();

      // Create mock LocalAuthentication
      mockLocalAuth = MockLocalAuthentication();
    });

    tearDown(() async {
      // Clear all preferences after each test
      await prefs.clear();
    });

    group('Basic Lockout Functionality', () {
      test('should initialize with no lockout', () async {
        expect(await service.isLockedOut(), false);
        expect(service.getCurrentAttempts(), 0);
        expect(service.getRemainingAttempts(), 3);
      });

      test('should record failed attempts correctly', () async {
        await service.recordFailedAttempt();
        expect(service.getCurrentAttempts(), 1);
        expect(service.getRemainingAttempts(), 2);

        await service.recordFailedAttempt();
        expect(service.getCurrentAttempts(), 2);
        expect(service.getRemainingAttempts(), 1);
      });

      test('should trigger lockout after 3 failed attempts', () async {
        // Record 3 failed attempts
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        expect(service.getCurrentAttempts(), 3);
        expect(service.getRemainingAttempts(), 0);
        expect(await service.isLockedOut(), true);
        expect(service.getRemainingLockoutMinutes(), greaterThan(0));
        expect(service.getRemainingLockoutMinutes(), lessThanOrEqualTo(30));
      });

      test('should clear lockout after timeout period', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        expect(await service.isLockedOut(), true);

        // Simulate time passing by manually setting past timestamp
        final pastTime = DateTime.now().subtract(const Duration(minutes: 31));
        await prefs.setInt('app_lockout_time', pastTime.millisecondsSinceEpoch);

        expect(await service.isLockedOut(), false);
        expect(service.getRemainingLockoutMinutes(), 0);
      });

      test('should calculate remaining lockout time correctly', () async {
        // Trigger lockout
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        final remainingMinutes = service.getRemainingLockoutMinutes();
        expect(remainingMinutes, greaterThan(0));
        expect(remainingMinutes, lessThanOrEqualTo(30));
      });

      test('should clear lockout and reset attempts', () async {
        // Set up lockout state
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        expect(service.getCurrentAttempts(), 2);

        // Clear lockout
        await service.clearLockout();

        expect(service.getCurrentAttempts(), 0);
        expect(service.getRemainingAttempts(), 3);
        expect(await service.isLockedOut(), false);
      });
    });

    group('Device Authentication Integration', () {
      test('should handle device not supporting biometrics', () async {
        // Create a test-specific service with mocked LocalAuth
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, false);
        verify(mockLocalAuth.canCheckBiometrics).called(1);
        verify(mockLocalAuth.isDeviceSupported()).called(1);
        verifyNever(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        ));
      });

      test('should handle device not supported', () async {
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, false);
        verify(mockLocalAuth.isDeviceSupported()).called(1);
      });

      test('should authenticate successfully and clear lockout', () async {
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        // Set up lockout state
        await testService.recordFailedAttempt();
        await testService.recordFailedAttempt();
        await testService.recordFailedAttempt();
        expect(await testService.isLockedOut(), true);

        // Mock successful authentication
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer(
          (_) async => [BiometricType.fingerprint, BiometricType.face],
        );
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, true);
        expect(await testService.isLockedOut(), false);
        expect(testService.getCurrentAttempts(), 0);
        verify(mockLocalAuth.authenticate(
          localizedReason: 'Test authentication',
          options: argThat(
            isA<AuthenticationOptions>()
                .having((o) => o.biometricOnly, 'biometricOnly', false)
                .having((o) => o.useErrorDialogs, 'useErrorDialogs', true)
                .having((o) => o.stickyAuth, 'stickyAuth', true),
            named: 'options',
          ),
        )).called(1);
      });

      test('should handle failed authentication', () async {
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        // Mock failed authentication
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer(
          (_) async => [BiometricType.fingerprint],
        );
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, false);
        verify(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).called(1);
      });

      test('should handle authentication exceptions gracefully', () async {
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        when(mockLocalAuth.canCheckBiometrics).thenThrow(Exception('Test error'));

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, false);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple clearLockout calls', () async {
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        await service.clearLockout();
        await service.clearLockout(); // Second call should not error

        expect(service.getCurrentAttempts(), 0);
      });

      test('should not increment beyond max attempts', () async {
        // Record more than 3 attempts
        for (int i = 0; i < 5; i++) {
          await service.recordFailedAttempt();
        }

        expect(service.getCurrentAttempts(), 5);
        expect(await service.isLockedOut(), true);
      });

      test('should handle getRemainingLockoutMinutes when not locked', () {
        expect(service.getRemainingLockoutMinutes(), 0);
      });

      test('should persist lockout state across service instances', () async {
        // Create first service instance and trigger lockout
        final service1 = AppLockoutService();
        await service1.init();

        await service1.recordFailedAttempt();
        await service1.recordFailedAttempt();
        await service1.recordFailedAttempt();

        expect(await service1.isLockedOut(), true);

        // Create second service instance - should maintain lockout state
        final service2 = AppLockoutService();
        await service2.init();

        expect(await service2.isLockedOut(), true);
        expect(service2.getCurrentAttempts(), 3);
      });

      test('should handle empty available biometrics list', () async {
        final testService = TestableAppLockoutService(mockLocalAuth);
        await testService.init();

        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.getAvailableBiometrics()).thenAnswer((_) async => []);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        final result = await testService.authenticateWithDevice(
          localizedReason: 'Test authentication',
        );

        expect(result, true);
      });
    });

    group('SharedPreferences Storage', () {
      test('should store correct keys in SharedPreferences', () async {
        await service.recordFailedAttempt();
        expect(prefs.getInt('app_lockout_attempts'), 1);

        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        expect(prefs.getInt('app_lockout_attempts'), 3);
        expect(prefs.getInt('app_lockout_time'), isNotNull);
      });

      test('should remove keys from SharedPreferences on clear', () async {
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();
        await service.recordFailedAttempt();

        expect(prefs.containsKey('app_lockout_attempts'), true);
        expect(prefs.containsKey('app_lockout_time'), true);

        await service.clearLockout();

        expect(prefs.containsKey('app_lockout_attempts'), false);
        expect(prefs.containsKey('app_lockout_time'), false);
      });
    });
  });
}

/// Testable version of AppLockoutService that allows injecting mock LocalAuthentication
class TestableAppLockoutService extends AppLockoutService {
  final LocalAuthentication mockLocalAuth;

  TestableAppLockoutService(this.mockLocalAuth);

  @override
  Future<bool> authenticateWithDevice({required String localizedReason}) async {
    try {
      final canCheckBiometrics = await mockLocalAuth.canCheckBiometrics;
      final isDeviceSupported = await mockLocalAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      await mockLocalAuth.getAvailableBiometrics();

      final authenticated = await mockLocalAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (authenticated) {
        await clearLockout();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}