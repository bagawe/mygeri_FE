# 🧪 Radar Feature - Testing Guide

**Date:** January 8, 2026  
**App:** MyGeri (Flutter)  
**Feature:** Radar Location Tracking  
**Backend URL:** http://103.127.138.40:3030/api/radar

---

## ✅ Pre-Test Checklist

### Environment
- [x] Flutter packages installed (`flutter pub get`)
- [x] Android permissions configured (`AndroidManifest.xml`)
- [x] iOS permissions configured (`Info.plist`)
- [x] No compile errors
- [x] App running successfully

### Backend Status
- [ ] Backend server online (check: `curl http://103.127.138.40:3030/api/radar/my-status`)
- [ ] User has valid JWT token
- [ ] User role correctly set (`simpatisan`, `kader`, or `admin`)

---

## 📱 Testing Steps

### 1. **Launch App & Navigate to Radar**

**Steps:**
1. Open MyGeri app
2. Login dengan akun Anda
3. Tap menu **"Beranda"**
4. Tap icon **"Radar"** (ikon dengan simbol radar)

**Expected:**
- ✅ Radar page terbuka
- ✅ Peta OpenStreetMap ditampilkan
- ✅ Muncul dialog permission untuk akses lokasi

---

### 2. **Grant Location Permissions**

**Steps:**
1. Ketika diminta permission, pilih **"Allow"** atau **"Izinkan"**
2. Android: Pilih "Allow all the time" untuk background updates
3. iOS: Pilih "Allow While Using App" kemudian "Always Allow"

**Expected:**
- ✅ Permission diberikan
- ✅ GPS mulai aktif
- ✅ Loading indicator muncul

---

### 3. **Enable Location Sharing**

**Steps:**
1. Di bagian atas peta, lihat card "Share Lokasi Saya"
2. Toggle switch ke posisi **ON** (hijau)
3. Tunggu proses...

**Expected:**
- ✅ Toggle berubah jadi ON (warna merah)
- ✅ Muncul tombol "Refresh Lokasi Sekarang"
- ✅ Snackbar: "Location sharing diaktifkan (auto-update setiap 1 jam)"
- ✅ Background service dimulai

**If Error:**
```
❌ "Gagal mengubah setting"
→ Check: Backend server online?
→ Check: Token masih valid?
→ Check: Network connection OK?
```

---

### 4. **Update Location (Manual)**

**Steps:**
1. Pastikan sharing sudah ON
2. Tap tombol **"Refresh Lokasi Sekarang"**
3. Tunggu proses...

**Expected:**
- ✅ Tombol berubah jadi "Mengupdate..." dengan spinner
- ✅ GPS mendapatkan koordinat Anda
- ✅ Data terkirim ke backend
- ✅ Snackbar: "Lokasi berhasil diupdate!"
- ✅ Marker biru (my location) muncul di peta
- ✅ Peta auto-zoom ke lokasi Anda

**If Error:**
```
❌ "Tidak bisa mendapatkan lokasi"
→ Check: GPS aktif?
→ Check: Permission granted?
→ Try: Go outdoor (GPS lebih akurat)

❌ "Rate limit exceeded"
→ Wait: 1 menit sejak update terakhir
→ Reason: Backend limit 1 update/menit

❌ "Gagal update lokasi"
→ Check: Network connection
→ Check: Backend server status
```

---

### 5. **View Nearby Users**

**Steps:**
1. Pastikan lokasi Anda sudah terupdate
2. Lihat peta di sekitar marker Anda
3. Cari marker user lain (circle dengan border warna)

**Expected:**
- ✅ Marker user lain muncul (jika ada yang online)
- ✅ Marker menampilkan foto profil user
- ✅ Border berwarna sesuai role:
  - 🟢 **Hijau** = Simpatisan
  - 🔵 **Biru** = Kader
  - 🟣 **Ungu** = Admin

**Role-Based Visibility:**

| Your Role | You Can See |
|-----------|-------------|
| **Simpatisan** | Hanya sesama Simpatisan (hijau) |
| **Kader** | Kader (biru) + Simpatisan (hijau) |
| **Admin** | Semua user (semua warna) |

**If No Users Visible:**
```
ℹ️ Possible reasons:
1. Tidak ada user lain dalam radius 50km
2. User lain tidak enable location sharing
3. User lain belum update lokasi (>24 jam)
4. Role-based filtering (cek role Anda)
```

---

### 6. **View User Info**

**Steps:**
1. Tap salah satu marker user di peta
2. Bottom sheet akan muncul dari bawah

