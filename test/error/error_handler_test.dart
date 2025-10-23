import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/error/error_handler.dart';
import 'package:everyday_christian/core/error/app_error.dart';

void main() {
  group('ErrorHandler', () {
    test('should handle SocketException as network error', () {
      const exception = SocketException('No network');
      final error = ErrorHandler.handle(exception);

      expect(error, isA<NetworkError>());
      error.when(
        network: (message, details, _) {
          expect(message, 'No internet connection');
          expect(error.userMessage, 'No internet connection. Please check your network settings.');
        },
        database: (_, __, ___, ____, _____) => fail('Expected NetworkError'),
        validation: (_, __, ___) => fail('Expected NetworkError'),
        permission: (_, __, ___) => fail('Expected NetworkError'),
        unknown: (_, __, ___) => fail('Expected NetworkError'),
        api: (_, __, ___, ____) => fail('Expected NetworkError'),
        ai: (_, __, ___, ____, _____) => fail('Expected NetworkError'),
        notification: (_, __, ___, ____) => fail('Expected NetworkError'),
        storage: (_, __, ___, ____) => fail('Expected NetworkError'),
        service: (_, __, ___, ____, _____) => fail('Expected NetworkError'),
      );
    });

    test('should handle DatabaseException as database error', () {
      // Create a mock database exception
      final error = ErrorHandler.handle(
        Exception('DatabaseException: Query failed'),
        context: 'test',
      );

      expect(error, isA<UnknownError>());
      error.when(
        network: (_, __, ___) {},
        database: (message, details, severity, _, __) {},
        validation: (_, __, ___) => fail('Expected DatabaseError'),
        permission: (_, __, ___) => fail('Expected DatabaseError'),
        unknown: (_, __, ___) => fail('Expected DatabaseError'),
        api: (_, __, ___, ____) => fail('Expected DatabaseError'),
        ai: (_, __, ___, ____, _____) => fail('Expected DatabaseError'),
        notification: (_, __, ___, ____) => fail('Expected DatabaseError'),
        storage: (_, __, ___, ____) => fail('Expected DatabaseError'),
        service: (_, __, ___, ____, _____) => fail('Expected DatabaseError'),
      );
    });

    test('should handle FormatException as validation error', () {
      const exception = FormatException('Invalid format');
      final error = ErrorHandler.handle(exception);

      expect(error, isA<ValidationError>());
      error.when(
        network: (_, __, ___) => fail('Expected ValidationError'),
        database: (_, __, ___, ____, _____) => fail('Expected ValidationError'),
        validation: (message, field, severity) {
          expect(message, 'Invalid data format');
          expect(severity, ErrorSeverity.warning);
        },
        permission: (_, __, ___) => fail('Expected ValidationError'),
        unknown: (_, __, ___) => fail('Expected ValidationError'),
        api: (_, __, ___, ____) => fail('Expected ValidationError'),
        ai: (_, __, ___, ____, _____) => fail('Expected ValidationError'),
        notification: (_, __, ___, ____) => fail('Expected ValidationError'),
        storage: (_, __, ___, ____) => fail('Expected ValidationError'),
        service: (_, __, ___, ____, _____) => fail('Expected ValidationError'),
      );
    });

    test('should detect out of memory errors', () {
      final exception = Exception('Out of memory error');
      final error = ErrorHandler.handle(exception);

      expect(error, isA<AIError>());
      error.when(
        network: (_, __, ___) => fail('Expected AIError'),
        database: (_, __, ___, ____, _____) => fail('Expected AIError'),
        validation: (_, __, ___) => fail('Expected AIError'),
        permission: (_, __, ___) => fail('Expected AIError'),
        unknown: (_, __, ___) => fail('Expected AIError'),
        api: (_, __, ___, ____) => fail('Expected AIError'),
        ai: (message, details, severity, modelPath, isOOM) {
          expect(message, 'Insufficient memory');
          expect(isOOM, true);
          expect(error.userMessage, contains('doesn\'t have enough memory'));
        },
        notification: (_, __, ___, ____) => fail('Expected AIError'),
        storage: (_, __, ___, ____) => fail('Expected AIError'),
        service: (_, __, ___, ____, _____) => fail('Expected AIError'),
      );
    });

    test('should handle unknown exceptions', () {
      final exception = Exception('Unknown error');
      final error = ErrorHandler.handle(exception);

      expect(error, isA<UnknownError>());
      expect(error.userMessage, 'Something unexpected happened. Please try again.');
    });

    test('should handle async operations with fallback value', () async {
      final result = await ErrorHandler.handleAsync<int>(
        () async {
          throw Exception('Test error');
        },
        context: 'test',
        fallbackValue: 42,
      );

      expect(result, 42);
    });

    test('should rethrow when no fallback value provided', () async {
      try {
        await ErrorHandler.handleAsync<int>(
          () async {
            throw Exception('Test error');
          },
          context: 'test',
        );
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<AppError>());
      }
    });

    test('should handle sync operations with fallback value', () {
      final result = ErrorHandler.handleSync<int>(
        () {
          throw Exception('Test error');
        },
        context: 'test',
        fallbackValue: 99,
      );

      expect(result, 99);
    });

    test('should create database error with context', () {
      final error = ErrorHandler.databaseError(
        message: 'Test error',
        details: 'Test details',
        query: 'SELECT * FROM test',
        table: 'test_table',
      );

      expect(error, isA<DatabaseError>());
      error.when(
        network: (_, __, ___) => fail('Expected DatabaseError'),
        database: (message, details, severity, query, table) {
          expect(message, 'Test error');
          expect(details, 'Test details');
          expect(query, 'SELECT * FROM test');
          expect(table, 'test_table');
        },
        validation: (_, __, ___) => fail('Expected DatabaseError'),
        permission: (_, __, ___) => fail('Expected DatabaseError'),
        unknown: (_, __, ___) => fail('Expected DatabaseError'),
        api: (_, __, ___, ____) => fail('Expected DatabaseError'),
        ai: (_, __, ___, ____, _____) => fail('Expected DatabaseError'),
        notification: (_, __, ___, ____) => fail('Expected DatabaseError'),
        storage: (_, __, ___, ____) => fail('Expected DatabaseError'),
        service: (_, __, ___, ____, _____) => fail('Expected DatabaseError'),
      );
    });

    test('should create AI error with OOM flag', () {
      final error = ErrorHandler.aiError(
        message: 'Model load failed',
        isOutOfMemory: true,
      );

      expect(error, isA<AIError>());
      error.when(
        network: (_, __, ___) => fail('Expected AIError'),
        database: (_, __, ___, ____, _____) => fail('Expected AIError'),
        validation: (_, __, ___) => fail('Expected AIError'),
        permission: (_, __, ___) => fail('Expected AIError'),
        unknown: (_, __, ___) => fail('Expected AIError'),
        api: (_, __, ___, ____) => fail('Expected AIError'),
        ai: (message, details, severity, modelPath, isOOM) {
          expect(message, 'Model load failed');
          expect(isOOM, true);
          expect(error.isRetryable, false);
        },
        notification: (_, __, ___, ____) => fail('Expected AIError'),
        storage: (_, __, ___, ____) => fail('Expected AIError'),
        service: (_, __, ___, ____, _____) => fail('Expected AIError'),
      );
    });

    test('should create notification error with permission flag', () {
      final error = ErrorHandler.notificationError(
        message: 'Notification permission denied',
        isPermissionDenied: true,
      );

      expect(error, isA<NotificationError>());
      error.when(
        network: (_, __, ___) => fail('Expected NotificationError'),
        database: (_, __, ___, ____, _____) => fail('Expected NotificationError'),
        validation: (_, __, ___) => fail('Expected NotificationError'),
        permission: (_, __, ___) => fail('Expected NotificationError'),
        unknown: (_, __, ___) => fail('Expected NotificationError'),
        api: (_, __, ___, ____) => fail('Expected NotificationError'),
        ai: (_, __, ___, ____, _____) => fail('Expected NotificationError'),
        notification: (message, details, severity, isPermissionDenied) {
          expect(message, 'Notification permission denied');
          expect(isPermissionDenied, true);
          expect(error.isRetryable, false);
        },
        storage: (_, __, ___, ____) => fail('Expected NotificationError'),
        service: (_, __, ___, ____, _____) => fail('Expected NotificationError'),
      );
    });

    test('should have correct severity levels', () {
      final debugError = ErrorHandler.databaseError(
        message: 'Test',
        severity: ErrorSeverity.debug,
      );
      expect(debugError.severity, ErrorSeverity.debug);

      final fatalError = ErrorHandler.databaseError(
        message: 'Test',
        severity: ErrorSeverity.fatal,
      );
      expect(fatalError.severity, ErrorSeverity.fatal);
    });

    test('should convert error to map for logging', () {
      final error = ErrorHandler.databaseError(
        message: 'Test error',
        details: 'Test details',
      );

      final map = error.toMap();
      expect(map['type'], contains('DatabaseError'));
      expect(map['userMessage'], isNotEmpty);
      expect(map['technicalMessage'], isNotEmpty);
      expect(map['severity'], 'error');
      expect(map['isRetryable'], isA<bool>());
      expect(map['timestamp'], isNotEmpty);
    });
  });
}
