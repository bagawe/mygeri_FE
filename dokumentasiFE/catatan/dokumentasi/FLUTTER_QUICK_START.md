# MyGeri API Configuration for Flutter

## Quick Setup Guide for Flutter Developer

### 1. API Base URLs

```dart
// Development (Local)
const String API_BASE_URL_DEV = 'http://localhost:3030';

// Production (Update dengan domain actual)
const String API_BASE_URL_PROD = 'https://api.mygeri.com';
```

### 2. Default Admin Credentials (Testing Only)

```dart
// ⚠️ HANYA UNTUK TESTING! Jangan hardcode di production
const String TEST_ADMIN_EMAIL = 'admin@example.com';
const String TEST_ADMIN_PASSWORD = 'Admin123!';
```

### 3. Token Configuration

```dart
// Token akan expired setelah:
const Duration ACCESS_TOKEN_DURATION = Duration(minutes: 15);
const Duration REFRESH_TOKEN_DURATION = Duration(days: 7);

// Auto-refresh token sebelum expired (5 menit sebelum)
const Duration TOKEN_REFRESH_THRESHOLD = Duration(minutes: 5);
```

### 4. Required Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP Client
  http: ^1.1.0
  
  # Secure Storage for tokens
  flutter_secure_storage: ^9.0.0
  
  # State Management (pilih salah satu)
  provider: ^6.1.1
  # atau
  bloc: ^8.1.3
  flutter_bloc: ^8.1.4
  
  # JSON Serialization
  json_annotation: ^4.8.1
  
dev_dependencies:
  # JSON Code Generation
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
```

### 5. API Endpoints Summary

| Method | Endpoint | Auth Required | Admin Only |
|--------|----------|---------------|------------|
| GET | `/health` | ❌ | ❌ |
| POST | `/api/auth/register` | ❌ | ❌ |
| POST | `/api/auth/login` | ❌ | ❌ |
| POST | `/api/auth/refresh-token` | ❌ | ❌ |
| POST | `/api/auth/logout` | ❌ | ❌ |
| POST | `/api/auth/revoke-all-sessions` | ✅ | ❌ |
| GET | `/api/users/profile` | ✅ | ❌ |
| PUT | `/api/users/profile` | ✅ | ❌ |
| GET | `/api/users` | ✅ | ✅ |
| GET | `/api/users/:uuid` | ✅ | ✅ |
| PUT | `/api/users/:uuid` | ✅ | ✅ |
| DELETE | `/api/users/:uuid` | ✅ | ✅ |

### 6. HTTP Status Codes

```dart
class HttpStatus {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int conflict = 409;
  static const int tooManyRequests = 429;
  static const int serverError = 500;
}
```

### 7. Model Classes (Example)

```dart
// lib/models/user_model.dart
class User {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String username;
  final String? phone;
  final String? bio;
  final String? location;
  final bool isActive;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.username,
    this.phone,
    this.bio,
    this.location,
    required this.isActive,
    required this.roles,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      phone: json['phone'],
      bio: json['bio'],
      location: json['location'],
      isActive: json['isActive'] ?? true,
      roles: (json['roles'] as List?)
          ?.map((r) => r['role'] as String)
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'bio': bio,
      'location': location,
      'isActive': isActive,
      'roles': roles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// lib/models/auth_response.dart
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['data']['accessToken'],
      refreshToken: json['data']['refreshToken'],
      user: User.fromJson(json['data']['user']),
    );
  }
}

// lib/models/api_response.dart
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<Map<String, dynamic>>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      errors: json['errors'] != null
          ? List<Map<String, dynamic>>.from(json['errors'])
          : null,
    );
  }
}
```

### 8. Testing Flow

```dart
// 1. Health Check
final health = await apiService.healthCheck();
print('API Status: ${health['success']}');

// 2. Register (opsional, skip jika sudah ada user)
await authService.register(
  name: 'Test User',
  email: 'test@example.com',
  username: 'testuser',
  password: 'TestPass123',
);

