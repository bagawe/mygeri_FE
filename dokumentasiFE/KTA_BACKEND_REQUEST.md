# 🖥️ BACKEND REQUEST: KTA (Kartu Tanda Anggota) Feature

**Tanggal**: 9 Januari 2026 (Updated: 13 Januari 2026)  
**Request dari**: Frontend Team  
**Priority**: High (Blocking Feature)  
**Estimasi**: ~6-8 jam kerja

---

## 📋 RINGKASAN FITUR

User ingin bisa **melihat dan download Kartu Tanda Anggota (KTA)** digital mereka. KTA menampilkan:
- Foto profil
- Nama & ID anggota
- QR Code (berisi user ID)
- Detail profil lengkap (tanggal lahir, alamat, jenis kelamin)
- **Tanda tangan Ketua Umum & Sekretaris** (⚠️ **HANYA jika sudah diverifikasi admin**)

**Format:** 2 sisi kartu (depan & belakang), ukuran standar ID card, bisa di-download untuk print.

**PENTING - Platform:**
- **Mobile App (Flutter):** Hanya untuk user melihat KTA mereka sendiri
- **Web Admin:** Untuk admin melakukan verifikasi KTA (akan dikembangkan terpisah)
- Backend API harus support kedua platform dengan endpoint yang sama

### 🔐 **VERIFIKASI ADMIN (REQUIREMENT BARU)**

**Business Rule:**
- ❌ **User baru** → KTA **tanpa tanda tangan** (belum diverifikasi)
- ✅ **Admin verifikasi** → KTA **dengan tanda tangan** (sudah diverifikasi)
- 📥 **Download/Print** → Hanya tersedia jika sudah diverifikasi

**Alasan:**
- Kontrol kualitas data member
- Mencegah KTA palsu/tidak valid
- Admin bisa review dokumen sebelum approve

---

## 🤔 APAKAH PERLU BACKEND?

### ✅ **YA, PERLU BACKEND SUPPORT!** (UPDATE REQUIREMENT)

**Alasan:**
1. ✅ **Verifikasi Admin** - Tanda tangan hanya muncul jika user sudah diverifikasi admin
2. ✅ **Status Verifikasi** - Backend perlu track status verifikasi per user
3. ⚠️ Data profil existing - Perlu tambahan field `is_verified`
4. ✅ QR Code & download tetap di frontend

**Flow Bisnis:**
```
User Daftar → Belum Terverifikasi → KTA tanpa tanda tangan
     ↓
Admin Verifikasi → Status: Verified → KTA dengan tanda tangan
```

---

## 🔧 BACKEND REQUIREMENTS (WAJIB)

## 🔧 BACKEND REQUIREMENTS (WAJIB)

### 1️⃣ **DATABASE SCHEMA UPDATE**

**Tambah field di tabel users atau buat tabel khusus:**

**Option A: Update tabel `users`** (Recommended - Simple)
```sql
ALTER TABLE users 
ADD COLUMN kta_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN kta_verified_at TIMESTAMP NULL,
ADD COLUMN kta_verified_by INT NULL;  -- Admin ID yang verifikasi

-- Index untuk query cepat
CREATE INDEX idx_users_kta_verified ON users(kta_verified);
```

**Option B: Tabel khusus `kta_verifications`** (Jika perlu audit trail lengkap)
```sql
CREATE TABLE kta_verifications (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMP NULL,
  verified_by INT NULL,  -- Admin ID
  notes TEXT NULL,       -- Catatan admin (opsional)
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (verified_by) REFERENCES users(id),
  UNIQUE KEY unique_user (user_id)
);
```

**Recommendation:** Gunakan **Option A** (lebih simple, cukup untuk requirement ini).

---

### 2️⃣ **UPDATE API PROFILE/LOGIN**

**Response API harus include field verifikasi:**

**Endpoint:** `GET /api/user/profile` atau `POST /api/auth/login`

