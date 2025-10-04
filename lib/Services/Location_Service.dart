import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable location in settings.');
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Get address from coordinates
      String city = 'Unknown';
      String country = 'Unknown';

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          city = placemarks[0].locality ??
              placemarks[0].subAdministrativeArea ??
              placemarks[0].administrativeArea ??
              'Unknown';
          country = placemarks[0].country ?? 'Unknown';
        }
      } catch (e) {
        print('Error getting address: $e');
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': city,
        'country': country,
      };
    } catch (e) {
      print('Error getting location: $e');

      // Fallback to default location (Karachi)
      return {
        'latitude': 24.8607,
        'longitude': 67.0011,
        'city': 'Karachi',
        'country': 'Pakistan',
      };
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
    final dLat = (makkahLat - lat) * math.pi / 180;
    final dLng = (makkahLng - lng) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    const earthRadius = 6371; // Earth radius in km
    final distance = earthRadius * c;

    return distance;
  }

  static Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}