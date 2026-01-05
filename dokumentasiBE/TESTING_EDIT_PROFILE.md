# 🧪 Testing Edit Profile API - Manual Steps

## Prerequisites

1. **Server Running**: Pastikan backend berjalan di `http://localhost:3030`
2. **User Logged In**: Dapatkan access token dengan login
3. **Postman Installed**: Atau gunakan curl

---

## Step 1: Login untuk Mendapatkan Token

**Request:**
```bash
POST http://localhost:3030/api/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "Admin123!"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": { ... }
  }
}
```

**Copy `accessToken` untuk digunakan di request selanjutnya.**

---

## Step 2: Get Current Profile

**Request:**
```bash
GET http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "...",
    "name": "Admin User",
    "email": "admin@example.com",
    "username": "admin",
    "phone": null,
    "bio": null,
    "nik": null,
    "jenisKelamin": null,
    // ... semua field null karena belum diisi
  }
}
```

---

## Step 3: Update Profile (Partial Update)

Test dengan update beberapa field saja:

**Request:**
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{
  "nik": "3276047658400027",
  "jenisKelamin": "Laki-laki",
  "tempatLahir": "Jakarta",
  "tanggalLahir": "1990-01-15"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "nik": "3276047658400027",
    "jenisKelamin": "Laki-laki",
    "tempatLahir": "Jakarta",
    "tanggalLahir": "1990-01-15T00:00:00.000Z",
    // ... field lain tetap sama
  }
}
```

---

## Step 4: Update Profile (Full Data)

Test dengan update semua field sekaligus:

**Request:**
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{
  "phone": "+628123456789",
  "bio": "Kader Partai aktif sejak 2020",
  "nik": "3276047658400027",
  "jenisKelamin": "Laki-laki",
  "statusKawin": "Kawin",
  "tempatLahir": "Jakarta",
  "tanggalLahir": "1990-01-15",
  "provinsi": "DKI Jakarta",
  "kota": "Jakarta Selatan",
  "kecamatan": "Kebayoran Baru",
  "kelurahan": "Pulo",
  "rt": "001",
  "rw": "005",
  "jalan": "Jl. Merdeka No. 10",
  "pekerjaan": "Pegawai Swasta",
  "pendidikan": "S1",
  "underbow": "Partai Gerindra",
  "kegiatan": "Pelatihan Kader 2024, Kampanye Pemilu 2024"
}
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "uuid": "...",
    "name": "Admin User",
    "email": "admin@example.com",
    "username": "admin",
    "phone": "+628123456789",
    "bio": "Kader Partai aktif sejak 2020",
    "nik": "3276047658400027",
    "jenisKelamin": "Laki-laki",
    "statusKawin": "Kawin",
    "tempatLahir": "Jakarta",
    "tanggalLahir": "1990-01-15T00:00:00.000Z",
    "provinsi": "DKI Jakarta",
    "kota": "Jakarta Selatan",
    "kecamatan": "Kebayoran Baru",
    "kelurahan": "Pulo",
    "rt": "001",
    "rw": "005",
    "jalan": "Jl. Merdeka No. 10",
    "pekerjaan": "Pegawai Swasta",
    "pendidikan": "S1",
    "underbow": "Partai Gerindra",
    "kegiatan": "Pelatihan Kader 2024, Kampanye Pemilu 2024",
    "fotoKtp": null,
    "fotoProfil": null,
    "isActive": true,
    "lastLogin": "...",
    "createdAt": "...",
    "updatedAt": "..."
  }
}
```

---

## Step 5: Test Validation Errors

### 5.1. Invalid NIK (Not 16 digits)

**Request:**
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{
  "nik": "12345"
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "code": "too_small",
      "path": ["nik"],
      "message": "NIK must be exactly 16 digits"
    }
  ]
}
```

### 5.2. Invalid Jenis Kelamin

**Request:**
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{
  "jenisKelamin": "Male"
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "code": "invalid_enum_value",
      "path": ["jenisKelamin"],
      "message": "Jenis kelamin must be either \"Laki-laki\" or \"Perempuan\""
    }
  ]
}
```

### 5.3. Invalid Tanggal Lahir Format

