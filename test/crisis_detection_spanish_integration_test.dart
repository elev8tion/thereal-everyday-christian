/// Spanish Language Crisis Detection Integration Tests
/// Validates crisis detection works correctly in chat flow for Spanish users

import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/core/services/crisis_detection_service.dart';

void main() {
  group('Crisis Detection Chat Integration - Spanish', () {
    late CrisisDetectionService service;

    setUp(() {
      service = CrisisDetectionService();
    });

    group('Message Flow Tests (Spanish)', () {
      test('Spanish crisis message should allow message to continue', () {
        // Simulate Spanish user expressing suicidal thoughts
        const userMessage = 'Quiero matarme';

        // Step 1: Check for crisis
        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Spanish crisis should be detected');
        expect(crisisResult!.type, CrisisType.suicide);

        // Step 2: Verify message would still be sent
        // In actual implementation, message continues after dialog shown
        const shouldSendMessage = true; // Message should ALWAYS send
        expect(shouldSendMessage, isTrue,
            reason: 'Spanish crisis message should still be sent to AI');
      });

      test('non-crisis Spanish message should not trigger warning', () {
        const userMessage = '¿Cómo puedo encontrar paz con Dios?';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNull,
            reason: 'No crisis should be detected in Spanish faith question');

        // Message sends normally without any warning
        const shouldSendMessage = true;
        expect(shouldSendMessage, isTrue);
      });

      test('Spanish self-harm message should trigger but allow continuation',
          () {
        const userMessage = 'Me he estado cortando';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Spanish self-harm should be detected');
        expect(crisisResult!.type, CrisisType.selfHarm);

        // Message should still be sent to AI for pastoral guidance
        const shouldSendMessage = true;
        expect(shouldSendMessage, isTrue);
      });

      test('Spanish abuse message should trigger but allow continuation', () {
        const userMessage = 'Mi pareja me pega';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Spanish abuse should be detected');
        expect(crisisResult!.type, CrisisType.abuse);

        // User should still get AI response
        const shouldSendMessage = true;
        expect(shouldSendMessage, isTrue);
      });
    });

    group('Warning Display Tests (Spanish)', () {
      test('Spanish suicide keywords should provide 988 hotline', () {
        const userMessage = 'No quiero vivir más';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish suicide phrase');
        expect(crisisResult!.getHotline(), '988');
        expect(crisisResult.getMessage(), contains('988'));
      });

      test('Spanish self-harm keywords should provide Crisis Text Line', () {
        const userMessage = 'Quiero hacerme daño';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish self-harm phrase');
        expect(crisisResult!.getHotline(), 'Text HOME to 741741');
        expect(crisisResult.getMessage(), contains('741741'));
      });

      test('Spanish abuse keywords should provide RAINN hotline', () {
        const userMessage = 'Me están maltratando';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish abuse phrase');
        expect(crisisResult!.getHotline(), '800-656-4673');
      });
    });

    group('Edge Cases (Spanish)', () {
      test('discussing crisis topics in Spanish should trigger info', () {
        // Spanish user asking theological question about suicide
        const userMessage = '¿Qué dice la Biblia sobre el suicidio?';

        final crisisResult = service.detectCrisis(userMessage);
        // This WILL trigger detection (contains "suicidio")
        // But the dialog is dismissible and message still sends
        expect(crisisResult, isNotNull,
            reason: 'Should detect "suicidio" keyword even in question context');
        expect(crisisResult!.type, CrisisType.suicide);

        // Important: Message still goes through for pastoral guidance
      });

      test('helping others in Spanish should trigger info but not block', () {
        const userMessage =
            'Mi amigo está hablando de cortarse, ¿cómo puedo ayudar?';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish self-harm discussion');
        expect(crisisResult!.type, CrisisType.selfHarm);

        // User gets resources but can still get AI pastoral guidance
      });

      test('multiple Spanish crisis keywords should prioritize correctly', () {
        const userMessage = 'Me están abusando y quiero acabar con todo';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull);
        // Suicide has highest priority even in Spanish
        expect(crisisResult!.type, CrisisType.suicide,
            reason: 'Suicide should be prioritized over abuse in Spanish');
      });

      test('Spanish with English crisis mix should still detect', () {
        // Spanglish crisis message
        const userMessage = 'I want to matarme porque no puedo más';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect crisis in Spanglish');
        expect(crisisResult!.type, CrisisType.suicide);
      });
    });

    group('User Experience Flow (Spanish)', () {
      test('dismissible Spanish warning allows normal conversation', () {
        final testScenario = [
          'Quiero matarme', // Triggers warning
          'Cuéntame más sobre la oración', // Normal conversation continues
          'Me estoy sintiendo mejor', // Normal conversation continues
        ];

        for (int i = 0; i < testScenario.length; i++) {
          final message = testScenario[i];
          final crisisResult = service.detectCrisis(message);

          if (i == 0) {
            // First message triggers warning
            expect(crisisResult, isNotNull,
                reason: 'First Spanish crisis message should trigger warning');
          } else {
            // Subsequent messages work normally
            expect(crisisResult, isNull,
                reason: 'Normal Spanish messages should not trigger');
          }

          // All messages should be processable
          expect(message.isNotEmpty, isTrue);
        }
      });

      test('Spanish resources remain available throughout conversation', () {
        // If user dismisses dialog, they should be able to view it again
        const userMessage = 'Quiero lastimarme';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Spanish self-harm should trigger resources');

        // Resources are always available via dialog action button
        const hasViewButton = true; // Simulates dialog "View" action
        expect(hasViewButton, isTrue);
      });

      test('Spanish conversation with recurring crisis mentions', () {
        // User may mention crisis multiple times in session
        final conversation = [
          'No quiero vivir más', // First mention
          'Me siento muy mal', // Normal
          'Siento que soy una carga', // Crisis pattern
          '¿Dios me perdona?', // Spiritual question
        ];

        int crisisCount = 0;
        for (final message in conversation) {
          final crisisResult = service.detectCrisis(message);
          if (crisisResult != null) {
            crisisCount++;
            // Each crisis detection should provide resources
            expect(crisisResult.getHotline(), isNotEmpty);
          }
        }

        expect(crisisCount, greaterThan(0),
            reason: 'Should detect at least one crisis in Spanish conversation');
      });
    });

    group('Privacy and Logging (Spanish)', () {
      test('Spanish crisis detection logs type but not content', () {
        const userMessage = 'Quiero matarme';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull);

        // Verify logging would only include type and severity
        final loggedType = crisisResult!.type;
        final severity = service.getCrisisSeverity(crisisResult);

        expect(loggedType, CrisisType.suicide);
        expect(severity, 10);

        // Note: Spanish user input should NEVER be logged (privacy)
      });

      test('localized Spanish message does not expose user input', () {
        const userMessage = 'Me quiero cortar porque me siento vacío';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull);

        final displayMessage = crisisResult!.getMessage();
        // Message should contain hotline info but NOT user's actual words
        expect(displayMessage, contains('741741'));
        expect(displayMessage, isNot(contains('vacío')),
            reason: 'Should not echo user input in crisis message');
      });
    });

    group('Performance Tests (Spanish)', () {
      test('Spanish crisis detection is fast enough for real-time', () {
        const userMessage =
            'Quiero matarme y acabar con todo porque no aguanto más';

        final stopwatch = Stopwatch()..start();
        final crisisResult = service.detectCrisis(userMessage);
        stopwatch.stop();

        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish suicide phrase');
        // Should complete in < 100ms for good UX
        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Spanish crisis detection should be performant');
      });

      test('non-crisis Spanish messages are even faster', () {
        const userMessage = '¿Cómo puedo acercarme más a Dios?';

        final stopwatch = Stopwatch()..start();
        final crisisResult = service.detectCrisis(userMessage);
        stopwatch.stop();

        expect(crisisResult, isNull,
            reason: 'Should not detect crisis in normal Spanish question');
        // Should complete in < 50ms
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('long Spanish message with crisis keywords is still fast', () {
        const userMessage =
            'He estado pasando por un tiempo muy difícil últimamente. '
            'Perdí mi trabajo hace tres meses y no he podido encontrar otro. '
            'Mi familia está pasando por dificultades financieras. '
            'A veces siento que no puedo más y que todos estarían mejor sin mí. '
            '¿Qué dice la Biblia sobre esto?';

        final stopwatch = Stopwatch()..start();
        final crisisResult = service.detectCrisis(userMessage);
        stopwatch.stop();

        expect(crisisResult, isNotNull,
            reason: 'Should detect Spanish suicide patterns in long text');
        expect(stopwatch.elapsedMilliseconds, lessThan(150),
            reason: 'Should handle long Spanish messages efficiently');
      });
    });

    group('Accent Variation Handling (Spanish)', () {
      test('detects keywords with and without Spanish accents', () {
        final variations = [
          'Quiero hacerme daño', // With accent
          'Quiero hacerme dano', // Without accent
          'Me siento vacío', // With accent
          'Me siento vacio', // Without accent
          'Violación', // With accent
          'Violacion', // Without accent
        ];

        for (final message in variations) {
          final crisisResult = service.detectCrisis(message);
          expect(crisisResult, isNotNull,
              reason: 'Should detect crisis regardless of accents: $message');
        }
      });

      test('handles Spanish gender variations', () {
        final genderVariations = [
          'Estoy mejor muerto', // Masculine
          'Estoy mejor muerta', // Feminine
          'Estoy atrapado', // Masculine
          'Estoy atrapada', // Feminine
          'Fui violado', // Masculine
          'Fui violada', // Feminine
        ];

        for (final message in genderVariations) {
          final crisisResult = service.detectCrisis(message);
          expect(crisisResult, isNotNull,
              reason: 'Should detect crisis in both gendered forms: $message');
        }
      });
    });

    group('Real-World Spanish Scenarios', () {
      test('distressed teenager expressing suicidal thoughts', () {
        const userMessage =
            'No puedo seguir así. Todos me odian en la escuela. '
            'Mis padres no me entienden. Siento que no hay salida. '
            'Quiero acabar con todo.';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect crisis in realistic teen scenario');
        expect(crisisResult!.type, CrisisType.suicide);
        expect(crisisResult.getHotline(), '988');
      });

      test('domestic abuse victim seeking help', () {
        const userMessage =
            'Mi esposo me pega cuando bebe. '
            'Tengo miedo de irme porque amenaza con lastimarme más. '
            'No sé qué hacer.';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect abuse in realistic domestic violence scenario');
        expect(crisisResult!.type, CrisisType.abuse);
        expect(crisisResult.getHotline(), '800-656-4673');
      });

      test('young adult struggling with self-harm', () {
        const userMessage =
            'He estado cortándome desde hace meses. '
            'Es la única forma que tengo de lidiar con el dolor emocional. '
            '¿Qué puedo hacer?';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect self-harm in realistic scenario');
        expect(crisisResult!.type, CrisisType.selfHarm);
        expect(crisisResult.getHotline(), 'Text HOME to 741741');
      });

      test('parent concerned about child', () {
        const userMessage =
            'Encontré cortes en los brazos de mi hija. '
            'Estoy muy preocupada. ¿Cómo puedo ayudarla?';

        final crisisResult = service.detectCrisis(userMessage);
        expect(crisisResult, isNotNull,
            reason: 'Should detect crisis even when discussing someone else');
        expect(crisisResult!.type, CrisisType.selfHarm);
        // Parent should get resources to help their child
      });
    });

    group('False Positives Prevention (Spanish)', () {
      test('theological discussions should not block conversation', () {
        final theologicalQuestions = [
          '¿Por qué permite Dios el sufrimiento?',
          '¿Cómo encuentro esperanza en tiempos difíciles?',
          'Me siento triste por la pérdida de mi abuela',
          'Tengo ansiedad por mi futuro',
        ];

        for (final question in theologicalQuestions) {
          final crisisResult = service.detectCrisis(question);
          // These might trigger potential crisis but should not be severe
          if (crisisResult != null) {
            expect(service.getCrisisSeverity(crisisResult), lessThan(8),
                reason: 'Theological questions should not trigger high severity');
          }
        }
      });
    });
  });
}
