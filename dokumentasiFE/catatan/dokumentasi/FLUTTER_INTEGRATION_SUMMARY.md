# 📦 MyGeri Backend API - Summary untuk Flutter Frontend

Halo Flutter Developer! 👋

Ini adalah summary lengkap untuk mengintegrasikan MyGeri Backend API dengan Flutter Frontend.

---

## 📂 File-File Dokumentasi yang Tersedia

### 1. **API_DOCUMENTATION_FOR_FLUTTER.md** ⭐
**File utama** - Dokumentasi lengkap API dengan:
- ✅ Authentication flow
- ✅ Semua endpoint details
- ✅ Request/Response format
- ✅ Error handling
- ✅ Security headers
- ✅ Flutter implementation guide dengan contoh code

**📍 Lokasi:** `/Users/mac/development/mygery_BE/API_DOCUMENTATION_FOR_FLUTTER.md`

---

### 2. **FLUTTER_QUICK_START.md** 🚀
Quick reference untuk:
- ✅ API Configuration
- ✅ Required packages
- ✅ Endpoints summary table
- ✅ Model classes
- ✅ Testing flow
- ✅ Validation rules
- ✅ Environment config

**📍 Lokasi:** `/Users/mac/development/mygery_BE/FLUTTER_QUICK_START.md`

---

### 3. **flutter_api_client_example.dart** 💻
**Copy-paste ready code!** Complete implementation:
- ✅ ApiService (HTTP client)
- ✅ AuthService (authentication)
- ✅ UserService (user management)
- ✅ TokenStorage (secure storage)
- ✅ Login Screen example
- ✅ Home Screen example
- ✅ Main app setup

**📍 Lokasi:** `/Users/mac/development/mygery_BE/flutter_api_client_example.dart`

---

### 4. **Postman Collection** 📮
Testing API dengan Postman:
- Collection: `/Users/mac/development/mygery_BE/postman/mygeri-REST-API.postman_collection.json`
- Environment (Dev): `/Users/mac/development/mygery_BE/postman/mygeri-development.postman_environment.json`
- Environment (Prod): `/Users/mac/development/mygery_BE/postman/mygeri-production.postman_environment.json`

---

## 🎯 Quick Start untuk Flutter Developer

### Step 1: Baca Dokumentasi
Buka file **API_DOCUMENTATION_FOR_FLUTTER.md** untuk memahami:
- Endpoint apa saja yang tersedia
- Format request/response
- Error handling

### Step 2: Setup Flutter Project
```bash
# Buat project baru atau gunakan yang sudah ada
flutter create mygeri_app
cd mygeri_app

# Install dependencies
flutter pub add http
flutter pub add flutter_secure_storage
flutter pub add provider  # atau bloc/riverpod untuk state management
```

### Step 3: Copy Code Template
Copy code dari **flutter_api_client_example.dart** ke project Flutter:
```
lib/
  ├── services/
  │   ├── api_service.dart         # HTTP client
  │   ├── auth_service.dart        # Authentication
  │   └── user_service.dart        # User management
  ├── utils/
  │   └── token_storage.dart       # Secure token storage
  └── screens/
      ├── login_screen.dart        # Login UI
      └── home_screen.dart         # Home UI
```

### Step 4: Test Connection
```dart
// Test health check
final apiService = ApiService();
final health = await apiService.get('/health');
print('API Status: ${health['success']}'); // Should print: true
```

### Step 5: Test Login
```dart
// Login dengan admin
final authService = AuthService();
final result = await authService.login(
  identifier: 'admin@example.com',
  password: 'Admin123!',
);
print('Login success: ${result['data']['user']['name']}');
```

---

## 🔑 Default Admin Credentials (Testing)

```
Email: admin@example.com
Password: Admin123!
```

**⚠️ HANYA UNTUK TESTING!** Jangan hardcode di production.

---

## 🌐 API Base URLs

### Development (Local Backend)
```dart
const String API_BASE_URL = 'http://localhost:3030';
```

**Untuk test di Physical Device:**
1. Cek IP laptop dengan: `ifconfig | grep inet`
2. Gunakan IP tersebut: `http://192.168.1.XXX:3030`

### Production
```dart
const String API_BASE_URL = 'https://api.mygeri.com';
```
*(Update sesuai domain production)*

---

## 📋 API Endpoints Summary

| Endpoint | Method | Auth | Admin | Description |
|----------|--------|------|-------|-------------|
| `/health` | GET | ❌ | ❌ | Health check |
| `/api/auth/register` | POST | ❌ | ❌ | Register user |
| `/api/auth/login` | POST | ❌ | ❌ | Login |
| `/api/auth/refresh-token` | POST | ❌ | ❌ | Refresh token |
| `/api/auth/logout` | POST | ❌ | ❌ | Logout |
| `/api/auth/revoke-all-sessions` | POST | ✅ | ❌ | Revoke sessions |
| `/api/users/profile` | GET | ✅ | ❌ | Get profile |
| `/api/users/profile` | PUT | ✅ | ❌ | Update profile |
| `/api/users` | GET | ✅ | ✅ | List users |
| `/api/users/:uuid` | GET | ✅ | ✅ | Get user by UUID |
| `/api/users/:uuid` | PUT | ✅ | ✅ | Update user |
| `/api/users/:uuid` | DELETE | ✅ | ✅ | Delete user |

