import '../models/bible_verse.dart';
import '../models/chat_message.dart';
import 'verse_service.dart';

/// Service for providing contextual Bible verse recommendations
class VerseContextService {
  final VerseService _verseService = VerseService();

  /// Get verses relevant to a conversation context
  Future<List<BibleVerse>> getContextualVerses({
    required String userInput,
    List<ChatMessage> conversationHistory = const [],
    List<String> userPreferences = const [],
    int maxVerses = 3,
  }) async {
    final context = _analyzeContext(userInput, conversationHistory);

    // Get verses based on detected themes and emotions
    final verses = await _getVersesForContext(context, maxVerses);

    // Apply user preferences for filtering/ranking
    return _applyUserPreferences(verses, userPreferences);
  }

  /// Analyze conversation context to extract themes and emotions
  ConversationContext _analyzeContext(
    String userInput,
    List<ChatMessage> conversationHistory,
  ) {
    final themes = <String>{};
    final emotions = <String>{};
    final situations = <String>{};

    // Analyze current user input
    final inputAnalysis = _analyzeText(userInput);
    themes.addAll(inputAnalysis.themes);
    emotions.addAll(inputAnalysis.emotions);
    situations.addAll(inputAnalysis.situations);

    // Analyze conversation history for additional context
    for (final message in conversationHistory.reversed.take(5)) {
      if (message.isUser) {
        final historyAnalysis = _analyzeText(message.content);
        themes.addAll(historyAnalysis.themes);
        emotions.addAll(historyAnalysis.emotions);
        situations.addAll(historyAnalysis.situations);
      }
    }

    return ConversationContext(
      themes: themes.toList(),
      emotions: emotions.toList(),
      situations: situations.toList(),
      intensity: _calculateEmotionalIntensity(userInput),
      conversationLength: conversationHistory.length,
    );
  }

  /// Analyze a single text for themes, emotions, and situations
  TextAnalysis _analyzeText(String text) {
    final lowercaseText = text.toLowerCase();
    final themes = <String>{};
    final emotions = <String>{};
    final situations = <String>{};

    // Theme detection keywords
    final themeKeywords = {
      'faith': ['faith', 'believe', 'trust', 'doubt', 'believe'],
      'hope': ['hope', 'future', 'tomorrow', 'dreams', 'plans'],
      'love': ['love', 'relationship', 'family', 'friend', 'heart'],
      'peace': ['peace', 'calm', 'rest', 'quiet', 'tranquil'],
      'strength': ['strength', 'power', 'strong', 'overcome', 'endure'],
      'wisdom': ['wisdom', 'decision', 'choice', 'discernment', 'understanding'],
      'forgiveness': ['forgive', 'mercy', 'grace', 'pardon', 'reconcile'],
      'protection': ['protect', 'safe', 'security', 'shelter', 'refuge'],
      'provision': ['provide', 'need', 'supply', 'blessing', 'abundance'],
      'healing': ['heal', 'health', 'restore', 'recovery', 'wellness'],
    };

    // Emotion detection keywords
    final emotionKeywords = {
      'anxiety': ['anxious', 'worried', 'stress', 'nervous', 'overwhelmed'],
      'sadness': ['sad', 'depressed', 'down', 'blue', 'melancholy'],
      'fear': ['afraid', 'scared', 'fear', 'terrified', 'panic'],
      'anger': ['angry', 'mad', 'furious', 'irritated', 'upset'],
      'joy': ['happy', 'joyful', 'excited', 'elated', 'cheerful'],
      'gratitude': ['thankful', 'grateful', 'blessed', 'appreciate'],
      'loneliness': ['lonely', 'alone', 'isolated', 'abandoned'],
      'confusion': ['confused', 'lost', 'uncertain', 'unclear'],
    };

    // Situation detection keywords
    final situationKeywords = {
      'family': ['family', 'parent', 'child', 'spouse', 'marriage'],
      'work': ['job', 'work', 'career', 'boss', 'colleague'],
      'health': ['sick', 'illness', 'disease', 'doctor', 'hospital'],
      'finances': ['money', 'financial', 'debt', 'broke', 'bills'],
      'school': ['school', 'study', 'exam', 'student', 'education'],
      'death': ['death', 'died', 'funeral', 'grief', 'loss'],
      'moving': ['move', 'relocate', 'new city', 'change'],
      'pregnancy': ['pregnant', 'baby', 'expecting', 'childbirth'],
    };

    // Check for theme keywords
    for (final entry in themeKeywords.entries) {
      if (entry.value.any((keyword) => lowercaseText.contains(keyword))) {
        themes.add(entry.key);
      }
    }

    // Check for emotion keywords
    for (final entry in emotionKeywords.entries) {
      if (entry.value.any((keyword) => lowercaseText.contains(keyword))) {
        emotions.add(entry.key);
      }
    }

    // Check for situation keywords
    for (final entry in situationKeywords.entries) {
      if (entry.value.any((keyword) => lowercaseText.contains(keyword))) {
        situations.add(entry.key);
      }
    }

    return TextAnalysis(
      themes: themes.toList(),
      emotions: emotions.toList(),
      situations: situations.toList(),
    );
  }

