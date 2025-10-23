/// Crisis Detection Service
/// Detects crisis situations in user input and triggers appropriate interventions
///
/// Handles:
/// - Suicide ideation
/// - Self-harm
/// - Abuse (physical, sexual, emotional)
/// - Severe mental health crises

import 'package:flutter/foundation.dart';

/// Types of crises that can be detected
enum CrisisType {
  suicide,
  selfHarm,
  abuse,
}

/// Crisis detection result with type and matched keywords
class CrisisDetectionResult {
  final CrisisType type;
  final List<String> matchedKeywords;
  final String userInput;

  const CrisisDetectionResult({
    required this.type,
    required this.matchedKeywords,
    required this.userInput,
  });

  /// Get crisis hotline for this crisis type
  String getHotline() {
    switch (type) {
      case CrisisType.suicide:
        return '988';
      case CrisisType.selfHarm:
        return 'Text HOME to 741741';
      case CrisisType.abuse:
        return '800-656-4673';
    }
  }

  /// Get crisis message for this type
  String getMessage() {
    switch (type) {
      case CrisisType.suicide:
        return 'We detected you may be having thoughts of suicide. Your life matters. '
            'Please call 988 (Suicide & Crisis Lifeline) right now. They\'re available 24/7.';
      case CrisisType.selfHarm:
        return 'We detected you may be considering self-harm. You don\'t have to face this alone. '
            'Please text HOME to 741741 (Crisis Text Line) for immediate support.';
      case CrisisType.abuse:
        return 'We detected you may be experiencing abuse. Your safety matters. '
            'Please call RAINN at 800-656-4673 for confidential support.';
    }
  }
}

/// Service for detecting crisis situations in user input
class CrisisDetectionService {
  // Suicide ideation keywords (direct + indirect patterns)
  static const List<String> _suicideKeywords = [
    // Direct statements
    'kill myself',
    'end it all',
    'dont want to be alive',
    'don t want to be alive',
    'dont want to live',
    'don t want to live',
    'better off dead',
    'suicide',
    'suicidal',
    'want to die',
    'end my life',
    'take my life',
    'no reason to live',
    'cant go on',
    'can t go on',
    'everyone would be better without me',
    'world would be better without me',
    'goodbye forever',
    'final message',

    // Indirect patterns - hopelessness & trapped feelings
    'no way out',
    'cant see a way out',
    'can t see a way out',
    'nothing will ever change',
    'never going to get better',
    'never gonna get better',
    'stuck forever',
    'trapped',
    'burden to everyone',
    'burden to others',
    'want to disappear',
    'cant do this anymore',
    'can t do this anymore',
    'drowning',
    'cant cope',
    'can t cope',
    'end the pain',
    'no point anymore',
    'no point in living',
    'give up on life',
    'giving up',
    'hopeless',
    'unbearable',
    'cant take it',
    'can t take it',
  ];

  // Self-harm keywords (direct + indirect patterns)
  static const List<String> _selfHarmKeywords = [
    // Direct statements
    'cut myself',
    'hurt myself',
    'self harm',
    'self-harm',
    'cutting',
    'burn myself',
    'burning myself',
    'want to hurt',
    'harming myself',
    'ive been hurting',
    'i ve been hurting',

    // Indirect patterns - risky behaviors & coping struggles
    'punish myself',
    'need to feel pain',
    'deserve to hurt',
    'deserve pain',
    'only way to cope',
    'only way i cope',
    'cant stop hurting',
    'can t stop hurting',
    'keep hurting',
    'feel numb',
    'need to feel something',
    'release the pain',
    'physical pain helps',
    'cutting helps',
    'scars',
    'fresh cuts',
    'relapsed',
  ];

