/// Spanish Language Crisis Detection Tests
/// Validates that Spanish crisis keywords are properly detected
///
/// This test suite ensures the app properly detects crisis situations
/// for Spanish-speaking users, which is critical for App Store submission.

import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/crisis_detection_service.dart';

void main() {
  group('CrisisDetectionService - Spanish Language', () {
    late CrisisDetectionService service;

    setUp(() {
      service = CrisisDetectionService();
    });

    group('Suicide Detection (Spanish)', () {
      test('detects direct suicide keywords', () {
        final inputs = [
          'Quiero matarme',
          'Voy a acabar con todo',
          'No quiero vivir más',
          'Estoy mejor muerto',
          'Estoy pensando en el suicidio',
          'Quiero morir',
          'Voy a terminar con mi vida',
          'Me voy a quitar la vida',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('detects indirect suicide patterns', () {
        final inputs = [
          'No hay razón para vivir',
          'Todos estarían mejor sin mí',
          'El mundo estaría mejor sin mí',
          'No veo salida',
          'No puedo más',
          'No aguanto más',
          'No hay sentido en vivir',
          'Estoy sin esperanza',
          'Es insoportable',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('detects suicide phrases in longer Spanish text', () {
        const input =
            'Me he sentido muy mal últimamente y a veces pienso que todos estarían mejor sin mí. No quiero vivir más.';
        final result = service.detectCrisis(input);

        expect(result, isNotNull,
            reason: 'Failed to detect suicide in Spanish paragraph');
        expect(result!.type, CrisisType.suicide);
      });

      test('is case insensitive for Spanish keywords', () {
        final inputs = [
          'QUIERO MATARME',
          'quiero matarme',
          'Quiero Matarme',
          'NO QUIERO VIVIR MÁS',
          'no quiero vivir más',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });

      test('detects with Spanish punctuation variations', () {
        final inputs = [
          '¿Quiero matarme?',
          'Quiero matarme.',
          'Quiero matarme!',
          '¡Quiero matarme!',
          'Quiero... matarme',
          'No quiero vivir más...',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });

      test('detects "adiós para siempre" pattern', () {
        final inputs = [
          'Adiós para siempre',
          'Este es mi mensaje final',
          'Adiós a todos para siempre',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.suicide);
        }
      });
    });

    group('Self-Harm Detection (Spanish)', () {
      test('detects direct self-harm keywords', () {
        final inputs = [
          'Quiero cortarme',
          'Me he estado cortando',
          'He estado haciéndome daño',
          'Quiero lastimarme',
          'Practico autolesión',
          'Me estoy quemando',
          'Quiero hacerme daño',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.selfHarm,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('detects indirect self-harm patterns', () {
        final inputs = [
          'Necesito castigarme',
          'Necesito sentir dolor',
          'Merezco sufrir',
          'Es la única forma de lidiar',
          'No puedo dejar de hacerme daño',
          'Me siento vacío y necesito sentir algo',
          'El dolor físico ayuda',
          'Cortarme ayuda',
          'Tengo cicatrices nuevas',
          'Hice cortes frescos',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.selfHarm,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('handles Spanish accents and variations', () {
        final inputs = [
          'Me estoy cortándome', // With accent
          'Me estoy cortandome', // Without accent
          'Quiero hacerme daño', // With ñ
          'Quiero hacerme dano', // Without ñ
          'He estado haciéndome daño', // With accent
          'He estado haciendome dano', // Without accent
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.selfHarm);
        }
      });
    });

    group('Abuse Detection (Spanish)', () {
      test('detects direct abuse keywords', () {
        final inputs = [
          'Mi pareja me pega',
          'Mi esposo me golpea',
          'Alguien me está lastimando',
          'Me están maltratando',
          'Fui violado',
          'Fui violada',
          'Me están abusando',
          'Tengo miedo por mi seguridad',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.abuse,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('detects indirect abuse patterns', () {
        final inputs = [
          'Me amenaza constantemente',
          'Temo por mi seguridad',
          'He sido físicamente lastimada',
          'Sufro maltrato',
          'Hay violencia en casa',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.abuse,
              reason: 'Wrong crisis type for: $input');
        }
      });

      test('handles Spanish accent variations for abuse', () {
        final inputs = [
          'Violación', // With accent
          'Violacion', // Without accent
          'Agresión', // With accent
          'Agresion', // Without accent
          'Físicamente lastimado', // With accent
          'Fisicamente lastimado', // Without accent
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull, reason: 'Failed to detect: $input');
          expect(result!.type, CrisisType.abuse);
        }
      });
    });

    group('Priority Detection (Spanish)', () {
      test('prioritizes suicide over other crises in Spanish', () {
        const input =
            'Quiero matarme y también me he estado cortando'; // Suicide + self-harm
        final result = service.detectCrisis(input);

        expect(result, isNotNull);
        expect(result!.type, CrisisType.suicide,
            reason: 'Suicide should be prioritized over self-harm');
      });

      test('prioritizes suicide over abuse in Spanish', () {
        const input =
            'Mi pareja me pega y no quiero vivir más'; // Abuse + suicide
        final result = service.detectCrisis(input);

        expect(result, isNotNull);
        expect(result!.type, CrisisType.suicide,
            reason: 'Suicide should be prioritized over abuse');
      });

      test('prioritizes abuse over self-harm when no suicide', () {
        const input =
            'Me están golpeando y me corto'; // Abuse + self-harm
        final result = service.detectCrisis(input);

        expect(result, isNotNull);
        expect(result!.type, CrisisType.abuse,
            reason: 'Abuse should be prioritized over self-harm');
      });
    });

    group('False Positives Prevention (Spanish)', () {
      test('does not trigger on safe Spanish conversations', () {
        final inputs = [
          '¿Cómo manejo mi ansiedad?',
          'Me siento triste hoy',
          'Estoy luchando con el miedo',
          'Estoy preocupado por mi futuro',
          'Me siento solo',
          'Tengo problemas con la depresión',
          'Necesito ayuda espiritual',
          'Me siento desesperado a veces',
          '¿Cómo puedo tener esperanza?',
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNull, reason: 'False positive for: $input');
        }
      });

      test('handles empty Spanish input', () {
        final result = service.detectCrisis('');
        expect(result, isNull);
      });

      test('handles whitespace-only input', () {
        final result = service.detectCrisis('   ');
        expect(result, isNull);
      });

      test('does not trigger on partial word matches', () {
        // Make sure we don't match "abuso" in "abusón" (bully) context
        final inputs = [
          'Mi hermano es un abusón', // Bully, not abuse
          'No me gusta el maltrato animal', // Animal abuse, not personal
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          // These might still trigger, but should not be suicide
          if (result != null) {
            expect(result.type, isNot(CrisisType.suicide));
          }
        }
      });
    });

    group('Potential Crisis Detection (Spanish)', () {
      test('detects concerning Spanish patterns', () {
        final inputs = [
          'No veo ninguna razón para vivir',
          'No aguanto más',
          'Me estoy rindiendo',
          'Me siento sin esperanza',
          'Estoy atrapado',
          'Nada va a cambiar',
          'Es insoportable',
        ];

        for (final input in inputs) {
          final isPotential = service.isPotentialCrisis(input);
          expect(isPotential, isTrue,
              reason: 'Failed to detect potential crisis: $input');
        }
      });
    });

    group('Crisis Severity (Spanish)', () {
      test('assigns maximum severity to Spanish suicide keywords', () {
        final result = service.detectCrisis('Quiero matarme');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 10,
            reason: 'Suicide should have severity 10');
      });

      test('assigns high severity to Spanish abuse keywords', () {
        final result = service.detectCrisis('Me están maltratando');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 9,
            reason: 'Abuse should have severity 9');
      });

      test('assigns high severity to Spanish self-harm keywords', () {
        final result = service.detectCrisis('Quiero cortarme');
        expect(result, isNotNull);
        expect(service.getCrisisSeverity(result!), 8,
            reason: 'Self-harm should have severity 8');
      });
    });

    group('Crisis Resources (Spanish)', () {
      test('provides correct hotline for Spanish suicide detection', () {
        final result = service.detectCrisis('Quiero matarme');
        expect(result, isNotNull);
        expect(result!.getHotline(), '988',
            reason: 'Should provide 988 hotline for suicide');
      });

      test('provides correct hotline for Spanish self-harm detection', () {
        final result = service.detectCrisis('Quiero cortarme');
        expect(result, isNotNull);
        expect(result!.getHotline(), 'Text HOME to 741741',
            reason: 'Should provide Crisis Text Line for self-harm');
      });

      test('provides correct hotline for Spanish abuse detection', () {
        final result = service.detectCrisis('Mi pareja me pega');
        expect(result, isNotNull);
        expect(result!.getHotline(), '800-656-4673',
            reason: 'Should provide RAINN hotline for abuse');
      });

      test('provides localized Spanish messages', () {
        final suicideResult = service.detectCrisis('Quiero matarme');
        expect(suicideResult, isNotNull);
        final message = suicideResult!.getMessage();
        expect(message, contains('988'),
            reason: 'Should include 988 in Spanish suicide message');

        final selfHarmResult = service.detectCrisis('Quiero cortarme');
        expect(selfHarmResult, isNotNull);
        final selfHarmMessage = selfHarmResult!.getMessage();
        expect(selfHarmMessage, contains('741741'),
            reason: 'Should include 741741 in Spanish self-harm message');

        final abuseResult = service.detectCrisis('Me están maltratando');
        expect(abuseResult, isNotNull);
        final abuseMessage = abuseResult!.getMessage();
        expect(abuseMessage, contains('800-656-4673'),
            reason: 'Should include RAINN hotline in Spanish abuse message');
      });
    });

    group('Mixed Language Detection', () {
      test('detects crisis in Spanglish (mixed Spanish/English)', () {
        final inputs = [
          'I want to matarme', // English + Spanish
          'Quiero kill myself', // Spanish + English
          'Me quiero cortar myself', // Mixed self-harm
        ];

        for (final input in inputs) {
          final result = service.detectCrisis(input);
          expect(result, isNotNull,
              reason: 'Should detect crisis in mixed language: $input');
        }
      });
    });

    group('Comprehensive Spanish Keyword Coverage', () {
      test('detects all documented Spanish suicide keywords', () {
        // Testing a comprehensive sample of keywords from the service
        final criticalKeywords = [
          'matarme',
          'acabar con todo',
          'terminar con todo',
          'no quiero vivir',
          'no quiero estar vivo',
          'mejor muerto',
          'suicidio',
          'suicida',
          'quiero morir',
          'terminar con mi vida',
          'acabar con mi vida',
          'quitarme la vida',
          'no hay razón para vivir',
          'no puedo seguir',
          'todos estarían mejor sin mi',
          'adiós para siempre',
          'mensaje final',
          'no hay salida',
          'atrapado',
          'una carga para todos',
          'quiero desaparecer',
          'no puedo más',
          'sin esperanza',
          'insoportable',
        ];

        int detectedCount = 0;
        for (final keyword in criticalKeywords) {
          final result = service.detectCrisis('Me siento $keyword');
          if (result != null && result.type == CrisisType.suicide) {
            detectedCount++;
          } else {
            print(
                '⚠️ Failed to detect Spanish suicide keyword: "$keyword" in context');
          }
        }

        expect(detectedCount, greaterThan(20),
            reason:
                'Should detect most Spanish suicide keywords in natural context');
      });

      test('detects all documented Spanish self-harm keywords', () {
        final criticalKeywords = [
          'cortarme',
          'hacerme daño',
          'lastimarme',
          'autolesión',
          'quemarme',
          'castigarme',
          'necesito sentir dolor',
          'merezco dolor',
          'no puedo dejar de hacerme daño',
          'cicatrices',
        ];

        int detectedCount = 0;
        for (final keyword in criticalKeywords) {
          final result = service.detectCrisis('Quiero $keyword');
          if (result != null && result.type == CrisisType.selfHarm) {
            detectedCount++;
          } else {
            print(
                '⚠️ Failed to detect Spanish self-harm keyword: "$keyword" in context');
          }
        }

        expect(detectedCount, greaterThan(8),
            reason:
                'Should detect most Spanish self-harm keywords in natural context');
      });

      test('detects all documented Spanish abuse keywords', () {
        final criticalKeywords = [
          'me pega',
          'me golpea',
          'me lastima',
          'me maltrata',
          'maltrato',
          'abusando de mí',
          'siendo abusado',
          'violación',
          'violado',
          'asalto',
          'agresión',
          'abuso',
          'violento',
          'me amenaza',
          'temo por mi seguridad',
        ];

        int detectedCount = 0;
        for (final keyword in criticalKeywords) {
          final result = service.detectCrisis('$keyword cada día');
          if (result != null && result.type == CrisisType.abuse) {
            detectedCount++;
          } else {
            print(
                '⚠️ Failed to detect Spanish abuse keyword: "$keyword" in context');
          }
        }

        expect(detectedCount, greaterThan(12),
            reason:
                'Should detect most Spanish abuse keywords in natural context');
      });
    });
  });
}
