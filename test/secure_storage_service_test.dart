import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:everyday_christian/features/auth/services/secure_storage_service.dart';

import 'secure_storage_service_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService - User Data', () {
    test('storeUserData should encode and store user data successfully', () async {
      final userData = {'id': '123', 'name': 'John Doe', 'email': 'john@example.com'};

      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeUserData(userData);

      final captured = verify(mockStorage.write(
        key: 'user_data',
        value: captureAnyNamed('value'),
      )).captured.single as String;

      expect(jsonDecode(captured), equals(userData));
    });

    test('storeUserData should throw SecureStorageException on error', () async {
      final userData = {'id': '123'};

      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Storage error'));

      expect(
        () => service.storeUserData(userData),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('getUserData should return decoded user data when exists', () async {
      final userData = {'id': '123', 'name': 'Jane Doe'};
      final jsonString = jsonEncode(userData);

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => jsonString);

      final result = await service.getUserData();

      expect(result, equals(userData));
    });

    test('getUserData should return null when no data exists', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => null);

      final result = await service.getUserData();

      expect(result, isNull);
    });

    test('getUserData should throw SecureStorageException on decode error', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => 'invalid json');

      expect(
        () => service.getUserData(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('getUserData should throw SecureStorageException on read error', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenThrow(Exception('Read error'));

      expect(
        () => service.getUserData(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('hasUserData should return true when data exists', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => '{"id":"123"}');

      final result = await service.hasUserData();

      expect(result, isTrue);
    });

    test('hasUserData should return false when no data exists', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => null);

      final result = await service.hasUserData();

      expect(result, isFalse);
    });

    test('hasUserData should return false on error', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenThrow(Exception('Read error'));

      final result = await service.hasUserData();

      expect(result, isFalse);
    });
  });

  group('SecureStorageService - Credentials', () {
    test('storeUserCredentials should store credentials with timestamp', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeUserCredentials('test@example.com', 'hashed_password');

      final captured = verify(mockStorage.write(
        key: 'user_credentials',
        value: captureAnyNamed('value'),
      )).captured.single as String;

      final credentials = jsonDecode(captured) as Map<String, dynamic>;
      expect(credentials['email'], equals('test@example.com'));
      expect(credentials['password_hash'], equals('hashed_password'));
      expect(credentials['created_at'], isA<int>());
    });

    test('storeUserCredentials should throw SecureStorageException on error', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Write error'));

      expect(
        () => service.storeUserCredentials('test@example.com', 'hash'),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('getStoredPassword should return password hash for matching email', () async {
      final credentials = {
        'email': 'test@example.com',
        'password_hash': 'stored_hash',
        'created_at': 12345,
      };

      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => jsonEncode(credentials));

      final result = await service.getStoredPassword('test@example.com');

      expect(result, equals('stored_hash'));
    });

    test('getStoredPassword should return null when no credentials exist', () async {
      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => null);

      final result = await service.getStoredPassword('test@example.com');

      expect(result, isNull);
    });

    test('getStoredPassword should return null for non-matching email', () async {
      final credentials = {
        'email': 'other@example.com',
        'password_hash': 'stored_hash',
        'created_at': 12345,
      };

      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => jsonEncode(credentials));

      final result = await service.getStoredPassword('test@example.com');

      expect(result, isNull);
    });

    test('getStoredPassword should throw SecureStorageException on error', () async {
      when(mockStorage.read(key: 'user_credentials'))
          .thenThrow(Exception('Read error'));

      expect(
        () => service.getStoredPassword('test@example.com'),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('hasCredentials should return true when credentials exist', () async {
      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => '{"email":"test@example.com"}');

      final result = await service.hasCredentials();

      expect(result, isTrue);
    });

    test('hasCredentials should return false when no credentials exist', () async {
      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => null);

      final result = await service.hasCredentials();

      expect(result, isFalse);
    });

    test('hasCredentials should return false on error', () async {
      when(mockStorage.read(key: 'user_credentials'))
          .thenThrow(Exception('Read error'));

      final result = await service.hasCredentials();

      expect(result, isFalse);
    });
  });

  group('SecureStorageService - User by Email', () {
    test('getUserByEmail should return user data for matching email', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'name': 'John Doe',
      };

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => jsonEncode(userData));

      final result = await service.getUserByEmail('test@example.com');

      expect(result, equals(userData));
    });

    test('getUserByEmail should return null when no user data exists', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => null);

      final result = await service.getUserByEmail('test@example.com');

      expect(result, isNull);
    });

    test('getUserByEmail should return null for non-matching email', () async {
      final userData = {
        'id': '123',
        'email': 'other@example.com',
        'name': 'Jane Doe',
      };

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => jsonEncode(userData));

      final result = await service.getUserByEmail('test@example.com');

      expect(result, isNull);
    });

    test('getUserByEmail should throw SecureStorageException on error', () async {
      when(mockStorage.read(key: 'user_data'))
          .thenThrow(Exception('Read error'));

      expect(
        () => service.getUserByEmail('test@example.com'),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('SecureStorageService - Biometric', () {
    test('setBiometricEnabled should store true as string', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.setBiometricEnabled(true);

      verify(mockStorage.write(
        key: 'biometric_enabled',
        value: 'true',
      )).called(1);
    });

    test('setBiometricEnabled should store false as string', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.setBiometricEnabled(false);

      verify(mockStorage.write(
        key: 'biometric_enabled',
        value: 'false',
      )).called(1);
    });

    test('setBiometricEnabled should throw SecureStorageException on error', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Write error'));

      expect(
        () => service.setBiometricEnabled(true),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('isBiometricEnabled should return true when value is "true"', () async {
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'true');

      final result = await service.isBiometricEnabled();

      expect(result, isTrue);
    });

    test('isBiometricEnabled should return true when value is "TRUE"', () async {
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'TRUE');

      final result = await service.isBiometricEnabled();

      expect(result, isTrue);
    });

    test('isBiometricEnabled should return false when value is "false"', () async {
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'false');

      final result = await service.isBiometricEnabled();

      expect(result, isFalse);
    });

    test('isBiometricEnabled should return false when value is null', () async {
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => null);

      final result = await service.isBiometricEnabled();

      expect(result, isFalse);
    });

    test('isBiometricEnabled should return false on error', () async {
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenThrow(Exception('Read error'));

      final result = await service.isBiometricEnabled();

      expect(result, isFalse);
    });
  });

  group('SecureStorageService - Last Login', () {
    test('setLastLogin should store current timestamp', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      final beforeTime = DateTime.now().millisecondsSinceEpoch;
      await service.setLastLogin();
      final afterTime = DateTime.now().millisecondsSinceEpoch;

      final captured = verify(mockStorage.write(
        key: 'last_login',
        value: captureAnyNamed('value'),
      )).captured.single as String;

      final timestamp = int.parse(captured);
      expect(timestamp, greaterThanOrEqualTo(beforeTime));
      expect(timestamp, lessThanOrEqualTo(afterTime));
    });

    test('setLastLogin should throw SecureStorageException on error', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Write error'));

      expect(
        () => service.setLastLogin(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('getLastLogin should return DateTime from stored timestamp', () async {
      final expectedTime = DateTime.now();
      final timestamp = expectedTime.millisecondsSinceEpoch.toString();

      when(mockStorage.read(key: 'last_login'))
          .thenAnswer((_) async => timestamp);

      final result = await service.getLastLogin();

      expect(result, isNotNull);
      expect(result!.millisecondsSinceEpoch, equals(expectedTime.millisecondsSinceEpoch));
    });

    test('getLastLogin should return null when no timestamp exists', () async {
      when(mockStorage.read(key: 'last_login'))
          .thenAnswer((_) async => null);

      final result = await service.getLastLogin();

      expect(result, isNull);
    });

    test('getLastLogin should return null for invalid timestamp string', () async {
      when(mockStorage.read(key: 'last_login'))
          .thenAnswer((_) async => 'invalid');

      final result = await service.getLastLogin();

      expect(result, isNull);
    });

    test('getLastLogin should return null on error', () async {
      when(mockStorage.read(key: 'last_login'))
          .thenThrow(Exception('Read error'));

      final result = await service.getLastLogin();

      expect(result, isNull);
    });
  });

  group('SecureStorageService - Session Token', () {
    test('storeSessionToken should store token successfully', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeSessionToken('abc123token');

      verify(mockStorage.write(
        key: 'session_token',
        value: 'abc123token',
      )).called(1);
    });

    test('storeSessionToken should throw SecureStorageException on error', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Write error'));

      expect(
        () => service.storeSessionToken('token'),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('getSessionToken should return stored token', () async {
      when(mockStorage.read(key: 'session_token'))
          .thenAnswer((_) async => 'stored_token');

      final result = await service.getSessionToken();

      expect(result, equals('stored_token'));
    });

    test('getSessionToken should return null when no token exists', () async {
      when(mockStorage.read(key: 'session_token'))
          .thenAnswer((_) async => null);

      final result = await service.getSessionToken();

      expect(result, isNull);
    });

    test('getSessionToken should return null on error', () async {
      when(mockStorage.read(key: 'session_token'))
          .thenThrow(Exception('Read error'));

      final result = await service.getSessionToken();

      expect(result, isNull);
    });
  });

  group('SecureStorageService - Clear Data', () {
    test('clearUserData should delete user data, session token, and last login', () async {
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      await service.clearUserData();

      verify(mockStorage.delete(key: 'user_data')).called(1);
      verify(mockStorage.delete(key: 'session_token')).called(1);
      verify(mockStorage.delete(key: 'last_login')).called(1);
    });

    test('clearUserData should throw SecureStorageException on error', () async {
      when(mockStorage.delete(key: anyNamed('key')))
          .thenThrow(Exception('Delete error'));

      expect(
        () => service.clearUserData(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('clearCredentials should delete credentials', () async {
      when(mockStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async => {});

      await service.clearCredentials();

      verify(mockStorage.delete(key: 'user_credentials')).called(1);
    });

    test('clearCredentials should throw SecureStorageException on error', () async {
      when(mockStorage.delete(key: anyNamed('key')))
          .thenThrow(Exception('Delete error'));

      expect(
        () => service.clearCredentials(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('clearAllData should delete all stored data', () async {
      when(mockStorage.deleteAll())
          .thenAnswer((_) async => {});

      await service.clearAllData();

      verify(mockStorage.deleteAll()).called(1);
    });

    test('clearAllData should throw SecureStorageException on error', () async {
      when(mockStorage.deleteAll())
          .thenThrow(Exception('Delete error'));

      expect(
        () => service.clearAllData(),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('SecureStorageService - Storage Keys', () {
    test('getAllKeys should return list of all stored keys', () async {
      final mockData = {
        'user_data': '{}',
        'user_credentials': '{}',
        'session_token': 'abc',
      };

      when(mockStorage.readAll())
          .thenAnswer((_) async => mockData);

      final result = await service.getAllKeys();

      expect(result, containsAll(['user_data', 'user_credentials', 'session_token']));
      expect(result.length, equals(3));
    });

    test('getAllKeys should return empty list when no data exists', () async {
      when(mockStorage.readAll())
          .thenAnswer((_) async => {});

      final result = await service.getAllKeys();

      expect(result, isEmpty);
    });

    test('getAllKeys should return empty list on error', () async {
      when(mockStorage.readAll())
          .thenThrow(Exception('Read error'));

      final result = await service.getAllKeys();

      expect(result, isEmpty);
    });
  });

  group('SecureStorageService - Health Check', () {
    test('checkHealth should return healthy status with all data', () async {
      final userData = jsonEncode({'id': '123'});
      final credentials = jsonEncode({'email': 'test@example.com'});
      final lastLoginTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => userData);
      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => credentials);
      when(mockStorage.read(key: 'last_login'))
          .thenAnswer((_) async => lastLoginTimestamp);
      when(mockStorage.read(key: 'biometric_enabled'))
          .thenAnswer((_) async => 'true');

      final result = await service.checkHealth();

      expect(result.isHealthy, isTrue);
      expect(result.hasUserData, isTrue);
      expect(result.hasCredentials, isTrue);
      expect(result.biometricEnabled, isTrue);
      expect(result.lastLogin, isNotNull);
      expect(result.error, isNull);
    });

    test('checkHealth should return healthy status with no data', () async {
      when(mockStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);

      final result = await service.checkHealth();

      expect(result.isHealthy, isTrue);
      expect(result.hasUserData, isFalse);
      expect(result.hasCredentials, isFalse);
      expect(result.biometricEnabled, isFalse);
      expect(result.lastLogin, isNull);
      expect(result.error, isNull);
    });

    test('checkHealth should return healthy with false values on storage errors', () async {
      // When storage methods throw errors, they're caught by the individual methods
      // which return false/null, so health check completes successfully
      when(mockStorage.read(key: anyNamed('key')))
          .thenThrow(Exception('Storage error'));

      final result = await service.checkHealth();

      // The health check itself succeeds, but all values are false/null
      expect(result.isHealthy, isTrue);
      expect(result.hasUserData, isFalse);
      expect(result.hasCredentials, isFalse);
      expect(result.biometricEnabled, isFalse);
      expect(result.lastLogin, isNull);
      expect(result.error, isNull);
    });
  });

  group('SecureStorageService - Data Export/Import', () {
    test('exportData should return JSON string of all data', () async {
      final mockData = {
        'user_data': '{"id":"123"}',
        'session_token': 'abc123',
        'biometric_enabled': 'true',
      };

      when(mockStorage.readAll())
          .thenAnswer((_) async => mockData);

      final result = await service.exportData();

      expect(result, isNotNull);
      final decoded = jsonDecode(result!);
      expect(decoded, equals(mockData));
    });

    test('exportData should throw SecureStorageException on error', () async {
      when(mockStorage.readAll())
          .thenThrow(Exception('Read error'));

      expect(
        () => service.exportData(),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('importData should clear and restore all data', () async {
      final exportedData = jsonEncode({
        'user_data': '{"id":"123"}',
        'session_token': 'abc123',
      });

      when(mockStorage.deleteAll())
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.importData(exportedData);

      verify(mockStorage.deleteAll()).called(1);
      verify(mockStorage.write(key: 'user_data', value: '{"id":"123"}')).called(1);
      verify(mockStorage.write(key: 'session_token', value: 'abc123')).called(1);
    });

    test('importData should throw SecureStorageException on invalid JSON', () async {
      when(mockStorage.deleteAll())
          .thenAnswer((_) async => {});

      expect(
        () => service.importData('invalid json'),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('importData should throw SecureStorageException on clear error', () async {
      when(mockStorage.deleteAll())
          .thenThrow(Exception('Delete error'));

      expect(
        () => service.importData('{"key":"value"}'),
        throwsA(isA<SecureStorageException>()),
      );
    });

    test('importData should throw SecureStorageException on write error', () async {
      final exportedData = jsonEncode({'key': 'value'});

      when(mockStorage.deleteAll())
          .thenAnswer((_) async => {});
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenThrow(Exception('Write error'));

      expect(
        () => service.importData(exportedData),
        throwsA(isA<SecureStorageException>()),
      );
    });
  });

  group('StorageHealthCheck Model', () {
    test('should create health check with all properties', () {
      final now = DateTime.now();
      final health = StorageHealthCheck(
        hasUserData: true,
        hasCredentials: true,
        lastLogin: now,
        biometricEnabled: true,
        isHealthy: true,
      );

      expect(health.hasUserData, isTrue);
      expect(health.hasCredentials, isTrue);
      expect(health.lastLogin, equals(now));
      expect(health.biometricEnabled, isTrue);
      expect(health.isHealthy, isTrue);
      expect(health.error, isNull);
    });

    test('should create unhealthy check with error', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: false,
        error: 'Storage failure',
      );

      expect(health.isHealthy, isFalse);
      expect(health.hasUserData, isFalse);
      expect(health.hasCredentials, isFalse);
      expect(health.biometricEnabled, isFalse);
      expect(health.lastLogin, isNull);
      expect(health.error, equals('Storage failure'));
    });

    test('should generate empty summary when no data stored', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: true,
      );

      expect(health.summary, equals('No data stored'));
    });

    test('should generate summary with user data', () {
      const health = StorageHealthCheck(
        hasUserData: true,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: true,
      );

      expect(health.summary, contains('User data ✓'));
      expect(health.summary, isNot(contains('Credentials ✓')));
    });

    test('should generate summary with credentials', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: true,
        biometricEnabled: false,
        isHealthy: true,
      );

      expect(health.summary, contains('Credentials ✓'));
      expect(health.summary, isNot(contains('User data ✓')));
    });

    test('should generate summary with biometric enabled', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: true,
        isHealthy: true,
      );

      expect(health.summary, contains('Biometric ✓'));
    });

    test('should generate summary with last login days', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: true,
        lastLogin: threeDaysAgo,
      );

      expect(health.summary, contains('Last login: 3d ago'));
    });

    test('should generate summary with all features', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final health = StorageHealthCheck(
        hasUserData: true,
        hasCredentials: true,
        biometricEnabled: true,
        isHealthy: true,
        lastLogin: yesterday,
      );

      expect(health.summary, contains('User data ✓'));
      expect(health.summary, contains('Credentials ✓'));
      expect(health.summary, contains('Biometric ✓'));
      expect(health.summary, contains('Last login: 1d ago'));
    });

    test('should generate unhealthy summary with error', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: false,
        error: 'Database corruption',
      );

      expect(health.summary, equals('Storage unhealthy: Database corruption'));
    });

    test('should generate unhealthy summary with unknown error', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: false,
      );

      expect(health.summary, equals('Storage unhealthy: Unknown error'));
    });

    test('should generate toString representation', () {
      const health = StorageHealthCheck(
        hasUserData: true,
        hasCredentials: false,
        biometricEnabled: true,
        isHealthy: true,
        error: null,
      );

      final string = health.toString();
      expect(string, contains('StorageHealthCheck'));
      expect(string, contains('healthy: true'));
      expect(string, contains('userData: true'));
      expect(string, contains('credentials: false'));
      expect(string, contains('biometric: true'));
      expect(string, contains('error: null'));
    });

    test('should include error in toString when present', () {
      const health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: false,
        error: 'Test error',
      );

      final string = health.toString();
      expect(string, contains('error: Test error'));
    });

    test('should handle same-day login in summary', () {
      final now = DateTime.now();
      final health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: true,
        lastLogin: now,
      );

      expect(health.summary, contains('Last login: 0d ago'));
    });

    test('should handle old login in summary', () {
      final longAgo = DateTime.now().subtract(const Duration(days: 365));
      final health = StorageHealthCheck(
        hasUserData: false,
        hasCredentials: false,
        biometricEnabled: false,
        isHealthy: true,
        lastLogin: longAgo,
      );

      expect(health.summary, contains('Last login: 365d ago'));
    });
  });

  group('SecureStorageException', () {
    test('should create exception with message', () {
      const exception = SecureStorageException('Test error');

      expect(exception.message, equals('Test error'));
    });

    test('should generate toString with message', () {
      const exception = SecureStorageException('Test error');

      expect(exception.toString(), equals('SecureStorageException: Test error'));
    });

    test('should handle empty message', () {
      const exception = SecureStorageException('');

      expect(exception.message, equals(''));
      expect(exception.toString(), equals('SecureStorageException: '));
    });

    test('should handle long message', () {
      final longMessage = 'Error: ' * 100;
      final exception = SecureStorageException(longMessage);

      expect(exception.message, equals(longMessage));
      expect(exception.toString(), contains('SecureStorageException'));
    });

    test('should handle special characters in message', () {
      const exception = SecureStorageException('Error with special chars: \$@#%&*');

      expect(exception.message, contains('\$@#%&*'));
    });

    test('should implement Exception interface', () {
      const exception = SecureStorageException('Test');

      expect(exception, isA<Exception>());
    });
  });

  group('SecureStorageService - Edge Cases', () {
    test('should handle empty user data map', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeUserData({});

      final captured = verify(mockStorage.write(
        key: 'user_data',
        value: captureAnyNamed('value'),
      )).captured.single as String;

      expect(jsonDecode(captured), equals({}));
    });

    test('should handle user data with nested objects', () async {
      final complexData = {
        'id': '123',
        'profile': {
          'name': 'John',
          'settings': {'theme': 'dark', 'notifications': true}
        },
        'tags': ['user', 'premium']
      };

      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeUserData(complexData);

      final captured = verify(mockStorage.write(
        key: 'user_data',
        value: captureAnyNamed('value'),
      )).captured.single as String;

      expect(jsonDecode(captured), equals(complexData));
    });

    test('should handle empty email in getUserByEmail', () async {
      final userData = {'id': '123', 'email': ''};

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => jsonEncode(userData));

      final result = await service.getUserByEmail('');

      expect(result, equals(userData));
    });

    test('should handle empty session token', () async {
      when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async => {});

      await service.storeSessionToken('');

      verify(mockStorage.write(
        key: 'session_token',
        value: '',
      )).called(1);
    });

    test('should handle import with empty data object', () async {
      when(mockStorage.deleteAll())
          .thenAnswer((_) async => {});

      await service.importData('{}');

      verify(mockStorage.deleteAll()).called(1);
      verifyNever(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')));
    });

    test('should handle credentials without password_hash field', () async {
      final credentials = {
        'email': 'test@example.com',
        'created_at': 12345,
      };

      when(mockStorage.read(key: 'user_credentials'))
          .thenAnswer((_) async => jsonEncode(credentials));

      final result = await service.getStoredPassword('test@example.com');

      expect(result, isNull);
    });

    test('should handle user data without email field', () async {
      final userData = {'id': '123', 'name': 'John'};

      when(mockStorage.read(key: 'user_data'))
          .thenAnswer((_) async => jsonEncode(userData));

      final result = await service.getUserByEmail('test@example.com');

      expect(result, isNull);
    });
  });
}
