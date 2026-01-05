# 🔐 CHANGE PASSWORD API - Dokumentasi untuk Flutter

## 🎯 Overview

Backend sudah support fitur **Change Password** untuk user yang ingin mengubah password mereka sendiri. Endpoint ini memerlukan autentikasi dan akan me-revoke semua refresh tokens setelah password berhasil diubah (user harus login ulang untuk keamanan).

---

## 🔑 Authentication

Endpoint ini memerlukan **Bearer Token** di header:
```
Authorization: Bearer <access_token>
```

---

## 📡 Endpoint

### **PUT Change Password**

User dapat mengubah password mereka sendiri dengan menyediakan old password dan new password.

**Endpoint:**
```
PUT /api/users/change-password
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "oldPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}
```

**Notes:**
- `oldPassword` digunakan untuk verifikasi identitas user
- `newPassword` harus memenuhi password policy
- Frontend sudah validasi `confirmPassword`, jadi tidak perlu dikirim ke backend

---

### Success Response

**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

**Important:** Setelah password berhasil diubah, **semua refresh tokens akan di-revoke**. User harus login ulang untuk mendapatkan token baru.

---

### Error Responses

#### 1. Old Password Salah
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "Old password is incorrect"
}
```

#### 2. New Password Tidak Valid (Weak Password)
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "code": "too_small",
      "minimum": 8,
      "type": "string",
      "message": "Password must be at least 8 characters",
      "path": ["newPassword"]
    },
    {
      "code": "invalid_string",
      "validation": "regex",
      "message": "Password must contain at least one uppercase letter",
      "path": ["newPassword"]
    },
    {
      "code": "invalid_string",
      "validation": "regex",
      "message": "Password must contain at least one number",
      "path": ["newPassword"]
    }
  ]
}
```

#### 3. New Password Sama dengan Old Password
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "New password must be different from old password"
}
```

#### 4. Unauthorized (Token Invalid/Expired)
**Status Code:** `401 Unauthorized`

```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## ✅ Validation Rules

### 1. Old Password
- ✅ **Required:** Harus diisi
- ✅ **Match:** Harus cocok dengan password saat ini di database

### 2. New Password
- ✅ **Required:** Harus diisi
- ✅ **Min Length:** Minimal 8 karakter
- ✅ **Lowercase:** Harus ada minimal 1 huruf kecil (a-z)
- ✅ **Uppercase:** Harus ada minimal 1 huruf besar (A-Z)
- ✅ **Number:** Harus ada minimal 1 angka (0-9)
- ✅ **Different:** Tidak boleh sama dengan old password

**Contoh Password Valid:**
- ✅ `Password123`
- ✅ `MyNewPass2024`
- ✅ `Secure1234`

**Contoh Password Invalid:**
- ❌ `password` - Tidak ada huruf besar & angka
- ❌ `PASSWORD123` - Tidak ada huruf kecil
- ❌ `Password` - Tidak ada angka
- ❌ `Pass12` - Kurang dari 8 karakter
- ❌ `OldPassword123` - Sama dengan old password

---

## 🔐 Security Features

### 1. Old Password Verification
Backend akan memverifikasi old password menggunakan bcrypt sebelum mengizinkan perubahan.

### 2. Password Policy Enforcement
New password harus memenuhi semua kriteria keamanan (8+ chars, mixed case, numbers).

### 3. Token Revocation
Setelah password berhasil diubah, **semua refresh tokens akan di-revoke** untuk keamanan. Ini berarti:
- User harus login ulang setelah change password
- Semua device/session lain akan logout otomatis
- Mencegah akses tidak sah jika password diubah karena security breach

---

## 📝 Flutter Implementation Guide

### Service: `lib/services/password_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordService {
  final String baseUrl;
  final String? accessToken;

  PasswordService({required this.baseUrl, this.accessToken});

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/change-password'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Success - password changed
      return;
    } else {
      final error = jsonDecode(response.body);
      
      // Handle validation errors
      if (error['errors'] != null) {
        List<String> errorMessages = [];
        for (var err in error['errors']) {
          errorMessages.add(err['message']);
        }
        throw Exception(errorMessages.join(', '));
      }
      
      throw Exception(error['message'] ?? 'Failed to change password');
    }
  }
}
```

---

### Usage Example: Integrate dengan Ganti Password Page

```dart
import 'package:flutter/material.dart';

