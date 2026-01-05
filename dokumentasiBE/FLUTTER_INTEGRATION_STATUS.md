# Panduan Integrasi API - MyGeri Flutter

## ✅ Status Integrasi

### ✔️ Sudah Diintegrasikan
1. **Service Layer**
   - `lib/services/api_service.dart` - HTTP client dengan error handling
   - `lib/services/auth_service.dart` - Authentication service (register, login, logout, refresh token)
   - `lib/services/storage_service.dart` - Secure storage untuk token dan user data

2. **Models**
   - `lib/models/user_model.dart` - Model untuk user data
   - `lib/models/register_request.dart` - Model untuk request registrasi

3. **Halaman Register**
   - ✅ `register_simpatisan_page.dart` - Registrasi simpatisan dengan validasi
   - ✅ `register_kader_lama_page.dart` - Registrasi kader lama dengan upload foto KTA dan selfie
   - ✅ `register_kader_baru_page.dart` - Registrasi kader baru dengan form lengkap

4. **Dependencies Installed**
   - `http: ^1.1.0` - HTTP client
   - `flutter_secure_storage: ^9.0.0` - Secure storage untuk token
   - `image_picker: ^1.0.7` - Image picker untuk upload foto

---

## 🔧 Konfigurasi

### Base URL API
File: `lib/services/api_service.dart`

```dart
// Untuk development (localhost)
static const String baseUrl = 'http://localhost:3030';

// Untuk physical device (ganti dengan IP laptop Anda)
// static const String baseUrl = 'http://192.168.1.XXX:3030';

// Untuk production
// static const String baseUrl = 'https://api.mygeri.com';
```

### Testing Credentials
```
Email: admin@example.com
Password: Admin123!
```

---

## 📱 Fitur yang Sudah Diimplementasikan

### 1. Register Simpatisan
**File:** `lib/pages/register/register_simpatisan_page.dart`

**Fields:**
- Nama (required, min 2 karakter)
- Email (required, valid email format)
- Username (required, min 3 karakter, alphanumeric + underscore)
- Password (required, min 8 karakter)
- Konfirmasi Password

**API Endpoint:** `POST /api/auth/register`

**Flow:**
1. Validasi form
2. Cek password match
3. Kirim request ke backend
4. Simpan response (user data)
5. Navigate kembali ke login page
6. Tampilkan success message

---

### 2. Register Kader Lama
**File:** `lib/pages/register/register_kader_lama_page.dart`

**Fields:**
- Nama
- Email
- Username
- Upload Foto KTA (image picker)
- Upload Foto Selfie (image picker)
- Password
- Konfirmasi Password

**API Endpoint:** `POST /api/auth/register`

**Flow:**
1. Validasi form
2. Cek foto sudah diupload
3. Cek password match
4. Kirim request ke backend (dengan path foto lokal)
5. Navigate kembali ke login page
6. Tampilkan success message

⚠️ **TODO:** Upload gambar ke server dan dapatkan URL sebelum register

---

### 3. Register Kader Baru
**File:** `lib/pages/register/register_kader_baru_page.dart`

**Fields:**
- Data Pribadi: Nama, Email, Username, NIK, Jenis Kelamin, Status Kawin
- Tempat & Tanggal Lahir
- Alamat Lengkap: Provinsi, Kota, Kecamatan, Kelurahan, RT, RW, Jalan
- Pekerjaan & Pendidikan
- Upload Foto KTP & Selfie
- Password & Konfirmasi Password
- 2 Checkbox pernyataan (required)

**API Endpoint:** `POST /api/auth/register`

**Flow:**
1. Validasi form
2. Cek kedua checkbox tercentang
3. Cek foto sudah diupload
4. Cek password match
5. Kirim request ke backend dengan semua data
6. Navigate kembali ke login page
7. Tampilkan success message

⚠️ **TODO:** Upload gambar ke server dan dapatkan URL sebelum register

---

## 🔄 Fitur Belum Diintegrasikan

### 1. Login Page
**File:** `lib/pages/login_page.dart`

**TODO:**
- Integrasikan dengan `AuthService.login()`
- Simpan token ke secure storage
- Simpan user data
- Navigate ke home page setelah login berhasil

