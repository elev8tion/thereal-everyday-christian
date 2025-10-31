import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/unified_verse_service.dart';
import '../models/bible_verse.dart';
import '../models/chat_message.dart';
import '../core/services/content_filter_service.dart';
import '../core/services/input_security_service.dart';

/// Provider for AI service instance (Gemini AI)
final aiServiceProvider = Provider<AIService>((ref) {
  return GeminiAIServiceAdapter();
});

/// Provider for AI service initialization status
final aiServiceInitializedProvider = FutureProvider<bool>((ref) async {
  try {
    await GeminiAIService.instance.initialize();
    return true;
  } catch (e) {
    return false;
  }
});

/// Provider for AI service readiness
final aiServiceReadyProvider = Provider<bool>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return aiService.isReady;
});

/// Provider for AI performance stats
final aiPerformanceProvider = Provider<Map<String, dynamic>>((ref) {
  return AIPerformanceMonitor.stats;
});

/// Provider that watches for AI service state changes
final aiServiceStateProvider = StateNotifierProvider<AIServiceStateNotifier, AIServiceState>((ref) {
  return AIServiceStateNotifier(ref.read(aiServiceProvider));
});

/// State notifier for AI service state management
class AIServiceStateNotifier extends StateNotifier<AIServiceState> {
  final AIService _aiService;

  AIServiceStateNotifier(this._aiService) : super(AIServiceState.initializing()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      state = AIServiceState.initializing();
      await _aiService.initialize();

      if (_aiService.isReady) {
        state = AIServiceState.ready();
      } else {
        state = AIServiceState.fallback('AI model not available, using fallback responses');
      }
    } catch (e) {
      state = AIServiceState.error(e.toString());
    }
  }

  Future<void> reinitialize() async {
    await _initialize();
  }
}

/// AI service state
abstract class AIServiceState {
  const AIServiceState();

  factory AIServiceState.initializing() = _Initializing;
  factory AIServiceState.ready() = _Ready;
  factory AIServiceState.fallback(String reason) = _Fallback;
  factory AIServiceState.error(String message) = _Error;

  T when<T>({
    required T Function() initializing,
    required T Function() ready,
    required T Function(String reason) fallback,
    required T Function(String message) error,
  }) {
    if (this is _Initializing) return initializing();
    if (this is _Ready) return ready();
    if (this is _Fallback) return fallback((this as _Fallback).reason);
    if (this is _Error) return error((this as _Error).message);
    throw Exception('Unknown AI service state');
  }

  bool get isReady => this is _Ready;
  bool get isError => this is _Error;
  bool get isFallback => this is _Fallback;
  bool get isInitializing => this is _Initializing;
}

class _Initializing extends AIServiceState {
  const _Initializing();
}

class _Ready extends AIServiceState {
  const _Ready();
}

class _Fallback extends AIServiceState {
  final String reason;
  const _Fallback(this.reason);
}

class _Error extends AIServiceState {
  final String message;
  const _Error(this.message);
}

/// Adapter that wraps GeminiAIService to implement AIService interface
class GeminiAIServiceAdapter implements AIService {
  final GeminiAIService _gemini = GeminiAIService.instance;
  final UnifiedVerseService _verseService = UnifiedVerseService();
  final ContentFilterService _contentFilter = ContentFilterService();
  final InputSecurityService _inputSecurity = InputSecurityService();

  @override
  Future<void> initialize() async {
    await _gemini.initialize();
  }

  @override
  bool get isReady => _gemini.isReady;

