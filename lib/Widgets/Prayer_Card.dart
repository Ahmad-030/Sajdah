import 'package:flutter/material.dart';
import 'dart:ui';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final String adhanTime;
  final String jamatTime;
  final bool isAlarmOn;
  final Function(bool) onAlarmToggle;

  const PrayerCard({
    Key? key,
    required this.prayerName,
    required this.adhanTime,
    required this.jamatTime,
    required this.isAlarmOn,
    required this.onAlarmToggle,
  }) : super(key: key);

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.wb_sunny_outlined;
      case 'Maghrib':
        return Icons.wb_cloudy;
      case 'Isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return const Color(0xFF7E57C2);
      case 'Dhuhr':
        return const Color(0xFFFFB74D);
      case 'Asr':
        return const Color(0xFFFF9800);
      case 'Maghrib':
        return const Color(0xFFE91E63);
      case 'Isha':
        return const Color(0xFF5C6BC0);
      default:
        return const Color(0xFF66BB6A);
    }
  }

  String _getPrayerDescription(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return 'Dawn Prayer';
      case 'Dhuhr':
        return 'Noon Prayer';
      case 'Asr':
        return 'Afternoon Prayer';
      case 'Maghrib':
        return 'Sunset Prayer';
      case 'Isha':
        return 'Night Prayer';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerColor = _getPrayerColor(prayerName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.08),
          ]
              : [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.2)
              : prayerColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: prayerColor.withOpacity(0.25),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Icon Container with gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        prayerColor,
                        prayerColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: prayerColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getPrayerIcon(prayerName),
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Prayer Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prayerName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPrayerDescription(prayerName),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Adhan Time Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: prayerColor.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Adhan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.access_time_rounded,
                            size: 18,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            adhanTime,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // // Jamat Time Row (Highlighted)
                      // Row(
                      //   children: [
                      //     Container(
                      //       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      //       decoration: BoxDecoration(
                      //         color: prayerColor,
                      //         borderRadius: BorderRadius.circular(4),
                      //       ),
                      //       child: const Text(
                      //         'Jamat',
                      //         style: TextStyle(
                      //           fontSize: 10,
                      //           fontWeight: FontWeight.bold,
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //     const SizedBox(width: 6),
                      //     Icon(
                      //       Icons.groups,
                      //       size: 14,
                      //       color: prayerColor,
                      //     ),
                      //     const SizedBox(width: 4),
                      //     Text(
                      //       jamatTime,
                      //       style: TextStyle(
                      //         fontSize: 16,
                      //         color: isDark ? Colors.white : Colors.black87,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                // Alarm Toggle with better styling
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Transform.scale(
                    scale: 0.85,
                    child: Switch(
                      value: isAlarmOn,
                      onChanged: onAlarmToggle,
                      activeColor: prayerColor,
                      activeTrackColor: prayerColor.withOpacity(0.5),
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: isDark
                          ? Colors.grey[700]
                          : Colors.grey[300],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}