// 3. Login
final loginResult = await authService.login(
  identifier: 'admin@example.com',
  password: 'Admin123!',
);
print('Login success: ${loginResult['data']['user']['name']}');

// 4. Get Profile
final profile = await userService.getProfile();
print('User: ${profile['data']['name']}');

// 5. Update Profile
await userService.updateProfile(
  name: 'New Name',
  phone: '+6281234567890',
);

// 6. Logout
await authService.logout(refreshToken);
```

### 9. Error Messages Reference

```dart
class ApiErrorMessages {
  // Authentication Errors
  static const String invalidCredentials = 'Invalid credentials';
  static const String emailAlreadyExists = 'Email already exists';
  static const String usernameAlreadyExists = 'Username already exists';
  static const String tokenExpired = 'Token expired';
  static const String invalidToken = 'Invalid token';
  static const String authRequired = 'Authentication required';
  
  // Validation Errors
  static const String invalidEmail = 'Invalid email format';
  static const String weakPassword = 'Password must be at least 8 characters';
  static const String requiredField = 'This field is required';
  
  // Permission Errors
  static const String accessDenied = 'Access denied';
  static const String adminRequired = 'Admin role required';
  
  // General Errors
  static const String notFound = 'Resource not found';
  static const String serverError = 'Internal server error';
  static const String networkError = 'No internet connection';
  static const String timeout = 'Request timeout';
  static const String rateLimitExceeded = 'Too many requests, please try again later';
}
```

### 10. Validation Rules

```dart
class ValidationRules {
  // Email
  static final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
  );
  
  // Username (alphanumeric + underscore)
  static final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
  
  // Password (min 8 characters)
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
  
  // Name (min 2 characters)
  static bool isValidName(String name) {
    return name.length >= 2;
  }
  
  // Phone (Indonesian format)
  static final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');
}
```

### 11. Network Configuration

```dart
// lib/config/network_config.dart
class NetworkConfig {
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Retry configuration
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Required headers
  static Map<String, String> get commonHeaders => {
    'Content-Type': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
    'Accept': 'application/json',
  };
}
```

### 12. Environment Configuration

```dart
// lib/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _current = Environment.development;
  
  static Environment get current => _current;
  
  static void setEnvironment(Environment env) {
    _current = env;
  }
  
  static String get apiBaseUrl {
    switch (_current) {
      case Environment.development:
        return 'http://localhost:3030';
      case Environment.staging:
        return 'https://staging-api.mygeri.com';
      case Environment.production:
        return 'https://api.mygeri.com';
    }
  }
  
  static bool get isDebug => _current == Environment.development;
}
```

---

## 📋 Checklist untuk Flutter Developer

- [ ] Install required packages (`http`, `flutter_secure_storage`)
- [ ] Setup `ApiService` class dengan base URL
- [ ] Implement `AuthService` untuk authentication
- [ ] Implement `UserService` untuk user management
- [ ] Setup `TokenStorage` untuk secure token storage
- [ ] Create model classes (`User`, `AuthResponse`, `ApiResponse`)
- [ ] Implement error handling
- [ ] Test health check endpoint
- [ ] Test login flow
- [ ] Test get profile
- [ ] Test update profile
- [ ] Implement auto token refresh
- [ ] Handle network errors
- [ ] Add loading states
- [ ] Add proper error messages

---

## 🔗 Important Links

- **Postman Collection:** `/postman/mygeri-REST-API.postman_collection.json`
- **Full Documentation:** `/API_DOCUMENTATION_FOR_FLUTTER.md`
- **Backend README:** `/README.md`

---

## ⚡ Quick Start Command

```bash
# Backend (di laptop ini)
cd /Users/mac/development/mygery_BE
npm run dev

# Server akan berjalan di: http://localhost:3030
# Health check: http://localhost:3030/health
```

---

## 📞 Contact Backend Team

Jika ada pertanyaan tentang API atau perlu tambahan endpoint, hubungi backend team.

**Happy Coding from Flutter! 🚀📱**