class GantiPasswordPage extends StatefulWidget {
  @override
  _GantiPasswordPageState createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Get service instance
  late PasswordService _passwordService;

  @override
  void initState() {
    super.initState();
    // Initialize service with baseUrl and token from your auth provider
    _passwordService = PasswordService(
      baseUrl: 'http://YOUR_IP:3030',
      accessToken: 'YOUR_ACCESS_TOKEN', // Get from auth provider/storage
    );
  }

  // Validate password strength
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar';
    }
    
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password harus mengandung angka';
    }
    
    return null;
  }

  // Submit form
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate confirm password
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password baru dan konfirmasi tidak cocok'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _passwordService.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password berhasil diganti!'),
          backgroundColor: Colors.green,
        ),
      );

      // Important: Logout user and redirect to login
      // Since all tokens are revoked, user needs to login again
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ganti Password'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info message
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Setelah password diganti, Anda akan logout otomatis dan harus login ulang.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Old Password
              TextFormField(
                controller: _oldPasswordController,
                obscureText: _obscureOldPassword,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureOldPassword = !_obscureOldPassword);
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password lama harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureNewPassword = !_obscureNewPassword);
                    },
                  ),
                  border: OutlineInputBorder(),
                  helperText: 'Min 8 karakter, harus ada: A-Z, a-z, 0-9',
                  helperMaxLines: 2,
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: Icon(Icons.lock_check),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    },
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi password harus diisi';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Ganti Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
```

---

## 🧪 Testing dengan Postman

### Test 1: Success - Change Password
```bash
PUT http://localhost:3030/api/users/change-password
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

Body:
{
  "oldPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}

Expected Response (200 OK):
{
  "success": true,
  "message": "Password changed successfully"
}
```

### Test 2: Error - Wrong Old Password
```bash
PUT http://localhost:3030/api/users/change-password
Authorization: Bearer YOUR_TOKEN

Body:
{
  "oldPassword": "WrongPassword",
  "newPassword": "NewPassword456"
}

Expected Response (400):
{
  "success": false,
  "message": "Old password is incorrect"
}
```

### Test 3: Error - Weak New Password
```bash
PUT http://localhost:3030/api/users/change-password
Authorization: Bearer YOUR_TOKEN

Body:
{
  "oldPassword": "OldPassword123",
  "newPassword": "weak"
}

Expected Response (400):
{
  "success": false,
  "message": "Validation error",
  "errors": [...]
}
```

### Test 4: Error - Same Password
```bash
PUT http://localhost:3030/api/users/change-password
Authorization: Bearer YOUR_TOKEN

Body:
{
  "oldPassword": "OldPassword123",
  "newPassword": "OldPassword123"
}

Expected Response (400):
{
  "success": false,
  "message": "New password must be different from old password"
}
```

---

## ⚠️ Important Notes

### 1. Logout After Change Password
Setelah password berhasil diubah, **user akan logout otomatis** karena semua refresh tokens di-revoke. Pastikan Flutter app menangani ini dengan:
```dart
// After successful password change
await authProvider.logout(); // Clear local tokens
Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
```

### 2. Frontend Validation
Meskipun backend sudah validasi, **frontend tetap harus validasi** untuk UX yang lebih baik:
- Password minimal 8 karakter
- Ada lowercase, uppercase, dan number
- Confirm password cocok dengan new password

### 3. Error Handling
Handle semua kemungkinan error dengan message yang user-friendly:
- Old password salah → "Password lama yang Anda masukkan salah"
- Weak password → Tampilkan detail requirement yang tidak terpenuhi
- Network error → "Tidak dapat terhubung ke server"

### 4. Security
- Jangan tampilkan password di log/console
- Gunakan obscureText untuk semua password fields
- Clear controllers setelah submit sukses

---

## 🎉 Summary

✅ **Backend sudah support Change Password**  
✅ **Validasi lengkap** (old password, password policy)  
✅ **Token revocation** untuk keamanan  
✅ **Error handling** yang jelas  
✅ **Flutter code siap digunakan**  

**Status:** ✅ **READY TO USE**

---

**Last Updated:** 24 Desember 2025  
**Backend Version:** v1.0.0
