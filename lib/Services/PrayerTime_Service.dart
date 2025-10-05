import 'package:adhan/adhan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerTimeService {
  // Jamat time delay in minutes after Adhan
  static const int JAMAT_DELAY_MINUTES = 15;

  static Future<Map<String, DateTime>> calculatePrayerTimes(
      double latitude,
      double longitude,
      ) async {
    try {
      // Get calculation method from preferences
      final prefs = await SharedPreferences.getInstance();
      final methodName = prefs.getString('calculation_method') ?? 'Hanafi';

      // Create coordinates
      final coordinates = Coordinates(latitude, longitude);

      // Select calculation method based on user preference
      CalculationParameters params;

      switch (methodName) {
        case 'ISNA':
          params = CalculationMethod.north_america.getParameters();
          break;
        case 'Umm al-Qura':
          params = CalculationMethod.umm_al_qura.getParameters();
          break;
        case 'Muslim World League':
          params = CalculationMethod.muslim_world_league.getParameters();
          break;
        case 'Egyptian':
          params = CalculationMethod.egyptian.getParameters();
          break;
        case 'Hanafi':
        default:
          params = CalculationMethod.karachi.getParameters();
          params.madhab = Madhab.hanafi;
          break;
      }

      // Calculate prayer times for today
      final now = DateTime.now();
      final prayerTimes = PrayerTimes(coordinates, DateComponents.from(now), params);

      // Return Adhan times (original prayer times)
      return {
        'Fajr': prayerTimes.fajr,
        'Sunrise': prayerTimes.sunrise,
        'Dhuhr': prayerTimes.dhuhr,
        'Asr': prayerTimes.asr,
        'Maghrib': prayerTimes.maghrib,
        'Isha': prayerTimes.isha,
      };
    } catch (e) {
      print('Error calculating prayer times: $e');
      throw Exception('Failed to calculate prayer times: ${e.toString()}');
    }
  }

  // Get Jamat times (Adhan + 15 minutes)
  static Map<String, DateTime> getJamatTimes(Map<String, DateTime> adhanTimes) {
    return {
      'Fajr': adhanTimes['Fajr']!.add(const Duration(minutes: JAMAT_DELAY_MINUTES)),
      'Sunrise': adhanTimes['Sunrise']!, // Sunrise doesn't have Jamat
      'Dhuhr': adhanTimes['Dhuhr']!.add(const Duration(minutes: JAMAT_DELAY_MINUTES)),
      'Asr': adhanTimes['Asr']!.add(const Duration(minutes: JAMAT_DELAY_MINUTES)),
      'Maghrib': adhanTimes['Maghrib']!.add(const Duration(minutes: JAMAT_DELAY_MINUTES)),
      'Isha': adhanTimes['Isha']!.add(const Duration(minutes: JAMAT_DELAY_MINUTES)),
    };
  }

  static String getNextPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      final prayerTime = prayerTimes[prayer];
      if (prayerTime != null && prayerTime.isAfter(now)) {
        return prayer;
      }
    }

    // If all prayers have passed, return Fajr for next day
    return 'Fajr';
  }

  static Duration getTimeUntilPrayer(DateTime prayerTime) {
    final now = DateTime.now();

    if (prayerTime.isBefore(now)) {
      // Add 24 hours for next day
      prayerTime = prayerTime.add(const Duration(days: 1));
    }

    return prayerTime.difference(now);
  }

  static String getCurrentPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (int i = prayers.length - 1; i >= 0; i--) {
      final prayerTime = prayerTimes[prayers[i]];
      if (prayerTime != null && prayerTime.isBefore(now)) {
        return prayers[i];
      }
    }

    return 'Isha'; // Default to Isha if before Fajr
  }

  static Future<void> saveCalculationMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method);
  }

  static Future<String> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('calculation_method') ?? 'Hanafi';
  }

  static Future<void> saveAlarmState(String prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_$prayer', enabled);
  }

  static Future<bool> getAlarmState(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('alarm_$prayer') ?? true;
  }

  static Future<Map<String, bool>> loadAllAlarmStates() async {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final Map<String, bool> states = {};

    for (var prayer in prayers) {
      states[prayer] = await getAlarmState(prayer);
    }

    return states;
  }

}