**Response UPDATED:**
```json
{
  "success": true,
  "data": {
    "id": 12345,
    "name": "John Doe",
    "fotoProfil": "https://...",
    "tanggal_lahir": "1990-01-15",
    "alamat_lengkap": "Jl. Example No. 1, Jakarta Selatan",
    "jenis_kelamin": "Laki-laki",
    "roles": [
      {"role": "simpatisan"}
    ],
    
    // ← FIELD BARU (WAJIB)
    "kta_verified": false,              // Apakah KTA sudah diverifikasi admin
    "kta_verified_at": null,            // Kapan diverifikasi (null jika belum)
    "kta_verified_by": null             // Admin ID yang verifikasi (null jika belum)
  }
}
```

**Jika user sudah diverifikasi:**
```json
{
  "kta_verified": true,
  "kta_verified_at": "2026-01-09T10:30:00Z",
  "kta_verified_by": 999  // Admin ID
}
```

---

### 3️⃣ **API ADMIN: VERIFIKASI USER**

**Endpoint baru untuk admin verifikasi KTA user:**

**POST /api/admin/kta/verify**

**Authorization:** Bearer token (harus admin)

**Request:**
```json
POST /api/admin/kta/verify
Content-Type: application/json
Authorization: Bearer <admin_token>

{
  "user_id": 12345,          // User yang mau diverifikasi
  "verified": true,          // true = verifikasi, false = batalkan verifikasi
  "notes": "Dokumen lengkap" // Opsional: catatan admin
}
```

**Response (Success):**
```json
{
  "success": true,
  "message": "User berhasil diverifikasi",
  "data": {
    "user_id": 12345,
    "kta_verified": true,
    "verified_at": "2026-01-09T10:30:00Z",
    "verified_by": 999  // Admin ID dari token
  }
}
```

**Response (Error - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized. Admin access required."
}
```

**Response (Error - User Not Found):**
```json
{
  "success": false,
  "message": "User tidak ditemukan"
}
```

**Business Logic:**
```javascript
// Pseudocode
async function verifyKTA(adminId, userId, verified, notes) {
  // 1. Check if requester is admin
  const admin = await User.findById(adminId);
  if (!admin.isAdmin()) {
    throw new UnauthorizedException('Admin access required');
  }
  
  // 2. Check if user exists
  const user = await User.findById(userId);
  if (!user) {
    throw new NotFoundException('User tidak ditemukan');
  }
  
  // 3. Update verification status
  user.kta_verified = verified;
  user.kta_verified_at = verified ? new Date() : null;
  user.kta_verified_by = verified ? adminId : null;
  await user.save();
  
  // 4. Optional: Log ke audit trail
  await AuditLog.create({
    action: verified ? 'KTA_VERIFIED' : 'KTA_UNVERIFIED',
    admin_id: adminId,
    user_id: userId,
    notes: notes
  });
  
  return user;
}
```

---

### 4️⃣ **API ADMIN: LIST USER UNTUK VERIFIKASI**

**Endpoint untuk admin melihat daftar user yang perlu/sudah diverifikasi:**

**GET /api/admin/kta/users**

**Authorization:** Bearer token (harus admin)

**Request:**
```
GET /api/admin/kta/users?status=unverified&page=1&limit=20
Authorization: Bearer <admin_token>
```

**Query Parameters:**
- `status` (optional): `all`, `verified`, `unverified` (default: `all`)
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 20)
- `search` (optional): Cari nama user

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 12345,
        "name": "John Doe",
        "fotoProfil": "https://...",
        "roles": [{"role": "simpatisan"}],
        "kta_verified": false,
        "kta_verified_at": null,
        "created_at": "2024-01-01T00:00:00Z"
      },
      {
        "id": 12346,
        "name": "Jane Doe",
        "fotoProfil": "https://...",
        "roles": [{"role": "kader"}],
        "kta_verified": true,
        "kta_verified_at": "2026-01-08T15:00:00Z",
        "verified_by_name": "Admin User",  // Nama admin yang verifikasi
        "created_at": "2024-02-01T00:00:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 5,
      "total_items": 100,
      "items_per_page": 20
    }
  }
}
```