**Expected:**
- ✅ Bottom sheet slide up
- ✅ Menampilkan:
  - **Avatar** user (atau initial nama)
  - **Nama** lengkap
  - **Badge role** dengan warna:
    - 🟢 "Simpatisan" (hijau)
    - 🔵 "Kader" (biru)
    - 🟣 "Admin" (ungu)
  - **Pekerjaan** (jika ada)
  - **Provinsi** (jika ada)
  - **Distance** dari Anda (contoh: "1.5km")
  - **Last update** (contoh: "2 jam lalu")
- ✅ Tombol "Tutup" di bawah

**Test:**
- Tap "Tutup" → Bottom sheet close
- Tap area di luar sheet → Bottom sheet close
- Swipe down → Bottom sheet close

---

### 7. **Check Stats Card**

**Steps:**
1. Lihat card di bagian bawah peta
2. Baca informasi yang ditampilkan

**Expected:**
- ✅ Menampilkan jumlah user online (contoh: "5 user online")
- ✅ Menampilkan GPS accuracy Anda (contoh: "10m")
- ✅ Update otomatis saat refresh

---

### 8. **Refresh All Data**

**Steps:**
1. Tap icon **refresh** di AppBar (pojok kanan atas)
2. Tunggu loading...

**Expected:**
- ✅ Reload my status dari backend
- ✅ Reload my location dari GPS
- ✅ Reload nearby users
- ✅ Peta update dengan data terbaru
- ✅ Stats card update

---

### 9. **Disable Location Sharing**

**Steps:**
1. Toggle switch "Share Lokasi Saya" ke posisi **OFF**
2. Tunggu proses...

**Expected:**
- ✅ Toggle berubah jadi OFF (abu-abu)
- ✅ Tombol "Refresh Lokasi Sekarang" hilang
- ✅ Snackbar: "Location sharing dinonaktifkan"
- ✅ Background service berhenti
- ✅ Marker Anda tetap terlihat (untuk Anda sendiri)
- ✅ User lain TIDAK bisa lihat marker Anda lagi

---

### 10. **Test Background Auto-Update** (Advanced)

**Setup:**
1. Enable location sharing (ON)
2. Update lokasi manual 1x
3. Close app (minimize atau kill)
4. Tunggu 1 jam

**Expected After 1 Hour:**
- ✅ Background service trigger otomatis
- ✅ Lokasi Anda terupdate di backend
- ✅ Tidak perlu buka app

**Check Logs (Android):**
```bash
adb logcat | grep "Background task"
# Look for: "🔄 Background task started"
# Look for: "✅ Location updated successfully in background"
```

**If Not Working:**
```
⚠️ Possible issues:
1. Battery saver mode active
2. App removed from background
3. Background permission not granted
4. WorkManager not initialized
```

---

## 🐛 Common Issues & Solutions

### Issue 1: "Backend server timeout"
**Problem:** `curl` test ke backend timeout  
**Solution:**
- Check server online: `ping 103.127.138.40`
- Check endpoint deployed: Contact backend team
- Check firewall: Pastikan port 3030 terbuka

### Issue 2: "Token expired"
**Problem:** JWT token sudah kadaluarsa  
**Solution:**
- Logout dari app
- Login kembali
- Token baru akan di-generate

### Issue 3: "GPS tidak akurat"
**Problem:** Accuracy >100m atau lokasi salah  
**Solution:**
- Go outdoor (GPS lebih akurat)
- Wait beberapa detik untuk GPS lock
- Enable "High Accuracy" di phone settings
- Restart phone GPS

### Issue 4: "Marker tidak muncul"
**Problem:** Tidak ada user lain terlihat  
**Solution:**
- Check role Anda (Simpatisan hanya lihat Simpatisan)
- Expand radius (default 50km)
- Pastikan user lain sudah enable sharing
- Pastikan user lain update <24 jam

### Issue 5: "Background update tidak jalan"
**Problem:** Lokasi tidak auto-update setelah 1 jam  
**Solution:**
- Check battery saver OFF
- Check background permission granted
- Check WorkManager initialized
- Check logs untuk error

---

## 📊 Test Matrix

### Functional Testing

