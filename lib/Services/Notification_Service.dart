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
      description: 'Notifications for prayer times',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('azan'), // Add azan.mp3 to android/app/src/main/res/raw/
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
  }

  static void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
    int reminderMinutes = 5, // Changed to 5 minutes before
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('alarm_$prayerName') ?? true;

    if (!isEnabled) return;

    // Schedule reminder notification 5 minutes before prayer
    final reminderTime = prayerTime.subtract(Duration(minutes: reminderMinutes));
    if (reminderTime.isAfter(DateTime.now())) {
      await _scheduleNotification(
        id: id + 1000,
        title: '⏰ $prayerName Prayer Alert',
        body: '$prayerName prayer in $reminderMinutes minutes. Get ready! 🕌',
        scheduledTime: reminderTime,
        isReminder: true,
      );
    }

    // Schedule main azan notification at exact prayer time
    await _scheduleNotification(
      id: id,
      title: '🕌 $prayerName Azaan',
      body: 'It\'s time for $prayerName prayer. Allahu Akbar! 🤲',
      scheduledTime: prayerTime,
      isReminder: false,
    );
  }

  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required bool isReminder,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_times_channel',
          'Prayer Times',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          icon: '@mipmap/ic_launcher',
          // Play azan sound only for main prayer notification, not reminder
          sound: isReminder
              ? null
              : const RawResourceAndroidNotificationSound('azan'),
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
          // Keep notification visible
          ongoing: !isReminder,
          autoCancel: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: isReminder ? 'default' : 'azan.mp3', // Add azan.mp3 to ios/Runner/Resources/
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

      if (prayerTime != null && prayerTime.isAfter(DateTime.now())) {
        await schedulePrayerNotification(
          id: i,
          prayerName: prayer,
          prayerTime: prayerTime,
          reminderMinutes: 5, // 5 minutes before
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
          sound: RawResourceAndroidNotificationSound('azan'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'azan.mp3',
        ),
      ),
    );
  }
}