---

### 5️⃣ **UPDATE API: GET MY KTA DATA**

**Endpoint user melihat status KTA mereka sendiri:**

**GET /api/kta/my-status**

**Authorization:** Bearer token (user logged in)

**Request:**
```
GET /api/kta/my-status
Authorization: Bearer <user_token>
```

**Response (Belum Diverifikasi):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "tanggal_lahir": "1990-01-15",
      "alamat_lengkap": "Jl. Example No. 1, Jakarta Selatan",
      "jenis_kelamin": "Laki-laki",
      "roles": [{"role": "simpatisan"}]
    },
    "kta": {
      "verified": false,               // ← User belum diverifikasi
      "verified_at": null,
      "can_print": false,              // ← Tidak bisa print (tanpa tanda tangan)
      "message": "KTA Anda sedang dalam proses verifikasi admin"
    }
  }
}
```

**Response (Sudah Diverifikasi):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "tanggal_lahir": "1990-01-15",
      "alamat_lengkap": "Jl. Example No. 1, Jakarta Selatan",
      "jenis_kelamin": "Laki-laki",
      "roles": [{"role": "simpatisan"}]
    },
    "kta": {
      "verified": true,                // ← User sudah diverifikasi
      "verified_at": "2026-01-09T10:30:00Z",
      "can_print": true,               // ← Bisa print (dengan tanda tangan)
      "card_number": "KTA-2024-12345", // Optional: nomor KTA unik
      "issued_date": "2026-01-09"
    }
  }
}
```

---

### 6️⃣ **PERMISSION & AUTHORIZATION**

### 6️⃣ **PERMISSION & AUTHORIZATION**

**Pastikan middleware permission untuk endpoint admin:**

```javascript
// Middleware untuk check admin
function requireAdmin(req, res, next) {
  const user = req.user; // Dari JWT token
  
  if (!user || !user.roles.some(r => r.role === 'admin')) {
    return res.status(403).json({
      success: false,
      message: 'Forbidden. Admin access required.'
    });
  }
  
  next();
}

// Apply di route
router.post('/api/admin/kta/verify', requireAdmin, verifyKTAController);
router.get('/api/admin/kta/users', requireAdmin, listUsersController);
```

**Role yang bisa verifikasi:** Hanya `admin`

---

## 🔄 OPTIONAL ENHANCEMENTS

### 7️⃣ **QR CODE VERIFICATION API** (Optional - untuk scan KTA)

Untuk scan QR Code dan verifikasi keanggotaan (misalnya di event, security check, dll).

**Endpoint:** `POST /api/kta/verify-qr`

**Request:**
```json
POST /api/kta/verify-qr
Content-Type: application/json

{
  "qr_data": "12345"  // User ID dari scan QR code
}
```

**Response (User Valid & Verified):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "verified": true,           // KTA sudah diverifikasi admin
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "roles": [{"role": "simpatisan"}],
      "member_since": "2024-01-01"
    },
    "kta": {
      "verified_at": "2026-01-09T10:30:00Z",
      "status": "active"
    }
  }
}
```

**Response (User Valid tapi Belum Verified):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "verified": false,          // KTA belum diverifikasi
    "message": "KTA belum diverifikasi oleh admin",
    "user": {
      "id": 12345,
      "name": "John Doe",
      "roles": [{"role": "simpatisan"}]
    }
  }
}
```

**Response (User Invalid):**
```json
{
  "success": true,
  "data": {
    "valid": false,
    "message": "User tidak ditemukan atau KTA tidak aktif"
  }
}
```

---

### 8️⃣ **DYNAMIC ASSETS API** (Optional)

Jika logo atau signature perlu update tanpa update aplikasi.

**Endpoint:** `GET /api/kta/assets`