**Request:**
```bash
PUT http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json

{
  "tanggalLahir": "15-01-1990"
}
```

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "code": "invalid_string",
      "path": ["tanggalLahir"],
      "message": "Tanggal lahir must be in YYYY-MM-DD format"
    }
  ]
}
```

---

## Step 6: Upload Foto Profile

### Using Postman:

1. Method: **POST**
2. URL: `http://localhost:3030/api/users/profile/upload-foto`
3. Headers:
   - `Authorization: Bearer <ACCESS_TOKEN>`
4. Body:
   - Type: **form-data**
   - Add field: `fotoType` = `profil`
   - Add field: `file` = [Select Image File]

**Expected Response:**
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

### Using curl:

```bash
curl -X POST http://localhost:3030/api/users/profile/upload-foto \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -F "fotoType=profil" \
  -F "file=@/path/to/your/image.jpg"
```

---

## Step 7: Upload Foto KTP

**Request (Postman):**
1. Method: **POST**
2. URL: `http://localhost:3030/api/users/profile/upload-foto`
3. Headers:
   - `Authorization: Bearer <ACCESS_TOKEN>`
4. Body:
   - Type: **form-data**
   - Add field: `fotoType` = `ktp`
   - Add field: `file` = [Select Image File]

**Expected Response:**
```json
{
  "success": true,
  "message": "Foto ktp uploaded successfully",
  "data": {
    "url": "/uploads/ktp/ktp-1-1735000000000-123456789.jpg",
    "filename": "ktp-1-1735000000000-123456789.jpg",
    "type": "ktp"
  }
}
```

---

## Step 8: Verify Foto Upload

Setelah upload, foto akan otomatis tersimpan di profile. Verify dengan:

**Request:**
```bash
GET http://localhost:3030/api/users/profile
Authorization: Bearer <ACCESS_TOKEN>
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "fotoProfil": "/uploads/profiles/profil-1-1735000000000-987654321.jpg",
    "fotoKtp": "/uploads/ktp/ktp-1-1735000000000-123456789.jpg",
    // ... field lain
  }
}
```

---

## Step 9: Access Uploaded Photos

Foto bisa diakses langsung via browser atau Image.network di Flutter:

**Foto Profile:**
```
http://localhost:3030/uploads/profiles/profil-1-1735000000000-987654321.jpg
```

**Foto KTP:**
```
http://localhost:3030/uploads/ktp/ktp-1-1735000000000-123456789.jpg
```

---

## Step 10: Test File Size Limit

Upload file lebih dari 5MB:

**Expected Response (400):**
```json
{
  "success": false,
  "message": "File too large. Maximum size is 5MB"
}
```

---

## Step 11: Test Invalid File Type

Upload file .pdf atau .txt:

**Expected Response (400):**
```json
{
  "success": false,
  "message": "Only .png, .jpg and .jpeg format allowed!"
}
```

---

## ✅ Testing Checklist

- [ ] Login berhasil dan dapat access token
- [ ] Get profile mengembalikan data user
- [ ] Update profile partial (beberapa field) berhasil
- [ ] Update profile full (semua field) berhasil
- [ ] Validation error NIK ditangani dengan benar
- [ ] Validation error jenisKelamin ditangani dengan benar
- [ ] Validation error tanggalLahir ditangani dengan benar
- [ ] Upload foto profile berhasil
- [ ] Upload foto KTP berhasil
- [ ] Foto tersimpan di database (cek dengan GET profile)
- [ ] Foto bisa diakses via URL
- [ ] File size limit (>5MB) ditolak
- [ ] File type invalid (.pdf, .txt) ditolak
- [ ] Upload foto baru menghapus foto lama

---

## 🐛 Troubleshooting

### Error: "No file uploaded"
- Pastikan field name di multipart adalah `file` (bukan `image` atau yang lain)
- Pastikan Content-Type: multipart/form-data

### Error: "Invalid fotoType"
- fotoType harus `ktp` atau `profil` (bukan `profile`, `foto`, dll)

### Error: 401 Unauthorized
- Token expired, login ulang untuk dapat token baru
- Pastikan format header: `Authorization: Bearer <TOKEN>`

### Foto tidak bisa diakses (404)
- Pastikan server running
- Cek path: `/uploads/profiles/` atau `/uploads/ktp/`
- Cek permission folder uploads (chmod 755)

---

**Happy Testing! 🚀**
