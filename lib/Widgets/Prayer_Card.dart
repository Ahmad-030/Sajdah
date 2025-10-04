import 'package:flutter/material.dart';
import 'dart:ui';

class PrayerCard extends StatelessWidget {
  final String prayerName;
  final String prayerTime;
  final bool isAlarmOn;
  final Function(bool) onAlarmToggle;

  const PrayerCard({
    Key? key,
    required this.prayerName,
    required this.prayerTime,
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
        return Icons.wb_cloudy;
      case 'Maghrib':
        return Icons.nights_stay;
      case 'Isha':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }

  Color _getPrayerColor(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Color(0xFF5E35B1); // Deep Purple
      case 'Dhuhr':
        return Color(0xFFFFA726); // Orange
      case 'Asr':
        return Color(0xFF42A5F5); // Blue
      case 'Maghrib':
        return Color(0xFFFF7043); // Deep Orange
      case 'Isha':
        return Color(0xFF5C6BC0); // Indigo
      default:
        return Color(0xFF66BB6A); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final prayerColor = _getPrayerColor(prayerName);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: prayerColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        prayerColor,
                        prayerColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: prayerColor.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    _getPrayerIcon(prayerName),
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                SizedBox(width: 16),

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
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.white70,
                          ),
                          SizedBox(width: 4),
                          Text(
                            prayerTime,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Alarm Toggle
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: isAlarmOn,
                      onChanged: onAlarmToggle,
                      activeColor: prayerColor,
                      activeTrackColor: prayerColor.withOpacity(0.5),
                      inactiveThumbColor: Colors.grey[400],
                      inactiveTrackColor: Colors.grey[600],
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