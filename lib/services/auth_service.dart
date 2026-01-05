import 'api_service.dart';
import 'storage_service.dart';
import 'history_service.dart';
import '../models/user_model.dart';
import '../models/register_request.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Register user
  Future<UserModel> register(RegisterRequest request) async {
    try {
      final response = await _api.post(
        '/api/auth/register',
        request.toJson(),
      );

      if (response['success'] == true) {
        return UserModel.fromJson(response['data']);
      } else {
        // Get error details from backend
        final message = response['message'] ?? 'Registration failed';
        final errors = response['errors'];
        
        if (errors != null && errors is List && errors.isNotEmpty) {
          // Format validation errors
          final errorMessages = errors.map((e) => '• ${e['msg'] ?? e['message'] ?? e}').join('\n');
          throw Exception('$message:\n$errorMessages');
        }
        
        throw Exception(message);
      }
    } on ApiException catch (e) {
      // Handle ApiException with validation errors
      final message = e.message;
      final errors = e.errors;
      
      if (errors != null && errors is List && errors.isNotEmpty) {
        // Format validation errors
        final errorMessages = errors.map((e) => '• ${e['msg'] ?? e['message'] ?? e}').join('\n');
        throw Exception('$message:\n$errorMessages');
      }
      
      throw Exception(message);
    } catch (e) {
      // Re-throw with more context
      if (e.toString().contains('Registration failed:') || e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Registration failed: $e');
    }
  }

  // Login user
  Future<LoginResponse> login(String identifier, String password) async {
    try {
      print('=== LOGIN REQUEST ===');
      print('Identifier: "$identifier"');
      print('Password length: ${password.length}');
      
      final response = await _api.post(
        '/api/auth/login',
        {
          'identifier': identifier,
          'password': password,
        },
      );

      print('=== LOGIN RESPONSE ===');
      print('Response: $response');

      if (response['success'] == true) {
        final data = response['data'];
        
        // Check if data is null
        if (data == null) {
          throw Exception('Login response data is null');
        }
        
        // Check tokens
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        
        if (accessToken == null || accessToken.isEmpty) {
          throw Exception('Access token is missing');
        }
        if (refreshToken == null || refreshToken.isEmpty) {
          throw Exception('Refresh token is missing');
        }
        
        print('Access Token: ${accessToken.substring(0, 20)}...');
        print('Refresh Token: ${refreshToken.substring(0, 20)}...');
        
        // Save tokens (parallel write)
        await _storage.saveTokens(accessToken, refreshToken);
        
        // Verify tokens saved successfully
        print('🔍 Verifying tokens saved...');
        final savedAccessToken = await _storage.getAccessToken();
        final savedRefreshToken = await _storage.getRefreshToken();
        
        if (savedAccessToken == null || savedRefreshToken == null) {
          throw Exception('Failed to save tokens to storage. Please try again.');
        }
        
        print('✅ Tokens verified successfully');

        // Save user data
        final user = data['user'];
        if (user == null) {
          throw Exception('User data is missing');
        }
        
        print('User data: $user');
        
        await _storage.saveUserData(
          id: (user['id'] ?? 0).toString(),
          uuid: user['uuid'] as String? ?? '',
          name: user['name'] as String? ?? '',
          email: user['email'] as String? ?? '',
        );

        // Catat riwayat login
        try {
          await HistoryService().logHistory('login', description: 'Login berhasil');
        } catch (e) {
          print('❌ Gagal mencatat riwayat login: $e');
        }

        return LoginResponse(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: UserModel.fromJson(user),
        );
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('=== LOGIN ERROR ===');
      print('Error: $e');
      throw Exception('Login failed: $e');
    }
  }

  // Refresh token
  Future<void> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final response = await _api.post(
        '/api/auth/refresh-token',
        {'refreshToken': refreshToken},
      );

      if (response['success'] == true) {
        final data = response['data'];
        await _storage.saveTokens(
          data['accessToken'],
          data['refreshToken'],
        );
      }
    } catch (e) {
      throw Exception('Token refresh failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    print('=== LOGOUT START ===');
    
    try {
      final refreshToken = await _storage.getRefreshToken();
      print('Refresh token: ${refreshToken != null ? "exists" : "null"}');
      
      if (refreshToken != null) {
        // Add timeout untuk logout API call (5 detik)
        await _api.post(
          '/api/auth/logout',
          {'refreshToken': refreshToken},
        ).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('Logout API timeout - continuing anyway');
            return {'success': true}; // Return dummy response
          },
        );
      }
      print('Logout API success');
      
      // Catat riwayat logout
      try {
        await HistoryService().logHistory('logout', description: 'Logout aplikasi');
      } catch (e) {
        print('❌ Gagal mencatat riwayat logout: $e');
      }
    } catch (e) {
      // Continue logout even if API call fails
      print('Logout API error: $e - continuing anyway');
    } finally {
      print('Clearing storage...');
      await _storage.clearAll();
      print('=== LOGOUT COMPLETE ===');
    }
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    return await _storage.isLoggedIn();
  }

  // Get current user data
  Future<Map<String, String?>> getCurrentUser() async {
    return await _storage.getUserData();
  }
}

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}
