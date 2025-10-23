import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/unified_verse_service.dart';
import '../models/bible_verse.dart';
import '../core/services/content_filter_service.dart';

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

    // Detect theme from user input
    final themes = BiblicalPrompts.detectThemes(userInput);
    final theme = themes.isNotEmpty ? themes.first : 'comfort';

    // Get relevant verses for the theme
    final verses = await getRelevantVerses(theme, limit: 3);

    // Convert conversation history to strings (if needed)
    final historyStrings = conversationHistory.map((msg) {
      if (msg is String) return msg;
      return msg.toString();
    }).toList();

    // Call Gemini AI
    final response = await _gemini.generateResponse(
      userInput: userInput,
      theme: theme,
      verses: verses,
      conversationHistory: historyStrings,
    );

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
    // Detect theme from user input
    final themes = BiblicalPrompts.detectThemes(userInput);
    final theme = themes.isNotEmpty ? themes.first : 'comfort';

    // Get relevant verses for the theme
    final verses = await getRelevantVerses(theme, limit: 3);

    // Convert conversation history to strings
    final historyStrings = conversationHistory.map((msg) {
      if (msg is String) return msg;
      return msg.toString();
    }).toList();

    // Use Gemini's streaming capability
    final stream = _gemini.generateStreamingResponse(
      userInput: userInput,
      theme: theme,
      verses: verses,
      conversationHistory: historyStrings,
    );

    // Buffer all chunks to filter complete response
    final buffer = StringBuffer();
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
  }

  @override
  Future<List<BibleVerse>> getRelevantVerses(String topic, {int limit = 3}) async {
    try {
      return await _verseService.searchVerses(topic, limit: limit);
    } catch (e) {
      return [];
    }
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