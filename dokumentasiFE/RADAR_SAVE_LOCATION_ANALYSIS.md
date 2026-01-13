# 📍 ANALISIS FITUR: SAVE LOCATION (OFFLINE/ONLINE MARKER)

**Tanggal**: 9 Januari 2026  
**Fitur**: Mengganti tombol "Refresh" dengan "Save Location" + Marker abu-abu untuk user offline

---

## 🎯 REQUIREMENT USER

### Yang Diminta:
1. ✅ **Ganti tombol refresh di AppBar** → Menjadi tombol "Save Location"
2. ✅ **Save location saat offline** → User bisa save lokasi meskipun tidak sedang sharing
3. ✅ **Visual marker berbeda**:
   - 🔵 **ONLINE** (sharing enabled) → Titik berwarna (hijau/biru/ungu sesuai role)
   - ⚪ **OFFLINE** (saved location) → Titik abu-abu
4. ✅ **Status user terlihat** → Bisa bedakan user yang aktif sharing vs user yang cuma save lokasi

---

## 🔍 ANALISIS TEKNIS

### 1️⃣ KONDISI SAAT INI (EXISTING)

**Current Flow:**
```
User Login → Toggle Sharing ON → Background Service Aktif (1 jam sekali update)
                                → Location terkirim ke backend dengan is_sharing=true
```

**Current Backend Data (My Status):**
```json
{
  "id": 1,
  "latitude": -6.2088,
  "longitude": 106.8456,
  "is_sharing_enabled": true,  // ← Hanya ada status sharing
  "last_update": "2026-01-09T10:00:00Z"
}
```

**Current Frontend Marker Logic:**
- Semua user di map = sedang sharing (is_sharing_enabled = true)
- Warna marker berdasarkan role: simpatisan (hijau), kader (biru), admin (ungu)
- **TIDAK ADA** marker untuk user yang offline/tidak sharing

---

### 2️⃣ PERUBAHAN YANG DIBUTUHKAN

#### 🖥️ **A. BACKEND (PERLU DUKUNGAN TIM BACKEND)**

**1. Database Schema Update:**
```sql
-- Tabel: user_locations
ALTER TABLE user_locations 
ADD COLUMN is_saved_location BOOLEAN DEFAULT FALSE;

-- Sekarang bisa punya 2 mode:
-- is_sharing_enabled = true  → User sedang sharing real-time (background service)
-- is_saved_location = true   → User save manual tapi tidak sharing real-time
```

**2. API Update - Endpoint `/update-location` (sudah ada):**
```json
// POST /api/radar/update-location
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 10.5,
  "is_saved_only": true  // ← BARU: Flag untuk "save location" tanpa enable sharing
}
```

**3. API Update - Endpoint `/nearby` (sudah ada):**
```json
// GET /api/radar/nearby?latitude=-6.2088&longitude=106.8456&radius=5000
// Response harus include status:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "latitude": -6.2088,
      "longitude": 106.8456,
      "is_sharing_enabled": false,  // ← User tidak sedang sharing
      "is_saved_location": true,    // ← BARU: User save manual
      "user": {
        "name": "John Doe",
        "roles": [{"role": "simpatisan"}]
      }
    }
  ]
}
```

**4. Business Logic Backend:**
```
SKENARIO 1: User klik "Save Location" (tidak aktifkan sharing)
- is_sharing_enabled = false
- is_saved_location = true
- Background service TIDAK jalan
- Location hanya update saat user klik manual

SKENARIO 2: User toggle "Enable Sharing" ON
- is_sharing_enabled = true
- is_saved_location = true (tetap true, karena pernah save)
- Background service JALAN (update otomatis 1 jam sekali)

SKENARIO 3: User toggle "Enable Sharing" OFF
- is_sharing_enabled = false
- is_saved_location = true (tetap ada saved location sebelumnya)
- Background service STOP
```

---

#### 📱 **B. FRONTEND (FLUTTER)**

**1. Update Model `UserLocation`:**
```dart
// lib/models/radar_models.dart
class UserLocation {
  final int id;
  final double latitude;
  final double longitude;
  final double? distance;
  final DateTime lastUpdate;
  final RadarLocationUser user;
  final bool isSharingEnabled;     // ← BARU
  final bool isSavedLocation;      // ← BARU

  // Computed property
  bool get isOnline => isSharingEnabled;
  bool get isOffline => !isSharingEnabled && isSavedLocation;
}
```

**2. Update API Service:**
```dart
// lib/services/radar_api_service.dart

// BARU: Method untuk save location tanpa enable sharing
Future<void> saveLocationOnly(double latitude, double longitude, double accuracy) async {
  await http.post(
    Uri.parse('$baseUrl/update-location'),
    headers: _headers(token),
    body: jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'is_saved_only': true,  // ← Flag baru
    }),
  );
}
```