  /// Calculate emotional intensity from text
  double _calculateEmotionalIntensity(String text) {
    final intensityWords = [
      'extremely', 'very', 'really', 'so', 'completely',
      'absolutely', 'totally', 'incredibly', 'deeply',
      'overwhelmingly', 'devastated', 'terrified', 'ecstatic'
    ];

    final exclamationMarks = text.split('!').length - 1;
    final capsWords = RegExp(r'\b[A-Z]{2,}\b').allMatches(text).length;
    final intensityWordCount = intensityWords
        .where((word) => text.toLowerCase().contains(word))
        .length;

    // Scale from 0 to 1
    final intensity = ((exclamationMarks * 0.2) +
                     (capsWords * 0.1) +
                     (intensityWordCount * 0.15))
                     .clamp(0.0, 1.0);

    return intensity;
  }

  /// Get verses based on conversation context
  Future<List<BibleVerse>> _getVersesForContext(
    ConversationContext context,
    int maxVerses,
  ) async {
    final verses = <BibleVerse>[];

    // Priority 1: Verses for specific emotions (highest priority for urgent needs)
    if (context.emotions.isNotEmpty) {
      for (final emotion in context.emotions.take(2)) {
        final emotionVerses = await _getVersesForEmotion(emotion);
        verses.addAll(emotionVerses);
      }
    }

    // Priority 2: Verses for life situations
    if (context.situations.isNotEmpty && verses.length < maxVerses) {
      for (final situation in context.situations.take(1)) {
        final situationVerses = await _getVersesForSituation(situation);
        verses.addAll(situationVerses);
      }
    }

    // Priority 3: Verses for spiritual themes
    if (context.themes.isNotEmpty && verses.length < maxVerses) {
      for (final theme in context.themes.take(2)) {
        final themeVerses = await _verseService.getVersesByTheme(theme, limit: 2);
        verses.addAll(themeVerses.map((v) => BibleVerse.fromMap(v)));
      }
    }

    // Remove duplicates and limit results
    final uniqueVerses = _removeDuplicateVerses(verses);
    return uniqueVerses.take(maxVerses).toList();
  }

  /// Get verses specifically for emotions
  Future<List<BibleVerse>> _getVersesForEmotion(String emotion) async {
    final emotionThemeMap = {
      'anxiety': ['peace', 'comfort', 'trust'],
      'sadness': ['comfort', 'hope', 'joy'],
      'fear': ['courage', 'protection', 'strength'],
      'anger': ['peace', 'forgiveness', 'patience'],
      'loneliness': ['presence', 'love', 'companionship'],
      'confusion': ['wisdom', 'guidance', 'clarity'],
      'gratitude': ['thankfulness', 'blessing', 'praise'],
    };

    final themes = emotionThemeMap[emotion] ?? ['comfort'];
    final verses = <BibleVerse>[];

    for (final theme in themes.take(1)) {
      final themeVerses = await _verseService.getVersesByTheme(theme, limit: 2);
      verses.addAll(themeVerses.map((v) => BibleVerse.fromMap(v)));
    }

    return verses;
  }

  /// Get verses for life situations
  Future<List<BibleVerse>> _getVersesForSituation(String situation) async {
    final situationThemeMap = {
      'family': ['love', 'unity', 'forgiveness'],
      'work': ['diligence', 'integrity', 'purpose'],
      'health': ['healing', 'strength', 'peace'],
      'finances': ['provision', 'trust', 'contentment'],
      'death': ['comfort', 'eternal', 'hope'],
      'moving': ['guidance', 'new beginnings', 'trust'],
      'pregnancy': ['blessing', 'protection', 'joy'],
    };

    final themes = situationThemeMap[situation] ?? ['guidance'];
    final verses = <BibleVerse>[];

    for (final theme in themes.take(1)) {
      final themeVerses = await _verseService.getVersesByTheme(theme, limit: 1);
      verses.addAll(themeVerses.map((v) => BibleVerse.fromMap(v)));
    }

    return verses;
  }

  /// Apply user preferences to verse selection
  List<BibleVerse> _applyUserPreferences(
    List<BibleVerse> verses,
    List<String> userPreferences,
  ) {
    if (userPreferences.isEmpty) return verses;

    // Score verses based on user preferences
    final scoredVerses = verses.map((verse) {
      double score = 0.0;

      for (final preference in userPreferences) {
        if (verse.themes.contains(preference)) {
          score += 2.0; // High weight for direct theme match
        }
        if (verse.category == preference) {
          score += 1.5; // Medium weight for category match
        }
        if (verse.text.toLowerCase().contains(preference.toLowerCase())) {
          score += 1.0; // Lower weight for text content match
        }
      }

      return ScoredVerse(verse: verse, score: score);
    }).toList();

    // Sort by score descending
    scoredVerses.sort((a, b) => b.score.compareTo(a.score));

    return scoredVerses.map((sv) => sv.verse).toList();
  }

