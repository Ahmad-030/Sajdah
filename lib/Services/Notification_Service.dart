import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'prayer_times_channel',
      'Prayer Times',
      description: 'Notifications for prayer times',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    int reminderMinutes = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('alarm_$prayerName') ?? true;

    if (!isEnabled) return;

    // Schedule main notification at prayer time
    await _scheduleNotification(
      id: id,
      title: '🕌 Time for $prayerName Prayer',
      body: 'It\'s time to pray $prayerName',
      scheduledTime: prayerTime,
    );

    // Schedule reminder notification
    final reminderTime = prayerTime.subtract(Duration(minutes: reminderMinutes));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id + 1000, // Different ID for reminder
        title: '⏰ $prayerName Prayer Reminder',
        body: '$prayerName prayer in $reminderMinutes minutes',
        scheduledTime: reminderTime,
      );
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // REMOVED: uiLocalNotificationDateInterpretation - This line was causing the error
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> scheduleAllPrayerNotifications(
      Map<String, DateTime> prayerTimes,
      ) async {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    // Cancel existing notifications
    await cancelAllNotifications();

    // Schedule new notifications
    for (int i = 0; i < prayers.length; i++) {
      final prayer = prayers[i];
      final prayerTime = prayerTimes[prayer];

      if (prayerTime != null) {
        await schedulePrayerNotification(
          id: i,
          prayerName: prayer,
          prayerTime: prayerTime,
        );
      }
    }
  }

  static Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}