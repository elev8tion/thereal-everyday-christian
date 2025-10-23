import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences using SharedPreferences
///
/// This service provides type-safe methods for storing and retrieving
/// user settings like theme mode, language preference, and text size.
class PreferencesService {
  // Singleton pattern
  static PreferencesService? _instance;
  static SharedPreferences? _preferences;

  // Private constructor
  PreferencesService._();

  /// Get the singleton instance
  static Future<PreferencesService> getInstance() async {
    if (_instance == null) {
      _instance = PreferencesService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Initialize SharedPreferences
  Future<void> _init() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } catch (e) {
      rethrow;
    }
  }

  // Keys for stored preferences
  static const String _themeModeKey = 'theme_mode';
  static const String _languageKey = 'language_preference';
  static const String _textSizeKey = 'text_size';
  static const String _firstNameKey = 'user_first_name';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _dailyNotificationsKey = 'daily_notifications_enabled';
  static const String _prayerRemindersKey = 'prayer_reminders_enabled';
  static const String _verseOfTheDayKey = 'verse_of_the_day_enabled';
  static const String _notificationTimeKey = 'notification_time';
  static const String _termsAcceptedKey = 'terms_accepted_v1.0';
  static const String _legalAgreementsKey = 'legal_agreements_accepted_v1.0';

  // Default values
  static const String _defaultThemeMode = 'dark';
  static const String _defaultLanguage = 'English';
  static const double _defaultTextSize = 16.0;
  static const bool _defaultNotificationsEnabled = true;
  static const String _defaultNotificationTime = '08:00'; // 8:00 AM

  // ============================================================================
  // THEME MODE METHODS
  // ============================================================================

