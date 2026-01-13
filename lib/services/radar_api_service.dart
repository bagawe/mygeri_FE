import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/radar_models.dart';

class RadarApiService {
  final String baseUrl = 'http://103.127.138.40:3030/api/radar';
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Get My Location Status
  Future<MyLocationStatus> getMyStatus() async {
    try {
      final token = await _getToken();
      print('🗺️ GET $baseUrl/my-status');

      final response = await http.get(
        Uri.parse('$baseUrl/my-status'),
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return MyLocationStatus.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting my status: $e');
      rethrow;
    }
  }

  // 2. Toggle Location Sharing
  Future<bool> toggleSharing(bool enabled) async {
    try {
      final token = await _getToken();
      print('🗺️ POST $baseUrl/toggle-sharing (enabled: $enabled)');

      final response = await http.post(
        Uri.parse('$baseUrl/toggle-sharing'),
        headers: _headers(token),
        body: jsonEncode({'enabled': enabled}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data']['is_sharing_enabled'];
        } else {
          throw Exception(data['message'] ?? 'Failed to toggle sharing');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error toggling sharing: $e');
      rethrow;
    }
  }

  // 3. Update Location (with manual save support)
  Future<Map<String, dynamic>> updateLocation({
    required double latitude,
    required double longitude,
    double? accuracy,
    bool isSavedOnly = false, // ⭐ Tandai lokasi ini sebagai "saved marker"
  }) async {
    try {
      final token = await _getToken();
      print('🗺️ POST $baseUrl/location (lat: $latitude, lng: $longitude, savedOnly: $isSavedOnly)');

      final response = await http.post(
        Uri.parse('$baseUrl/location'),
        headers: _headers(token),
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          'is_saved_only': isSavedOnly,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Failed to update location');
        }
      } else if (response.statusCode == 429) {
        final data = jsonDecode(response.body);
        final retryAfter = data['retryAfter'] ?? 60;
        throw Exception('Tunggu $retryAfter detik sebelum menyimpan lagi');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error updating location: $e');
      rethrow;
    }
  }

  // 3b. Save Location Manually (create permanent marker)
  Future<Map<String, dynamic>> saveLocationManually({
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    return updateLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      isSavedOnly: true, // Tandai sebagai saved marker
    );
  }

  // 4. Get Nearby Locations
  Future<List<UserLocation>> getLocations({
    double? latitude,
    double? longitude,
    double? radius,
    String? region,
    String? jabatan,
    int? limit,
  }) async {
    try {
      final token = await _getToken();

      // Build query parameters
      final queryParams = <String, String>{};
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      if (region != null) queryParams['region'] = region;
      if (jabatan != null) queryParams['jabatan'] = jabatan;
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/locations').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🗺️ GET $uri');

      final response = await http.get(
        uri,
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List locationsJson = data['data'] ?? [];
          return locationsJson
              .map((json) => UserLocation.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to get locations');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting locations: $e');
      rethrow;
    }
  }

  // 5. Get Location History (Admin Only)
  Future<LocationHistory> getLocationHistory({
    required int userId,
    String? startDate,
    String? endDate,
    int? limit,
  }) async {
    try {
      final token = await _getToken();

      final queryParams = <String, String>{
        'userId': userId.toString(),
      };
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/admin/location-history').replace(
        queryParameters: queryParams,
      );

      print('🗺️ GET $uri');

      final response = await http.get(
        uri,
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return LocationHistory.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get history');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Admin access required');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting location history: $e');
      rethrow;
    }
  }

  // 6. Get Statistics (Admin Only)
  Future<RadarStats> getStats() async {
    try {
      final token = await _getToken();
      print('🗺️ GET $baseUrl/admin/stats');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return RadarStats.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get stats');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Admin access required');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting stats: $e');
      rethrow;
    }
  }
}
