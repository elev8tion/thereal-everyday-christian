/// Crisis Detection Service Tests
/// Validates that crisis keywords are properly detected

import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/crisis_detection_service.dart';

void main() {
  group('CrisisDetectionService', () {
    late CrisisDetectionService service;

    setUp(() {
      service = CrisisDetectionService();
    });

    group('Suicide Detection', () {
      test('detects explicit suicide keywords', () {
        final inputs = [
          'I want to kill myself',
          'I\'m going to end it all',
          'I don\'t want to be alive anymore',
          'I\'m better off dead',
          'I\'m thinking about suicide',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });

      test('detects suicide phrases in longer text', () {
        const input = 'I\'ve been feeling really down lately and sometimes I think everyone would be better off without me. I don\'t want to live anymore.';
        final result = service.detectCrisis(input);

        expect(result, isNotNull);
        expect(result!.type, CrisisType.suicide);
      });

      test('is case insensitive', () {
        final inputs = [
          'I WANT TO KILL MYSELF',
          'i want to end it all',
          'I Want To Die',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });

      test('detects with punctuation variations', () {
        final inputs = [
          'I want to kill myself.',
          'I want to kill myself!',
          'I want to kill myself...',
          'I want to... kill myself',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });
    });

    group('Self-Harm Detection', () {
      test('detects self-harm keywords', () {
        final inputs = [
          'I want to cut myself',
          'I\'ve been hurting myself',
          'I engage in self harm',
          'I\'ve been cutting',
          'I want to burn myself',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.selfHarm);
        }
      });
    });

    group('Abuse Detection', () {
      test('detects abuse keywords', () {
        final inputs = [
          'My partner is hitting me',
          'Someone is hurting me',
          'I was raped',
          'I\'m being abused',
          'I\'m afraid for my safety',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.abuse);
        }
      });
    });

    group('Priority Detection', () {
      test('prioritizes suicide over other crises', () {
        const input = 'I want to kill myself and I\'ve been cutting';
        final result = service.detectCrisis(input);

        expect(result, isNotNull);
        expect(result!.type, CrisisType.suicide);
      });
    });

    group('False Positives Prevention', () {
      test('does not trigger on safe conversations', () {
        final inputs = [
          'How do I deal with my anxiety?',
          'I\'m feeling sad today',
          'I\'m struggling with fear',
          'I\'m worried about my future',
          'I feel lonely',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNull, reason: 'False positive for: $input');
        }
      });

      test('handles empty input', () {
        final result = service.detectCrisis('');
        expect(result, isNull);
      });

      test('handles whitespace-only input', () {
        final result = service.detectCrisis('   ');
        expect(result, isNull);
      });
    });

    group('Potential Crisis Detection', () {
      test('detects concerning patterns', () {
        final inputs = [
          'I don\'t see any reason to live',
          'I can\'t take it anymore',
          'I\'m giving up',
          'I feel hopeless',
        ];

        for (final input in inputs) {
          final isPotential = service.isPotentialCrisis(input);
          expect(isPotential, isTrue, reason: 'Failed to detect potential crisis: $input');
        }
      });
    });

    group('Crisis Severity', () {
      test('assigns maximum severity to suicide', () {
        final result = service.detectCrisis('I want to kill myself');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 10);
      });

      test('assigns high severity to abuse', () {
        final result = service.detectCrisis('I\'m being abused');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 9);
      });

      test('assigns high severity to self-harm', () {
        final result = service.detectCrisis('I want to cut myself');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 8);
      });
    });

    group('Crisis Resources', () {
      test('provides correct hotline for suicide', () {
        final result = service.detectCrisis('I want to kill myself');
        expect(result, isNotNull);
        expect(result!.getHotline(), '988');
      });

      test('provides correct hotline for self-harm', () {
        final result = service.detectCrisis('I want to cut myself');
        expect(result, isNotNull);
        expect(result!.getHotline(), 'Text HOME to 741741');
      });

      test('provides correct hotline for abuse', () {
        final result = service.detectCrisis('I\'m being abused');
        expect(result, isNotNull);
        expect(result!.getHotline(), '800-656-4673');
      });

      test('provides appropriate message for each crisis type', () {
        final suicideResult = service.detectCrisis('I want to kill myself');
        expect(suicideResult!.getMessage(), contains('988'));
        expect(suicideResult.getMessage(), contains('Suicide & Crisis Lifeline'));

        final selfHarmResult = service.detectCrisis('I want to cut myself');
        expect(selfHarmResult!.getMessage(), contains('741741'));
        expect(selfHarmResult.getMessage(), contains('Crisis Text Line'));

        final abuseResult = service.detectCrisis('I\'m being abused');
        expect(abuseResult!.getMessage(), contains('800-656-4673'));
        expect(abuseResult.getMessage(), contains('RAINN'));
      });
    });
  });
}
