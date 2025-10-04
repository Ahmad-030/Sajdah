import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            _getPrayerIcon(prayerName),
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          prayerName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
        subtitle: Text(
          prayerTime,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch(
          value: isAlarmOn,
          onChanged: onAlarmToggle,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}