import 'package:flutter/material.dart';
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

    // Create notification channel for Android with azan sound
    const androidChannel = AndroidNotificationChannel(
      'prayer_times_channel',
      'Prayer Times',
      description: 'Notifications for prayer times with Azan sound',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      sound: RawResourceAndroidNotificationSound('azan'),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Request exact alarm permission for Android 12+
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Request notification permission for Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('alarm_$prayerName') ?? true;
    final reminderMinutes = prefs.getInt('reminder_minutes') ?? 5;

    if (!isEnabled) {
      print('Alarm disabled for $prayerName');
      return;
    }

    // Cancel existing notifications for this prayer
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1000);

    // Schedule reminder notification before prayer
    final reminderTime = prayerTime.subtract(Duration(minutes: reminderMinutes));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id + 1000,
        title: '⏰ $prayerName Prayer Alert',
        body: '$prayerName prayer in $reminderMinutes minutes. Get ready! 🕌',
        scheduledTime: reminderTime,
        playAzan: false,
      );
      print('Scheduled reminder for $prayerName at $reminderTime');
    }

    // Schedule main azan notification at exact prayer time
    if (prayerTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id,
        title: '🕌 $prayerName Azaan',
        body: 'It\'s time for $prayerName prayer. Allahu Akbar! 🤲',
        scheduledTime: prayerTime,
        playAzan: true,
      );
      print('Scheduled azan for $prayerName at $prayerTime');
    }
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required bool playAzan,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times with Azan sound',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: playAzan
              ? const RawResourceAndroidNotificationSound('azan')
              : null,
          enableVibration: true,
          enableLights: true,
          color: const Color(0xFF2E7D32),
          ledColor: const Color(0xFF2E7D32),
          ledOnMs: 1000,
          ledOffMs: 500,
          fullScreenIntent: playAzan,
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
            summaryText: 'Sajdah Prayer Times',
          ),
          ongoing: false,
          autoCancel: true,
          channelShowBadge: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: playAzan ? 'azan.mp3' : 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    await _notifications.cancel(id + 1000); // Cancel reminder too
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

    print('Scheduling notifications for all prayers...');

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

    print('All prayer notifications scheduled');
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
          channelDescription: 'Test notification with Azan sound',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('azan'),
          enableVibration: true,
          enableLights: true,
          color: Color(0xFF2E7D32),
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'azan.mp3',
        ),
      ),
    );
  }
}