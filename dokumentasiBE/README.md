# 📚 Backend Documentation - Edit Profile API

Dokumentasi API backend untuk fitur Edit Profile.

---

## 📄 Files

### 1. **README_EDIT_PROFILE.md** 📖
   - Overview implementasi backend
   - Database changes (migration)
   - 18+ new profile fields
   - API endpoints summary
   - Quick start guide
   - **Target Audience:** General overview, Project Manager, QA

### 2. **FLUTTER_EDIT_PROFILE_API.md** 📱
   - Complete API documentation untuk Flutter
   - Request/Response examples
   - Flutter models (copy-paste ready)
   - Flutter services (copy-paste ready)
   - Usage examples dengan code
   - Validation rules
   - **Target Audience:** Flutter Developers

### 3. **TESTING_EDIT_PROFILE.md** 🧪
   - Manual testing steps
   - Postman/curl examples
   - Test data examples
   - Expected responses
   - Troubleshooting guide
   - **Target Audience:** QA Testers, Backend Developers

---

## 🎯 Implementation Summary

### Backend Status: ✅ COMPLETE

Backend telah mengimplementasikan:
- ✅ 18+ profile fields di database
- ✅ GET /api/users/profile (fetch profile)
- ✅ PUT /api/users/profile (update profile)
- ✅ POST /api/users/profile/upload-foto (upload KTP/Profile)
- ✅ Validation lengkap (NIK 16 digit, dll)
- ✅ File upload dengan auto-cleanup
- ✅ Tested & ready

### Frontend Status: ✅ COMPLETE

Flutter telah mengimplementasikan:
- ✅ UserProfile model (18+ fields)
- ✅ ProfileService (3 endpoints)
- ✅ Edit Profile UI lengkap
- ✅ Photo upload (KTP & Profile)
- ✅ Validation & error handling
- ✅ Ready to test

---

## 📦 Database Fields

Backend menambahkan 18+ fields ke tabel `users`:

### Identity (5 fields)
- `nik` - NIK 16 digit
- `jenisKelamin` - Laki-laki/Perempuan
- `statusKawin` - Kawin/Belum/Janda/Duda
- `tempatLahir` - Tempat lahir
- `tanggalLahir` - Tanggal lahir

### Address (7 fields)
- `provinsi`, `kota`, `kecamatan`, `kelurahan`
- `rt`, `rw`, `jalan`

### Profession & Education (2 fields)
- `pekerjaan` - Pekerjaan
- `pendidikan` - Tingkat pendidikan

### Political (2 fields)
- `underbow` - Underbow partai
- `kegiatan` - Kegiatan partai

### Photos (2 fields)
- `fotoKtp` - URL foto KTP
- `fotoProfil` - URL foto profile

### Additional (2 fields)
- `phone` - Nomor telepon
- `bio` - Bio/deskripsi

**Total:** 20+ fields (18 new + 2 existing)

---

## 🚀 API Endpoints

### 1. GET Profile
```
GET /api/users/profile
Authorization: Bearer <token>
```
**Response:** User profile dengan semua fields

### 2. Update Profile
```
PUT /api/users/profile
Authorization: Bearer <token>
Content-Type: application/json

Body: { ...profile fields... }
```
**Response:** Updated profile

### 3. Upload Photo
```
POST /api/users/profile/upload-foto
Authorization: Bearer <token>
Content-Type: multipart/form-data

Body:
  - fotoType: "ktp" | "profil"
  - file: [Image File]
```
**Response:** Photo URL

---

## ✅ Validation Rules

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

## 📂 File Upload

**Storage Location:**
- Profile photos: `/uploads/profiles/`
- KTP photos: `/uploads/ktp/`

**Constraints:**
- Max size: 5MB
- Formats: .jpg, .jpeg, .png
- Auto cleanup: Old photos deleted on new upload

**Photo URLs:**
```
http://YOUR_IP:3030/uploads/profiles/profil-1-xxx.jpg
http://YOUR_IP:3030/uploads/ktp/ktp-1-xxx.jpg
```

---

## 🧪 Quick Test

### 1. Login
```bash
POST http://10.191.38.178:3030/api/auth/login
{
  "email": "admin@example.com",
  "password": "Admin123!"
}
```

### 2. Get Profile
```bash
GET http://10.191.38.178:3030/api/users/profile
Authorization: Bearer <token>
```

### 3. Update Profile
```bash
PUT http://10.191.38.178:3030/api/users/profile
Authorization: Bearer <token>
{
  "nik": "3276047658400027",
  "jenisKelamin": "Laki-laki",
  "tempatLahir": "Jakarta"
}
```

---

## 📖 Read More

- **Overview:** [README_EDIT_PROFILE.md](./README_EDIT_PROFILE.md)
- **Flutter Guide:** [FLUTTER_EDIT_PROFILE_API.md](./FLUTTER_EDIT_PROFILE_API.md)
- **Testing Guide:** [TESTING_EDIT_PROFILE.md](./TESTING_EDIT_PROFILE.md)

---

**Last Updated:** 24 Desember 2025  
**Backend Version:** v1.0.0  
**Status:** ✅ Production Ready
