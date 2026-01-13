# 📍 SAVE LOCATION - Correct Implementation

**Updated**: 13 Januari 2026  
**Status**: ✅ Correct Behavior

---

## 🎯 Skenario yang Benar

### Flow User:

1. **User buka aplikasi** 
   - Status: Online (terlihat di map)
   - Marker: Belum ada (atau di lokasi terakhir save)

2. **User tap "Simpan Lokasi Saya"** 📍
   - Lokasi current disimpan ke backend
   - **Marker tertanam di map** (orang lain bisa lihat)
   - Badge: 🟠 Orange "Saved" dengan icon pin

3. **Switch Sharing = ON** ✅
   - Status: Real-time location active
   - Marker: Ikut gerak sesuai posisi real-time
   - Badge: 🟢 Green "Online"

4. **Switch Sharing = OFF** ❌
   - Status: Real-time location stopped
   - Marker: **Tetap di lokasi terakhir yang di-save**
   - Badge: 🟠 Orange "Saved" dengan icon pin

---

## 📊 Status & Marker Behavior

| Kondisi | Switch | Marker Position | Badge Color | Badge Text | Icon |
|---------|--------|-----------------|-------------|------------|------|
| Baru buka app | OFF | None / Last saved | - | - | - |
| Save location | OFF/ON | Current position | 🟠 Orange | "Saved" | 📍 Pin |
| Switch ON | ON | Real-time (moving) | 🟢 Green | "Online" | ⚫ Dot |
| Switch OFF | OFF | Last saved position | 🟠 Orange | "Saved" | 📍 Pin |

---

## 🎨 Visual Indicators

### Marker dengan Saved Location:
```
    👤
   [🟠📍]  ← Orange dengan pin icon
  [Saved]
```

### Marker dengan Real-time ON:
```
    👤
   [🟢]    ← Green dot
 [Online]
```

### Marker Inactive (lama tidak update):
```
    👤
   [⚫]    ← Gray
[2h ago]
```

---

## 🔧 Backend Behavior

### API: POST /api/radar/location

**Request dengan `is_saved_only: true`:**
```json
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 10.5,
  "is_saved_only": true  // Tandai sebagai saved marker
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user_id": 1,
    "latitude": -6.2088,
    "longitude": 106.8456,
    "is_sharing_enabled": false,  // Tidak berubah
    "is_saved_location": true,    // Flag: ini saved marker
    "last_seen": "2026-01-13T10:30:00.000Z"
  }
}
```

**Ketika GET /api/radar/locations (orang lain lihat map):**
```json
{
  "locations": [
    {
      "user_id": 1,
      "name": "John Doe",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "is_sharing_enabled": false,  // Real-time OFF
      "is_saved_location": true,    // Ada saved marker
      "last_seen": "2026-01-13T10:30:00.000Z"
    }
  ]
}
```

---

## 📱 UI Control Panel

```
┌────────────────────────────────────────┐
│ 📍 Share Lokasi Saya            [OFF] │
├────────────────────────────────────────┤
│ 🟠 Real-time OFF: Marker tetap di     │
│    lokasi terakhir                     │
├────────────────────────────────────────┤
│ Tap "Simpan" untuk tandai lokasi       │
│ di map                                 │
├────────────────────────────────────────┤
│         [📍 Simpan Lokasi Saya]       │
└────────────────────────────────────────┘
```

**Dengan Switch ON:**
```
┌────────────────────────────────────────┐
│ 📍 Share Lokasi Saya             [ON] │
├────────────────────────────────────────┤
│ 🟢 Real-time ON: Lokasi ikut gerak    │
├────────────────────────────────────────┤
│ Tap "Simpan" untuk tandai lokasi       │
│ di map                                 │
├────────────────────────────────────────┤
│         [📍 Simpan Lokasi Saya]       │
└────────────────────────────────────────┘
```

---

## 🎬 Use Cases

### Use Case 1: Save Checkpoint
**Skenario:** User sedang di lokasi acara, mau tandai kehadirannya

1. User di lokasi acara
2. Tap "Simpan Lokasi Saya"
3. ✅ Marker tertanam di lokasi acara
4. Orang lain buka map → lihat marker user di lokasi acara
5. Switch OFF → Marker tetap di sana walaupun user pindah

**Result:** Checkpoint tersimpan di map

---

### Use Case 2: Real-time Tracking
**Skenario:** Koordinator lapangan mau tim track posisinya

1. User di lapangan
2. Switch ON → Real-time aktif
3. ✅ Marker ikut gerak sesuai posisi
4. Tim lihat marker bergerak real-time
5. Badge: Green "Online"

**Result:** Tim bisa track posisi real-time

---

### Use Case 3: Mixed Mode
**Skenario:** Save checkpoint, lalu aktifkan real-time

1. User di pos 1 → Tap "Simpan"
2. ✅ Marker tertanam di pos 1 (Orange "Saved")
3. User jalan ke pos 2
4. Switch ON → Marker mulai ikut gerak
5. Badge berubah: Green "Online"
6. Switch OFF → Marker kembali ke pos 1 (lokasi terakhir save)

**Result:** Flexibilitas antara saved checkpoint dan real-time

---

## 💡 Key Differences from Old Implementation

| Aspek | ❌ Old (Wrong) | ✅ New (Correct) |
|-------|---------------|-----------------|
| Save location | Hanya simpan data, tidak terlihat | Marker tertanam di map, terlihat |
| Switch OFF | User tidak terlihat sama sekali | Marker tetap di lokasi terakhir save |
| Badge color | Gray (offline) | Orange (saved) dengan pin icon |
| Purpose | Privacy mode | Checkpoint/landmark mode |

---

## 🔐 Privacy Note

- User **selalu terlihat** di map jika pernah save location
- Switch OFF = Marker tidak moving, bukan invisible
- Jika user mau invisible sepenuhnya → hapus fitur atau tambah "Hide from radar" button

---

## ✅ Implementation Checklist

- [x] API service: `saveLocationManually()` dengan `is_saved_only: true`
- [x] Model: `isSavedLocation` flag
- [x] Marker: Orange badge dengan pin icon untuk saved location
- [x] Marker: Green badge untuk real-time ON
- [x] Control panel: Status indicator dengan warna yang sesuai
- [x] Button: "Simpan Lokasi Saya" dengan pin icon
- [x] Message: "Lokasi disimpan! Marker tertanam di map"

---

## 🚀 Testing Scenarios

### Test 1: Save without real-time
1. Open app (switch OFF)
2. Tap "Simpan Lokasi Saya"
3. ✅ Check: Marker muncul di map dengan orange badge
4. Move to different location
5. ✅ Check: Marker tetap di lokasi save (tidak ikut gerak)

### Test 2: Real-time tracking
1. Switch ON
2. ✅ Check: Badge berubah green "Online"
3. Move to different location
4. ✅ Check: Marker ikut gerak

### Test 3: Toggle switch
1. Switch ON → OFF
2. ✅ Check: Marker kembali ke lokasi terakhir save
3. Switch OFF → ON
4. ✅ Check: Marker mulai gerak real-time

---

**Status: IMPLEMENTED & CORRECT** ✅  
**Ready for Testing: YES** ✅
