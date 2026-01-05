# 🚀 MyGeri API - Quick Reference Card

**Backend:** http://localhost:3030  
**Version:** 1.0.0  
**For:** Flutter Frontend Development

---

## 🔑 Test Credentials
```
Email: admin@example.com
Password: Admin123!
```

---

## 🌐 Base URLs
```dart
// Development
'http://localhost:3030'

// Physical Device (ganti dengan IP laptop)
'http://192.168.1.XXX:3030'

// Production
'https://api.mygeri.com'
```

---

## 📍 Endpoints

### Health Check
```
GET  /health
```

### Authentication
```
POST /api/auth/register
POST /api/auth/login
POST /api/auth/refresh-token
POST /api/auth/logout
POST /api/auth/revoke-all-sessions  [AUTH]
```

### User Profile
```
GET  /api/users/profile              [AUTH]
PUT  /api/users/profile              [AUTH]
```

### Admin User Management
```
GET    /api/users                    [AUTH] [ADMIN]
GET    /api/users/:uuid              [AUTH] [ADMIN]
PUT    /api/users/:uuid              [AUTH] [ADMIN]
DELETE /api/users/:uuid              [AUTH] [ADMIN]
```

---

## 📦 Request Headers
```dart
{
  'Content-Type': 'application/json',
  'X-Requested-With': 'XMLHttpRequest',
  'Authorization': 'Bearer $accessToken',  // if authenticated
}
```

---

## 🔐 Authentication Flow

### 1. Login
```dart
POST /api/auth/login
Body: { "identifier": "email", "password": "pass" }
Response: { "accessToken": "...", "refreshToken": "..." }
```

### 2. Use Access Token
```dart
GET /api/users/profile
Headers: { "Authorization": "Bearer {accessToken}" }
```

### 3. Refresh Token (when expired)
```dart
POST /api/auth/refresh-token
Body: { "refreshToken": "..." }
Response: { "accessToken": "...", "refreshToken": "..." }
```

### 4. Logout
```dart
POST /api/auth/logout
Body: { "refreshToken": "..." }
```

---

## 📝 Common Request Examples

### Register
```dart
POST /api/auth/register
{
  "name": "John Doe",
  "email": "john@example.com",
  "username": "johndoe",
  "password": "SecurePass123"
}
```

### Login
```dart
POST /api/auth/login
{
  "identifier": "john@example.com",
  "password": "SecurePass123"
}
```

### Get Profile
```dart
GET /api/users/profile
Headers: { "Authorization": "Bearer {token}" }
```

### Update Profile
```dart
PUT /api/users/profile
Headers: { "Authorization": "Bearer {token}" }
{
  "name": "New Name",
  "phone": "+6281234567890",
  "bio": "My bio",
  "location": "Jakarta"
}
```

### List Users (Admin)
```dart
GET /api/users?page=1&limit=10&search=john&isActive=true
Headers: { "Authorization": "Bearer {token}" }
```

---

## ⚠️ HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200  | OK |
| 201  | Created |
| 400  | Bad Request / Validation Error |
| 401  | Unauthorized / Invalid Token |
| 403  | Forbidden / Need Admin Role |
| 404  | Not Found |
| 409  | Conflict (email already exists) |
| 429  | Too Many Requests |
| 500  | Server Error |

---

## 📊 Response Format

### Success
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* data here */ }
}
```

### Error
```json
{
  "success": false,
  "message": "Error message",
  "errors": [ /* validation errors */ ]
}
```

---

## 🔧 Flutter Packages
```yaml
http: ^1.1.0
flutter_secure_storage: ^9.0.0
provider: ^6.1.1
```

---

## 💻 Quick Flutter Setup

```dart
// API Service
class ApiService {
  static const baseUrl = 'http://localhost:3030';
  String? _accessToken;
  
  void setTokens(String access, String refresh) {
    _accessToken = access;
  }
}

// Auth Service
class AuthService {
  final _api = ApiService();
  
  Future<Map> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );
    return json.decode(response.body);
  }
}

// Usage
final auth = AuthService();
final result = await auth.login('admin@example.com', 'Admin123!');
await TokenStorage.saveTokens(
  result['data']['accessToken'],
  result['data']['refreshToken'],
);
```

---

## 🧪 Quick Test

```dart
// 1. Health Check
final health = await http.get(
  Uri.parse('http://localhost:3030/health')
);
print(health.body); // {"success": true, ...}

// 2. Login
final login = await http.post(
  Uri.parse('http://localhost:3030/api/auth/login'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({
    'identifier': 'admin@example.com',
    'password': 'Admin123!',
  }),
);
print(login.body); // {"success": true, "data": {...}}
```

---

## 📱 Physical Device Setup

1. **Get laptop IP:**
   ```bash
   ifconfig | grep inet
   # Example: 192.168.1.100
   ```

2. **Update Flutter:**
   ```dart
   static const baseUrl = 'http://192.168.1.100:3030';
   ```

3. **Same Wi-Fi:** Laptop & device must be on same network

4. **Test in browser (on device):**
   ```
   http://192.168.1.100:3030/health
   ```

---

## 🔍 Troubleshooting

### Cannot connect
- ✅ Backend running? `npm run dev`
- ✅ Correct URL?
- ✅ Same Wi-Fi?
- ✅ Firewall blocking port 3030?

### Token expired
- ✅ Use refresh token
- ✅ Check token expiry (15 min)

### Invalid credentials
- ✅ Check email/password
- ✅ Use test admin: admin@example.com / Admin123!

---

## 📚 Full Documentation

- **Complete docs:** `API_DOCUMENTATION_FOR_FLUTTER.md`
- **Quick start:** `FLUTTER_QUICK_START.md`
- **Code example:** `flutter_api_client_example.dart`
- **Device testing:** `PHYSICAL_DEVICE_TESTING.md`
- **Index:** `INDEX.md`

---

## 🎯 Start Backend
```bash
cd /Users/mac/development/mygery_BE
npm run dev
# Server running at http://localhost:3030
```

---

## 📞 Important Commands

```bash
# Start backend
npm run dev

# Check health
curl http://localhost:3030/health

# Find laptop IP
ifconfig | grep inet

# Test login
curl -X POST http://localhost:3030/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"admin@example.com","password":"Admin123!"}'
```

---

**Print this or keep it open while coding!** 🚀

**Last Updated:** December 17, 2025
