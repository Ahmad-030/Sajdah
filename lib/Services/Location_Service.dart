import 'dart:math' as math;

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // In production, use Geolocator:
      // bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // if (!serviceEnabled) {
      //   throw Exception('Location services are disabled');
      // }

      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      // }

      // Position position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );

      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //   position.latitude,
      //   position.longitude,
      // );

      // For demo purposes - Khurarianwala coordinates
      return {
        'latitude': 31.5204,
        'longitude': 73.0479,
        'city': 'Khurarianwala',
        'country': 'Pakistan',
      };
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  static double calculateQiblaDirection(double lat, double lng) {
    const makkahLat = 21.4225;
    const makkahLng = 39.8262;

    final dLng = (makkahLng - lng) * math.pi / 180;
    final lat1 = lat * math.pi / 180;
    final lat2 = makkahLat * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final bearing = (math.atan2(y, x) * 180 / math.pi + 360) % 360;
    return bearing;
  }

  static double calculateDistanceToKaaba(double lat, double lng) {
    const makkahLat = 21.4225;
    const makkahLng = 39.8262;

    final lat1 = lat * math.pi / 180;
    final lat2 = makkahLat * math.pi / 180;
    final dLng = (makkahLng - lng) * math.pi / 180;

    final distance = math.acos(
        math.sin(lat1) * math.sin(lat2) +
            math.cos(lat1) * math.cos(lat2) * math.cos(dLng)
    ) * 6371; // Earth radius in km

    return distance;
  }
}