**3. Update UI - Replace Refresh Button:**
```dart
// lib/pages/radar/radar_page.dart
appBar: AppBar(
  title: const Text('Radar'),
  actions: [
    // HAPUS: IconButton refresh
    // TAMBAH: IconButton save location
    IconButton(
      icon: const Icon(Icons.bookmark_add),  // atau Icons.push_pin
      onPressed: _saveCurrentLocation,
      tooltip: 'Save Lokasi Saya',
    ),
  ],
)

Future<void> _saveCurrentLocation() async {
  try {
    // Get current location
    final position = await _locationService.getCurrentLocation();
    
    // Save ke backend (tanpa enable sharing)
    await _radarApi.saveLocationOnly(
      position.latitude,
      position.longitude,
      position.accuracy,
    );
    
    // Update local state
    setState(() {
      _myPosition = position;
    });
    
    // Reload nearby locations untuk lihat diri sendiri di map
    await _loadNearbyLocations();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Lokasi berhasil disimpan'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Gagal menyimpan lokasi: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

**4. Update Marker Colors:**
```dart
// lib/pages/radar/radar_page.dart

Color _getMarkerColor(UserLocation location) {
  // OFFLINE (saved location only) → ABU-ABU
  if (location.isOffline) {
    return Colors.grey;
  }
  
  // ONLINE (sharing enabled) → WARNA SESUAI ROLE
  if (location.user.isKader) return Colors.blue;
  if (location.user.isSimpatisan) return Colors.green;
  if (location.user.isAdmin) return Colors.purple;
  return Colors.grey;
}

// Update CircleMarker di map
CircleMarker(
  point: LatLng(location.latitude, location.longitude),
  color: _getMarkerColor(location).withOpacity(0.7),
  borderColor: _getMarkerColor(location),
  borderStrokeWidth: 2,
  radius: location.isOffline ? 6 : 8,  // Offline marker lebih kecil
)
```

**5. Update User Info Dialog:**
```dart
// Tambahkan status badge
Row(
  children: [
    Icon(
      location.isOnline ? Icons.circle : Icons.circle_outlined,
      color: location.isOnline ? Colors.green : Colors.grey,
      size: 12,
    ),
    const SizedBox(width: 4),
    Text(
      location.isOnline ? 'ONLINE' : 'OFFLINE',
      style: TextStyle(
        color: location.isOnline ? Colors.green : Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    ),
  ],
)
```

---

## 📊 COMPARISON: BEFORE vs AFTER

| Aspek | SEBELUM (Current) | SESUDAH (Proposed) |
|-------|-------------------|-------------------|
| **Tombol AppBar** | Refresh (🔄) | Save Location (📍) |
| **User di Map** | Hanya yang sharing | Sharing + Saved Location |
| **Marker Color** | Semua berwarna (by role) | Online=Warna, Offline=Abu-abu |
| **Background Service** | Jalan saat sharing ON | Tetap sama |
| **Manual Save** | ❌ Tidak ada | ✅ Ada (klik save button) |
| **Status Visual** | Role only | Role + Online/Offline badge |

---

## 🤔 APAKAH PERLU BACKEND?

### ✅ **YA, PERLU DUKUNGAN BACKEND!**

**Alasan:**

1. **Database Schema Change:**
   - Perlu kolom `is_saved_location` di tabel `user_locations`
   - Backend harus handle logic: "save location tanpa enable sharing"

2. **API Endpoint Update:**
   - Endpoint `/update-location` perlu terima parameter `is_saved_only`
   - Endpoint `/nearby` harus return field `is_sharing_enabled` dan `is_saved_location`

3. **Business Logic:**
   - Backend harus bisa bedakan:
     - User yang cuma save lokasi (is_saved_location=true, is_sharing_enabled=false)
     - User yang aktif sharing (is_sharing_enabled=true)
   - Saat `/nearby` dipanggil, harus return SEMUA user (online + offline saved)

4. **Data Persistence:**
   - Saved location harus tersimpan di database
   - Tetap muncul di radar user lain (sebagai marker abu-abu)

---

## 🚀 IMPLEMENTASI FLOW

### **TANPA BACKEND SUPPORT:**
❌ **TIDAK BISA** - Karena:
- Tidak bisa simpan "offline location" ke server
- Tidak bisa tampilkan user offline di map user lain
- Data hanya tersimpan lokal (tidak berguna untuk fitur radar)

### **DENGAN BACKEND SUPPORT:**
✅ **BISA FULL FITUR** - Flow:

**STEP 1: Backend Update (Tim Backend)**
1. Tambah kolom `is_saved_location` di database
2. Update endpoint `/update-location` untuk handle `is_saved_only=true`
3. Update endpoint `/nearby` untuk return status online/offline
4. Test API dengan Postman

**STEP 2: Frontend Update (Flutter)**
1. Update model `UserLocation` + `MyLocationStatus`
2. Update `RadarApiService` (add `saveLocationOnly()`)
3. Replace refresh button → save location button
4. Update marker colors (online=warna, offline=grey)
5. Update UI dialog (tampilkan badge online/offline)
6. Test end-to-end

---

## 📋 DOKUMENTASI BACKEND YANG DIBUTUHKAN

**Request ke Tim Backend:**

```markdown
# API Update Request: Radar Save Location Feature

## 1. Database Migration
ALTER TABLE user_locations 
ADD COLUMN is_saved_location BOOLEAN DEFAULT FALSE;

## 2. POST /api/radar/update-location
Request Body (UPDATED):
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 10.5,
  "is_saved_only": true  // NEW FIELD
}

