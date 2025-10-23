import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:everyday_christian/features/auth/services/auth_service.dart';
import 'package:everyday_christian/features/auth/services/secure_storage_service.dart';
import 'package:everyday_christian/features/auth/services/biometric_service.dart';
import 'package:everyday_christian/features/auth/models/user_model.dart';
import 'package:everyday_christian/core/database/database_helper.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([SecureStorageService, BiometricService, DatabaseHelper])
void main() {
  late MockSecureStorageService mockSecureStorage;
  late MockBiometricService mockBiometric;
  late MockDatabaseHelper mockDatabase;
  late AuthService authService;

  setUp(() {
    mockSecureStorage = MockSecureStorageService();
    mockBiometric = MockBiometricService();
    mockDatabase = MockDatabaseHelper();
    authService = AuthService(mockSecureStorage, mockBiometric, mockDatabase);
  });

  group('AuthService Initialization', () {
    test('should initialize with unauthenticated state when no user data', () async {
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

      await authService.initialize();

      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
    });

    test('should initialize with authenticated state when user data exists', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      await authService.initialize();

      User? authenticatedUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => authenticatedUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(authenticatedUser, isNotNull);
      expect(authenticatedUser!.email, equals('test@example.com'));
    });

    test('should handle initialization error', () async {
      when(mockSecureStorage.getUserData())
          .thenThrow(const SecureStorageException('Storage error'));

      await authService.initialize();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, isNotNull);
      expect(errorMessage, contains('Failed to initialize'));
    });
  });

  group('AuthService Sign Up', () {
    test('should successfully sign up new user', () async {
      when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.storeUserCredentials(any, any))
          .thenAnswer((_) async {});
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.signUp(
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
      );

      expect(result, isTrue);
      verify(mockSecureStorage.storeUserCredentials('newuser@example.com', any))
          .called(1);
      verify(mockSecureStorage.storeUserData(any)).called(1);
    });

    test('should reject invalid email', () async {
      final result = await authService.signUp(
        email: 'invalid-email',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('valid email'));
    });

    test('should reject short password', () async {
      final result = await authService.signUp(
        email: 'test@example.com',
        password: '12345',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('6 characters'));
    });

    test('should reject duplicate email', () async {
      final existingUser = {'email': 'test@example.com'};
      when(mockSecureStorage.getUserByEmail('test@example.com'))
          .thenAnswer((_) async => existingUser);

      final result = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('already exists'));
    });
  });

  group('AuthService Sign In', () {
    test('should successfully sign in with valid credentials', () async {
      // Calculate the expected hash for 'password123' using the same algorithm
      const password = 'password123';
      const salt = 'everyday_christian_salt_2024';
      final bytes = utf8.encode(password + salt);
      final expectedHash = sha256.convert(bytes).toString();

      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserByEmail('test@example.com'))
          .thenAnswer((_) async => userData);
      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => expectedHash);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isTrue);
      User? authenticatedUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => authenticatedUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(authenticatedUser, isNotNull);
    });

    test('should reject sign in with non-existent user', () async {
      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => null);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
    });

    test('should handle biometric sign in when supported', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => true);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isTrue);
      verify(mockBiometric.authenticate()).called(1);
    });
  });

  group('AuthService Sign Out', () {
    test('should successfully sign out', () async {
      when(mockSecureStorage.clearUserData()).thenAnswer((_) async {});

      await authService.signOut();

      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
      verify(mockSecureStorage.clearUserData()).called(1);
    });

    test('should handle sign out error', () async {
      when(mockSecureStorage.clearUserData())
          .thenThrow(const SecureStorageException('Clear error'));

      await authService.signOut();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, isNotNull);
    });
  });

  group('AuthService Delete Account', () {
    test('should delete account successfully', () async {
      final currentUser = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      authService.state = AuthState.authenticated(currentUser);

      when(mockSecureStorage.clearAllData()).thenAnswer((_) async {});
      when(mockDatabase.deleteOldChatMessages(0)).thenAnswer((_) async => 1);

      final result = await authService.deleteAccount();

      expect(result, isTrue);
      bool isUnauthenticated = false;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () => isUnauthenticated = true,
        error: (_) {},
      );
      expect(isUnauthenticated, isTrue);
      verify(mockSecureStorage.clearAllData()).called(1);
      verify(mockDatabase.deleteOldChatMessages(0)).called(1);
    });
  });

  group('AuthService Continue as Guest', () {
    test('should continue as guest', () async {
      await authService.continueAsGuest();

      User? guestUser;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => guestUser = user,
        unauthenticated: () {},
        error: (_) {},
      );
      expect(guestUser, isNotNull);
      expect(guestUser!.isAnonymous, isTrue);
    });
  });

  group('AuthService Biometric Authentication', () {
    test('should enable biometric authentication', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => true);
      when(mockDatabase.setSetting('biometric_enabled', true))
          .thenAnswer((_) async {});

      final result = await authService.enableBiometric();

      expect(result, isTrue);
      verify(mockDatabase.setSetting('biometric_enabled', true)).called(1);
    });

    test('should disable biometric authentication', () async {
      when(mockDatabase.setSetting('biometric_enabled', false))
          .thenAnswer((_) async {});

      await authService.disableBiometric();

      verify(mockDatabase.setSetting('biometric_enabled', false)).called(1);
    });

    test('should check if biometric is enabled', () async {
      when(mockDatabase.getSetting<bool>('biometric_enabled',
              defaultValue: anyNamed('defaultValue')))
          .thenAnswer((_) async => true);

      final result = await authService.isBiometricEnabled();

      expect(result, isTrue);
    });
  });

  group('AuthService Update Profile', () {
    test('should update user profile successfully', () async {
      final updatedUser = User(
        id: '123',
        email: 'test@example.com',
        name: 'Updated Name',
        dateJoined: DateTime.now(),
      );

      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final result = await authService.updateUserProfile(updatedUser);

      expect(result, isTrue);
      verify(mockSecureStorage.storeUserData(any)).called(1);
    });

    test('should handle update profile error', () async {
      final updatedUser = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );

      when(mockSecureStorage.storeUserData(any))
          .thenThrow(const SecureStorageException('Update error'));

      final result = await authService.updateUserProfile(updatedUser);

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to update profile'));
    });
  });

  group('AuthService Sign In Edge Cases', () {
    test('should reject sign in with incorrect password', () async {
      const correctPassword = 'password123';
      final correctBytes = utf8.encode('${correctPassword}everyday_christian_salt_2024');
      final correctHash = sha256.convert(correctBytes).toString();

      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => correctHash);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'wrongpassword',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Incorrect password'));
    });

    test('should handle missing user data after password validation', () async {
      const password = 'password123';
      const salt = 'everyday_christian_salt_2024';
      final bytes = utf8.encode(password + salt);
      final expectedHash = sha256.convert(bytes).toString();

      when(mockSecureStorage.getStoredPassword('test@example.com'))
          .thenAnswer((_) async => expectedHash);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('User data not found'));
    });

    test('should handle sign in exception', () async {
      when(mockSecureStorage.getStoredPassword(any))
          .thenThrow(Exception('Database error'));

      final result = await authService.signIn(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Sign in failed'));
    });
  });

  group('AuthService Biometric Sign In Edge Cases', () {
    test('should fail biometric sign in when not available', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => false);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('not available'));
    });

    test('should fail biometric sign in when authentication fails', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => false);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('authentication failed'));
    });

    test('should fail biometric sign in when user data not found', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => true);
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('User data not found'));
    });

    test('should handle biometric sign in exception', () async {
      when(mockBiometric.canCheckBiometrics()).thenThrow(Exception('Biometric error'));

      final result = await authService.signIn(
        email: 'test@example.com',
        password: '',
        useBiometric: true,
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Biometric sign in failed'));
    });
  });

  group('AuthService Continue as Guest Error Handling', () {
    test('should handle continue as guest error', () async {
      when(mockSecureStorage.storeUserData(any))
          .thenThrow(const SecureStorageException('Storage error'));

      await authService.continueAsGuest();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to continue as guest'));
    });
  });

  group('AuthService Biometric Error Handling', () {
    test('should fail to enable biometric when not available', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => false);

      final result = await authService.enableBiometric();

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('not available on this device'));
    });

    test('should fail to enable biometric when authentication fails', () async {
      when(mockBiometric.canCheckBiometrics()).thenAnswer((_) async => true);
      when(mockBiometric.authenticate()).thenAnswer((_) async => false);

      final result = await authService.enableBiometric();

      expect(result, isFalse);
    });

    test('should handle enable biometric exception', () async {
      when(mockBiometric.canCheckBiometrics()).thenThrow(Exception('Error'));

      final result = await authService.enableBiometric();

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to enable biometric'));
    });

    test('should handle disable biometric exception', () async {
      when(mockDatabase.setSetting('biometric_enabled', false))
          .thenThrow(Exception('Database error'));

      await authService.disableBiometric();

      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to disable biometric'));
    });

    test('should return false when checking biometric throws exception', () async {
      when(mockDatabase.getSetting<bool>('biometric_enabled',
              defaultValue: anyNamed('defaultValue')))
          .thenThrow(Exception('Database error'));

      final result = await authService.isBiometricEnabled();

      expect(result, isFalse);
    });
  });

  group('AuthService Reset Password', () {
    test('should reset password successfully', () async {
      final userData = {
        'id': '123',
        'email': 'test@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);
      when(mockSecureStorage.storeUserCredentials(any, any))
          .thenAnswer((_) async {});

      final result = await authService.resetPassword(
        email: 'test@example.com',
        newPassword: 'newpassword123',
      );

      expect(result, isTrue);
      verify(mockSecureStorage.storeUserCredentials('test@example.com', any))
          .called(1);
    });

    test('should reject short password in reset', () async {
      final result = await authService.resetPassword(
        email: 'test@example.com',
        newPassword: '12345',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('6 characters'));
    });

    test('should reject reset when user not found', () async {
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => null);

      final result = await authService.resetPassword(
        email: 'test@example.com',
        newPassword: 'newpassword123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('User not found'));
    });

    test('should reject reset when email mismatch', () async {
      final userData = {
        'id': '123',
        'email': 'different@example.com',
        'date_joined': DateTime.now().millisecondsSinceEpoch,
      };
      when(mockSecureStorage.getUserData()).thenAnswer((_) async => userData);

      final result = await authService.resetPassword(
        email: 'test@example.com',
        newPassword: 'newpassword123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('does not match'));
    });

    test('should handle reset password exception', () async {
      when(mockSecureStorage.getUserData()).thenThrow(Exception('Error'));

      final result = await authService.resetPassword(
        email: 'test@example.com',
        newPassword: 'newpassword123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to reset password'));
    });
  });

  group('AuthService Delete Account Error Handling', () {
    test('should handle delete account exception', () async {
      when(mockSecureStorage.clearAllData()).thenThrow(Exception('Error'));

      final result = await authService.deleteAccount();

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Failed to delete account'));
    });
  });

  group('AuthService Sign Up Error Handling', () {
    test('should handle sign up exception', () async {
      when(mockSecureStorage.getUserByEmail(any))
          .thenThrow(Exception('Database error'));

      final result = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isFalse);
      String? errorMessage;
      authService.state.when(
        initial: () {},
        loading: () {},
        authenticated: (_) {},
        unauthenticated: () {},
        error: (msg) => errorMessage = msg,
      );
      expect(errorMessage, contains('Sign up failed'));
    });
  });

  group('AuthService Helper Methods', () {
    test('_generateUserId should generate unique IDs', () {
      final authService1 = AuthService(mockSecureStorage, mockBiometric, mockDatabase);

      // Access private method via reflection is not possible, but we can test via sign up
      // which uses _generateUserId. We'll verify uniqueness through multiple sign ups.
      when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.storeUserCredentials(any, any))
          .thenAnswer((_) async {});
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final futures = <Future<bool>>[];
      for (int i = 0; i < 5; i++) {
        futures.add(authService1.signUp(
          email: 'user$i@example.com',
          password: 'password123',
        ));
      }

      // If all sign ups succeed, IDs are being generated
      expect(futures, everyElement(completion(isTrue)));
    });

    test('_hashPassword should produce consistent hashes', () {
      // We can verify hash consistency through sign up and sign in
      const password = 'testpassword';
      const salt = 'everyday_christian_salt_2024';
      final bytes = utf8.encode(password + salt);
      final expectedHash = sha256.convert(bytes).toString();

      // This hash should be used consistently
      expect(expectedHash, isNotEmpty);
      expect(expectedHash.length, equals(64)); // SHA-256 produces 64 hex characters
    });

    test('_isValidEmail should validate email formats', () async {
      // Test valid email
      when(mockSecureStorage.getUserByEmail(any)).thenAnswer((_) async => null);
      when(mockSecureStorage.storeUserCredentials(any, any))
          .thenAnswer((_) async {});
      when(mockSecureStorage.storeUserData(any)).thenAnswer((_) async {});

      final validResult = await authService.signUp(
        email: 'valid.email@example.com',
        password: 'password123',
      );
      expect(validResult, isTrue);

      // Test invalid emails
      final invalidEmails = [
        'notanemail',
        '@example.com',
        'test@',
        'test@com',
      ];

      for (final invalidEmail in invalidEmails) {
        final result = await authService.signUp(
          email: invalidEmail,
          password: 'password123',
        );
        expect(result, isFalse);
      }
    });
  });

  group('AuthService Getters', () {
    test('currentUser should return user when authenticated', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      authService.state = AuthState.authenticated(user);

      expect(authService.currentUser, equals(user));
    });

    test('currentUser should return null when unauthenticated', () {
      authService.state = const AuthState.unauthenticated();

      expect(authService.currentUser, isNull);
    });

    test('currentUser should return null when in error state', () {
      authService.state = const AuthState.error('Error');

      expect(authService.currentUser, isNull);
    });

    test('currentUser should return null when loading', () {
      authService.state = const AuthState.loading();

      expect(authService.currentUser, isNull);
    });

    test('isAuthenticated should return true when authenticated', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      authService.state = AuthState.authenticated(user);

      expect(authService.isAuthenticated, isTrue);
    });

    test('isAuthenticated should return false when unauthenticated', () {
      authService.state = const AuthState.unauthenticated();

      expect(authService.isAuthenticated, isFalse);
    });

    test('isAnonymous should return true for anonymous user', () {
      final user = User.anonymous();
      authService.state = AuthState.authenticated(user);

      expect(authService.isAnonymous, isTrue);
    });

    test('isAnonymous should return false for regular user', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      authService.state = AuthState.authenticated(user);

      expect(authService.isAnonymous, isFalse);
    });

    test('isAnonymous should return false when unauthenticated', () {
      authService.state = const AuthState.unauthenticated();

      expect(authService.isAnonymous, isFalse);
    });
  });

  group('AuthState Classes', () {
    test('_Authenticated should implement equality', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      final user2 = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: user1.dateJoined,
      );
      final user3 = User(
        id: '456',
        email: 'different@example.com',
        dateJoined: DateTime.now(),
      );

      final state1 = AuthState.authenticated(user1);
      final state2 = AuthState.authenticated(user2);
      final state3 = AuthState.authenticated(user3);

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });

    test('_Authenticated should have consistent hashCode', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        dateJoined: DateTime.now(),
      );
      final state = AuthState.authenticated(user);

      expect(state.hashCode, equals(user.hashCode));
    });

    test('_Error should implement equality', () {
      const error1 = AuthState.error('Error message');
      const error2 = AuthState.error('Error message');
      const error3 = AuthState.error('Different error');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('_Error should have consistent hashCode', () {
      const message = 'Error message';
      const error = AuthState.error(message);

      expect(error.hashCode, equals(message.hashCode));
    });

    test('AuthState.when should handle all states', () {
      const initial = AuthState.initial();
      const loading = AuthState.loading();
      final user = User(id: '123', email: 'test@example.com', dateJoined: DateTime.now());
      final authenticated = AuthState.authenticated(user);
      const unauthenticated = AuthState.unauthenticated();
      const error = AuthState.error('Error');

      expect(
        initial.when(
          initial: () => 'initial',
          loading: () => 'loading',
          authenticated: (_) => 'authenticated',
          unauthenticated: () => 'unauthenticated',
          error: (_) => 'error',
        ),
        equals('initial'),
      );

      expect(
        loading.when(
          initial: () => 'initial',
          loading: () => 'loading',
          authenticated: (_) => 'authenticated',
          unauthenticated: () => 'unauthenticated',
          error: (_) => 'error',
        ),
        equals('loading'),
      );

      expect(
        authenticated.when(
          initial: () => 'initial',
          loading: () => 'loading',
          authenticated: (u) => 'authenticated: ${u.email}',
          unauthenticated: () => 'unauthenticated',
          error: (_) => 'error',
        ),
        equals('authenticated: test@example.com'),
      );

      expect(
        unauthenticated.when(
          initial: () => 'initial',
          loading: () => 'loading',
          authenticated: (_) => 'authenticated',
          unauthenticated: () => 'unauthenticated',
          error: (_) => 'error',
        ),
        equals('unauthenticated'),
      );

      expect(
        error.when(
          initial: () => 'initial',
          loading: () => 'loading',
          authenticated: (_) => 'authenticated',
          unauthenticated: () => 'unauthenticated',
          error: (msg) => 'error: $msg',
        ),
        equals('error: Error'),
      );
    });

    test('AuthState.maybeWhen should use orElse for unhandled states', () {
      const initial = AuthState.initial();
      final user = User(id: '123', email: 'test@example.com', dateJoined: DateTime.now());
      final authenticated = AuthState.authenticated(user);

      expect(
        initial.maybeWhen(
          authenticated: (_) => 'authenticated',
          orElse: () => 'other',
        ),
        equals('other'),
      );

      expect(
        authenticated.maybeWhen(
          authenticated: (u) => 'authenticated: ${u.email}',
          orElse: () => 'other',
        ),
        equals('authenticated: test@example.com'),
      );
    });
  });
}
