# MyGeri REST API Documentation for Flutter Frontend

**Base URL (Development):** `http://localhost:3030`  
**Base URL (Production):** `https://api.mygeri.com` (update sesuai domain)

**API Version:** 1.0.0  
**Last Updated:** December 17, 2025

---

## 📋 Table of Contents

1. [Authentication Flow](#authentication-flow)
2. [API Endpoints](#api-endpoints)
3. [Request/Response Format](#requestresponse-format)
4. [Error Handling](#error-handling)
5. [Security Headers](#security-headers)
6. [Flutter Implementation Guide](#flutter-implementation-guide)

---

## 🔐 Authentication Flow

### Authentication Type: JWT Bearer Token

```
Authorization: Bearer {access_token}
```

### Token Lifecycle

1. **Login** → Dapatkan `accessToken` (15 menit) dan `refreshToken` (7 hari)
2. **Gunakan** `accessToken` untuk setiap authenticated request
3. **Refresh** ketika `accessToken` expired menggunakan `refreshToken`
4. **Logout** → Blacklist `refreshToken`

### Required Headers for All Requests

```dart
{
  'Content-Type': 'application/json',
  'X-Requested-With': 'XMLHttpRequest',  // Required untuk POST/PUT/DELETE
  'Authorization': 'Bearer $accessToken',  // Untuk authenticated routes
}
```

---

## 🚀 API Endpoints

### 1. Health Check

#### GET `/health`
Cek status server (tidak perlu authentication)

**Response:**
```json
{
  "success": true,
  "timestamp": "2025-12-17T10:00:00.000Z",
  "version": "1.0.0",
  "environment": "development"
}
```

---

### 2. Authentication Endpoints

#### POST `/api/auth/register`
Registrasi user baru

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "username": "johndoe",
  "password": "SecurePass123"
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "username": "johndoe",
    "isActive": true,
    "createdAt": "2025-12-17T10:00:00.000Z"
  }
}
```

**Validation Rules:**
- `name`: Required, min 2 karakter
- `email`: Required, valid email format
- `username`: Required, min 3 karakter, alphanumeric + underscore
- `password`: Required, min 8 karakter

---

#### POST `/api/auth/login`
Login user

**Request Body:**
```json
{
  "identifier": "john@example.com",  // Bisa email atau username
  "password": "SecurePass123"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "name": "John Doe",
      "email": "john@example.com",
      "username": "johndoe",
      "roles": [
        {
          "role": "jobseeker",
          "profileData": {}
        }
      ]
    }
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

#### POST `/api/auth/refresh-token`
Refresh access token

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Token refreshed successfully",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

---

#### POST `/api/auth/logout`
Logout user dan blacklist token

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Logout successful"
}
```

---

#### POST `/api/auth/revoke-all-sessions`
Revoke semua sessions user (requires authentication)

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "All sessions revoked successfully"
}
```

---

### 3. User Profile Endpoints

#### GET `/api/users/profile`
Get profile user yang sedang login

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "username": "johndoe",
    "phone": "+6281234567890",
    "bio": "Software Developer",
    "location": "Jakarta, Indonesia",
    "isActive": true,
    "createdAt": "2025-12-17T10:00:00.000Z",
    "updatedAt": "2025-12-17T10:00:00.000Z",
    "roles": [
      {
        "role": "jobseeker",
        "profileData": {
          "skills": ["Flutter", "Dart"],
          "experience": "2 years"
        }
      }
    ]
  }
}
```

---

#### PUT `/api/users/profile`
Update profile user yang sedang login

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "phone": "+6281234567890",
  "bio": "Senior Software Developer",
  "location": "Bandung, Indonesia"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe Updated",
    "email": "john@example.com",
    "phone": "+6281234567890",
    "bio": "Senior Software Developer",
    "location": "Bandung, Indonesia"
  }
}
```

---

### 4. Admin User Management Endpoints

**Note:** Semua endpoint ini memerlukan role `admin`

#### GET `/api/users`
List semua users dengan pagination

**Headers:**
```
Authorization: Bearer {access_token}
```

**Query Parameters:**
- `page` (optional, default: 1) - Page number
- `limit` (optional, default: 10, max: 100) - Items per page
- `search` (optional) - Search by name, email, or username
- `role` (optional) - Filter by role: `jobseeker`, `company`, `admin`
- `isActive` (optional) - Filter by active status: `true` or `false`

**Example:** `/api/users?page=1&limit=20&search=john&role=jobseeker&isActive=true`

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 1,
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "name": "John Doe",
        "email": "john@example.com",
        "username": "johndoe",
        "isActive": true,
        "roles": ["jobseeker"],
        "createdAt": "2025-12-17T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 50,
      "totalPages": 3
    }
  }
}
```

---

#### GET `/api/users/:uuid`
Get user by UUID

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe",
    "email": "john@example.com",
    "username": "johndoe",
    "phone": "+6281234567890",
    "isActive": true,
    "roles": [
      {
        "role": "jobseeker",
        "profileData": {}
      }
    ]
  }
}
```

---

#### PUT `/api/users/:uuid`
Update user by UUID (admin only)

**Headers:**
```
Authorization: Bearer {access_token}
```

**Request Body:**
```json
{
  "name": "John Doe Updated",
  "email": "newemail@example.com",
  "isActive": true
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User updated successfully",
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "John Doe Updated",
    "email": "newemail@example.com",
    "isActive": true
  }
}
```

