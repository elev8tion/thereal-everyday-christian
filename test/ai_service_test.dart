import 'package:flutter_test/flutter_test.dart';
import 'package:everyday_christian/services/ai_service.dart';
import 'package:everyday_christian/models/bible_verse.dart';
import 'package:everyday_christian/models/chat_message.dart';

void main() {
  group('AIResponse', () {
    test('should create AIResponse with required fields', () {
      const response = AIResponse(
        content: 'Test response',
        processingTime: Duration(milliseconds: 100),
      );

      expect(response.content, 'Test response');
      expect(response.processingTime.inMilliseconds, 100);
      expect(response.confidence, 1.0);
      expect(response.verses, isEmpty);
      expect(response.metadata, isNull);
    });

    test('should create AIResponse with all fields', () {
      final verses = [
        const BibleVerse(
          book: 'John',
          chapter: 3,
          verseNumber: 16,
          text: 'For God so loved the world...',
          translation: 'ESV',
          reference: 'John 3:16',
          themes: ['love'],
          category: 'salvation',
        ),
      ];

      final response = AIResponse(
        content: 'Complete response',
        verses: verses,
        metadata: {'key': 'value'},
        processingTime: const Duration(milliseconds: 500),
        confidence: 0.95,
      );

      expect(response.content, 'Complete response');
      expect(response.verses.length, 1);
      expect(response.metadata?['key'], 'value');
      expect(response.confidence, 0.95);
    });

    test('should create error response', () {
      final response = AIResponse.error('Test error');

      expect(response.hasError, true);
      expect(response.error, 'Test error');
      expect(response.content, contains('trouble processing'));
      expect(response.confidence, 0.0);
      expect(response.processingTime, Duration.zero);
    });

    test('should detect errors correctly', () {
      const normalResponse = AIResponse(
        content: 'Normal',
        processingTime: Duration(milliseconds: 100),
      );
      expect(normalResponse.hasError, false);
      expect(normalResponse.error, isNull);

      const errorResponse = AIResponse(
        content: 'Error',
        processingTime: Duration.zero,
        metadata: {'error': 'Something went wrong'},
      );
      expect(errorResponse.hasError, true);
      expect(errorResponse.error, 'Something went wrong');
    });
  });

  group('AIConfig', () {
    test('should create default config', () {
      const config = AIConfig();

      expect(config.temperature, 0.7);
      expect(config.maxTokens, 500);
      expect(config.preferredThemes, ['comfort', 'hope', 'strength']);
      expect(config.responseStyle, 'compassionate');
      expect(config.includeVerses, true);
      expect(config.maxVerses, 3);
    });

    test('should create custom config', () {
      const config = AIConfig(
        temperature: 0.5,
        maxTokens: 1000,
        preferredThemes: ['wisdom', 'guidance'],
        responseStyle: 'wise',
        includeVerses: false,
        maxVerses: 5,
      );

      expect(config.temperature, 0.5);
      expect(config.maxTokens, 1000);
      expect(config.preferredThemes, ['wisdom', 'guidance']);
      expect(config.responseStyle, 'wise');
      expect(config.includeVerses, false);
      expect(config.maxVerses, 5);
    });

    test('should create config for anxiety situation', () {
      final config = AIConfig.forSituation('anxiety');

      expect(config.temperature, 0.6);
      expect(config.preferredThemes, ['peace', 'comfort', 'trust']);
      expect(config.responseStyle, 'calming');
    });

    test('should create config for depression situation', () {
      final config = AIConfig.forSituation('depression');

      expect(config.temperature, 0.7);
      expect(config.preferredThemes, ['hope', 'comfort', 'love']);
      expect(config.responseStyle, 'encouraging');
    });

    test('should create config for guidance situation', () {
      final config = AIConfig.forSituation('guidance');

      expect(config.temperature, 0.5);
      expect(config.preferredThemes, ['wisdom', 'guidance', 'discernment']);
      expect(config.responseStyle, 'wise');
    });

    test('should create config for strength situation', () {
      final config = AIConfig.forSituation('strength');

      expect(config.temperature, 0.8);
      expect(config.preferredThemes, ['strength', 'courage', 'perseverance']);
      expect(config.responseStyle, 'empowering');
    });

    test('should return default config for unknown situation', () {
      final config = AIConfig.forSituation('unknown-situation');

      expect(config.temperature, 0.7);
      expect(config.preferredThemes, ['comfort', 'hope', 'strength']);
    });

    test('should be case-insensitive for situations', () {
      final config1 = AIConfig.forSituation('ANXIETY');
      final config2 = AIConfig.forSituation('anxiety');

      expect(config1.responseStyle, config2.responseStyle);
      expect(config1.preferredThemes, config2.preferredThemes);
    });
  });

  group('BiblicalPrompts', () {
    test('should have system prompt', () {
      expect(BiblicalPrompts.systemPrompt, isNotEmpty);
      expect(BiblicalPrompts.systemPrompt, contains('compassionate'));
      expect(BiblicalPrompts.systemPrompt, contains('biblical'));
    });

    test('should build user prompt with input only', () {
      final prompt = BiblicalPrompts.buildUserPrompt(
        userInput: 'I need help with anxiety',
      );

      expect(prompt, contains('I need help with anxiety'));
      expect(prompt, contains('respond with'));
      expect(prompt, contains('compassionate'));
    });

    test('should include conversation history', () {
      final history = [
        ChatMessage.user(content: 'Previous question'),
        ChatMessage.ai(content: 'Previous answer'),
      ];

      final prompt = BiblicalPrompts.buildUserPrompt(
        userInput: 'Follow-up question',
        conversationHistory: history,
      );

      expect(prompt, contains('Previous conversation context'));
      expect(prompt, contains('Previous question'));
      expect(prompt, contains('Previous answer'));
    });

    test('should include preferred themes', () {
      final prompt = BiblicalPrompts.buildUserPrompt(
        userInput: 'Help me',
        preferredThemes: ['peace', 'comfort'],
      );

      expect(prompt, contains('peace, comfort'));
    });

    test('should use custom response style', () {
      final prompt = BiblicalPrompts.buildUserPrompt(
        userInput: 'Help me',
        responseStyle: 'empowering',
      );

      expect(prompt, contains('empowering'));
    });

    test('should limit conversation history to 3 messages', () {
      final history = List.generate(
        10,
        (i) => ChatMessage.user(content: 'Message $i'),
      );

      final prompt = BiblicalPrompts.buildUserPrompt(
        userInput: 'Current',
        conversationHistory: history,
      );

      // Should only include first 3
      expect(prompt, contains('Message 0'));
      expect(prompt, contains('Message 1'));
      expect(prompt, contains('Message 2'));
      expect(prompt, isNot(contains('Message 3')));
    });

    test('should get theme prompts', () {
      final themes = BiblicalPrompts.getThemePrompts();

      expect(themes, isNotEmpty);
      expect(themes['anxiety'], isNotNull);
      expect(themes['depression'], isNotNull);
      expect(themes['strength'], isNotNull);
      expect(themes['guidance'], isNotNull);
      expect(themes['forgiveness'], isNotNull);
    });

    test('should detect anxiety themes', () {
      final themes = BiblicalPrompts.detectThemes('I feel so anxious and worried');

      expect(themes, contains('anxiety'));
    });

    test('should detect depression themes', () {
      final themes = BiblicalPrompts.detectThemes('I feel sad and hopeless');

      expect(themes, contains('depression'));
    });

    test('should detect strength themes', () {
      final themes = BiblicalPrompts.detectThemes('I feel so weak and tired');

      expect(themes, contains('strength'));
    });

    test('should detect guidance themes', () {
      final themes = BiblicalPrompts.detectThemes('I need help with this decision');

      expect(themes, contains('guidance'));
    });

    test('should detect forgiveness themes', () {
      final themes = BiblicalPrompts.detectThemes('I am angry and hurt');

      expect(themes, contains('forgiveness'));
    });

    test('should detect multiple themes', () {
      final themes = BiblicalPrompts.detectThemes(
        'I feel anxious and need guidance for this difficult decision',
      );

      expect(themes, contains('anxiety'));
      expect(themes, contains('guidance'));
    });

    test('should return default themes for no matches', () {
      final themes = BiblicalPrompts.detectThemes('Hello there');

      expect(themes, ['comfort', 'hope']);
    });

    test('should be case-insensitive', () {
      final themes = BiblicalPrompts.detectThemes('I AM ANXIOUS AND WORRIED');

      expect(themes, contains('anxiety'));
    });

    test('should detect relationship themes', () {
      final themes = BiblicalPrompts.detectThemes('Having trouble in my marriage');

      expect(themes, contains('relationships'));
    });

    test('should detect fear themes', () {
      final themes = BiblicalPrompts.detectThemes('I am so afraid and scared');

      expect(themes, contains('fear'));
    });

    test('should detect doubt themes', () {
      final themes = BiblicalPrompts.detectThemes('I have doubts about my faith');

      expect(themes, contains('doubt'));
    });

    test('should detect gratitude themes', () {
      final themes = BiblicalPrompts.detectThemes('I am so thankful and blessed');

      expect(themes, contains('gratitude'));
    });
  });

  group('FallbackResponses', () {
    test('should have predefined responses', () {
      expect(FallbackResponses.responses, isNotEmpty);
      expect(FallbackResponses.responses.length, greaterThanOrEqualTo(3));
    });

    test('should get random response', () {
      final response = FallbackResponses.getRandomResponse();

      expect(response.content, isNotEmpty);
      expect(response.verses, isNotEmpty);
      expect(response.processingTime, isNotNull);
      expect(response.metadata?['source'], 'fallback');
    });

    test('should get different random responses', () {
      final responses = <String>{};

      // Get 100 random responses
      for (int i = 0; i < 100; i++) {
        responses.add(FallbackResponses.getRandomResponse().content);
      }

      // Should have gotten more than one unique response
      expect(responses.length, greaterThan(1));
    });

    test('should get theme-specific response for anxiety', () {
      final response = FallbackResponses.getThemeResponse('anxiety');

      expect(response.content, contains('anxiety'));
      expect(response.verses, isNotEmpty);
      expect(response.metadata?['theme'], 'anxiety');
      expect(response.metadata?['source'], 'theme_fallback');
    });

    test('should get theme-specific response for strength', () {
      final response = FallbackResponses.getThemeResponse('strength');

      expect(response.content, contains('strength'));
      expect(response.verses, isNotEmpty);
      expect(response.metadata?['theme'], 'strength');
    });

    test('should fallback to anxiety for unknown theme', () {
      final response = FallbackResponses.getThemeResponse('unknown-theme');

      expect(response.content, isNotEmpty);
      expect(response.verses, isNotEmpty);
    });

    test('should include valid Bible verses', () {
      final response = FallbackResponses.getRandomResponse();

      for (final verse in response.verses) {
        expect(verse.book, isNotEmpty);
        expect(verse.chapter, greaterThan(0));
        expect(verse.verseNumber, greaterThan(0));
        expect(verse.text, isNotEmpty);
      }
    });

    test('should have reasonable confidence', () {
      final response = FallbackResponses.getRandomResponse();
      expect(response.confidence, greaterThanOrEqualTo(0.5));
      expect(response.confidence, lessThanOrEqualTo(1.0));
    });

    test('should have reasonable processing time', () {
      final response = FallbackResponses.getRandomResponse();
      expect(response.processingTime.inMilliseconds, lessThan(2000));
    });
  });
}