**Request:**
```json
POST /api/kta/verify
Content-Type: application/json

{
  "qr_data": "12345"  // User ID dari scan QR code
}
```

**Response (User Valid):**
```json
{
  "success": true,
  "data": {
    "valid": true,
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "roles": [
        {"role": "simpatisan"}
      ],
      "member_since": "2024-01-01",
      "status": "active"  // active, inactive, suspended
    },
    "kta_info": {
      "issued_date": "2024-01-01",
      "valid_until": "2026-12-31",  // Jika ada expiry
      "card_number": "KTA-2024-12345"
    }
  }
}
```

**Response (User Invalid):**
```json
{
  "success": true,
  "data": {
    "valid": false,
    "message": "User tidak ditemukan atau kartu tidak aktif"
  }
}
```

**Use Case:**
- Security/admin scan QR code di KTA
- Backend verifikasi apakah user valid
- Tampilkan info user untuk konfirmasi identitas

---

### 2️⃣ **DYNAMIC ASSETS API** (Optional)

Jika logo atau signature perlu update tanpa update aplikasi.

**Endpoint:** `GET /api/kta/assets`

**Request:**
```
GET /api/kta/assets
Authorization: Bearer <token>  // Optional
```

**Response:**
```json
{
  "success": true,
  "data": {
    "logo_url": "https://cdn.example.com/logo_gerindra.png",
    "signature_ketua": "https://cdn.example.com/ttd_ketua_umum.png",
    "signature_sekjen": "https://cdn.example.com/ttd_sekretaris.png",
    "ketua_name": "Prabowo Subianto",
    "ketua_title": "Ketua Umum",
    "sekjen_name": "Sufmi Dasco",
    "sekjen_title": "Sekretaris Jenderal",
    "version": "1.0"  // Untuk cache invalidation
  }
}
```

---

## 🧪 TEST CASES

### Test 1: Admin Verifikasi User
```bash
POST /api/admin/kta/verify
Authorization: Bearer <admin_token>
{
  "user_id": 12345,
  "verified": true,
  "notes": "Dokumen lengkap dan valid"
}

# Expected Response:
{
  "success": true,
  "message": "User berhasil diverifikasi",
  "data": {
    "user_id": 12345,
    "kta_verified": true,
    "verified_at": "2026-01-09T10:30:00Z",
    "verified_by": 999
  }
}

# Expected DB State:
# users.kta_verified = true
# users.kta_verified_at = "2026-01-09 10:30:00"
# users.kta_verified_by = 999
```

### Test 2: Admin Batalkan Verifikasi
```bash
POST /api/admin/kta/verify
Authorization: Bearer <admin_token>
{
  "user_id": 12345,
  "verified": false,
  "notes": "Dokumen tidak valid"
}

# Expected DB State:
# users.kta_verified = false
# users.kta_verified_at = null
# users.kta_verified_by = null
```

### Test 3: User Cek Status KTA (Belum Verified)
```bash
GET /api/kta/my-status
Authorization: Bearer <user_token>

# Expected Response:
{
  "success": true,
  "data": {
    "kta": {
      "verified": false,
      "can_print": false,
      "message": "KTA Anda sedang dalam proses verifikasi admin"
    }
  }
}
```

### Test 4: User Cek Status KTA (Sudah Verified)
```bash
GET /api/kta/my-status
Authorization: Bearer <verified_user_token>

# Expected Response:
{
  "success": true,
  "data": {
    "kta": {
      "verified": true,
      "verified_at": "2026-01-09T10:30:00Z",
      "can_print": true
    }
  }
}
```

### Test 5: Non-Admin Coba Verifikasi (Should Fail)
```bash
POST /api/admin/kta/verify
Authorization: Bearer <non_admin_token>
{
  "user_id": 12345,
  "verified": true
}

# Expected Response:
{
  "success": false,
  "message": "Forbidden. Admin access required."
}
# HTTP Status: 403
```

