import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/logging/app_logger.dart';

void main() {
  group('AppLogger', () {
    late AppLogger logger;

    setUp(() {
      logger = AppLogger.instance;
    });

    test('should create log entry with correct format', () {
      final entry = LogEntry(
        timestamp: DateTime(2025, 1, 1, 12, 0, 0),
        level: LogLevel.info,
        message: 'Test message',
        context: 'TestContext',
      );

      final formatted = entry.toFormattedString();
      expect(formatted, contains('[INFO   ]'));
      expect(formatted, contains('[TestContext]'));
      expect(formatted, contains('Test message'));
    });

    test('should support all log levels', () {
      logger.debug('Debug message', context: 'test');
      logger.info('Info message', context: 'test');
      logger.warning('Warning message', context: 'test');
      logger.error('Error message', context: 'test');
      logger.fatal('Fatal message', context: 'test');

      final logs = logger.getRecentLogs();
      expect(logs.length, greaterThanOrEqualTo(5));
    });

    test('should filter logs by level', () {
      logger.debug('Debug');
      logger.info('Info');
      logger.warning('Warning');
      logger.error('Error');

      final errorLogs = logger.getRecentLogs(minimumLevel: LogLevel.error);
      expect(errorLogs.every((log) => log.level.value >= LogLevel.error.value), true);
    });

    test('should limit recent logs count', () {
      logger.debug('Test 1');
      logger.debug('Test 2');
      logger.debug('Test 3');
      logger.debug('Test 4');

      final limitedLogs = logger.getRecentLogs(limit: 2);
      expect(limitedLogs.length, 2);
    });

    test('should log with metadata', () {
      logger.info(
        'Test message',
        context: 'test',
        metadata: {'key1': 'value1', 'key2': 42},
      );

      final logs = logger.getRecentLogs(limit: 1);
      expect(logs.first.metadata, isNotNull);
      expect(logs.first.metadata!['key1'], 'value1');
      expect(logs.first.metadata!['key2'], 42);
    });

    test('should log with stack trace', () {
      try {
        throw Exception('Test error');
      } catch (e, stackTrace) {
        logger.error('Error occurred', stackTrace: stackTrace);
      }

      final logs = logger.getRecentLogs(limit: 1);
      expect(logs.first.stackTrace, isNotNull);
    });

    test('should convert log entry to JSON', () {
      final entry = LogEntry(
        timestamp: DateTime.now(),
        level: LogLevel.warning,
        message: 'Test',
        context: 'TestContext',
      );

      final json = entry.toJson();
      expect(json['timestamp'], isNotEmpty);
      expect(json['level'], 'warning');
      expect(json['message'], 'Test');
      expect(json['context'], 'TestContext');
    });

    test('should stream log entries', () async {
      final streamedLogs = <LogEntry>[];
      final subscription = logger.logStream.listen((entry) {
        streamedLogs.add(entry);
      });

      logger.info('Stream test 1');
      logger.info('Stream test 2');

      await Future.delayed(const Duration(milliseconds: 100));
      expect(streamedLogs.length, greaterThanOrEqualTo(2));

      await subscription.cancel();
    });

    test('should compare log levels correctly', () {
      expect(LogLevel.debug < LogLevel.info, true);
      expect(LogLevel.info >= LogLevel.info, true);
      expect(LogLevel.error >= LogLevel.warning, true);
      expect(LogLevel.fatal >= LogLevel.error, true);
    });
  });
}