  @override
  Future<AIResponse> generateResponse({
    required String userInput,
    List conversationHistory = const [],
    Map<String, dynamic>? context,
  }) async {
    final stopwatch = Stopwatch()..start();

    // ============================================================================
    // SECURITY: Validate user input BEFORE sending to AI
    // ============================================================================
    final securityCheck = _inputSecurity.validateInput(userInput);

    if (securityCheck.isRejected) {
      // Block malicious input - return safe rejection message
      return AIResponse(
        content: securityCheck.rejectionReason!,
        verses: [],
        metadata: {
          'security_blocked': true,
          'threat_level': securityCheck.threatLevel?.name,
          'detected_patterns': securityCheck.detectedPatterns,
        },
        processingTime: stopwatch.elapsed,
        confidence: 1.0, // High confidence - this is our security response
      );
    }

    // Detect theme from user input
    final themes = BiblicalPrompts.detectThemes(userInput);
    final theme = themes.isNotEmpty ? themes.first : 'comfort';

    // Get relevant verses for the theme
    final verses = await getRelevantVerses(theme, limit: 3);

    // Format conversation history with proper context and limit to last 20 messages
    final historyStrings = _formatConversationHistory(conversationHistory);

    // Call Gemini AI with error handling
    AIResponse response;
    try {
      response = await _gemini.generateResponse(
        userInput: userInput,
        theme: theme,
        verses: verses,
        conversationHistory: historyStrings,
      );
    } catch (e) {
      stopwatch.stop();
      // GRACEFUL FALLBACK: Return encouraging message with relevant verses
      return _createFallbackResponse(
        theme: theme,
        verses: verses,
        error: e.toString(),
        processingTime: stopwatch.elapsed,
      );
    }

    stopwatch.stop();

    // Filter AI response for harmful theology
    final filterResult = _contentFilter.filterResponse(response.content);

    if (filterResult.isRejected) {
      // Log the filtered response
      _contentFilter.logFilteredResponse(filterResult, response.content);

      // Use safe fallback response
      final fallbackContent = _contentFilter.getFallbackResponse(theme);

      return AIResponse(
        content: fallbackContent,
        verses: response.verses,
        metadata: {
          ...(response.metadata ?? {}),
          'filtered': true,
          'filter_reason': filterResult.rejectionReason,
        },
        processingTime: stopwatch.elapsed,
        confidence: 0.5, // Lower confidence for fallback
      );
    }

    // Return with proper processing time
    return AIResponse(
      content: response.content,
      verses: response.verses,
      metadata: response.metadata,
      processingTime: stopwatch.elapsed,
      confidence: response.confidence,
    );
  }

  @override
  Stream<String> generateResponseStream({
    required String userInput,
    List conversationHistory = const [],
    Map<String, dynamic>? context,
  }) async* {
    // ============================================================================
    // SECURITY: Validate user input BEFORE sending to AI
    // ============================================================================
    final securityCheck = _inputSecurity.validateInput(userInput);

    if (securityCheck.isRejected) {
      // Block malicious input - yield safe rejection message
      yield securityCheck.rejectionReason!;
      return;
    }

    // Detect theme from user input
    final themes = BiblicalPrompts.detectThemes(userInput);
    final theme = themes.isNotEmpty ? themes.first : 'comfort';

    // Get relevant verses for the theme
    final verses = await getRelevantVerses(theme, limit: 3);

    // Format conversation history with proper context and limit to last 20 messages
    final historyStrings = _formatConversationHistory(conversationHistory);

    // Use Gemini's streaming capability with error handling
    Stream<String> stream;
    try {
      stream = _gemini.generateStreamingResponse(
        userInput: userInput,
        theme: theme,
        verses: verses,
        conversationHistory: historyStrings,
      );
    } catch (e) {
      // GRACEFUL FALLBACK: Yield encouraging message with verses
      final fallback = _createFallbackMessage(theme, verses);
      yield fallback;
      return;
    }

    // Buffer all chunks to filter complete response
    final buffer = StringBuffer();
    try {
      await for (final chunk in stream) {
        buffer.write(chunk);
      }

      final completeResponse = buffer.toString();

      // Filter AI response for harmful theology
      final filterResult = _contentFilter.filterResponse(completeResponse);

      if (filterResult.isRejected) {
        // Log the filtered response
        _contentFilter.logFilteredResponse(filterResult, completeResponse);

        // Yield safe fallback response instead
        final fallbackContent = _contentFilter.getFallbackResponse(theme);
        yield fallbackContent;
      } else {
        // Yield the approved response
        yield completeResponse;
      }
    } catch (e) {
      // GRACEFUL FALLBACK: Stream failed mid-response
      final fallback = _createFallbackMessage(theme, verses);
      yield fallback;
    }
  }