| Feature | Test Case | Status |
|---------|-----------|--------|
| **Permission** | Request location permission | [ ] |
| **Permission** | Handle permission denied | [ ] |
| **Sharing** | Toggle sharing ON | [ ] |
| **Sharing** | Toggle sharing OFF | [ ] |
| **Update** | Manual location update | [ ] |
| **Update** | Rate limiting (1/min) | [ ] |
| **Map** | Display OpenStreetMap | [ ] |
| **Map** | Show my location marker | [ ] |
| **Map** | Show nearby users | [ ] |
| **Map** | Zoom to my location | [ ] |
| **Marker** | Display correct colors | [ ] |
| **Marker** | Show profile photo | [ ] |
| **Marker** | Tap to show info | [ ] |
| **Info Sheet** | Display user details | [ ] |
| **Info Sheet** | Show correct role badge | [ ] |
| **Info Sheet** | Show distance | [ ] |
| **Stats** | Display user count | [ ] |
| **Stats** | Display GPS accuracy | [ ] |
| **Refresh** | Reload all data | [ ] |
| **Background** | Auto-update after 1h | [ ] |
| **Error** | Handle network error | [ ] |
| **Error** | Handle GPS error | [ ] |

### Role-Based Testing

| User Role | Can See Simpatisan | Can See Kader | Can See Admin | Status |
|-----------|-------------------|---------------|---------------|--------|
| **Simpatisan** | ✅ Yes | ❌ No | ❌ No | [ ] |
| **Kader** | ✅ Yes | ✅ Yes | ❌ No | [ ] |
| **Admin** | ✅ Yes | ✅ Yes | ✅ Yes | [ ] |

### Visual Testing

| UI Element | Expected Appearance | Status |
|------------|-------------------|--------|
| Simpatisan badge | 🟢 Green background, "Simpatisan" text | [ ] |
| Kader badge | 🔵 Blue background, "Kader" text | [ ] |
| Admin badge | 🟣 Purple background, "Admin" text | [ ] |
| Marker border (Simpatisan) | Green circle border | [ ] |
| Marker border (Kader) | Blue circle border | [ ] |
| Marker border (Admin) | Purple circle border | [ ] |
| My location marker | Blue circle with location icon | [ ] |
| Toggle ON | Red/primary color | [ ] |
| Toggle OFF | Gray color | [ ] |

---

## 📝 Test Report Template

```markdown
## Radar Feature Test Report

**Date:** [Date]
**Tester:** [Your Name]
**Device:** [Device Model + OS Version]
**App Version:** [Version]
**Backend URL:** http://103.127.138.40:3030

### Test Results

#### 1. Basic Functionality
- [ ] PASS / [ ] FAIL - Open Radar page
- [ ] PASS / [ ] FAIL - Grant permissions
- [ ] PASS / [ ] FAIL - Enable sharing
- [ ] PASS / [ ] FAIL - Update location
- [ ] PASS / [ ] FAIL - View nearby users
- [ ] PASS / [ ] FAIL - View user info
- [ ] PASS / [ ] FAIL - Disable sharing

#### 2. Role-Based Filtering
- User Role: [Simpatisan/Kader/Admin]
- [ ] PASS / [ ] FAIL - Correct users visible
- [ ] PASS / [ ] FAIL - Correct badge colors
- [ ] PASS / [ ] FAIL - Correct badge text

#### 3. Issues Found
[List any bugs or issues]

#### 4. Notes
[Additional observations]
```

---

## 🎯 Acceptance Criteria

### Must Have (Critical):
- ✅ User can enable/disable location sharing
- ✅ User can update location manually
- ✅ User can see nearby users (role-filtered)
- ✅ User can view other user's info
- ✅ Role badges display correctly (Simpatisan/Kader/Admin)
- ✅ Marker colors match role (Green/Blue/Purple)

### Should Have (High):
- ✅ Background auto-update every 1 hour
- ✅ Rate limiting prevents spam (1/min)
- ✅ GPS accuracy displayed
- ✅ Distance calculation accurate
- ✅ Error messages user-friendly

### Nice to Have (Medium):
- ✅ Smooth animations
- ✅ Fast loading (<2s)
- ✅ Responsive UI
- ✅ Consistent design

---

## 🚀 Ready for Production?

### Checklist:
- [ ] All test cases PASS
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Backend stable
- [ ] Documentation complete
- [ ] Owner approval

### Go/No-Go Decision:
- **GO:** All critical features working, minor bugs acceptable
- **NO-GO:** Critical bugs found, needs fixing before release

---

**Happy Testing!** 🎉

Jika menemukan bug atau ada pertanyaan, dokumentasikan dengan:
1. Screenshot/video
2. Steps to reproduce
3. Expected vs Actual behavior
4. Device info & OS version
5. Backend response (jika ada error dari API)