  // Abuse keywords (direct + indirect patterns)
  static const List<String> _abuseKeywords = [
    // Direct statements
    'hitting me',
    'hurting me',
    'abusing me',
    'being abused',
    'im being abused',
    'i m being abused',
    'rape',
    'raped',
    'assault',
    'assaulted',
    'molest',
    'molested',
    'beating me',
    'violent',
    'threatens me',
    'afraid for my safety',
    'physically hurt',

    // Indirect patterns - fear, control, safety concerns
    'dont feel safe at home',
    'don t feel safe at home',
    'afraid to go home',
    'scared of my partner',
    'scared of my spouse',
    'controls everything i do',
    'wont let me leave',
    'won t let me leave',
    'isolates me',
    'tracks my phone',
    'checks my messages',
    'screams at me',
    'yells at me constantly',
    'calls me names',
    'makes me feel worthless',
    'blames me for everything',
    'punches walls',
    'destroys my things',
    'breaks things when angry',
    'afraid what they ll do',
    'afraid what they will do',
    'walking on eggshells',
    'cant talk about it',
    'can t talk about it',
    'made me do it',
    'forced me',
  ];

  /// Detect if user input contains crisis keywords
  /// Returns CrisisDetectionResult if crisis detected, null otherwise
  CrisisDetectionResult? detectCrisis(String userInput) {
    if (userInput.isEmpty) return null;

    final normalized = _normalizeInput(userInput);

    // Check for suicide keywords (highest priority)
    final suicideMatches = _findMatches(normalized, _suicideKeywords);
    if (suicideMatches.isNotEmpty) {
      return CrisisDetectionResult(
        type: CrisisType.suicide,
        matchedKeywords: suicideMatches,
        userInput: userInput,
      );
    }

    // Check for self-harm keywords
    final selfHarmMatches = _findMatches(normalized, _selfHarmKeywords);
    if (selfHarmMatches.isNotEmpty) {
      return CrisisDetectionResult(
        type: CrisisType.selfHarm,
        matchedKeywords: selfHarmMatches,
        userInput: userInput,
      );
    }

    // Check for abuse keywords
    final abuseMatches = _findMatches(normalized, _abuseKeywords);
    if (abuseMatches.isNotEmpty) {
      return CrisisDetectionResult(
        type: CrisisType.abuse,
        matchedKeywords: abuseMatches,
        userInput: userInput,
      );
    }

    return null;
  }

  /// Normalize user input for keyword matching
  String _normalizeInput(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), ' ') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Find keyword matches in normalized input
  List<String> _findMatches(String normalizedInput, List<String> keywords) {
    final matches = <String>[];

    for (final keyword in keywords) {
      // Check for exact phrase match
      if (normalizedInput.contains(keyword.toLowerCase())) {
        matches.add(keyword);
      }
    }

    return matches;
  }

  /// Check if input is likely a crisis based on patterns
  /// This is a more lenient check for borderline cases
  bool isPotentialCrisis(String userInput) {
    final normalized = _normalizeInput(userInput);

    // Check for concerning patterns (case insensitive)
    final concerningPatterns = [
      RegExp(r"\b(no|don\s*t|dont)\s+(point|reason|want)\s+(to\s+)?(live|go\s+on)\b", caseSensitive: false),
      RegExp(r"\b(can\s*t|cant)\s+(take\s+it|do\s+this)\s+(anymore|any\s+more)\b", caseSensitive: false),
      RegExp(r'\b(give|giving)\s+up\b', caseSensitive: false),
      RegExp(r'\b(hopeless|worthless)\b', caseSensitive: false),
      RegExp(r'\b(any|no)\s+reason\s+to\s+live\b', caseSensitive: false),
    ];

    for (final pattern in concerningPatterns) {
      if (pattern.hasMatch(normalized)) {
        return true;
      }
    }

    return false;
  }

  /// Get severity level (0-10) of detected crisis
  /// Used for logging and analytics, not for decision making
  int getCrisisSeverity(CrisisDetectionResult result) {
    switch (result.type) {
      case CrisisType.suicide:
        // Suicide is always maximum severity
        return 10;
      case CrisisType.selfHarm:
        // Self-harm is high severity
        return 8;
      case CrisisType.abuse:
        // Abuse is high severity
        return 9;
    }
  }

  /// Log crisis detection (for monitoring and improvement)
  void logCrisisDetection(CrisisDetectionResult result) {
    if (kDebugMode) {
    }

    // TODO: Add analytics logging (Firebase Analytics, etc.)
    // Do NOT log actual user input - privacy violation
  }
}
