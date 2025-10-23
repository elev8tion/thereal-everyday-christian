import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.notification.request();
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap with payload routing
    if (response.payload != null) {
      _handleNotificationPayload(response.payload!);
    }
  }

  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate accordingly
    // Format: "type:data" e.g., "verse:John 3:16" or "prayer:123"
    final parts = payload.split(':');
    if (parts.length >= 2) {
      final type = parts[0];
      final data = parts.sublist(1).join(':');

      switch (type) {
        case 'verse':
          // Navigate to daily verse screen with verse reference
          _navigateToDailyVerse(data);
          break;
        case 'prayer':
          // Navigate to prayer journal
          _navigateToPrayer(data);
          break;
        case 'reading':
          // Navigate to reading plan
          _navigateToReading(data);
          break;
      }
    }
  }

  void _navigateToDailyVerse(String reference) {
    // This will be handled by the app's navigation service
    // TODO: Implement navigation to daily verse screen
  }

  void _navigateToPrayer(String prayerId) {
    // TODO: Implement navigation to prayer journal
  }

  void _navigateToReading(String planId) {
    // TODO: Implement navigation to reading plan
  }

  Future<void> scheduleDailyDevotional({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      1,
      'Daily Devotional',
      'Start your day with God\'s word',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'devotional_channel',
          'Daily Devotional',
          channelDescription: 'Daily devotional reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleDailyVerse({
    required int hour,
    required int minute,
    required String verseReference,
    required String versePreview,
  }) async {
    // Create payload for deep linking
    final payload = 'verse:$verseReference';

    await _notifications.zonedSchedule(
      4, // Unique ID for daily verse notifications
      'Verse of the Day',
      '$verseReference - $versePreview',
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_verse_channel',
          'Daily Verse',
          channelDescription: 'Daily verse notifications',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            versePreview,
            contentTitle: 'Verse of the Day',
            summaryText: verseReference,
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showDailyVerseNotification({
    required String verseReference,
    required String verseText,
  }) async {
    try {
      // Check permission status first
      final permissionStatus = await Permission.notification.status;

      if (!permissionStatus.isGranted) {
        final newStatus = await Permission.notification.request();
        if (!newStatus.isGranted) {
          return;
        }
      }

      // Immediate notification for testing or on-demand
      final payload = 'verse:$verseReference';

      await _notifications.show(
        4,
        'Verse of the Day',
        '$verseReference - ${verseText.substring(0, verseText.length > 50 ? 50 : verseText.length)}...',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_verse_channel',
            'Daily Verse',
            channelDescription: 'Daily verse notifications',
            importance: Importance.high,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              verseText,
              contentTitle: 'Verse of the Day',
              summaryText: verseReference,
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      // Silent failure in production
      // Error details: $e
    }
  }

  Future<void> schedulePrayerReminder({
    required int hour,
    required int minute,
    required String title,
  }) async {
    await _notifications.zonedSchedule(
      2,
      'Prayer Reminder',
      'Time to pray for: $title',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Reminders',
          channelDescription: 'Prayer reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleReadingPlanReminder({
    required int hour,
    required int minute,
  }) async {
    await _notifications.zonedSchedule(
      3,
      'Bible Reading',
      'Continue your reading plan today',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_channel',
          'Reading Plan',
          channelDescription: 'Bible reading plan reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}