---

#### DELETE `/api/users/:uuid`
Delete user by UUID (admin only)

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

---

## 🎯 Request/Response Format

### Standard Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* response data */ }
}
```

### Standard Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": [ /* array of validation errors (optional) */ ]
}
```

---

## ⚠️ Error Handling

### HTTP Status Codes

| Status Code | Meaning | Description |
|------------|---------|-------------|
| 200 | OK | Request berhasil |
| 201 | Created | Resource berhasil dibuat |
| 400 | Bad Request | Validation error atau bad request |
| 401 | Unauthorized | Authentication required atau invalid token |
| 403 | Forbidden | Tidak punya permission |
| 404 | Not Found | Resource tidak ditemukan |
| 409 | Conflict | Data conflict (e.g., email sudah ada) |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Server error |

### Common Error Responses

#### Validation Error (400)
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    {
      "field": "email",
      "message": "Invalid email format"
    },
    {
      "field": "password",
      "message": "Password must be at least 8 characters"
    }
  ]
}
```

#### Unauthorized (401)
```json
{
  "success": false,
  "message": "Authentication required"
}
```

#### Token Expired (401)
```json
{
  "success": false,
  "message": "Token expired",
  "code": "TOKEN_EXPIRED"
}
```

#### Forbidden (403)
```json
{
  "success": false,
  "message": "Access denied. Admin role required"
}
```

#### Rate Limit (429)
```json
{
  "success": false,
  "message": "Too many requests, please try again later"
}
```

---

## 🔒 Security Headers

### Required Request Headers

```dart
final headers = {
  'Content-Type': 'application/json',
  'X-Requested-With': 'XMLHttpRequest',  // CSRF protection
  'Authorization': 'Bearer $accessToken', // Untuk authenticated requests
};
```

### Expected Response Headers

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`

---

## 📱 Flutter Implementation Guide

### 1. Setup HTTP Client

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3030'; // Development
  // static const String baseUrl = 'https://api.mygeri.com'; // Production
  
  String? _accessToken;
  String? _refreshToken;
  
  // Setter untuk tokens
  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
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
    };
    
    if (needsAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    return headers;
  }
  
  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await http.get(
      Uri.parse('$baseUrl/health'),
    );
    return json.decode(response.body);
  }
}
```

---

### 2. Authentication Service

```dart
// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // Register
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/register'),
      headers: _apiService._getHeaders(),
      body: json.encode({
        'name': name,
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }
  
  // Login
  Future<Map<String, dynamic>> login({
    required String identifier, // email or username
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/login'),
      headers: _apiService._getHeaders(),
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      // Save tokens
      _apiService.setTokens(
        data['data']['accessToken'],
        data['data']['refreshToken'],
      );
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }
  
  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/refresh-token'),
      headers: _apiService._getHeaders(),
      body: json.encode({
        'refreshToken': refreshToken,
      }),
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      // Update tokens
      _apiService.setTokens(
        data['data']['accessToken'],
        data['data']['refreshToken'],
      );
      return data;
    } else {
      throw Exception(data['message'] ?? 'Token refresh failed');
    }
  }
  
  // Logout
  Future<void> logout(String refreshToken) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/logout'),
      headers: _apiService._getHeaders(),
      body: json.encode({
        'refreshToken': refreshToken,
      }),
    );
    
    if (response.statusCode == 200) {
      _apiService.clearTokens();
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Logout failed');
    }
  }
}
```

---

### 3. User Service

```dart
// lib/services/user_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();
  
  // Get current user profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/api/users/profile'),
      headers: _apiService._getHeaders(needsAuth: true),
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized - Please login again');
    } else {
      throw Exception(data['message'] ?? 'Failed to get profile');
    }
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
    
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/api/users/profile'),
      headers: _apiService._getHeaders(needsAuth: true),
      body: json.encode(body),
    );
    
    final data = json.decode(response.body);
    
    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }
}
```

---

### 4. Error Handler

```dart
// lib/utils/api_error_handler.dart
class ApiErrorHandler {
  static String handleError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again';
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred';
  }
}
```

---

### 5. Token Storage (Secure Storage)

```dart
// pubspec.yaml
// dependencies:
//   flutter_secure_storage: ^9.0.0

// lib/utils/token_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  
  // Save tokens
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }
  
  // Get access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Delete tokens
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

---

### 6. Usage Example

```dart
// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/token_storage.dart';
import '../utils/api_error_handler.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.login(
        identifier: _emailController.text,
        password: _passwordController.text,
      );
      
      // Save tokens
      await TokenStorage.saveTokens(
        result['data']['accessToken'],
        result['data']['refreshToken'],
      );
      
      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ApiErrorHandler.handleError(e))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email or Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📝 Notes

### Rate Limiting
- **General endpoints:** 100 requests per 15 minutes
- **Auth endpoints:** Lebih ketat (untuk security)

### CORS
Allowed origins:
- `http://localhost:3030`
- `http://localhost:3000`

Untuk Flutter mobile app, tidak ada masalah CORS.

### Testing
- Gunakan admin credentials untuk testing:
  - Email: `admin@example.com`
  - Password: `Admin123!`

---

## 📞 Support

Jika ada pertanyaan atau issue, hubungi backend team atau lihat:
- Postman Collection: `/postman/mygeri-REST-API.postman_collection.json`
- README: `/README.md`

---

**Happy Coding! 🚀**
