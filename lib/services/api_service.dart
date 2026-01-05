import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import 'session_manager.dart';

class ApiService {
  // Base URL - UPDATED FOR REAL DEVICE TESTING (Mac via Phone Hotspot)
  // Mac IP when connected to phone hotspot
  // static const String baseUrl = 'http://10.132.51.232:3030';
  static const String baseUrl = 'http://103.127.138.40:3030';
  
  // For emulator use: 'http://10.0.2.2:3030'
  // For production use: 'https://api.mygeri.com'
  
  final StorageService _storage = StorageService();
  bool _isRefreshing = false;

  // GET request
  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout: GET $endpoint');
        },
      );
      return await _handleResponse(response);
    } on TokenRefreshedException {
      // Token refreshed, retry request
      return await _retryRequest('get', endpoint, requiresAuth: requiresAuth);
    } catch (e) {
      if (e is SessionExpiredException || e is ApiException) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout: POST $endpoint');
        },
      );
      return await _handleResponse(response);
    } on TokenRefreshedException {
      // Token refreshed, retry request
      return await _retryRequest('post', endpoint, body: body, requiresAuth: requiresAuth);
    } catch (e) {
      if (e is SessionExpiredException || e is ApiException) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout: PUT $endpoint');
        },
      );
      return await _handleResponse(response);
    } on TokenRefreshedException {
      // Token refreshed, retry request
      return await _retryRequest('put', endpoint, body: body, requiresAuth: requiresAuth);
    } catch (e) {
      if (e is SessionExpiredException || e is ApiException) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final headers = await _getHeaders(requiresAuth);
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timeout: DELETE $endpoint');
        },
      );
      return await _handleResponse(response);
    } on TokenRefreshedException {
      // Token refreshed, retry request
      return await _retryRequest('delete', endpoint, requiresAuth: requiresAuth);
    } catch (e) {
      if (e is SessionExpiredException || e is ApiException) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  // Get headers dengan atau tanpa auth
  Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };

    if (requiresAuth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Handle response with auto-refresh
  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final data = jsonDecode(response.body);
    
    // Debug logging
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // Handle token expired (401)
    if (response.statusCode == 401 && !_isRefreshing) {
      final message = data['message']?.toString().toLowerCase() ?? '';
      
      // Check if token expired
      if (message.contains('token') || message.contains('expired') || message.contains('unauthorized')) {
        try {
          _isRefreshing = true;
          
          // Try to refresh token
          final refreshToken = await _storage.getRefreshToken();
          print('Refresh token: $refreshToken');
          
          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshResponse = await http.post(
                Uri.parse('$baseUrl/api/auth/refresh-token'),
                headers: {
                  'Content-Type': 'application/json',
                  'X-Requested-With': 'XMLHttpRequest',
                },
                body: jsonEncode({'refreshToken': refreshToken}),
              ).timeout(
                const Duration(seconds: 10),
                onTimeout: () {
                  throw TimeoutException('Token refresh timeout');
                },
              );

              if (refreshResponse.statusCode == 200) {
                final refreshData = jsonDecode(refreshResponse.body);
                print('Refresh response: $refreshData');
                
                // Validate response structure
                if (refreshData['data'] == null) {
                  throw Exception('Refresh token response missing data field');
                }
                
                final accessToken = refreshData['data']['accessToken'] as String?;
                final newRefreshToken = refreshData['data']['refreshToken'] as String?;
                
                if (accessToken == null || accessToken.isEmpty) {
                  throw Exception('Refresh token response missing accessToken');
                }
                if (newRefreshToken == null || newRefreshToken.isEmpty) {
                  throw Exception('Refresh token response missing refreshToken');
                }
                
                // Save new tokens
                await _storage.saveTokens(accessToken, newRefreshToken);
                
                _isRefreshing = false;
                print('✅ Token refreshed successfully');
                
                // Don't retry here, let the caller retry
                throw TokenRefreshedException();
              } else {
                // Refresh API failed with error response
                print('⚠️ Refresh token API failed: ${refreshResponse.statusCode}');
                _isRefreshing = false;
                
                // Clear storage only if refresh actually failed (not if token is null)
                await _storage.clearAll();
                
                // Handle session expiration globally
                SessionManager().handleSessionExpired(
                  message: 'Sesi Anda telah berakhir. Silakan login kembali.',
                );
                
                throw SessionExpiredException();
              }
            } catch (e) {
              _isRefreshing = false;
              print('⚠️ Refresh token exception: $e');
              
              // Clear storage and force logout
              await _storage.clearAll();
              
              SessionManager().handleSessionExpired(
                message: 'Sesi Anda telah berakhir. Silakan login kembali.',
              );
              
              throw SessionExpiredException();
            }
          } else {
            // Refresh token is null - storage might not be ready yet!
            // DON'T clear storage, just throw exception to retry later
            _isRefreshing = false;
            print('⚠️ Refresh token is null - storage not ready or session expired');
            
            throw SessionExpiredException();
          }
        } catch (e) {
          _isRefreshing = false;
          
          // Only clear if it's not already a SessionExpiredException
          if (e is! SessionExpiredException) {
            await _storage.clearAll();
            
            SessionManager().handleSessionExpired(
              message: 'Sesi Anda telah berakhir. Silakan login kembali.',
            );
            
            throw SessionExpiredException();
          }
          
          rethrow;
        }
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: data['message'] ?? 'Unknown error',
        errors: data['errors'],
      );
    }
  }
  
  // Retry request after token refresh
  Future<Map<String, dynamic>> _retryRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    final headers = await _getHeaders(requiresAuth);
    http.Response response;

    switch (method.toLowerCase()) {
      case 'get':
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Retry request timeout: GET $endpoint');
          },
        );
        break;
      case 'post':
        response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Retry request timeout: POST $endpoint');
          },
        );
        break;
      case 'put':
        response = await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Retry request timeout: PUT $endpoint');
          },
        );
        break;
      case 'delete':
        response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Retry request timeout: DELETE $endpoint');
          },
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return await _handleResponse(response);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic errors;

  ApiException({
    required this.statusCode, 
    required this.message,
    this.errors,
  });

  @override
  String toString() => message;
}

class TokenRefreshedException implements Exception {}

class SessionExpiredException implements Exception {
  @override
  String toString() => 'Session expired. Please login again.';
}
