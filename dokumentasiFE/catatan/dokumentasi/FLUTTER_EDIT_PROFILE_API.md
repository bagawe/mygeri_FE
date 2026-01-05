# 📱 API EDIT PROFILE - Dokumentasi untuk Flutter

## 🎯 Overview

Backend sekarang sudah support **semua field** yang dibutuhkan oleh halaman Edit Profile di Flutter. Dokumen ini menjelaskan cara menggunakan API untuk update profile dan upload foto.

---

## 🔑 Authentication

Semua endpoint memerlukan **Bearer Token** di header:
```
Authorization: Bearer <access_token>
```

---

## 📡 Endpoints

### 1. **GET User Profile**

Mendapatkan data profile user yang sedang login.

**Endpoint:**
```
GET /api/users/profile
```

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Dani Setiawan",
    "email": "dani@example.com",
    "username": "danisetiawan",
    "isActive": true,
    "lastLogin": "2025-12-24T00:00:00.000Z",
    "createdAt": "2025-12-24T00:00:00.000Z",
    "updatedAt": "2025-12-24T00:00:00.000Z",
    
    // Optional fields (bisa null jika belum diisi)
    "phone": "+628123456789",
    "bio": "Kader Partai aktif",
    
    // Identity
    "nik": "3276047658400027",
    "jenisKelamin": "Laki-laki",
    "statusKawin": "Kawin",
    "tempatLahir": "Jakarta",
    "tanggalLahir": "1990-01-15T00:00:00.000Z",
    
    // Address
    "provinsi": "DKI Jakarta",
    "kota": "Jakarta Selatan",
    "kecamatan": "Kebayoran Baru",
    "kelurahan": "Pulo",
    "rt": "001",
    "rw": "005",
    "jalan": "Jl. Merdeka No. 10",
    
    // Profession & Education
    "pekerjaan": "Pegawai Swasta",
    "pendidikan": "S1",
    
    // Political
    "underbow": "Partai Gerindra",
    "kegiatan": "Pelatihan Kader 2024",
    
    // Photos
    "fotoKtp": "/uploads/ktp/ktp-1-1735000000000-123456789.jpg",
    "fotoProfil": "/uploads/profiles/profil-1-1735000000000-987654321.jpg",
    
    "roles": [
      {
        "id": 1,
        "role": "jobseeker",
        "isActive": true
      }
    ]
  }
}
```

---

### 2. **PUT Update Profile**

Update data profile user. **Semua field optional** - kirim hanya field yang ingin diubah.

**Endpoint:**
```
PUT /api/users/profile
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  // Basic fields (optional)
  "name": "Dani Setiawan",
  "email": "dani@example.com",
  "username": "danisetiawan",
  "phone": "+628123456789",
  "bio": "Kader Partai aktif",
  
  // Identity fields (optional)
  "nik": "3276047658400027",
  "jenisKelamin": "Laki-laki",
  "statusKawin": "Kawin",
  "tempatLahir": "Jakarta",
  "tanggalLahir": "1990-01-15",
  
  // Address fields (optional)
  "provinsi": "DKI Jakarta",
  "kota": "Jakarta Selatan",
  "kecamatan": "Kebayoran Baru",
  "kelurahan": "Pulo",
  "rt": "001",
  "rw": "005",
  "jalan": "Jl. Merdeka No. 10",
  
  // Profession & Education (optional)
  "pekerjaan": "Pegawai Swasta",
  "pendidikan": "S1",
  
  // Political affiliation (optional)
  "underbow": "Partai Gerindra",
  "kegiatan": "Pelatihan Kader 2024"
}
```

**Validasi Rules:**
- `nik`: Harus 16 digit angka (e.g., "3276047658400027")
- `jenisKelamin`: "Laki-laki" atau "Perempuan"
- `statusKawin`: "Kawin", "Belum Kawin", "Janda", atau "Duda"
- `tanggalLahir`: Format YYYY-MM-DD (e.g., "1990-01-15")
- `rt`, `rw`: Max 3 karakter
- `email`: Format email valid
- `username`: Min 3 karakter

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    // ... full user profile dengan data yang sudah diupdate
  }
}
```

**Response Error (400 Bad Request):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "code": "invalid_string",
      "path": ["nik"],
      "message": "NIK must be exactly 16 digits"
    }
  ]
}
```

---

### 3. **POST Upload Foto**

Upload foto KTP atau foto profile.

**Endpoint:**
```
POST /api/users/profile/upload-foto
```

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: multipart/form-data
```