---

## 🔒 Authentication Flow

```
1. User Login
   ↓
2. Get accessToken (15 min) & refreshToken (7 days)
   ↓
3. Save tokens to secure storage
   ↓
4. Use accessToken for authenticated requests
   ↓
5. When accessToken expired → Use refreshToken to get new accessToken
   ↓
6. On Logout → Blacklist refreshToken
```

---

## 📦 Required Flutter Packages

```yaml
dependencies:
  http: ^1.1.0                        # HTTP client
  flutter_secure_storage: ^9.0.0     # Secure token storage
  provider: ^6.1.1                    # State management (optional)
```

---

## 🧪 Testing Checklist

- [ ] Health check berhasil
- [ ] Register user baru
- [ ] Login berhasil dengan admin credentials
- [ ] Token tersimpan di secure storage
- [ ] Get user profile berhasil
- [ ] Update profile berhasil
- [ ] Refresh token berhasil
- [ ] Logout berhasil
- [ ] Error handling bekerja dengan baik

---

## 🛠️ Cara Menjalankan Backend (di laptop ini)

```bash
# Navigate ke folder backend
cd /Users/mac/development/mygery_BE

# Start development server
npm run dev

# Server akan running di: http://localhost:3030
# Health check: http://localhost:3030/health
```

**Status Server:**
- ✅ PostgreSQL 17 running
- ✅ Database `mygeri_dev` ready
- ✅ Admin user seeded
- ✅ API server ready at port 3030

---

## 📱 Tips untuk Flutter Development

### 1. Untuk iOS Simulator (localhost)
Tidak perlu konfigurasi tambahan, gunakan `http://localhost:3030`

### 2. Untuk Android Emulator (localhost)
Gunakan `http://10.0.2.2:3030` (ini adalah alias untuk localhost di Android emulator)

### 3. Untuk Physical Device
Gunakan IP laptop Anda, contoh: `http://192.168.1.100:3030`

**Cara cek IP laptop:**
```bash
# macOS
ifconfig | grep "inet "

# Cari IP yang dimulai dengan 192.168.x.x atau 10.0.x.x
```

### 4. Handle Network Errors
```dart
try {
  final result = await authService.login(...);
} on SocketException {
  // No internet connection
  showError('No internet connection');
} on TimeoutException {
  // Request timeout
  showError('Request timeout');
} on ApiException catch (e) {
  // API error (401, 404, etc)
  showError(e.message);
} catch (e) {
  // Unknown error
  showError('An unexpected error occurred');
}
```

### 5. Auto Token Refresh
Implement interceptor untuk auto refresh token ketika dapat 401:
```dart
// Check if error is 401 (Unauthorized)
if (statusCode == 401) {
  // Try refresh token
  final refreshToken = await TokenStorage.getRefreshToken();
  if (refreshToken != null) {
    await authService.refreshToken(refreshToken);
    // Retry original request
  }
}
```

---

## 🆘 Troubleshooting

### ❌ "Connection refused" / Cannot connect
**Solusi:**
1. Pastikan backend server running: `npm run dev`
2. Cek base URL sudah benar
3. Untuk physical device, gunakan IP laptop (bukan localhost)

### ❌ "Token expired"
**Solusi:**
1. Use refresh token to get new access token
2. Implement auto token refresh

### ❌ "CORS error"
**Solusi:**
- Flutter mobile app tidak punya masalah CORS
- Jika tetap ada error, pastikan headers lengkap

### ❌ "Invalid credentials"
**Solusi:**
- Cek email/username dan password
- Gunakan admin credentials untuk testing: `admin@example.com` / `Admin123!`

---

## 📞 Contact & Support

**Backend Developer:** 
- Cek file ini untuk info lebih lanjut
- Repository: `/Users/mac/development/mygery_BE`

**Documentation:**
- Main docs: `API_DOCUMENTATION_FOR_FLUTTER.md`
- Quick start: `FLUTTER_QUICK_START.md`
- Code example: `flutter_api_client_example.dart`

---

## 📚 Next Steps

1. ✅ Setup Flutter project dengan dependencies
2. ✅ Copy code dari `flutter_api_client_example.dart`
3. ✅ Test connection dengan health check
4. ✅ Implement login screen
5. ✅ Test authentication flow
6. ✅ Implement profile screen
7. ✅ Add error handling
8. ✅ Implement auto token refresh
9. ✅ Add state management (Provider/Bloc)
10. ✅ Build complete app features

---

## 🎉 You're Ready!

Semua dokumentasi dan code example sudah siap. Silakan mulai develop Flutter app Anda!

**Good luck and happy coding! 🚀📱**

---

**Last Updated:** December 17, 2025  
**Backend Version:** 1.0.0  
**API Status:** ✅ Running at http://localhost:3030
