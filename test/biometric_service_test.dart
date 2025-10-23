import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/features/auth/services/biometric_service.dart';

void main() {
  group('BiometricType Enum', () {
    test('should have correct enum values', () {
      expect(BiometricType.values.length, equals(4));
      expect(BiometricType.values.contains(BiometricType.face), isTrue);
      expect(BiometricType.values.contains(BiometricType.fingerprint), isTrue);
      expect(BiometricType.values.contains(BiometricType.iris), isTrue);
      expect(BiometricType.values.contains(BiometricType.voice), isTrue);
    });

    test('should have correct enum names', () {
      expect(BiometricType.face.name, equals('face'));
      expect(BiometricType.fingerprint.name, equals('fingerprint'));
      expect(BiometricType.iris.name, equals('iris'));
      expect(BiometricType.voice.name, equals('voice'));
    });
  });

  group('BiometricPlatformSupport Enum', () {
    test('should have correct enum values', () {
      expect(BiometricPlatformSupport.values.length, equals(3));
      expect(BiometricPlatformSupport.values.contains(BiometricPlatformSupport.none), isTrue);
      expect(BiometricPlatformSupport.values.contains(BiometricPlatformSupport.limited), isTrue);
      expect(BiometricPlatformSupport.values.contains(BiometricPlatformSupport.full), isTrue);
    });

    test('should have correct enum names', () {
      expect(BiometricPlatformSupport.none.name, equals('none'));
      expect(BiometricPlatformSupport.limited.name, equals('limited'));
      expect(BiometricPlatformSupport.full.name, equals('full'));
    });
  });

  group('BiometricSettings Model', () {
    test('should create settings with all properties', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face, BiometricType.fingerprint],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.isAvailable, isTrue);
      expect(settings.availableTypes.length, equals(2));
      expect(settings.availableTypes.contains(BiometricType.face), isTrue);
      expect(settings.availableTypes.contains(BiometricType.fingerprint), isTrue);
      expect(settings.isStrongSupported, isTrue);
      expect(settings.platformSupport, equals(BiometricPlatformSupport.full));
    });

    test('should check if specific type is available', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.hasType(BiometricType.face), isTrue);
      expect(settings.hasType(BiometricType.fingerprint), isFalse);
      expect(settings.hasType(BiometricType.iris), isFalse);
    });

    test('should generate description when not available', () {
      const settings = BiometricSettings(
        isAvailable: false,
        availableTypes: [],
        isStrongSupported: false,
        platformSupport: BiometricPlatformSupport.none,
      );

      expect(settings.description, equals('Biometric authentication not available on this device'));
    });

    test('should generate description with single type', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.description, equals('Face ID available'));
    });

    test('should generate description with two types', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face, BiometricType.fingerprint],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.description, equals('Face ID, Fingerprint available'));
    });

    test('should generate description with multiple types', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [
          BiometricType.face,
          BiometricType.fingerprint,
          BiometricType.iris,
        ],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.description, equals('Face ID, Fingerprint, Iris available'));
    });

    test('should generate description with no types but available', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [],
        isStrongSupported: false,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.description, equals('Biometric authentication available'));
    });

    test('should convert to JSON', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face, BiometricType.fingerprint],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      final json = settings.toJson();

      expect(json['isAvailable'], isTrue);
      expect(json['availableTypes'], isA<List>());
      expect(json['availableTypes'].length, equals(2));
      expect(json['availableTypes'].contains('face'), isTrue);
      expect(json['availableTypes'].contains('fingerprint'), isTrue);
      expect(json['isStrongSupported'], isTrue);
      expect(json['platformSupport'], equals('full'));
      expect(json['description'], isA<String>());
    });

    test('should generate toString representation', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      final string = settings.toString();
      expect(string, contains('BiometricSettings'));
      expect(string, contains('available: true'));
      expect(string, contains('types:'));
      expect(string, contains('BiometricType.face'));
      expect(string, contains('strong: true'));
      expect(string, contains('platform: BiometricPlatformSupport.full'));
    });

    test('should handle all biometric type names in description', () {
      const faceSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );
      expect(faceSettings.description, contains('Face ID'));

      const fingerprintSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.fingerprint],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );
      expect(fingerprintSettings.description, contains('Fingerprint'));

      const irisSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.iris],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );
      expect(irisSettings.description, contains('Iris'));

      const voiceSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.voice],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );
      expect(voiceSettings.description, contains('Voice'));
    });
  });

  group('BiometricException', () {
    test('should create exception with message', () {
      const exception = BiometricException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.code, isNull);
    });

    test('should create exception with message and code', () {
      const exception = BiometricException('Test error', 'ERROR_CODE');

      expect(exception.message, equals('Test error'));
      expect(exception.code, equals('ERROR_CODE'));
    });

    test('should generate toString without code', () {
      const exception = BiometricException('Test error');

      expect(exception.toString(), equals('BiometricException: Test error'));
    });

    test('should generate toString with code', () {
      const exception = BiometricException('Test error', 'ERROR_CODE');

      expect(exception.toString(), equals('BiometricException(ERROR_CODE): Test error'));
    });

    test('should handle empty message', () {
      const exception = BiometricException('');

      expect(exception.message, equals(''));
      expect(exception.toString(), equals('BiometricException: '));
    });

    test('should handle long message', () {
      final longMessage = 'Error: ' * 100;
      final exception = BiometricException(longMessage);

      expect(exception.message, equals(longMessage));
      expect(exception.toString(), contains('BiometricException'));
    });

    test('should implement Exception interface', () {
      const exception = BiometricException('Test');

      expect(exception, isA<Exception>());
    });
  });

  group('BiometricResult Model', () {
    test('should create successful result with factory', () {
      final result = BiometricResult.success();

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.usedType, isNull);
    });

    test('should create successful result with type', () {
      final result = BiometricResult.success(BiometricType.face);

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.usedType, equals(BiometricType.face));
    });

    test('should create failure result with factory', () {
      final result = BiometricResult.failure('Authentication failed');

      expect(result.success, isFalse);
      expect(result.error, equals('Authentication failed'));
      expect(result.usedType, isNull);
    });

    test('should create result with all properties', () {
      const result = BiometricResult(
        success: true,
        error: null,
        usedType: BiometricType.fingerprint,
      );

      expect(result.success, isTrue);
      expect(result.error, isNull);
      expect(result.usedType, equals(BiometricType.fingerprint));
    });

    test('should generate toString for success without type', () {
      final result = BiometricResult.success();

      expect(result.toString(), equals('BiometricResult: Success'));
    });

    test('should generate toString for success with type', () {
      final result = BiometricResult.success(BiometricType.face);

      expect(result.toString(), equals('BiometricResult: Success (face)'));
    });

    test('should generate toString for failure with error', () {
      final result = BiometricResult.failure('User cancelled');

      expect(result.toString(), equals('BiometricResult: Failed - User cancelled'));
    });

    test('should generate toString for failure without error', () {
      const result = BiometricResult(success: false);

      expect(result.toString(), equals('BiometricResult: Failed - Unknown error'));
    });

    test('should handle all biometric types in toString', () {
      final faceResult = BiometricResult.success(BiometricType.face);
      expect(faceResult.toString(), contains('face'));

      final fingerprintResult = BiometricResult.success(BiometricType.fingerprint);
      expect(fingerprintResult.toString(), contains('fingerprint'));

      final irisResult = BiometricResult.success(BiometricType.iris);
      expect(irisResult.toString(), contains('iris'));

      final voiceResult = BiometricResult.success(BiometricType.voice);
      expect(voiceResult.toString(), contains('voice'));
    });
  });

  group('BiometricService API Documentation', () {
    test('should have canCheckBiometrics method', () {
      final service = BiometricService();
      expect(service.canCheckBiometrics, isA<Function>());
    });

    test('should have getAvailableBiometrics method', () {
      final service = BiometricService();
      expect(service.getAvailableBiometrics, isA<Function>());
    });

    test('should have authenticate method', () {
      final service = BiometricService();
      expect(service.authenticate, isA<Function>());
    });

    test('should have isStrongBiometricSupported method', () {
      final service = BiometricService();
      expect(service.isStrongBiometricSupported, isA<Function>());
    });

    test('should have stopAuthentication method', () {
      final service = BiometricService();
      expect(service.stopAuthentication, isA<Function>());
    });

    test('should have getSettings method', () {
      final service = BiometricService();
      expect(service.getSettings, isA<Function>());
    });

    test('should have getBiometricDescription method', () {
      final service = BiometricService();
      expect(service.getBiometricDescription, isA<Function>());
    });
  });

  group('BiometricService Description Generation', () {
    late BiometricService service;

    setUp(() {
      service = BiometricService();
    });

    test('should generate description for empty biometrics', () async {
      // On web platform, should return empty list
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      final description = await service.getBiometricDescription();

      expect(description, equals('No biometric authentication available'));

      debugDefaultTargetPlatformOverride = null;
    });

    test('should generate description for single biometric type', () {
      // This test verifies the description logic, not actual platform behavior
      // We test via BiometricSettings which has the same logic
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [BiometricType.face],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.description, equals('Face ID available'));
    });

    test('should handle error in getBiometricDescription', () async {
      // Even with errors, should return a fallback description
      final description = await service.getBiometricDescription();

      expect(description, isA<String>());
      expect(description.isNotEmpty, isTrue);
    });
  });

  group('BiometricService Settings', () {
    late BiometricService service;

    setUp(() {
      service = BiometricService();
    });

    test('should get settings successfully', () async {
      final settings = await service.getSettings();

      expect(settings, isA<BiometricSettings>());
      expect(settings.isAvailable, isA<bool>());
      expect(settings.availableTypes, isA<List<BiometricType>>());
      expect(settings.isStrongSupported, isA<bool>());
      expect(settings.platformSupport, isA<BiometricPlatformSupport>());
    });

    test('should return safe default settings on error', () async {
      // Even if internal methods fail, getSettings should return valid object
      final settings = await service.getSettings();

      expect(settings, isA<BiometricSettings>());
    });
  });

  group('BiometricService Platform Support', () {
    late BiometricService service;

    setUp(() {
      service = BiometricService();
    });

    test('should check biometrics on current platform', () async {
      final canCheck = await service.canCheckBiometrics();

      expect(canCheck, isA<bool>());
    });

    test('should get available biometrics on current platform', () async {
      final biometrics = await service.getAvailableBiometrics();

      expect(biometrics, isA<List<BiometricType>>());
    });

    test('should check strong biometric support', () async {
      final isStrong = await service.isStrongBiometricSupported();

      expect(isStrong, isA<bool>());
    });

    test('should handle stopAuthentication without errors', () async {
      // Should not throw
      await service.stopAuthentication();
    });
  });

  group('BiometricService Authentication', () {
    late BiometricService service;

    setUp(() {
      service = BiometricService();
    });

    test('should accept authentication parameters', () async {
      // Verify method accepts all documented parameters
      try {
        await service.authenticate(
          localizedFallbackTitle: 'Use PIN',
          androidSignInTitle: 'Sign In',
          androidCancelButton: 'Cancel',
          androidGoToSettingsDescription: 'Setup biometrics',
          biometricOnly: true,
          stickyAuth: false,
        );
      } catch (e) {
        // Expected to potentially fail on unsupported platforms
        // We're just testing that parameters are accepted
        expect(e, isA<BiometricException>());
      }
    });

    test('should throw BiometricException on unsupported platform', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      expect(
        () async => await service.authenticate(),
        throwsA(isA<BiometricException>()),
      );

      debugDefaultTargetPlatformOverride = null;
    });
  });

  group('BiometricSettings JSON Serialization', () {
    test('should serialize all biometric types correctly', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [
          BiometricType.face,
          BiometricType.fingerprint,
          BiometricType.iris,
          BiometricType.voice,
        ],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      final json = settings.toJson();

      expect(json['availableTypes'], contains('face'));
      expect(json['availableTypes'], contains('fingerprint'));
      expect(json['availableTypes'], contains('iris'));
      expect(json['availableTypes'], contains('voice'));
    });

    test('should serialize all platform support levels', () {
      const noneSettings = BiometricSettings(
        isAvailable: false,
        availableTypes: [],
        isStrongSupported: false,
        platformSupport: BiometricPlatformSupport.none,
      );
      expect(noneSettings.toJson()['platformSupport'], equals('none'));

      const limitedSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [],
        isStrongSupported: false,
        platformSupport: BiometricPlatformSupport.limited,
      );
      expect(limitedSettings.toJson()['platformSupport'], equals('limited'));

      const fullSettings = BiometricSettings(
        isAvailable: true,
        availableTypes: [],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );
      expect(fullSettings.toJson()['platformSupport'], equals('full'));
    });
  });

  group('BiometricSettings Edge Cases', () {
    test('should handle empty available types list', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [],
        isStrongSupported: false,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.availableTypes.isEmpty, isTrue);
      expect(settings.hasType(BiometricType.face), isFalse);
      expect(settings.description, equals('Biometric authentication available'));
    });

    test('should handle duplicate types in list', () {
      const settings = BiometricSettings(
        isAvailable: true,
        availableTypes: [
          BiometricType.face,
          BiometricType.face,
          BiometricType.fingerprint,
        ],
        isStrongSupported: true,
        platformSupport: BiometricPlatformSupport.full,
      );

      expect(settings.availableTypes.length, equals(3));
      expect(settings.hasType(BiometricType.face), isTrue);
    });
  });
}
