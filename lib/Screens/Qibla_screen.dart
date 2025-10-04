import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../Services/Location_Service.dart';
import '../Widgets/Compass_painter.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _direction = 0;
  double _qiblaDirection = 0;
  int _distanceToKaaba = 0;
  bool isLoading = true;
  bool _hasCompassSupport = true;
  String locationText = 'Detecting location...';
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _initializeQibla();
    _initializeCompass();
  }

  Future<void> _initializeCompass() async {
    try {
      // Check if compass events are available
      final compassStream = FlutterCompass.events;

      if (compassStream == null) {
        setState(() {
          _hasCompassSupport = false;
        });
        return;
      }

      // Listen to compass events
      _compassSubscription = compassStream.listen((CompassEvent event) {
        if (mounted && event.heading != null) {
          setState(() {
            _direction = event.heading!;
          });
        }
      }, onError: (error) {
        print('Compass error: $error');
        if (mounted) {
          setState(() {
            _hasCompassSupport = false;
          });
        }
      });
    } catch (e) {
      print('Error initializing compass: $e');
      if (mounted) {
        setState(() {
          _hasCompassSupport = false;
        });
      }
    }
  }

  Future<void> _initializeQibla() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Get current location
      final location = await LocationService.getCurrentLocation();

      // Calculate Qibla direction
      final qiblaDir = LocationService.calculateQiblaDirection(
        location['latitude'],
        location['longitude'],
      );

      // Calculate distance to Kaaba
      final distance = LocationService.calculateDistanceToKaaba(
        location['latitude'],
        location['longitude'],
      );

      if (mounted) {
        setState(() {
          _qiblaDirection = qiblaDir;
          _distanceToKaaba = distance.round();
          locationText = '${location['city']}, ${location['country']}';
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationText = 'Location unavailable';
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error initializing Qibla: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
              const Color(0xFF1B5E20),
              const Color(0xFF121212),
            ]
                : [
              const Color(0xFF2E7D32),
              const Color(0xFFF5F7FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Text(
                      'Qibla Direction',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        _initializeQibla();
                        _initializeCompass();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        locationText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!_hasCompassSupport)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Compass not available. Please check device sensors.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: isLoading
                    ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Compass Background
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Rotating Compass
                          Transform.rotate(
                            angle: (_qiblaDirection - _direction) *
                                (math.pi / 180),
                            child: Container(
                              width: 280,
                              height: 280,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: CustomPaint(
                                painter: CompassPainter(),
                              ),
                            ),
                          ),
                          // Kaaba Icon
                          Transform.rotate(
                            angle: (_qiblaDirection - _direction) *
                                (math.pi / 180),
                            child: const Icon(
                              Icons.mosque,
                              size: 60,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          // Current direction indicator
                          Positioned(
                            top: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                '${_direction.toStringAsFixed(0)}°',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_qiblaDirection.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Qibla Direction',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '$_distanceToKaaba km to Kaaba',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFF2E7D32),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Hold device flat and rotate for accurate direction',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
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