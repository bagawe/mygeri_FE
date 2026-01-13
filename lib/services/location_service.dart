import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<bool> requestPermission() async {
    print('📍 Requesting location permission...');

    // Check if location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      return false;
    }

    // Check permission status
    LocationPermission permission = await Geolocator.checkPermission();
    print('📍 Current permission: $permission');

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print('📍 Permission after request: $permission');

      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permission denied forever');
      return false;
    }

    print('✅ Location permission granted');
    return true;
  }

  // Request background location permission (for Android 10+)
  Future<bool> requestBackgroundPermission() async {
    if (await Permission.locationAlways.isGranted) {
      return true;
    }

    final status = await Permission.locationAlways.request();
    return status.isGranted;
  }

  // Get current position
  Future<Position?> getCurrentLocation() async {
    try {
      print('📍 Getting current location...');

      // Check permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('❌ No location permission');
        return null;
      }

      // Get location
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      print('✅ Got location: ${position.latitude}, ${position.longitude}');
      print('   Accuracy: ${position.accuracy}m');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  // Get location with medium accuracy (faster, less battery)
  Future<Position?> getCurrentLocationMedium() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );

      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  // Calculate distance between two coordinates (in kilometers)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }

  // Stream location updates (for real-time tracking)
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