### Test 6: Admin List User (Filter Unverified)
```bash
GET /api/admin/kta/users?status=unverified
Authorization: Bearer <admin_token>

# Expected Response:
{
  "success": true,
  "data": {
    "users": [
      {
        "id": 12345,
        "name": "John Doe",
        "kta_verified": false,
        "created_at": "2024-01-01T00:00:00Z"
      }
    ]
  }
}
```

### Test 7: Login/Profile API Include Verification Status
```bash
POST /api/auth/login
{
  "email": "user@example.com",
  "password": "password"
}

# Expected Response harus include:
{
  "data": {
    "id": 12345,
    "name": "John Doe",
    "kta_verified": false,        # ← Field baru
    "kta_verified_at": null,      # ← Field baru
    "kta_verified_by": null       # ← Field baru
  }
}
```

---

## 📊 SKENARIO LENGKAP

### Skenario A: User Baru Daftar
```
User Register
    ↓
DB State:
- kta_verified = false (default)
- kta_verified_at = null
- kta_verified_by = null
    ↓
User buka KTA di app
    ↓
Frontend tampilkan:
- KTA tanpa tanda tangan
- Pesan: "KTA Anda sedang dalam proses verifikasi"
- Tombol download disabled atau tidak ada tanda tangan
```

### Skenario B: Admin Verifikasi User
```
Admin login ke dashboard
    ↓
Admin lihat list user (GET /api/admin/kta/users?status=unverified)
    ↓
Admin pilih user, klik "Verifikasi"
    ↓
Frontend call: POST /api/admin/kta/verify
{
  "user_id": 12345,
  "verified": true
}
    ↓
DB State:
- kta_verified = true
- kta_verified_at = "2026-01-09 10:30:00"
- kta_verified_by = 999 (admin ID)
    ↓
User refresh app atau re-login
    ↓
Frontend tampilkan:
- KTA dengan tanda tangan Ketua Umum & Sekretaris
- Tombol download enabled
- Pesan: "KTA Anda telah diverifikasi"
```

### Skenario C: User Check Status KTA
```
User buka halaman KTA
    ↓
Frontend call: GET /api/kta/my-status
    ↓
Backend response:
- verified: false → Tampilkan KTA tanpa TTD
- verified: true → Tampilkan KTA dengan TTD
    ↓
Frontend render card sesuai status
```

### Skenario D: Admin Batalkan Verifikasi (Edge Case)
```
Admin pilih user yang sudah verified
    ↓
Admin klik "Batalkan Verifikasi"
    ↓
POST /api/admin/kta/verify
{
  "user_id": 12345,
  "verified": false,
  "notes": "Dokumen tidak valid"
}
    ↓
DB State:
- kta_verified = false
- kta_verified_at = null
- kta_verified_by = null
    ↓
User tidak bisa print KTA dengan TTD lagi
```

---

## ⚠️ BACKWARD COMPATIBILITY

**Data Existing:**
- User yang sudah ada sebelum update akan punya `kta_verified = false` (default)
- Setelah migration, perlu ada proses verifikasi manual oleh admin

**Migration Data (Optional - Jika Semua User Lama Auto-Verified):**
```sql
-- Jika mau auto-verify user lama yang sudah lama terdaftar
UPDATE users 
SET kta_verified = true,
    kta_verified_at = NOW()
WHERE created_at < '2026-01-09'  -- User sebelum feature ini launched
  AND kta_verified = false;
```

**Catatan:** Lebih baik admin verifikasi manual per user untuk data quality.

---

## 📋 CHECKLIST IMPLEMENTATION

### ✅ **WAJIB - Phase 1 (Core Feature)**

- [ ] **Database**
  - [ ] Tambah field `kta_verified`, `kta_verified_at`, `kta_verified_by` di tabel users
  - [ ] Buat migration script
  - [ ] Set default `kta_verified = false` untuk user baru

- [ ] **API: Update Profile/Login Response**
  - [ ] Tambah field `kta_verified`, `kta_verified_at`, `kta_verified_by` di response
  - [ ] Test backward compatibility