**Request Body (multipart/form-data):**
```
fotoType: "ktp" | "profil"
file: [File Binary]
```

**Constraints:**
- Max file size: **5 MB**
- Allowed formats: **.jpg, .jpeg, .png**
- Field name untuk file: **"file"**
- Field name untuk type: **"fotoType"**

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Foto profil uploaded successfully",
  "data": {
    "url": "/uploads/profiles/profil-1-1735000000000-987654321.jpg",
    "filename": "profil-1-1735000000000-987654321.jpg",
    "type": "profil"
  }
}
```

**Response Error (400 Bad Request):**
```json
{
  "success": false,
  "message": "Only .png, .jpg and .jpeg format allowed!"
}
```

**Response Error (File Too Large):**
```json
{
  "success": false,
  "message": "File too large. Maximum size is 5MB"
}
```

---

## 📝 Flutter Implementation Guide

### Model: `lib/models/user_profile.dart`

```dart
class UserProfile {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String username;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional fields
  final String? phone;
  final String? bio;
  
  // Identity
  final String? nik;
  final String? jenisKelamin;
  final String? statusKawin;
  final String? tempatLahir;
  final DateTime? tanggalLahir;
  
  // Address
  final String? provinsi;
  final String? kota;
  final String? kecamatan;
  final String? kelurahan;
  final String? rt;
  final String? rw;
  final String? jalan;
  
  // Profession & Education
  final String? pekerjaan;
  final String? pendidikan;
  
  // Political
  final String? underbow;
  final String? kegiatan;
  
  // Photos
  final String? fotoKtp;
  final String? fotoProfil;