  /// Remove duplicate verses based on reference
  List<BibleVerse> _removeDuplicateVerses(List<BibleVerse> verses) {
    final seen = <String>{};
    return verses.where((verse) {
      final reference = verse.reference;
      if (seen.contains(reference)) {
        return false;
      }
      seen.add(reference);
      return true;
    }).toList();
  }

  /// Get seasonal or liturgical verses
  Future<List<BibleVerse>> getSeasonalVerses() async {
    final now = DateTime.now();

    // Christmas season (December)
    if (now.month == 12) {
      return await _getChristmasVerses();
    }

    // Easter season (March/April - simplified)
    if (now.month == 3 || now.month == 4) {
      return await _getEasterVerses();
    }

    // New Year (January)
    if (now.month == 1) {
      return await _getNewYearVerses();
    }

    // Fall/Thanksgiving (November)
    if (now.month == 11) {
      return await _getThanksgivingVerses();
    }

    // Default to hope/encouragement verses
    final verses = await _verseService.getVersesByTheme('hope', limit: 3);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }

  Future<List<BibleVerse>> _getChristmasVerses() async {
    // Implementation would return Christmas-themed verses
    final verses = await _verseService.getVersesByTheme('joy', limit: 3);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }

  Future<List<BibleVerse>> _getEasterVerses() async {
    // Implementation would return Easter/resurrection verses
    final verses = await _verseService.getVersesByTheme('hope', limit: 3);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }

  Future<List<BibleVerse>> _getNewYearVerses() async {
    // Implementation would return new beginnings verses
    final verses = await _verseService.getVersesByTheme('purpose', limit: 3);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }

  Future<List<BibleVerse>> _getThanksgivingVerses() async {
    // Implementation would return gratitude verses
    final verses = await _verseService.getVersesByTheme('gratitude', limit: 3);
    return verses.map((v) => BibleVerse.fromMap(v)).toList();
  }
}

/// Context analysis result
class ConversationContext {
  final List<String> themes;
  final List<String> emotions;
  final List<String> situations;
  final double intensity;
  final int conversationLength;

  const ConversationContext({
    required this.themes,
    required this.emotions,
    required this.situations,
    required this.intensity,
    required this.conversationLength,
  });

  bool get hasUrgentEmotions => emotions.any((e) =>
    ['anxiety', 'fear', 'sadness', 'anger'].contains(e)) && intensity > 0.6;

  bool get isFirstMessage => conversationLength == 0;

  Map<String, dynamic> toJson() => {
    'themes': themes,
    'emotions': emotions,
    'situations': situations,
    'intensity': intensity,
    'conversation_length': conversationLength,
    'has_urgent_emotions': hasUrgentEmotions,
  };
}

/// Text analysis result
class TextAnalysis {
  final List<String> themes;
  final List<String> emotions;
  final List<String> situations;

  const TextAnalysis({
    required this.themes,
    required this.emotions,
    required this.situations,
  });
}

/// Verse with relevance score
class ScoredVerse {
  final BibleVerse verse;
  final double score;

  const ScoredVerse({
    required this.verse,
    required this.score,
  });
}

/// Verse recommendation engine
class VerseRecommendationEngine {
  final VerseContextService _contextService = VerseContextService();

  /// Get personalized verse recommendations
  Future<List<BibleVerse>> getPersonalizedRecommendations({
    required String userId,
    List<String> recentTopics = const [],
    List<String> favoriteThemes = const [],
    int maxRecommendations = 5,
  }) async {
    final recommendations = <BibleVerse>[];

    // Get verses based on recent topics
    for (final topic in recentTopics.take(2)) {
      final topicVerses = await _contextService._getVersesForEmotion(topic);
      recommendations.addAll(topicVerses);
    }

    // Get verses for favorite themes
    for (final theme in favoriteThemes.take(2)) {
      final themeVerses = await VerseService().getVersesByTheme(theme, limit: 2);
      recommendations.addAll(themeVerses.map((v) => BibleVerse.fromMap(v)));
    }

    // Add seasonal verses if space remains
    if (recommendations.length < maxRecommendations) {
      final seasonalVerses = await _contextService.getSeasonalVerses();
      recommendations.addAll(seasonalVerses);
    }

    // Remove duplicates and limit
    final uniqueVerses = _contextService._removeDuplicateVerses(recommendations);
    return uniqueVerses.take(maxRecommendations).toList();
  }
}