  @override
  Future<List<BibleVerse>> getRelevantVerses(String topic, {int limit = 3}) async {
    try {
      // Use theme-based search for intelligent, contextual verse selection
      return await _verseService.searchByTheme(topic, limit: limit);
    } catch (e) {
      return [];
    }
  }

  /// Format conversation history with proper context and limit to last 20 messages
  ///
  /// Converts ChatMessage objects to natural conversation format:
  /// - USER: [user message content]
  /// - COUNSELOR: [AI response content]
  ///
  /// Limits to last 20 messages per conversation thread for:
  /// - Better performance (faster responses)
  /// - Lower API costs
  /// - Staying within token limits
  List<String> _formatConversationHistory(List conversationHistory) {
    // Limit to last 20 messages
    final recentHistory = conversationHistory.length > 20
        ? conversationHistory.sublist(conversationHistory.length - 20)
        : conversationHistory;

    // Format each message properly
    return recentHistory.map((msg) {
      if (msg is String) return msg;

      // Convert ChatMessage to natural conversation format
      if (msg is ChatMessage) {
        final label = msg.type == MessageType.user ? 'USER' : 'COUNSELOR';
        return '$label: ${msg.content}';
      }

      // Fallback for unknown types
      return msg.toString();
    }).toList();
  }

  /// Create graceful fallback response when AI service fails
  AIResponse _createFallbackResponse({
    required String theme,
    required List<BibleVerse> verses,
    required String error,
    required Duration processingTime,
  }) {
    final fallbackMessage = _createFallbackMessage(theme, verses);

    return AIResponse(
      content: fallbackMessage,
      verses: verses,
      metadata: {
        'fallback': true,
        'error': error,
        'fallback_reason': 'AI service temporarily unavailable',
      },
      processingTime: processingTime,
      confidence: 0.7, // Moderate confidence for fallback
    );
  }

  /// Create encouraging fallback message with Scripture
  String _createFallbackMessage(String theme, List<BibleVerse> verses) {
    final buffer = StringBuffer();

    // Opening message
    buffer.writeln("I'm having trouble connecting right now, but here's encouragement from Scripture while we reconnect:\n");

    // Add relevant verses
    if (verses.isNotEmpty) {
      for (final verse in verses) {
        buffer.writeln('"${verse.text}"');
        buffer.writeln('— ${verse.reference}\n');
      }
    } else {
      // Default comfort verse if no verses available
      buffer.writeln('"Cast all your anxiety on him because he cares for you."');
      buffer.writeln('— 1 Peter 5:7\n');
    }

    // Closing encouragement based on theme
    final encouragement = _getThemeEncouragement(theme);
    buffer.writeln(encouragement);

    buffer.writeln("\nPlease try sending your message again in a moment. I'm here for you.");

    return buffer.toString();
  }

  /// Get theme-specific encouragement
  String _getThemeEncouragement(String theme) {
    final encouragements = {
      'anxiety': 'God is with you in your anxiety. His peace surpasses all understanding.',
      'fear': 'You are not alone in your fear. God has not given you a spirit of fear, but of power, love, and sound mind.',
      'hope': 'Hold fast to hope. Your story is not over, and God is writing the next chapter.',
      'forgiveness': 'God\'s forgiveness is complete and unconditional. He remembers your sins no more.',
      'love': 'You are deeply loved by God. Nothing can separate you from His love.',
      'faith': 'Even when doubts arise, God is faithful. He meets you where you are.',
      'peace': 'The peace of Christ is available to you right now. Rest in His presence.',
      'strength': 'God\'s strength is made perfect in your weakness. Lean on Him.',
      'guidance': 'God will direct your steps. Trust Him one day at a time.',
      'comfort': 'God is near to the brokenhearted. He will comfort you in your pain.',
    };

    return encouragements[theme.toLowerCase()] ??
        'Remember, God is with you. He hears your prayers and cares about every detail of your life.';
  }

  @override
  Future<void> dispose() async {
    _gemini.dispose();
  }
}

/// Performance monitoring for AI service
class AIPerformanceMonitor {
  static final Map<String, dynamic> stats = {
    'total_requests': 0,
    'total_response_time_ms': 0,
    'average_response_time_ms': 0,
    'last_request_time': null,
  };
}