import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/intent_detection_service.dart';

void main() {
  group('IntentDetectionService', () {
    late IntentDetectionService service;

    setUp(() {
      service = IntentDetectionService();
    });

    group('Guidance Intent Detection', () {
      test('✅ Detects emotional distress as guidance', () {
        final inputs = [
          'I\'m struggling with anxiety',
          'I feel so lost and alone',
          'I\'m going through a difficult time',
          'I need help with my marriage',
          'Please pray for me',
          'I don\'t know what to do',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.guidance,
              reason: 'Should detect guidance intent for: "$input"');
          expect(result.confidence, greaterThan(0.6),
              reason: 'Should have good confidence for: "$input"');
        }
      });

      test('✅ Detects help requests as guidance', () {
        final inputs = [
          'Help me understand forgiveness',
          'I need guidance about my career',
          'Can you pray for my family?',
          'I\'m worried about my children',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.guidance,
              reason: 'Should detect guidance intent for: "$input"');
        }
      });
    });

    group('Discussion Intent Detection', () {
      test('✅ Detects theological questions as discussion', () {
        final inputs = [
          'What does the Bible say about tithing?',
          'Can you explain the Trinity?',
          'I want to understand predestination',
          'Tell me about spiritual gifts',
          'What\'s the difference between grace and mercy?',
          'How did Jesus fulfill Old Testament prophecies?',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.discussion,
              reason: 'Should detect discussion intent for: "$input"');
          expect(result.confidence, greaterThan(0.5),
              reason: 'Should have reasonable confidence for: "$input"');
        }
      });

      test('✅ Detects learning requests as discussion', () {
        final inputs = [
          'I\'m curious about the book of Revelation',
          'Teach me about biblical covenant',
          'Let\'s discuss end times theology',
          'What are your thoughts on Calvinism vs Arminianism?',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.discussion,
              reason: 'Should detect discussion intent for: "$input"');
        }
      });
    });

    group('Casual Intent Detection', () {
      test('✅ Detects greetings as casual', () {
        final inputs = [
          'Hello',
          'Hi there',
          'Good morning',
          'Thanks',
          'Thank you',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.casual,
              reason: 'Should detect casual intent for: "$input"');
        }
      });

      test('✅ Detects follow-ups as casual', () {
        final inputs = [
          'Tell me more',
          'Continue',
          'What else?',
          'I see',
          'Okay',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.casual,
              reason: 'Should detect casual intent for: "$input"');
        }
      });
    });

    group('Edge Cases and Mixed Signals', () {
      test('✅ Prioritizes guidance over discussion when mixed', () {
        final inputs = [
          'I\'m struggling to understand why God allows suffering',
          'Help me understand - I feel so confused about faith',
          'What does the Bible say when I\'m anxious?',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.guidance,
              reason: 'Should prioritize guidance when emotional needs present: "$input"');
        }
      });

      test('✅ Handles challenging questions correctly', () {
        final inputs = [
          'Is God real?',
          'What\'s the truth about Christianity?',
          'Can you explain the problem of evil?',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          expect(result.intent, ConversationIntent.discussion,
              reason: 'Should treat philosophical questions as discussion: "$input"');
        }
      });

      test('✅ Handles single-word inputs', () {
        final inputs = [
          'Truth',
          'Jesus',
          'Faith',
        ];

        for (final input in inputs) {
          final result = service.detectIntent(input);
          // Single words are ambiguous - accept any reasonable confidence
          expect(result.confidence, greaterThan(0.0),
              reason: 'Should detect some intent for: "$input"');
          // Intent is less important than confidence for single words
        }
      });
    });

    group('Confidence Scoring', () {
      test('✅ High confidence for clear guidance requests', () {
        final result = service.detectIntent('I\'m struggling with depression and need help');
        expect(result.confidence, greaterThan(0.8));
      });

      test('✅ High confidence for clear discussion requests', () {
        final result = service.detectIntent('What does the Bible say about baptism? Can you explain?');
        expect(result.confidence, greaterThan(0.7));
      });

      test('✅ Lower confidence for minimal input', () {
        final result = service.detectIntent('Help');
        expect(result.confidence, lessThan(0.8));
      });
    });

    group('Pattern Detection Reporting', () {
      test('✅ Reports detected patterns', () {
        final result = service.detectIntent('I\'m struggling and I need help');
        expect(result.detectedPatterns, isNotEmpty);
        expect(result.detectedPatterns.any((p) => p.contains('struggling')), true);
        expect(result.detectedPatterns.any((p) => p.contains('need help')), true);
      });
    });
  });
}
