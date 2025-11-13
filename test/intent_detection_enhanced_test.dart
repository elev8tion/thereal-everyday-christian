/// Enhanced Intent Detection Tests
/// Tests the refined intent detection system with crisis keywords,
/// tone guardrails, and default fallback behavior

import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/intent_detection_service.dart';

void main() {
  late IntentDetectionService service;

  setUp(() {
    service = IntentDetectionService();
  });

  group('Crisis & Life-Threatening Intent Detection', () {
    test('Detects suicide ideation as guidance', () {
      final inputs = [
        'I want to kill myself',
        'thinking about suicide',
        'I just want to end my life',
        'I\'m suicidal and need help',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance,
            reason: 'Input "$input" should trigger guidance intent');
        expect(result.confidence, greaterThan(0.5),
            reason: 'Suicide keywords should have high confidence');
      }
    });

    test('Detects self-harm as guidance', () {
      final inputs = [
        'I\'ve been cutting myself',
        'I hurt myself to cope',
        'self harm is the only way',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });

    test('Detects abuse situations as guidance', () {
      final inputs = [
        'My husband is abusing me',
        'I\'m being abused at home',
        'I don\'t feel safe',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });

    test('Detects faith crisis as guidance', () {
      final inputs = [
        'I\'m losing faith in God',
        'I doubt God even exists',
        'Where is God when I need him?',
        'God has abandoned me',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance,
            reason: 'Faith crisis should trigger guidance intent');
      }
    });

    test('Detects major life trauma as guidance', () {
      final inputs = [
        'My mother just died',
        'I lost my baby to miscarriage',
        'Going through a divorce',
        'Death of my spouse',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance,
            reason: 'Major trauma should trigger guidance intent');
      }
    });
  });

  group('Ambiguous/Unknown Topics - Default to Guidance', () {
    test('Serious topics without explicit keywords default to guidance', () {
      final inputs = [
        'This feels like the end times and revelations is happening',
        'The world seems to be falling apart',
        'Everything is going wrong',
        'I don\'t know what to believe anymore',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance,
            reason: 'Unknown serious topics should default to guidance (not casual)');
        expect(result.confidence, lessThan(0.5),
            reason: 'Default should have low confidence (no patterns matched)');
      }
    });
  });

  group('Existing Guidance Patterns Still Work', () {
    test('Detects emotional distress as guidance', () {
      final inputs = [
        'I\'m struggling with anxiety',
        'I feel so alone',
        'I\'m worried about my future',
        'I\'m hurting and need help',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });

    test('Detects prayer requests as guidance', () {
      final inputs = [
        'Please pray for me',
        'I need prayer',
        'Can you pray for my family?',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });

    test('Detects support requests as guidance', () {
      final inputs = [
        'I need guidance',
        'Help me understand',
        'What should I do about this?',
        'I need encouragement',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });
  });

  group('Discussion Intent Detection', () {
    test('Detects theological questions as discussion', () {
      final inputs = [
        'What does the Bible say about tithing?',
        'Can you explain the Trinity?',
        'Help me understand Romans 8',
        'What is the difference between grace and mercy?',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.discussion,
            reason: 'Theological questions should trigger discussion intent');
      }
    });

    test('Detects biblical curiosity as discussion', () {
      final inputs = [
        'I\'m curious about the rapture',
        'Tell me about the book of Revelation',
        'What happened in the Garden of Eden?',
        'Who was King David?',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.discussion);
      }
    });
  });

  group('Casual Intent Detection', () {
    test('Detects greetings as casual', () {
      final inputs = [
        'Hello',
        'Hi there',
        'Good morning',
        'Hey',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.casual);
      }
    });

    test('Detects follow-ups as casual', () {
      final inputs = [
        'Thanks',
        'Got it',
        'Okay',
        'Tell me more',
      ];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.casual);
      }
    });
  });

  group('Edge Cases & Intent Priority', () {
    test('Guidance takes priority over discussion when both match', () {
      const input = 'I\'m struggling to understand why God allows suffering';
      final result = service.detectIntent(input);

      // Should be guidance because "I'm struggling" is weighted higher
      expect(result.intent, ConversationIntent.guidance,
          reason: 'Emotional struggle should prioritize guidance over discussion');
    });

    test('Empty input defaults to guidance', () {
      final inputs = ['', '   ', '\n'];

      for (final input in inputs) {
        final result = service.detectIntent(input);
        expect(result.intent, ConversationIntent.guidance);
      }
    });

    test('First-person emotional language boosts guidance', () {
      const input = 'I feel confused about the end times';
      final result = service.detectIntent(input);

      expect(result.intent, ConversationIntent.guidance,
          reason: '"I feel" should boost guidance score');
    });
  });

  group('Confidence Scoring', () {
    test('Crisis keywords have very high confidence', () {
      final result = service.detectIntent('I want to kill myself');
      expect(result.confidence, greaterThanOrEqualTo(0.8),
          reason: 'Crisis keywords should have 80%+ confidence');
    });

    test('Default fallback has low confidence', () {
      final result = service.detectIntent('The world is changing');
      expect(result.confidence, lessThanOrEqualTo(0.4),
          reason: 'Default fallback should have ≤40% confidence');
    });

    test('Strong pattern matches have high confidence', () {
      final result = service.detectIntent('I\'m struggling with depression and anxiety and feeling lost');
      expect(result.confidence, greaterThanOrEqualTo(0.7),
          reason: 'Multiple matched patterns should have 70%+ confidence');
    });
  });

  group('Real-World Scenarios', () {
    test('Original problematic example: apocalyptic concern', () {
      const input = 'This feels like a new times and revelations is happening';
      final result = service.detectIntent(input);

      expect(result.intent, ConversationIntent.guidance,
          reason: 'Should default to guidance (not casual) for serious unknown topics');
      expect(result.confidence, lessThan(0.5),
          reason: 'No explicit patterns matched, so confidence should be low');
    });

    test('Marriage crisis', () {
      const input = 'My marriage is falling apart and I don\'t know what to do';
      final result = service.detectIntent(input);

      expect(result.intent, ConversationIntent.guidance);
      expect(result.confidence, greaterThan(0.5));
    });

    test('Academic Bible question', () {
      const input = 'Can you explain the historical context of the book of Daniel?';
      final result = service.detectIntent(input);

      expect(result.intent, ConversationIntent.discussion);
    });

    test('Casual faith sharing', () {
      const input = 'That\'s a beautiful verse, thanks for sharing';
      final result = service.detectIntent(input);

      expect(result.intent, ConversationIntent.casual);
    });
  });
}
