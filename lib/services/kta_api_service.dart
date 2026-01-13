import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/kta_models.dart';
import 'storage_service.dart';

class KTAApiService {
  final String baseUrl = 'http://103.127.138.40:3030/api/kta';
  final _storage = StorageService();

  Future<String?> _getToken() async {
    return await _storage.getAccessToken();
  }

  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// 1. Get My KTA Status
  /// User melihat status KTA mereka sendiri
  Future<KTAData> getMyStatus() async {
    try {
      final token = await _getToken();
      print('🎫 GET $baseUrl/my-status');

      final response = await http.get(
        Uri.parse('$baseUrl/my-status'),
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return KTAData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get KTA status');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting KTA status: $e');
      rethrow;
    }
  }

  /// 2. Admin: Verify KTA
  /// Admin melakukan verifikasi atau reject KTA user
  Future<KTAData> verifyKTA({
    required int userId,
    required bool verified,
    String? notes,
  }) async {
    try {
      final token = await _getToken();
      print('🎫 POST $baseUrl/admin/verify');
      print('📦 Body: userId=$userId, verified=$verified, notes=$notes');

      final response = await http.post(
        Uri.parse('$baseUrl/admin/verify'),
        headers: _headers(token),
        body: jsonEncode({
          'user_id': userId,
          'verified': verified,
          if (notes != null) 'notes': notes,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return KTAData.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to verify KTA');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang bisa melakukan verifikasi.');
      } else if (response.statusCode == 404) {
        throw Exception('User tidak ditemukan');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error verifying KTA: $e');
      rethrow;
    }
  }

  /// 3. Admin: Get Users List
  /// Admin melihat daftar semua user dengan filter
  Future<Map<String, dynamic>> getUsersList({
    String status = 'all', // 'verified', 'unverified', 'all'
    String role = 'all', // 'simpatisan', 'kader', 'admin', 'all'
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final token = await _getToken();
      
      final queryParams = {
        'status': status,
        'role': role,
        'limit': limit.toString(),
        'offset': offset.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final uri = Uri.parse('$baseUrl/admin/users').replace(
        queryParameters: queryParams,
      );

      print('🎫 GET $uri');

      final response = await http.get(
        uri,
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final usersData = data['data']['users'] as List;
          final users = usersData.map((u) => KTAUser.fromJson(u)).toList();
          final pagination = Pagination.fromJson(data['data']['pagination']);

          return {
            'users': users,
            'pagination': pagination,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to get users list');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang bisa mengakses daftar user.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting users list: $e');
      rethrow;
    }
  }

  /// 4. Verify QR Code (Public)
  /// Scan QR code untuk verify validitas KTA
  Future<QRVerificationResult> verifyQRCode(String qrData) async {
    try {
      print('🎫 POST $baseUrl/verify-qr');
      print('📦 QR Data: $qrData');

      final response = await http.post(
        Uri.parse('$baseUrl/verify-qr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'qr_data': qrData,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return QRVerificationResult.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to verify QR code');
        }
      } else if (response.statusCode == 400) {
        throw Exception('QR code tidak valid');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error verifying QR code: $e');
      rethrow;
    }
  }

  /// 5. Admin: Get Statistics
  /// Admin melihat statistik verifikasi KTA
  Future<KTAStatistics> getStatistics() async {
    try {
      final token = await _getToken();
      print('🎫 GET $baseUrl/admin/stats');

      final response = await http.get(
        Uri.parse('$baseUrl/admin/stats'),
        headers: _headers(token),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return KTAStatistics.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to get statistics');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Akses ditolak. Hanya admin yang bisa melihat statistik.');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting statistics: $e');
      rethrow;
    }
  }
}
