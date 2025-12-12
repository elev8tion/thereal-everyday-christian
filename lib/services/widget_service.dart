import 'dart:developer' as developer;
import 'package:home_widget/home_widget.dart';
import '../models/bible_verse.dart';

/// Service for managing iOS Home Screen Widget updates
///
/// Features:
/// - Daily Verse of the Day widget updates
/// - App Groups data sharing with widget extension
/// - Deep linking support
/// - Automatic widget refresh at midnight
class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  // App Group identifier (must match Xcode configuration)
  static const String _appGroupId = 'group.com.edcfaith.shared';

  // Widget data keys
  static const String _verseTextKey = 'verseText';
  static const String _verseReferenceKey = 'verseReference';
  static const String _verseTranslationKey = 'verseTranslation';
  static const String _lastUpdateKey = 'lastUpdate';

  bool _isInitialized = false;

  /// Initialize widget service with App Groups
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      developer.log('[WidgetService] Initializing with App Group: $_appGroupId',
          name: 'WidgetService');

      // Note: home_widget package automatically handles App Groups setup
      // The native iOS code will need the App Group configured in Xcode

      _isInitialized = true;
      developer.log('[WidgetService] ✅ Widget service initialized',
          name: 'WidgetService');
    } catch (e) {
      developer.log('[WidgetService] ❌ Initialization failed: $e',
          name: 'WidgetService');
      rethrow;
    }
  }

  /// Update widget with daily verse
  ///
  /// This method:
  /// 1. Serializes verse data
  /// 2. Writes to App Groups shared UserDefaults
  /// 3. Triggers widget timeline reload
  Future<void> updateDailyVerse(BibleVerse verse,
      {String translation = 'KJV'}) async {
    try {
      developer.log(
          '[WidgetService] 📝 Updating widget with verse: ${verse.reference}',
          name: 'WidgetService');

      // Save verse data to shared UserDefaults
      await HomeWidget.saveWidgetData<String>(_verseTextKey, verse.text);
      await HomeWidget.saveWidgetData<String>(
          _verseReferenceKey, verse.reference);
      await HomeWidget.saveWidgetData<String>(
          _verseTranslationKey, translation);
      await HomeWidget.saveWidgetData<String>(
          _lastUpdateKey, DateTime.now().toIso8601String());

      // Trigger widget reload
      await HomeWidget.updateWidget(
        iOSName: 'VerseWidget',
        androidName: 'VerseWidget', // Not used, but required by package
      );

      developer.log('[WidgetService] ✅ Widget updated successfully',
          name: 'WidgetService');
    } catch (e) {
      developer.log('[WidgetService] ❌ Failed to update widget: $e',
          name: 'WidgetService');
      // Don't throw - widget update failure shouldn't crash the app
    }
  }

  /// Clear widget data (useful for debugging)
  Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String?>(_verseTextKey, null);
      await HomeWidget.saveWidgetData<String?>(_verseReferenceKey, null);
      await HomeWidget.saveWidgetData<String?>(_verseTranslationKey, null);
      await HomeWidget.saveWidgetData<String?>(_lastUpdateKey, null);

      await HomeWidget.updateWidget(
        iOSName: 'VerseWidget',
        androidName: 'VerseWidget',
      );

      developer.log('[WidgetService] 🗑️ Widget data cleared',
          name: 'WidgetService');
    } catch (e) {
      developer.log('[WidgetService] ❌ Failed to clear widget data: $e',
          name: 'WidgetService');
    }
  }

  /// Register callback for widget tap events (deep linking)
  void registerCallback(Function(Uri?) callback) {
    HomeWidget.widgetClicked.listen((uri) {
      if (uri != null) {
        developer.log('[WidgetService] 🔗 Widget tapped with URI: $uri',
            name: 'WidgetService');
        callback(uri);
      }
    });
  }

  /// Get last update timestamp
  Future<DateTime?> getLastUpdate() async {
    try {
      final lastUpdate = await HomeWidget.getWidgetData<String>(_lastUpdateKey);
      if (lastUpdate != null) {
        return DateTime.parse(lastUpdate);
      }
    } catch (e) {
      developer.log('[WidgetService] ⚠️ Failed to get last update: $e',
          name: 'WidgetService');
    }
    return null;
  }

  /// Check if widget needs update (daily refresh at midnight)
  Future<bool> needsUpdate() async {
    final lastUpdate = await getLastUpdate();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    // Update if last update was before today's midnight
    return lastUpdate.isBefore(midnight);
  }
}
