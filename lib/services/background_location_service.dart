import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'radar_api_service.dart';
import 'location_service.dart';

class BackgroundLocationService {
  static const String _taskName = 'radar_location_update';
  static const String _uniqueName = 'radar_location_update_task';

  /// Initialize WorkManager
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
    print('✅ WorkManager initialized');
  }

  /// Start periodic location updates (every 1 hour)
  static Future<void> startPeriodicUpdates() async {
    try {
      await Workmanager().registerPeriodicTask(
        _uniqueName,
        _taskName,
        frequency: const Duration(hours: 1), // Minimum 15 minutes for Android
        initialDelay: const Duration(minutes: 1), // First run after 1 minute
        constraints: Constraints(
          networkType: NetworkType.connected, // Require internet
        ),
      );
      print('✅ Periodic location updates started (every 1 hour)');
    } catch (e) {
      print('❌ Error starting periodic updates: $e');
      rethrow;
    }
  }

  /// Stop periodic location updates
  static Future<void> stopPeriodicUpdates() async {
    try {
      await Workmanager().cancelByUniqueName(_uniqueName);
      print('✅ Periodic location updates stopped');
    } catch (e) {
      print('❌ Error stopping periodic updates: $e');
      rethrow;
    }
  }

  /// Cancel all background tasks
  static Future<void> cancelAll() async {
    try {
      await Workmanager().cancelAll();
      print('✅ All background tasks cancelled');
    } catch (e) {
      print('❌ Error cancelling all tasks: $e');
      rethrow;
    }
  }
}

/// Background task callback dispatcher
/// This function must be a top-level function (not inside a class)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('🔄 Background task started: $task');

    try {
      // Check if location sharing is enabled
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('radar_sharing_enabled') ?? false;

      if (!isEnabled) {
        print('⏭️ Location sharing disabled, skipping update');
        return Future.value(true);
      }

      print('📍 Location sharing enabled, getting current location...');

      // Get current location
      final locationService = LocationService();
      final position = await locationService.getCurrentLocationMedium();

      if (position == null) {
        print('❌ Failed to get location');
        return Future.value(false);
      }

      print('✅ Got location: ${position.latitude}, ${position.longitude}');

      // Update location to backend
      final radarApi = RadarApiService();
      await radarApi.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      print('✅ Location updated successfully in background');
      return Future.value(true);
    } catch (e) {
      print('❌ Error in background task: $e');
      return Future.value(false);
    }
  });
}
