# Permission & Role Requirements - Agenda & Announcement

## 🚨 **PENTING: Backend Permission Requirements**

### **Issue Ditemukan:**
User dengan role **"simpatisan"** mendapat error **403 Forbidden** saat mengakses:
- `/api/agenda` 
- `/api/announcement`

### **Error Message dari Backend:**
```json
{
  "success": false,
  "message": "Forbidden: insufficient privileges"
}
```

---

## 📋 **Role & Permission yang Dibutuhkan**

### **Saat Ini:**
Backend mengharuskan user memiliki **privilege/role tertentu** untuk mengakses endpoint Agenda dan Announcement.

### **Role yang Tersedia di Sistem:**
Berdasarkan data user:
```json
"roles": [
  {
    "id": 6,
    "uuid": "05509de8-284c-4f6a-ad04-8667ff15dcab",
    "userId": 8,
    "role": "simpatisan"
  }
]
```

---

## 🔧 **Solusi**

### **Opsi 1: Backend - Update Permission (RECOMMENDED)**

Backend developer perlu:

1. **Buka akses untuk role "simpatisan"** agar bisa melihat Agenda dan Announcement
   ```javascript
   // Di backend middleware/authorization
   // Izinkan "simpatisan" untuk READ Agenda dan Announcement
   if (endpoint === '/api/agenda' && method === 'GET') {
     allowedRoles = ['admin', 'kader', 'simpatisan']; // Tambahkan simpatisan
   }
   
   if (endpoint === '/api/announcement' && method === 'GET') {
     allowedRoles = ['admin', 'kader', 'simpatisan']; // Tambahkan simpatisan
   }
   ```

2. **Atau buat public endpoint** untuk Agenda dan Announcement (tanpa auth)
   ```javascript
   // Endpoint publik untuk announcement
   router.get('/api/announcement/public', getPublicAnnouncements);
   
   // Endpoint publik untuk agenda
   router.get('/api/agenda/public', getPublicAgendas);
   ```

---

### **Opsi 2: Frontend - Tambahkan Role Check**

Sembunyikan menu jika user tidak punya akses:

```dart
// Di beranda_page.dart
bool canAccessAgenda() {
  // Cek role user dari profile
  final roles = _userProfile?.roles ?? [];
  return roles.any((role) => 
    role.role == 'admin' || 
    role.role == 'kader'
  );
}

// Dalam menu items
if (canAccessAgenda() && item['label'] == 'Agenda') {
  // Show menu
} else {
  // Hide menu atau show disabled state
}
```

---

### **Opsi 3: Temporary - Ganti User Role**

Untuk testing, bisa ubah role user di database:

```sql
-- Update role user untuk testing
UPDATE user_roles 
SET role = 'kader' 
WHERE userId = 8 AND role = 'simpatisan';
```

---

## 📱 **Update Frontend - Error Handling**

Frontend sudah diupdate untuk menampilkan pesan yang lebih informatif:

### **Agenda Service:**
```dart
if (response['message'].toString().contains('Forbidden')) {
  throw Exception('Anda tidak memiliki akses ke fitur Agenda. Silakan hubungi admin.');
}
```

### **Announcement Service:**
```dart
if (response['message'].toString().contains('Forbidden')) {
  throw Exception('Anda tidak memiliki akses ke fitur My Gerindra. Silakan hubungi admin.');
}
```

### **UI Display:**
Sekarang akan tampil error message yang jelas:
```
Terjadi Kesalahan
Anda tidak memiliki akses ke fitur Agenda. 
Silakan hubungi admin.
```

---

## 🎯 **Recommended Action**

### **UNTUK BACKEND DEVELOPER:**

**Pertanyaan yang perlu dijawab:**

1. **Apakah Agenda dan Announcement harus restricted?**
   - Jika YA: Role apa saja yang boleh akses?
   - Jika TIDAK: Buat endpoint public atau buka untuk semua authenticated user

2. **Role "simpatisan" seharusnya punya akses apa?**
   - READ-only untuk Agenda dan Announcement?
   - Atau benar-benar tidak boleh akses?

3. **Apakah perlu endpoint terpisah?**
   - `/api/agenda` (protected) - CRUD untuk admin/kader
   - `/api/agenda/public` (public) - READ untuk semua orang

### **UNTUK TESTING SEMENTARA:**

Jika ingin test fitur sekarang:

1. **Update role di database** ke "admin" atau "kader"
2. **Atau buat user baru** dengan role yang punya akses
3. **Atau minta backend** temporary buka akses untuk "simpatisan"

---

## 📊 **Expected Behavior**

### **Setelah Permission Diperbaiki:**

#### **Agenda:**
```
GET /api/agenda
Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Rapat Koordinasi",
      "description": "...",
      "date": "2026-02-15T09:00:00Z",
      "location": "Kantor DPC"
    }
  ]
}
```

#### **Announcement:**
```
GET /api/announcement
Response: 200 OK
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "Pengumuman Penting",
      "content": "...",
      "isPinned": true
    }
  ]
}
```

---

## 🔍 **Debug Info**

### **Current User Info:**
```json
{
  "id": 8,
  "name": "farhan",
  "email": "farhan@example.com",
  "username": "aaaaa",
  "roles": [
    {
      "role": "simpatisan"
    }
  ]
}
```

### **Endpoints Tested:**
- ❌ `GET /api/agenda` → 403 Forbidden
- ❌ `GET /api/announcement` → 403 Forbidden

### **Authentication:**
- ✅ Token valid
- ✅ User authenticated
- ❌ Insufficient privileges for endpoints

---

## 📞 **Next Steps**

1. **Koordinasi dengan Backend Developer** tentang permission model
2. **Tentukan role mapping** untuk setiap feature
3. **Update backend authorization** sesuai kesepakatan
4. **Test ulang** setelah backend updated

---

**Last Updated:** 11 Februari 2026  
**Status:** BLOCKED - Waiting for Backend Permission Update  
**Priority:** HIGH - Feature tidak bisa diakses oleh user "simpatisan"
