// =============================================================================
// COMPLETE FLUTTER API CLIENT IMPLEMENTATION
// File ini siap digunakan untuk project Flutter
// =============================================================================

// ALL IMPORTS
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// 1. API SERVICE (lib/services/api_service.dart)
// -----------------------------------------------------------------------------

class ApiService {
  static const String baseUrlDev = 'http://localhost:3030';
  static const String baseUrlProd = 'https://api.mygeri.com';
  
  // Gunakan development URL by default
  static String get baseUrl => baseUrlDev;
  
  String? _accessToken;
  String? _refreshToken;
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  // Set tokens
  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
  // Get access token
  String? get accessToken => _accessToken;
  
  // Get refresh token
  String? get refreshToken => _refreshToken;
  
  // Clear tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }
  
  // Get headers
  Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Accept': 'application/json',
    };
    
    if (needsAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }
  
  // Generic GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool needsAuth = false,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      final response = await http
          .get(uri, headers: _getHeaders(needsAuth: needsAuth))
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Generic POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool needsAuth = false,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Generic PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool needsAuth = false,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Generic DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool needsAuth = false,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: _getHeaders(needsAuth: needsAuth),
          )
          .timeout(const Duration(seconds: 30));
      
      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timeout. Please try again');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 'Request failed';
      throw ApiException(
        message: message,
        statusCode: response.statusCode,
        errors: data['errors'],
      );
    }
  }
}

// Custom Exception
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final List<dynamic>? errors;
  
  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });
  
  @override
  String toString() => message;
}

// -----------------------------------------------------------------------------
// 2. AUTH SERVICE (lib/services/auth_service.dart)
// -----------------------------------------------------------------------------
class AuthService {
  final ApiService _api = ApiService();
  
  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    return await _api.post('/api/auth/register', {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    });
  }
  
  // Login
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _api.post('/api/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    
    // Save tokens
    if (response['success'] == true && response['data'] != null) {
      _api.setTokens(
        response['data']['accessToken'],
        response['data']['refreshToken'],
      );
    }
    
    return response;
  }
  
  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _api.post('/api/auth/refresh-token', {
      'refreshToken': refreshToken,
    });
    
    // Update tokens
    if (response['success'] == true && response['data'] != null) {
      _api.setTokens(
        response['data']['accessToken'],
        response['data']['refreshToken'] ?? refreshToken,
      );
    }
    
    return response;
  }
  
  // Logout
  Future<void> logout(String refreshToken) async {
    await _api.post('/api/auth/logout', {
      'refreshToken': refreshToken,
    });
    _api.clearTokens();
  }
  
  // Revoke all sessions
  Future<void> revokeAllSessions() async {
    await _api.post('/api/auth/revoke-all-sessions', {}, needsAuth: true);
    _api.clearTokens();
  }
}

// -----------------------------------------------------------------------------
// 3. USER SERVICE (lib/services/user_service.dart)
// -----------------------------------------------------------------------------
class UserService {
  final ApiService _api = ApiService();
  
  // Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/api/users/profile', needsAuth: true);
  }
  
  // Update profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? location,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (location != null) body['location'] = location;
    
    return await _api.put('/api/users/profile', body, needsAuth: true);
  }
  
  // List users (Admin only)
  Future<Map<String, dynamic>> listUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (role != null && role.isNotEmpty) {
      queryParams['role'] = role;
    }
    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }
    
    return await _api.get(
      '/api/users',
      needsAuth: true,
      queryParams: queryParams,
    );
  }
  
  // Get user by UUID (Admin only)
  Future<Map<String, dynamic>> getUserByUuid(String uuid) async {
    return await _api.get('/api/users/$uuid', needsAuth: true);
  }
  
  // Update user by UUID (Admin only)
  Future<Map<String, dynamic>> updateUserByUuid(
    String uuid,
    Map<String, dynamic> data,
  ) async {
    return await _api.put('/api/users/$uuid', data, needsAuth: true);
  }
  
  // Delete user (Admin only)
  Future<void> deleteUser(String uuid) async {
    await _api.delete('/api/users/$uuid', needsAuth: true);
  }
}

// -----------------------------------------------------------------------------
// 4. TOKEN STORAGE (lib/utils/token_storage.dart)
// -----------------------------------------------------------------------------
// Requires: flutter_secure_storage package

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';
  
  // Save tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }
  
  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Save user data
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(key: _userDataKey, value: json.encode(userData));
  }
  
  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userDataKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }
  
  // Delete all tokens
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
  
  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

// -----------------------------------------------------------------------------
// 5. USAGE EXAMPLE (main.dart atau login_screen.dart)
// -----------------------------------------------------------------------------

// Example: Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController(text: 'admin@example.com');
  final _passwordController = TextEditingController(text: 'Admin123!');
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final result = await _authService.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Save tokens to secure storage
      await TokenStorage.saveTokens(
        result['data']['accessToken'],
        result['data']['refreshToken'],
      );
      
      // Save user data
      await TokenStorage.saveUserData(result['data']['user']);
      
      // Navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
      
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo atau Title
            const Text(
              'MyGeri',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Email TextField
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email or Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            
            // Password TextField
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            
            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade800),
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
            
            // Register Button
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.pushNamed(context, '/register');
                    },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}

// Example: Home Screen with Profile
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  final _authService = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  
  Future<void> _loadProfile() async {
    try {
      final response = await _userService.getProfile();
      setState(() {
        _userData = response['data'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }
  
  Future<void> _handleLogout() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        await _authService.logout(refreshToken);
      }
      await TokenStorage.deleteAll();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('No data'))
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Profile Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userData!['name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _userData!['email'] ?? '',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              if (_userData!['phone'] != null) ...[
                                const SizedBox(height: 4),
                                Text(_userData!['phone']),
                              ],
                              if (_userData!['bio'] != null) ...[
                                const SizedBox(height: 8),
                                Text(_userData!['bio']),
                              ],
                              if (_userData!['location'] != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text(_userData!['location']),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Edit Profile Button
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to edit profile screen
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// -----------------------------------------------------------------------------
// 6. MAIN APP SETUP
// -----------------------------------------------------------------------------
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if user is logged in
  final isLoggedIn = await TokenStorage.isLoggedIn();
  
  // Load tokens to ApiService
  if (isLoggedIn) {
    final accessToken = await TokenStorage.getAccessToken();
    final refreshToken = await TokenStorage.getRefreshToken();
    if (accessToken != null && refreshToken != null) {
      ApiService().setTokens(accessToken, refreshToken);
    }
  }
  
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyGeri App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // '/register': (context) => const RegisterScreen(),
        // '/profile/edit': (context) => const EditProfileScreen(),
      },
    );
  }
}

// -----------------------------------------------------------------------------
// NOTES:
// 1. Tambahkan ke pubspec.yaml:
//    - http: ^1.1.0
//    - flutter_secure_storage: ^9.0.0
//
// 2. Untuk iOS, tambahkan di ios/Runner/Info.plist:
//    <key>NSAppTransportSecurity</key>
//    <dict>
//      <key>NSAllowsLocalNetworking</key>
//      <true/>
//    </dict>
//
// 3. Untuk Android, tidak perlu konfigurasi tambahan untuk localhost
//
// 4. Untuk testing di physical device, ganti localhost dengan IP laptop:
//    static const String baseUrlDev = 'http://192.168.1.XXX:3030';
//    (cek IP dengan: ifconfig | grep inet)
// -----------------------------------------------------------------------------