- [ ] **API: POST /api/admin/kta/verify**
  - [ ] Implement endpoint untuk admin verifikasi user
  - [ ] Validasi: hanya admin yang bisa akses
  - [ ] Update DB status verifikasi
  - [ ] Return updated status

- [ ] **API: GET /api/admin/kta/users**
  - [ ] Implement list user dengan filter verified/unverified
  - [ ] Support pagination
  - [ ] Support search by name
  - [ ] Validasi: hanya admin yang bisa akses

- [ ] **API: GET /api/kta/my-status**
  - [ ] Implement endpoint untuk user cek status KTA
  - [ ] Return verification status
  - [ ] Return user profile data

- [ ] **Permission & Authorization**
  - [ ] Middleware `requireAdmin` untuk endpoint admin
  - [ ] Test unauthorized access (non-admin coba akses)

- [ ] **Testing**
  - [ ] Test admin verifikasi user
  - [ ] Test admin batalkan verifikasi
  - [ ] Test non-admin tidak bisa akses endpoint admin
  - [ ] Test user cek status KTA (verified & unverified)
  - [ ] Test login/profile response include verification status

### ⏳ **OPTIONAL - Phase 2 (Enhancement)**

- [ ] **API: POST /api/kta/verify-qr**
  - [ ] Implement QR verification endpoint
  - [ ] Check user valid & verified

- [ ] **API: GET /api/kta/assets**
  - [ ] Dynamic assets untuk logo & signature
  - [ ] CDN support

- [ ] **Audit Trail**
  - [ ] Log semua verifikasi activity
  - [ ] Track siapa admin yang verifikasi

- [ ] **Notification**
  - [ ] Kirim notifikasi ke user saat KTA diverifikasi
  - [ ] Push notification atau email

---

## 🚀 DEPLOYMENT NOTES

**Urutan Deploy:**
1. ✅ Deploy database migration (add columns)
2. ✅ Deploy backend update (new endpoints + updated responses)
3. ✅ Test API dengan Postman
4. ✅ Notify frontend team → Frontend update UI based on verification status
5. ✅ Deploy frontend
6. ⚠️ Admin mulai verifikasi user secara manual

**Rollback Plan:**
- Field `kta_verified` bisa di-set `false` untuk semua user jika ada masalah
- Frontend harus handle `null` value untuk backward compatibility

---

## 📞 COMMUNICATION

**Frontend Team:**
- File analisis lengkap: `dokumentasiFE/KTA_FEATURE_ANALYSIS.md`
- Frontend akan check field `kta_verified`:
  - `false` → Tampilkan KTA tanpa tanda tangan + pesan "Sedang diverifikasi"
  - `true` → Tampilkan KTA lengkap dengan tanda tangan + enable download

**Backend Team:**
- **Action Required:** ✅ WAJIB IMPLEMENT (untuk fitur KTA berfungsi)
- **Priority:** High (blocking frontend release)
- **Estimasi:** ~6-8 jam
  - Database migration: 1 jam
  - API endpoints: 4 jam
  - Testing: 2 jam
  - Deployment: 1 jam

---

## 🎯 SUMMARY

| Item | Status | Notes |
|------|--------|-------|
| **Database Schema** | ✅ Required | Add `kta_verified` fields |
| **API Profile Update** | ✅ Required | Include verification status |
| **API Admin Verify** | ✅ Required | POST /api/admin/kta/verify |
| **API Admin List Users** | ✅ Required | GET /api/admin/kta/users |
| **API User Check Status** | ✅ Required | GET /api/kta/my-status |
| **Permission Control** | ✅ Required | Only admin can verify |
| **QR Verification API** | ⏳ Optional | For scanning KTA |
| **Dynamic Assets** | ⏳ Optional | For remote updates |
| **Audit Trail** | ⏳ Optional | Logging verification activity |
| **Notifications** | ⏳ Optional | Notify user when verified |