  /// Save theme mode to preferences
  ///
  /// Converts ThemeMode enum to string for storage.
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveThemeMode(ThemeMode mode) async {
    try {
      final String modeString = _themeModeToString(mode);
      final result = await _preferences?.setString(_themeModeKey, modeString);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load theme mode from preferences
  ///
  /// Returns saved ThemeMode or defaults to ThemeMode.dark if not found.
  ThemeMode loadThemeMode() {
    try {
      final String? modeString = _preferences?.getString(_themeModeKey);
      if (modeString == null) {
        return _stringToThemeMode(_defaultThemeMode);
      }
      return _stringToThemeMode(modeString);
    } catch (e) {
      return _stringToThemeMode(_defaultThemeMode);
    }
  }

  /// Convert ThemeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _stringToThemeMode(String modeString) {
    switch (modeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  // ============================================================================
  // LANGUAGE PREFERENCE METHODS
  // ============================================================================

  /// Save language preference to preferences
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveLanguage(String language) async {
    try {
      final result = await _preferences?.setString(_languageKey, language);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load language preference from preferences
  ///
  /// Returns saved language or defaults to 'English' if not found.
  String loadLanguage() {
    try {
      final String? language = _preferences?.getString(_languageKey);
      if (language == null) {
        return _defaultLanguage;
      }
      return language;
    } catch (e) {
      return _defaultLanguage;
    }
  }

  /// Alias for loadLanguage() - returns language code (e.g., 'en', 'es')
  ///
  /// Converts full language name to language code.
  String getLanguage() {
    final language = loadLanguage();
    // Convert full language name to code
    switch (language.toLowerCase()) {
      case 'english':
        return 'en';
      case 'spanish':
        return 'es';
      default:
        return language.length > 2 ? 'en' : language;
    }
  }

  /// Alias for saveLanguage() - accepts language code (e.g., 'en', 'es')
  ///
  /// Converts language code to full language name before saving.
  Future<bool> setLanguage(String languageCode) async {
    // Convert code to full language name
    String language;
    switch (languageCode.toLowerCase()) {
      case 'en':
        language = 'English';
        break;
      case 'es':
        language = 'Spanish';
        break;
      default:
        language = languageCode;
    }
    return await saveLanguage(language);
  }

  // ============================================================================
  // TEXT SIZE METHODS
  // ============================================================================

  /// Save text size to preferences
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveTextSize(double size) async {
    try {
      final result = await _preferences?.setDouble(_textSizeKey, size);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load text size from preferences
  ///
  /// Returns saved text size or defaults to 16.0 if not found.
  double loadTextSize() {
    try {
      final double? size = _preferences?.getDouble(_textSizeKey);
      if (size == null) {
        return _defaultTextSize;
      }
      return size;
    } catch (e) {
      return _defaultTextSize;
    }
  }

  // ============================================================================
  // FIRST NAME METHODS
  // ============================================================================

  /// Save user's first name to preferences
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveFirstName(String firstName) async {
    try {
      final result = await _preferences?.setString(_firstNameKey, firstName);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load user's first name from preferences
  ///
  /// Returns saved first name or null if not set.
  String? loadFirstName() {
    try {
      return _preferences?.getString(_firstNameKey);
    } catch (e) {
      return null;
    }
  }

  /// Get user's first name or "friend" as default greeting
  ///
  /// Returns saved first name or "friend" if not set.
  String getFirstNameOrDefault() {
    final firstName = loadFirstName();
    return firstName?.trim().isEmpty == true || firstName == null
        ? 'friend'
        : firstName;
  }

  /// Delete user's first name from preferences
  ///
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> deleteFirstName() async {
    try {
      final result = await _preferences?.remove(_firstNameKey);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // ONBOARDING COMPLETION METHODS
  // ============================================================================

  /// Mark onboarding as completed
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> setOnboardingCompleted() async {
    try {
      final result = await _preferences?.setBool(_onboardingCompletedKey, true);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has completed onboarding
  ///
  /// Returns true if onboarding is completed, false otherwise.
  bool hasCompletedOnboarding() {
    try {
      return _preferences?.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // NOTIFICATION SETTINGS METHODS
  // ============================================================================

  /// Save daily notifications enabled status
  Future<bool> saveDailyNotificationsEnabled(bool enabled) async {
    try {
      final result = await _preferences?.setBool(_dailyNotificationsKey, enabled);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load daily notifications enabled status
  bool loadDailyNotificationsEnabled() {
    try {
      final bool? enabled = _preferences?.getBool(_dailyNotificationsKey);
      return enabled ?? _defaultNotificationsEnabled;
    } catch (e) {
      return _defaultNotificationsEnabled;
    }
  }

  /// Save prayer reminders enabled status
  Future<bool> savePrayerRemindersEnabled(bool enabled) async {
    try {
      final result = await _preferences?.setBool(_prayerRemindersKey, enabled);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load prayer reminders enabled status
  bool loadPrayerRemindersEnabled() {
    try {
      final bool? enabled = _preferences?.getBool(_prayerRemindersKey);
      return enabled ?? _defaultNotificationsEnabled;
    } catch (e) {
      return _defaultNotificationsEnabled;
    }
  }

  /// Save verse of the day enabled status
  Future<bool> saveVerseOfTheDayEnabled(bool enabled) async {
    try {
      final result = await _preferences?.setBool(_verseOfTheDayKey, enabled);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load verse of the day enabled status
  bool loadVerseOfTheDayEnabled() {
    try {
      final bool? enabled = _preferences?.getBool(_verseOfTheDayKey);
      return enabled ?? _defaultNotificationsEnabled;
    } catch (e) {
      return _defaultNotificationsEnabled;
    }
  }

  /// Save notification time (format: "HH:mm")
  Future<bool> saveNotificationTime(String time) async {
    try {
      final result = await _preferences?.setString(_notificationTimeKey, time);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Load notification time (format: "HH:mm")
  String loadNotificationTime() {
    try {
      final String? time = _preferences?.getString(_notificationTimeKey);
      return time ?? _defaultNotificationTime;
    } catch (e) {
      return _defaultNotificationTime;
    }
  }

  // ============================================================================
  // TERMS ACCEPTANCE METHODS
  // ============================================================================

  /// Save terms acceptance status
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveTermsAcceptance(bool accepted) async {
    try {
      final result = await _preferences?.setBool(_termsAcceptedKey, accepted);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has accepted terms
  ///
  /// Returns true if terms have been accepted, false otherwise.
  bool hasAcceptedTerms() {
    try {
      final bool? accepted = _preferences?.getBool(_termsAcceptedKey);
      return accepted ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // LEGAL AGREEMENTS ACCEPTANCE METHODS (Combined disclaimer + terms/privacy)
  // ============================================================================

  /// Save legal agreements acceptance status
  ///
  /// This covers the combined legal agreements screen that includes:
  /// - Crisis disclaimer
  /// - Terms of Service
  /// - Privacy Policy
  ///
  /// Returns true if save was successful, false otherwise.
  Future<bool> saveLegalAgreementAcceptance(bool accepted) async {
    try {
      final result = await _preferences?.setBool(_legalAgreementsKey, accepted);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if user has accepted all legal agreements
  ///
  /// Returns true if legal agreements have been accepted, false otherwise.
  bool hasAcceptedLegalAgreements() {
    try {
      final bool? accepted = _preferences?.getBool(_legalAgreementsKey);
      return accepted ?? false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Clear all preferences (useful for testing or reset functionality)
  Future<bool> clearAll() async {
    try {
      final result = await _preferences?.clear();
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clear specific preference by key
  Future<bool> remove(String key) async {
    try {
      final result = await _preferences?.remove(key);
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Check if preferences have been initialized
  bool get isInitialized => _preferences != null;

  /// Get all stored preferences (for debugging)
  Map<String, dynamic> getAllPreferences() {
    if (_preferences == null) {
      return {};
    }

    return {
      'theme_mode': _preferences!.getString(_themeModeKey),
      'language': _preferences!.getString(_languageKey),
      'text_size': _preferences!.getDouble(_textSizeKey),
    };
  }
}