  UserProfile({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.username,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.bio,
    this.nik,
    this.jenisKelamin,
    this.statusKawin,
    this.tempatLahir,
    this.tanggalLahir,
    this.provinsi,
    this.kota,
    this.kecamatan,
    this.kelurahan,
    this.rt,
    this.rw,
    this.jalan,
    this.pekerjaan,
    this.pendidikan,
    this.underbow,
    this.kegiatan,
    this.fotoKtp,
    this.fotoProfil,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      username: json['username'],
      isActive: json['isActive'],
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      phone: json['phone'],
      bio: json['bio'],
      nik: json['nik'],
      jenisKelamin: json['jenisKelamin'],
      statusKawin: json['statusKawin'],
      tempatLahir: json['tempatLahir'],
      tanggalLahir: json['tanggalLahir'] != null ? DateTime.parse(json['tanggalLahir']) : null,
      provinsi: json['provinsi'],
      kota: json['kota'],
      kecamatan: json['kecamatan'],
      kelurahan: json['kelurahan'],
      rt: json['rt'],
      rw: json['rw'],
      jalan: json['jalan'],
      pekerjaan: json['pekerjaan'],
      pendidikan: json['pendidikan'],
      underbow: json['underbow'],
      kegiatan: json['kegiatan'],
      fotoKtp: json['fotoKtp'],
      fotoProfil: json['fotoProfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'bio': bio,
      'nik': nik,
      'jenisKelamin': jenisKelamin,
      'statusKawin': statusKawin,
      'tempatLahir': tempatLahir,
      'tanggalLahir': tanggalLahir?.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      'provinsi': provinsi,
      'kota': kota,
      'kecamatan': kecamatan,
      'kelurahan': kelurahan,
      'rt': rt,
      'rw': rw,
      'jalan': jalan,
      'pekerjaan': pekerjaan,
      'pendidikan': pendidikan,
      'underbow': underbow,
      'kegiatan': kegiatan,
    };
  }

  // Helper untuk get full photo URL
  String? getFullPhotoUrl(String baseUrl) {
    if (fotoProfil == null) return null;
    return '$baseUrl$fotoProfil';
  }

  String? getFullKtpUrl(String baseUrl) {
    if (fotoKtp == null) return null;
    return '$baseUrl$fotoKtp';
  }
}
```

---

### Service: `lib/services/profile_service.dart`

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class ProfileService {
  final String baseUrl;
  final String? accessToken;

  ProfileService({required this.baseUrl, this.accessToken});

  // Get current user profile
  Future<UserProfile> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get profile');
    }
  }

  // Update profile
  Future<UserProfile> updateProfile(Map<String, dynamic> profileData) async {
    // Remove null values
    profileData.removeWhere((key, value) => value == null);

    final response = await http.put(
      Uri.parse('$baseUrl/api/users/profile'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserProfile.fromJson(data['data']);
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
      
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }

  // Upload photo (KTP or Profile)
  Future<String> uploadFoto(File imageFile, String fotoType) async {
    // Validate fotoType
    if (!['ktp', 'profil'].contains(fotoType)) {
      throw Exception('Invalid fotoType. Must be "ktp" or "profil"');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/users/profile/upload-foto'),
    );

    request.headers['Authorization'] = 'Bearer $accessToken';
    
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['url']; // Returns the photo URL
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to upload foto');
    }
  }
}
```

---

### Usage Example: Update Profile

```dart
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileService _profileService = ProfileService(
    baseUrl: 'http://YOUR_IP:3030',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );

  // Controllers
  final _nikController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final _jalanController = TextEditingController();
  final _pekerjaanController = TextEditingController();
  final _underbowController = TextEditingController();
  final _kegiatanController = TextEditingController();

  // Dropdowns
  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _selectedPendidikan;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final profile = await _profileService.getProfile();
      
      // Populate fields
      _nikController.text = profile.nik ?? '';
      _tempatLahirController.text = profile.tempatLahir ?? '';
      _tanggalLahirController.text = profile.tanggalLahir?.toIso8601String().split('T')[0] ?? '';
      _jalanController.text = profile.jalan ?? '';
      _pekerjaanController.text = profile.pekerjaan ?? '';
      _underbowController.text = profile.underbow ?? '';
      _kegiatanController.text = profile.kegiatan ?? '';
      
      setState(() {
        _selectedGender = profile.jenisKelamin;
        _selectedStatus = profile.statusKawin;
        _selectedProvinsi = profile.provinsi;
        _selectedKota = profile.kota;
        _selectedKecamatan = profile.kecamatan;
        _selectedKelurahan = profile.kelurahan;
        _selectedPendidikan = profile.pendidikan;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final profileData = {
        'nik': _nikController.text.isNotEmpty ? _nikController.text : null,
        'jenisKelamin': _selectedGender,
        'statusKawin': _selectedStatus,
        'tempatLahir': _tempatLahirController.text.isNotEmpty ? _tempatLahirController.text : null,
        'tanggalLahir': _tanggalLahirController.text.isNotEmpty ? _tanggalLahirController.text : null,
        'provinsi': _selectedProvinsi,
        'kota': _selectedKota,
        'kecamatan': _selectedKecamatan,
        'kelurahan': _selectedKelurahan,
        'jalan': _jalanController.text.isNotEmpty ? _jalanController.text : null,
        'pekerjaan': _pekerjaanController.text.isNotEmpty ? _pekerjaanController.text : null,
        'pendidikan': _selectedPendidikan,
        'underbow': _underbowController.text.isNotEmpty ? _underbowController.text : null,
        'kegiatan': _kegiatanController.text.isNotEmpty ? _kegiatanController.text : null,
      };

      await _profileService.updateProfile(profileData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile berhasil diupdate!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // NIK
                  TextFormField(
                    controller: _nikController,
                    decoration: InputDecoration(labelText: 'NIK (16 digit)'),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                  ),
                  
                  // Jenis Kelamin
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(labelText: 'Jenis Kelamin'),
                    items: ['Laki-laki', 'Perempuan']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedGender = val),
                  ),
                  
                  // Status Kawin
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(labelText: 'Status Kawin'),
                    items: ['Kawin', 'Belum Kawin', 'Janda', 'Duda']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => _selectedStatus = val),
                  ),
                  
                  // ... Add more fields here ...
                  
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    child: Text('Simpan Profile'),
                  ),
                ],
              ),
            ),
    );
  }
}
```

---

### Usage Example: Upload Foto

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UploadFotoExample extends StatefulWidget {
  @override
  _UploadFotoExampleState createState() => _UploadFotoExampleState();
}

class _UploadFotoExampleState extends State<UploadFotoExample> {
  final ProfileService _profileService = ProfileService(
    baseUrl: 'http://YOUR_IP:3030',
    accessToken: 'YOUR_ACCESS_TOKEN',
  );

  File? _selectedImage;
  String? _uploadedPhotoUrl;
  bool _isUploading = false;

