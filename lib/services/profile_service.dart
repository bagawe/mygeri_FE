import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_profile.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ProfileService {
  final ApiService _apiService;
  final StorageService _storage = StorageService();

  ProfileService(this._apiService);

  // Get current user profile
  Future<UserProfile> getProfile() async {
    try {
      print('🔍 ProfileService: Getting profile...');
      final response = await _apiService.get('/api/users/profile', requiresAuth: true);

      print('✅ ProfileService: Profile retrieved successfully');
      return UserProfile.fromJson(response['data']);
    } catch (e) {
      print('❌ ProfileService: Error getting profile - $e');
      rethrow;
    }
  }

  /// Refresh profile & update role di localStorage
  /// Dipanggil secara periodik atau manual untuk mendeteksi perubahan role
  /// Returns: {profile, roleChanged, newRole}
  Future<Map<String, dynamic>> refreshUserProfile() async {
    try {
      print('🔄 ProfileService: Refreshing user profile...');
      final response = await _apiService.get('/api/users/profile', requiresAuth: true);
      final data = response['data'];

      // Debug: log raw role data dari API
      print('🔍 ProfileService: raw data[role] = ${data['role']}');
      print('🔍 ProfileService: raw data[roles] = ${data['roles']}');

      // Ambil role baru dari API response
      // Backend bisa kirim 'role' (string) atau 'roles' (array of objects)
      String newRole = 'simpatisan';
      
      if (data['role'] != null && data['role'] is String && (data['role'] as String).isNotEmpty) {
        // Format 1: flat string "role": "kader"
        newRole = data['role'] as String;
      } else if (data['roles'] != null && data['roles'] is List && (data['roles'] as List).isNotEmpty) {
        // Format 2: array "roles": [{"role": "kader", ...}]
        final rolesList = data['roles'] as List;
        // Ambil role tertinggi (prioritas: admin > kader > simpatisan)
        for (final r in rolesList) {
          final roleName = (r is Map) ? (r['role'] as String? ?? '') : r.toString();
          if (roleName == 'admin') {
            newRole = 'admin';
            break;
          } else if (roleName == 'kader') {
            newRole = 'kader';
          } else if (roleName == 'simpatisan' && newRole != 'kader') {
            newRole = 'simpatisan';
          }
        }
      }

      final oldRole = await _storage.getUserRole();

      // Update role di storage
      await _storage.saveUserRole(newRole);

      final roleChanged = oldRole != newRole;
      if (roleChanged) {
        print('🎉 Role berubah: $oldRole → $newRole');
      } else {
        print('✅ Role tidak berubah: $newRole');
      }

      return {
        'profile': UserProfile.fromJson(data),
        'roleChanged': roleChanged,
        'oldRole': oldRole,
        'newRole': newRole,
      };
    } catch (e) {
      print('❌ ProfileService: Error refreshing profile - $e');
      rethrow;
    }
  }

  // Update profile (partial update)
  Future<UserProfile> updateProfile(Map<String, dynamic> profileData) async {
    try {
      print('🔄 ProfileService: Updating profile...');
      print('📤 Data: ${jsonEncode(profileData)}');
      
      final response = await _apiService.put('/api/users/profile', profileData, requiresAuth: true);
      
      print('✅ ProfileService: Profile updated successfully');
      return UserProfile.fromJson(response['data']);
    } catch (e) {
      print('❌ ProfileService: Error updating profile - $e');
      
      // Handle ApiException with validation errors
      if (e is ApiException && e.errors != null) {
        List<String> errorMessages = [];
        for (var error in e.errors!) {
          if (error is Map && error.containsKey('message')) {
            errorMessages.add(error['message'].toString());
          }
        }
        if (errorMessages.isNotEmpty) {
          throw Exception(errorMessages.join(', '));
        }
      }
      
      rethrow;
    }
  }

  // Upload photo (KTP or Profile)
  Future<String> uploadFoto(File imageFile, String fotoType) async {
    try {
      // Validate fotoType
      if (!['ktp', 'profil'].contains(fotoType)) {
        throw Exception('Invalid fotoType. Must be "ktp" or "profil"');
      }

      print('📸 ProfileService: Uploading $fotoType photo...');
      
      final uri = Uri.parse('${ApiService.baseUrl}/api/users/profile/upload-foto');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      final storage = StorageService();
      final token = await storage.getAccessToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fotoType field
      request.fields['fotoType'] = fotoType;

      // Add file
      String fileName = imageFile.path.split('/').last;
      String ext = fileName.split('.').last.toLowerCase();

      // Determine mime type
      String mimeType = 'image/jpeg';
      if (ext == 'png') mimeType = 'image/png';

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', ext),
        ),
      );

      print('📤 Sending file: $fileName ($mimeType)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photoUrl = data['data']['url'] as String;
        
        print('✅ ProfileService: Photo uploaded successfully');
        print('📷 Photo URL: $photoUrl');
        
        return photoUrl;
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? 'Failed to upload foto';
        
        print('❌ ProfileService: Upload failed - $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ ProfileService: Error uploading photo - $e');
      rethrow;
    }
  }
}