**Backend Team: Action required untuk implement verification system. Koordinasi untuk timeline dan deployment!** 🚀

Jika logo atau signature perlu update tanpa update aplikasi.

**Endpoint:** `GET /api/kta/assets`

**Request:**
```
GET /api/kta/assets
Authorization: Bearer <token>  // Optional
```

**Response:**
```json
{
  "success": true,
  "data": {
    "logo_url": "https://cdn.example.com/logo_gerindra.png",
    "signature_ketua": "https://cdn.example.com/ttd_ketua_umum.png",
    "signature_sekjen": "https://cdn.example.com/ttd_sekretaris.png",
    "ketua_name": "Prabowo Subianto",
    "ketua_title": "Ketua Umum",
    "sekjen_name": "Sufmi Dasco",
    "sekjen_title": "Sekretaris Jenderal",
    "version": "1.0"  // Untuk cache invalidation
  }
}
```

**Use Case:**
- Jika tanda tangan/nama pejabat berubah
- Frontend download asset dari URL
- Tidak perlu update aplikasi

---

### 3️⃣ **KTA DATA ENDPOINT** (Optional)

Jika ada data tambahan yang tidak ada di profile API.

**Endpoint:** `GET /api/kta/my-card`

**Request:**
```
GET /api/kta/my-card
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "tanggal_lahir": "1990-01-15",
      "alamat_lengkap": "Jl. Example No. 1, Jakarta Selatan",
      "jenis_kelamin": "Laki-laki",
      "roles": [
        {"role": "simpatisan"}
      ]
    },
    "kta": {
      "card_number": "KTA-2024-12345",  // Nomor KTA unik
      "issued_date": "2024-01-01",      // Tanggal terbit
      "valid_until": "2026-12-31",      // Masa berlaku (jika ada)
      "status": "active",               // active, expired, suspended
      "member_since": "2024-01-01"      // Sejak kapan jadi anggota
    }
  }
}
```

**Use Case:**
- Jika KTA punya nomor unik (bukan hanya user ID)
- Jika ada masa berlaku KTA
- Jika ada status keanggotaan khusus

---

## 📊 DATA PROFIL YANG DIBUTUHKAN

**Dari API Existing (Login/Profile):**

Frontend butuh field-field ini dari response API yang sudah ada:

```json
{
  "id": 12345,                    // ✅ WAJIB - Untuk QR code
  "name": "John Doe",             // ✅ WAJIB - Nama di KTA
  "fotoProfil": "https://...",    // ⚠️ OPTIONAL - Foto di KTA (bisa kosong)
  "tanggal_lahir": "1990-01-15",  // ⚠️ RECOMMENDED - Untuk KTA belakang
  "alamat_lengkap": "...",        // ⚠️ RECOMMENDED - Untuk KTA belakang
  "jenis_kelamin": "Laki-laki",   // ⚠️ RECOMMENDED - Untuk KTA belakang
  "roles": [
    {"role": "simpatisan"}        // ✅ WAJIB - Untuk identifikasi role
  ]
}
```

**Jika field tidak ada di API existing:**

1. **tanggal_lahir** → Tampilkan "-" di KTA
2. **alamat_lengkap** → Tampilkan "-" di KTA
3. **jenis_kelamin** → Default "Laki-laki" atau tampilkan "-"
4. **fotoProfil** → Tampilkan avatar/inisial nama

**Request:** Pastikan field-field ini tersedia di response API profile/login.

---

## 🧪 TEST CASES (Jika Backend Implement API)

### Test 1: Verify KTA (Valid User)
```bash
POST /api/kta/verify
{
  "qr_data": "12345"
}

# Expected Response:
{
  "success": true,
  "data": {
    "valid": true,
    "user": { ... }
  }
}
```

### Test 2: Verify KTA (Invalid User)
```bash
POST /api/kta/verify
{
  "qr_data": "99999"  # Non-existent user
}

# Expected Response:
{
  "success": true,
  "data": {
    "valid": false,
    "message": "User tidak ditemukan"
  }
}
```

