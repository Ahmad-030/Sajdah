import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../Services/Location_Service.dart';
import '../Services/PrayerTime_Service.dart';
import '../Services/Notification_Service.dart';
import '../Widgets/Prayer_Card.dart';
import 'dart:ui';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    Key? key,
    required this.toggleTheme,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  String currentTime = '';
  String nextPrayer = 'Loading...';
  String timeUntilPrayer = '--:--:--';
  String locationText = 'Detecting location...';
  bool isLoading = true;

  Map<String, DateTime> prayerTimes = {};
  Map<String, String> prayerTimesFormatted = {};
  Map<String, dynamic>? locationData;

  Map<String, bool> alarmEnabled = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTime();
        _updateCountdown();
      }
    });

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Load saved alarm states
      alarmEnabled = await PrayerTimeService.loadAllAlarmStates();

      // Get location
      locationData = await LocationService.getCurrentLocation();

      // Calculate prayer times
      prayerTimes = await PrayerTimeService.calculatePrayerTimes(
        locationData!['latitude'],
        locationData!['longitude'],
      );

      // Format prayer times
      _formatPrayerTimes();

      // Update next prayer
      _updateNextPrayer();

      // Schedule notifications
      await NotificationService.scheduleAllPrayerNotifications(prayerTimes);

      // Update home screen widget
      await _updateHomeWidget();

      setState(() {
        locationText = '${locationData!['city']}, ${locationData!['country']}';
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Prayer times updated'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        locationText = 'Location unavailable';
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Error: ${e.toString()}')),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error initializing app: $e');
    }
  }

  Future<void> _updateHomeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>('next_prayer', nextPrayer);
      await HomeWidget.saveWidgetData<String>('prayer_time', prayerTimesFormatted[nextPrayer] ?? '');
      await HomeWidget.saveWidgetData<String>('time_remaining', timeUntilPrayer);
      await HomeWidget.updateWidget(
        name: 'SajdahWidgetProvider',
        androidName: 'SajdahWidgetProvider',
        iOSName: 'SajdahWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  void _formatPrayerTimes() {
    prayerTimesFormatted = prayerTimes.map((key, value) {
      final hour = value.hour > 12 ? value.hour - 12 : (value.hour == 0 ? 12 : value.hour);
      final minute = value.minute.toString().padLeft(2, '0');
      final period = value.hour >= 12 ? 'PM' : 'AM';
      return MapEntry(key, '$hour:$minute $period');
    });
  }

  void _updateNextPrayer() {
    if (prayerTimes.isEmpty) return;
    setState(() {
      nextPrayer = PrayerTimeService.getNextPrayer(prayerTimes);
    });
  }

  void _updateCountdown() {
    if (prayerTimes.isEmpty || nextPrayer == 'Loading...') return;

    final prayerTime = prayerTimes[nextPrayer];
    if (prayerTime == null) return;

    final duration = PrayerTimeService.getTimeUntilPrayer(prayerTime);

    setState(() {
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      timeUntilPrayer = '$hours:$minutes:$seconds';
    });

    _updateHomeWidget();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
      final minute = now.minute.toString().padLeft(2, '0');
      final second = now.second.toString().padLeft(2, '0');
      final period = now.hour >= 12 ? 'PM' : 'AM';
      currentTime = '$hour:$minute:$second $period';
    });
  }

  Future<void> _handleAlarmToggle(String prayer, bool value) async {
    setState(() {
      alarmEnabled[prayer] = value;
    });

    await PrayerTimeService.saveAlarmState(prayer, value);

    if (prayerTimes.isNotEmpty) {
      await NotificationService.scheduleAllPrayerNotifications(prayerTimes);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(value ? Icons.notifications_active : Icons.notifications_off, color: Colors.white),
              SizedBox(width: 10),
              Text(value ? '$prayer alarm enabled' : '$prayer alarm disabled'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isDarkMode
                ? [
              Color(0xFF1B5E20),
              Color(0xFF004D40),
              Color(0xFF263238),
            ]
                : [
              Color(0xFF2E7D32),
              Color(0xFF00897B),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sajdah',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    locationText,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                    color: Colors.white,
                                  ),
                                  onPressed: widget.toggleTheme,
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.refresh, color: Colors.white),
                                  onPressed: _initializeApp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Current Time Display
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Time',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      currentTime,
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.access_time, color: Colors.white, size: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: isLoading
                    ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Next Prayer Card with Animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (math.sin(_pulseController.value * 2 * math.pi) * 0.02),
                            child: Container(
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.mosque, color: Colors.white, size: 24),
                                          SizedBox(width: 8),
                                          Text(
                                            'Next Prayer',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15),
                                      Text(
                                        nextPrayer,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        prayerTimesFormatted[nextPrayer] ?? '',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 25,
                                          vertical: 15,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.timer, color: Colors.white, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              timeUntilPrayer,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),

                      // Prayer Times List Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Today\'s Prayers',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),

                      // Prayer Times List
                      ...prayerTimesFormatted.entries
                          .where((e) => e.key != 'Sunrise')
                          .map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: PrayerCard(
                            prayerName: entry.key,
                            prayerTime: entry.value,
                            isAlarmOn: alarmEnabled[entry.key] ?? true,
                            onAlarmToggle: (value) => _handleAlarmToggle(entry.key, value),
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}