**Contoh Kode:**
```dart
Future<void> _handleLogin() async {
  try {
    final response = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    // Token dan user data sudah disimpan otomatis oleh AuthService
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  } catch (e) {
    // Tampilkan error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login gagal: $e')),
    );
  }
}
```

---

### 2. Profile Page
**File:** `lib/pages/profil/profile_page.dart`

**TODO:**
- Fetch user profile dengan `GET /api/users/profile`
- Tampilkan data user
- Update profile dengan `PUT /api/users/profile`

**Contoh Kode:**
```dart
Future<void> _fetchProfile() async {
  try {
    final response = await _apiService.get(
      '/api/users/profile',
      requiresAuth: true,
    );
    
    setState(() {
      _userData = UserModel.fromJson(response['data']);
    });
  } catch (e) {
    // Handle error
  }
}
```

---

### 3. Logout
**File:** `lib/pages/pengaturan/pengaturan_page.dart`

**TODO:**
- Integrasikan dengan `AuthService.logout()`
- Clear token dan user data
- Navigate ke login page

**Contoh Kode:**
```dart
Future<void> _handleLogout() async {
  try {
    await _authService.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    // Handle error
  }
}
```

---

### 4. Image Upload Service
**TODO:** Buat service untuk upload gambar ke server

**File:** `lib/services/upload_service.dart`

**Contoh Kode:**
```dart
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  final ApiService _api = ApiService();
  
  Future<String> uploadImage(File image) async {
    // TODO: Implement multipart upload
    // Return URL dari server
  }
}
```

---

## 🔐 Security Best Practices

1. **Token Storage**
   - ✅ Token disimpan di `flutter_secure_storage`
   - ✅ Auto-expired dalam 15 menit (access token)
   - ✅ Refresh token valid 7 hari

2. **Password**
   - ✅ Minimal 8 karakter
   - ✅ Tidak ditampilkan (obscureText: true)
   - ✅ Validasi konfirmasi password

3. **API Requests**
   - ✅ HTTPS di production (update base URL)
   - ✅ Authorization header untuk authenticated routes
   - ✅ X-Requested-With header untuk POST/PUT/DELETE

---

## 📝 Testing Checklist

### Register Simpatisan
- [ ] Form validation bekerja
- [ ] Email validation bekerja
- [ ] Username validation bekerja
- [ ] Password minimal 8 karakter
- [ ] Konfirmasi password match
- [ ] API call berhasil
- [ ] Success message muncul
- [ ] Navigate ke login page

### Register Kader Lama
- [ ] Form validation bekerja
- [ ] Image picker bekerja
- [ ] Preview image muncul
- [ ] Validasi foto required
- [ ] API call berhasil
- [ ] Success message muncul

### Register Kader Baru
- [ ] Semua form field validation bekerja
- [ ] Image picker bekerja
- [ ] Checkbox validation bekerja
- [ ] Semua data terkirim dengan benar
- [ ] API call berhasil
- [ ] Success message muncul

---

## 🚀 Next Steps

1. **Prioritas Tinggi:**
   - [ ] Integrasikan Login Page
   - [ ] Buat Image Upload Service
   - [ ] Test registrasi end-to-end dengan backend
   - [ ] Update register kader untuk upload image ke server

2. **Prioritas Menengah:**
   - [ ] Integrasikan Profile Page
   - [ ] Integrasikan Logout
   - [ ] Add token refresh logic
   - [ ] Error handling improvement

3. **Prioritas Rendah:**
   - [ ] Loading state improvement
   - [ ] Form UX improvement
   - [ ] Add analytics/logging
   - [ ] Performance optimization

---

## 🐛 Known Issues

1. **Image Upload**
   - Saat ini hanya menyimpan path lokal
   - Perlu service untuk upload ke server
   - Perlu update backend untuk menerima multipart/form-data

2. **Token Refresh**
   - Auto-refresh belum diimplementasikan
   - Perlu interceptor untuk auto-refresh saat token expired

3. **Error Messages**
   - Error dari backend belum di-parse dengan baik
   - Perlu improvement untuk user-friendly error messages

---

## 📚 Resources

- [Flutter HTTP Package](https://pub.dev/packages/http)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Image Picker](https://pub.dev/packages/image_picker)
- [API Documentation](./API_DOCUMENTATION_FOR_FLUTTER.md)
- [Quick Reference](./QUICK_REFERENCE.md)
