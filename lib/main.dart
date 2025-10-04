import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Screens/Splash_screen.dart';
import 'Services/Notification_Service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize notifications
  await NotificationService.initialize();

  // Request permissions
  await _requestPermissions();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SajdahApp());
}

Future<void> _requestPermissions() async {
  // Request location permission
  await Permission.location.request();

  // Request notification permission (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

class SajdahApp extends StatefulWidget {
  const SajdahApp({Key? key}) : super(key: key);

  @override
  State<SajdahApp> createState() => _SajdahAppState();
}

class _SajdahAppState extends State<SajdahApp> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sajdah',
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? _darkTheme() : _lightTheme(),
      home: SplashScreen(
        onComplete: () {},
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: const Color(0xFF2E7D32),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF2E7D32),
        secondary: Color(0xFF00BFA5),
        surface: Colors.white,
      ),
      cardTheme: const CardThemeData(
        elevation: 8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF1B5E20),
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF00BFA5),
        surface: Color(0xFF1E1E1E),
      ),
      cardTheme: const CardThemeData(
        elevation: 8,
        color: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
    );
  }
}