  Future<void> _pickAndUploadImage(String fotoType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isUploading = true;
      });

      try {
        final photoUrl = await _profileService.uploadFoto(_selectedImage!, fotoType);
        
        setState(() {
          _uploadedPhotoUrl = photoUrl;
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto berhasil diupload!')),
        );
      } catch (e) {
        setState(() => _isUploading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error upload foto: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upload Foto Profile
        ElevatedButton(
          onPressed: _isUploading ? null : () => _pickAndUploadImage('profil'),
          child: Text('Upload Foto Profile'),
        ),
        
        // Upload Foto KTP
        ElevatedButton(
          onPressed: _isUploading ? null : () => _pickAndUploadImage('ktp'),
          child: Text('Upload Foto KTP'),
        ),
        
        // Show uploaded image
        if (_uploadedPhotoUrl != null)
          Image.network(
            'http://YOUR_IP:3030$_uploadedPhotoUrl',
            height: 200,
          ),
          
        if (_isUploading)
          CircularProgressIndicator(),
      ],
    );
  }
}
```

---

## ✅ Validation Rules Summary

| Field | Rule | Example |
|-------|------|---------|
| **nik** | 16 digit angka | `"3276047658400027"` |
| **jenisKelamin** | "Laki-laki" atau "Perempuan" | `"Laki-laki"` |
| **statusKawin** | "Kawin", "Belum Kawin", "Janda", "Duda" | `"Kawin"` |
| **tanggalLahir** | YYYY-MM-DD format | `"1990-01-15"` |
| **rt**, **rw** | Max 3 karakter | `"001"`, `"005"` |
| **email** | Valid email format | `"user@example.com"` |
| **username** | Min 3 karakter | `"johndoe"` |
| **Foto** | Max 5MB, .jpg/.jpeg/.png | - |

---

## 🚀 Testing dengan Postman

### 1. Get Profile
```bash
GET http://localhost:3030/api/users/profile
Authorization: Bearer YOUR_TOKEN
```

### 2. Update Profile
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "nik": "3276047658400027",
  "jenisKelamin": "Laki-laki",
  "statusKawin": "Kawin",
  "tempatLahir": "Jakarta",
  "tanggalLahir": "1990-01-15",
  "provinsi": "DKI Jakarta",
  "kota": "Jakarta Selatan",
  "pekerjaan": "Pegawai Swasta",
  "pendidikan": "S1"
}
```

### 3. Upload Foto
```bash
POST http://localhost:3030/api/users/profile/upload-foto
Authorization: Bearer YOUR_TOKEN
Content-Type: multipart/form-data

fotoType: profil
file: [Select Image File]
```

---

## 📂 File Uploads Location

Uploaded files disimpan di:
```
/uploads/
  ├── profiles/   (Foto profile user)
  └── ktp/        (Foto KTP user)
```

Untuk akses foto dari Flutter:
```
http://YOUR_IP:3030/uploads/profiles/profil-1-1735000000000-987654321.jpg
http://YOUR_IP:3030/uploads/ktp/ktp-1-1735000000000-123456789.jpg
```

---

## ⚠️ Important Notes

1. **Foto URL**: Saat upload foto berhasil, backend akan return URL path (e.g., `/uploads/profiles/xxx.jpg`). Simpan ini di state, lalu saat update profile, field `fotoProfil` dan `fotoKtp` akan otomatis terupdate.

2. **Old Photo Deletion**: Backend otomatis menghapus foto lama saat upload foto baru.

3. **Photo Display**: Untuk menampilkan foto, gunakan full URL:
   ```dart
   Image.network('http://YOUR_IP:3030${profile.fotoProfil}')
   ```

4. **Validation**: Frontend harus validasi NIK (16 digit) dan tanggal (YYYY-MM-DD) sebelum kirim ke backend.

5. **Optional Fields**: Semua field profile adalah optional. User bisa update sebagian field saja.

---

## 🎉 Summary

✅ **Backend sudah support semua field** yang dibutuhkan FE  
✅ **Upload foto KTP dan Profile** sudah tersedia  
✅ **Validasi lengkap** untuk semua input  
✅ **Old photo auto-delete** saat upload baru  
✅ **API Documentation lengkap** untuk Flutter integration  

**Status:** ✅ **READY TO USE**

---

**Last Updated:** 24 Desember 2025  
**Backend Version:** v1.0.0
