/// Intent Detection Service
/// Determines whether user wants pastoral guidance vs theological discussion
///
/// This helps the AI respond appropriately:
/// - Guidance: Empathetic, supportive, counseling tone
/// - Discussion: Conversational, educational, exploratory tone

import 'package:flutter/foundation.dart';

/// User's conversation intent
enum ConversationIntent {
  /// Seeking emotional support, prayer, pastoral care
  guidance,

  /// Wanting to learn, discuss theology, understand concepts
  discussion,

  /// Casual conversation about faith topics
  casual,
}

/// Result of intent detection
class IntentResult {
  final ConversationIntent intent;
  final double confidence;
  final List<String> detectedPatterns;

  const IntentResult({
    required this.intent,
    required this.confidence,
    required this.detectedPatterns,
  });
}

/// Service for detecting user's conversation intent
class IntentDetectionService {
  // ============================================================================
  // GUIDANCE PATTERNS (Seeking help, support, prayer)
  // ============================================================================

  static const List<String> _guidancePatterns = [
    // Emotional distress
    'i m struggling',
    'i m feeling',
    'i feel',
    'i m worried',
    'i m anxious',
    'i m depressed',
    'i m afraid',
    'i m scared',
    'i m lost',
    'i m hurting',
    'i m broken',

    // Requests for help
    'help me',
    'i need help',
    'i need guidance',
    'i need prayer',
    'pray for me',
    'can you pray',
    'please pray',

    // Life situations
    'i m going through',
    'i m dealing with',
    'i m facing',
    'i don t know what to do',
    'what should i do',
    'how do i handle',
    'how do i cope',
    'how can i deal',

    // Direct support requests
    'i need support',
    'i need encouragement',
    'i need hope',
    'i need wisdom',
    'i need advice',
    'counsel me',
    'guide me',
  ];

  // ============================================================================
  // DISCUSSION PATTERNS (Intellectual curiosity, learning)
  // ============================================================================

  static const List<String> _discussionPatterns = [
    // Questions about theology
    'what does the bible say',
    'what does scripture say',
    'what does god say',
    'what does jesus say',
    'where in the bible',
    'is it biblical',
    'is it scriptural',

    // Explanation requests
    'can you explain',
    'help me understand',
    'i want to understand',
    'i m curious about',
    'i m wondering about',
    'what does it mean',
    'what is the meaning',
    'tell me about',
    'teach me about',

    // Discussion starters
    'let s talk about',
    'let s discuss',
    'i d like to discuss',
    'what are your thoughts',
    'what do you think about',
    'i ve been thinking about',
    'i ve been studying',

    // Doctrinal questions
    'what is',
    'who is',
    'why did',
    'how did',
    'when did',
    'what happened',
    'what s the difference between',
    'compare',
    'contrast',
  ];

  // ============================================================================
  // CASUAL PATTERNS (General conversation)
  // ============================================================================

  static const List<String> _casualPatterns = [
    // Greetings
    'hello',
    'hi',
    'hey',
    'good morning',
    'good afternoon',
    'good evening',

    // General statements
    'that s interesting',
    'i see',
    'okay',
    'thanks',
    'thank you',
    'got it',
    'i understand',

    // Follow-ups
    'tell me more',
    'continue',
    'what else',
    'anything else',
  ];

  /// Detect user's conversation intent
  IntentResult detectIntent(String userInput) {
    final normalized = _normalizeText(userInput);

    // Count pattern matches for each intent
    int guidanceScore = 0;
    int discussionScore = 0;
    int casualScore = 0;

    List<String> guidanceMatches = [];
    List<String> discussionMatches = [];
    List<String> casualMatches = [];

    // Check guidance patterns
    for (final pattern in _guidancePatterns) {
      if (normalized.contains(pattern)) {
        guidanceScore += 3; // Weight guidance higher (emotional needs prioritized)
        guidanceMatches.add(pattern);
      }
    }

    // Check discussion patterns
    for (final pattern in _discussionPatterns) {
      if (normalized.contains(pattern)) {
        discussionScore += 2;
        discussionMatches.add(pattern);
      }
    }

    // Check casual patterns
    for (final pattern in _casualPatterns) {
      if (normalized.contains(pattern)) {
        casualScore += 1;
        casualMatches.add(pattern);
      }
    }

    // Additional heuristics

    // Question marks suggest discussion/learning
    if (normalized.contains('?')) {
      // But "what should I do?" is guidance
      if (!normalized.contains('what should i') &&
          !normalized.contains('how do i') &&
          !normalized.contains('can you help')) {
        discussionScore += 1;
      }
    }

    // First-person emotional language suggests guidance
    if (normalized.contains('i m') || normalized.contains('i feel')) {
      guidanceScore += 2;
    }

    // "Truth", "real", "fake" often in challenging questions (treat as discussion)
    if (normalized.contains('truth') ||
        normalized.contains('real') ||
        normalized.contains('fake')) {
      discussionScore += 1;
    }

    // Determine primary intent
    ConversationIntent intent;
    double confidence;
    List<String> detectedPatterns;

    if (guidanceScore > discussionScore && guidanceScore > casualScore) {
      intent = ConversationIntent.guidance;
      confidence = _calculateConfidence(guidanceScore, discussionScore, casualScore);
      detectedPatterns = guidanceMatches;
    } else if (discussionScore > casualScore) {
      intent = ConversationIntent.discussion;
      confidence = _calculateConfidence(discussionScore, guidanceScore, casualScore);
      detectedPatterns = discussionMatches;
    } else {
      intent = ConversationIntent.casual;
      confidence = _calculateConfidence(casualScore, guidanceScore, discussionScore);
      detectedPatterns = casualMatches;
    }

    // Log detection
    if (kDebugMode) {
      debugPrint('💬 [IntentDetection] Input: "$userInput"');
      debugPrint('   Intent: ${intent.name} (confidence: ${(confidence * 100).toStringAsFixed(0)}%)');
      debugPrint('   Scores: guidance=$guidanceScore, discussion=$discussionScore, casual=$casualScore');
      if (detectedPatterns.isNotEmpty) {
        debugPrint('   Patterns: ${detectedPatterns.take(3).join(", ")}');
      }
    }

    return IntentResult(
      intent: intent,
      confidence: confidence,
      detectedPatterns: detectedPatterns,
    );
  }

  /// Calculate confidence score (0.0 to 1.0)
  double _calculateConfidence(int primaryScore, int secondaryScore, int tertiaryScore) {
    if (primaryScore == 0) return 0.3; // Default low confidence

    final total = primaryScore + secondaryScore + tertiaryScore;
    if (total == 0) return 0.3;

    final ratio = primaryScore / total;

    // Scale confidence based on dominance
    if (ratio > 0.7) return 0.95; // Very confident
    if (ratio > 0.5) return 0.80; // Confident
    if (ratio > 0.4) return 0.65; // Somewhat confident
    return 0.50; // Low confidence
  }

  /// Normalize text for pattern matching
  String _normalizeText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }
}