### Test 3: Get KTA Assets
```bash
GET /api/kta/assets

# Expected Response:
{
  "success": true,
  "data": {
    "logo_url": "https://...",
    "signature_ketua": "https://...",
    "signature_sekjen": "https://..."
  }
}
```

### Test 4: Get My KTA Data
```bash
GET /api/kta/my-card
Authorization: Bearer <valid_token>

# Expected Response:
{
  "success": true,
  "data": {
    "user": { ... },
    "kta": {
      "card_number": "KTA-2024-12345",
      "status": "active"
    }
  }
}
```

---

## 📋 CHECKLIST IMPLEMENTATION

### ❌ **TIDAK PERLU DIKERJAKAN SEKARANG**

Frontend akan implement fitur KTA **tanpa** backend support terlebih dahulu:
- [x] Data dari storage lokal (hasil login)
- [x] Assets bundle di Flutter app
- [x] QR code generated di client
- [x] Download/save di client

### ✅ **OPSIONAL - Untuk Future Enhancement**

Jika diperlukan nanti, backend bisa implement:

- [ ] **API: POST /api/kta/verify**
  - [ ] Accept QR data (user ID)
  - [ ] Verify user exists and active
  - [ ] Return user info + KTA status

- [ ] **API: GET /api/kta/assets**
  - [ ] Return CDN URLs for logo & signatures
  - [ ] Support versioning for cache

- [ ] **API: GET /api/kta/my-card** (jika ada data tambahan)
  - [ ] Return card number (jika ada)
  - [ ] Return issued date & expiry (jika ada)
  - [ ] Return member status

- [ ] **Database** (jika perlu table khusus)
  - [ ] Table: `kta_cards` (jika ada nomor KTA unik)
  - [ ] Columns: user_id, card_number, issued_date, valid_until, status

---

## 🚀 DEPLOYMENT NOTES

### Phase 1: Frontend Only (SEKARANG)
1. ✅ Frontend implement KTA tanpa backend
2. ✅ Data dari API profile existing
3. ✅ Assets static bundle di Flutter
4. ✅ QR code = user ID

### Phase 2: Backend Enhancement (FUTURE - Jika Diperlukan)
1. Backend implement verification API
2. Frontend tambah QR scanner untuk verifikasi
3. Admin/security bisa scan QR untuk verifikasi
4. (Optional) Backend serve dynamic assets

**Kesimpulan:** Backend **tidak perlu** develop apa-apa untuk release pertama KTA.

---

## 📞 COMMUNICATION

**Frontend Team:**
- File analisis lengkap: `dokumentasiFE/KTA_FEATURE_ANALYSIS.md`
- Frontend akan implement KTA secara **mandiri** (tidak tunggu backend)

**Backend Team:**
- **Action Required:** ❌ TIDAK ADA (untuk sekarang)
- **Optional Future Work:** Implement verification API jika diperlukan nanti
- **Estimasi (jika dikerjakan nanti):** ~2 jam (verification API only)

---

## 🎯 SUMMARY

| Item | Status | Notes |
|------|--------|-------|
| **KTA Display** | ✅ Frontend Only | Data dari profile API existing |
| **QR Code** | ✅ Frontend Only | Generated di client (user ID) |
| **Download/Print** | ✅ Frontend Only | Screenshot & save to gallery |
| **Assets (Logo, TTD)** | ✅ Frontend Only | Bundle di Flutter app |
| **Verification API** | ⏳ Future Optional | Untuk scan & verify KTA |
| **Dynamic Assets** | ⏳ Future Optional | Jika signature perlu update |
| **KTA Database** | ⏳ Future Optional | Jika ada nomor KTA unik |

**Backend Team:** Tidak ada action required untuk release pertama. Koordinasi lagi jika frontend butuh API tambahan nanti. 👍

---

**Terima kasih!** 🙏
