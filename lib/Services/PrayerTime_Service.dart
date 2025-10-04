class PrayerTimeService {
  static Future<Map<String, DateTime>> calculatePrayerTimes(
      double latitude,
      double longitude,
      ) async {
    // In production, use Adhan package:
    // final coordinates = Coordinates(latitude, longitude);
    // final params = CalculationMethod.karachi.getParameters();
    // params.madhab = Madhab.hanafi;
    // final prayerTimes = PrayerTimes.today(coordinates, params);

    // For demo, calculating approximate times
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return {
      'Fajr': today.add(const Duration(hours: 5, minutes: 15)),
      'Sunrise': today.add(const Duration(hours: 6, minutes: 35)),
      'Dhuhr': today.add(const Duration(hours: 12, minutes: 30)),
      'Asr': today.add(const Duration(hours: 15, minutes: 45)),
      'Maghrib': today.add(const Duration(hours: 18, minutes: 25)),
      'Isha': today.add(const Duration(hours: 19, minutes: 45)),
    };
  }

  static String getNextPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (var prayer in prayers) {
      if (prayerTimes[prayer]!.isAfter(now)) {
        return prayer;
      }
    }
    return 'Fajr'; // Next day
  }

  static Duration getTimeUntilPrayer(DateTime prayerTime) {
    final now = DateTime.now();
    if (prayerTime.isBefore(now)) {
      // Add 24 hours for next day
      prayerTime = prayerTime.add(const Duration(days: 1));
    }
    return prayerTime.difference(now);
  }
}