Logic:
- Jika is_saved_only = true:
  - Set is_saved_location = true
  - JANGAN update is_sharing_enabled (biarkan false jika user belum toggle)
- Jika is_saved_only = false (default/tidak ada):
  - Behavior sama seperti sekarang (update location + set is_sharing_enabled)

## 3. GET /api/radar/nearby
Response Body (UPDATED):
{
  "success": true,
  "data": [
    {
      "id": 1,
      "latitude": -6.2088,
      "longitude": 106.8456,
      "is_sharing_enabled": false,  // EXISTING
      "is_saved_location": true,    // NEW FIELD
      "last_update": "2026-01-09T10:00:00Z",
      "user": {
        "id": 1,
        "name": "John Doe",
        "roles": [{"role": "simpatisan"}]
      }
    }
  ]
}

Logic:
- Return SEMUA user yang punya location (is_saved_location = true OR is_sharing_enabled = true)
- Include field is_sharing_enabled dan is_saved_location di response

## 4. GET /api/radar/my-status
Response Body (UPDATED):
{
  "success": true,
  "data": {
    "has_location": true,
    "latitude": -6.2088,
    "longitude": 106.8456,
    "is_sharing_enabled": false,
    "is_saved_location": true,     // NEW FIELD
    "last_update": "2026-01-09T10:00:00Z"
  }
}
```

---

## ⏱️ ESTIMASI WAKTU

### Backend (Tim Backend):
- Database migration: 30 menit
- Update endpoint `/update-location`: 1 jam
- Update endpoint `/nearby`: 1 jam
- Update endpoint `/my-status`: 30 menit
- Testing API: 1 jam
- **TOTAL BACKEND: ~4 jam**

### Frontend (Flutter):
- Update models: 30 menit
- Update API service: 1 jam
- Update UI (button + markers): 2 jam
- Update dialog/info: 1 jam
- Testing: 1 jam
- **TOTAL FRONTEND: ~5.5 jam**

**TOTAL PROJECT: ~9-10 jam** (1-2 hari kerja)

---

## 🎨 MOCKUP UI

### AppBar (BEFORE → AFTER):
```
BEFORE:                AFTER:
┌──────────────┐      ┌──────────────┐
│ Radar    🔄  │  →  │ Radar    📍  │
└──────────────┘      └──────────────┘
  (Refresh)             (Save Location)
```

### Map Markers:
```
ONLINE USER (Sharing Enabled):
🔵 Kader (biru, radius 8)
🟢 Simpatisan (hijau, radius 8)
🟣 Admin (ungu, radius 8)

OFFLINE USER (Saved Location Only):
⚪ Semua role (abu-abu, radius 6)
```

### User Info Badge:
```
┌─────────────────────────┐
│ 🟢 ONLINE               │  ← User sedang sharing
│ John Doe (Simpatisan)   │
│ 2.3 km · 5 menit lalu   │
└─────────────────────────┘

┌─────────────────────────┐
│ ⚪ OFFLINE              │  ← User save manual
│ Jane Doe (Kader)        │
│ 1.8 km · 2 jam lalu     │
└─────────────────────────┘
```

---

## ✅ KESIMPULAN

### **JAWABAN UNTUK USER:**

1. ✅ **BISA diimplementasikan**, tapi **PERLU DUKUNGAN BACKEND**
2. ✅ **Fitur lengkap**: Ganti refresh → save location, marker abu-abu untuk offline
3. ✅ **Tidak kompleks**: Backend cuma tambah 1 field + update 3 endpoint
4. ✅ **UX bagus**: User bisa bedakan mana yang online (aktif sharing) vs offline (saved location)

### **NEXT STEPS:**

**OPTION 1: Full Implementation (Recommended)**
1. Koordinasi dengan tim backend untuk update API
2. Backend kerjakan update schema + endpoint
3. Frontend tunggu backend selesai, lalu kerjakan UI
4. Test end-to-end

**OPTION 2: Frontend Only (Not Recommended)**
- Bisa ganti button refresh → save location
- Tapi data hanya tersimpan lokal (tidak muncul di radar user lain)
- Tidak ada marker abu-abu (karena backend tidak support)
- **TIDAK RECOMMENDED** karena fitur tidak lengkap

---

**Recommendation: Pilih OPTION 1 untuk implementasi lengkap!** 🚀
