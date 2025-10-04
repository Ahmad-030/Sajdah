import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Services/Location_Service.dart';
import '../Services/PrayerTime_Service.dart';
import '../Widgets/Prayer_Card.dart';

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
  late AnimationController _controller;
  String currentTime = '';
  String nextPrayer = 'Loading...';
  String timeUntilPrayer = '--:--:--';
  String locationText = 'Detecting location...';
  bool isLoading = true;

  Map<String, DateTime> prayerTimes = {};
  Map<String, String> prayerTimesFormatted = {};
  Map<String, dynamic>? locationData;

  final Map<String, bool> alarmEnabled = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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

      setState(() {
        locationText = '${locationData!['city']}, ${locationData!['country']}';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        locationText = 'Location unavailable';
        isLoading = false;
      });
      print('Error initializing app: $e');
    }
  }

  void _formatPrayerTimes() {
    prayerTimesFormatted = prayerTimes.map((key, value) {
      final hour = value.hour > 12 ? value.hour - 12 : value.hour;
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

    final duration = PrayerTimeService.getTimeUntilPrayer(
        prayerTimes[nextPrayer]!
    );

    setState(() {
      final hours = duration.inHours.toString().padLeft(2, '0');
      final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      timeUntilPrayer = '$hours:$minutes:$seconds';
    });
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.isDarkMode
                        ? [
                      const Color(0xFF1B5E20),
                      const Color(0xFF004D40),
                    ]
                        : [
                      const Color(0xFF2E7D32),
                      const Color(0xFF00897B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                locationText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                widget.isDarkMode
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: Colors.white,
                              ),
                              onPressed: widget.toggleTheme,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              onPressed: _initializeApp,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          currentTime,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: isLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            )
                : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Next Prayer Card
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (math.sin(_controller.value * 2 * math.pi) * 0.02),
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Next Prayer',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                nextPrayer,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                prayerTimesFormatted[nextPrayer] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  timeUntilPrayer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // Prayer Times List
                  ...prayerTimesFormatted.entries
                      .where((e) => e.key != 'Sunrise')
                      .map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: PrayerCard(
                        prayerName: entry.key,
                        prayerTime: entry.value,
                        isAlarmOn: alarmEnabled[entry.key] ?? false,
                        onAlarmToggle: (value) {
                          setState(() {
                            alarmEnabled[entry.key] = value;
                          });
                          // Save to SharedPreferences in production
                        },
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}