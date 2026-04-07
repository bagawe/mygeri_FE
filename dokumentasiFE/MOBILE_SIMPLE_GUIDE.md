# Mobile — What To Do (Ringkas)

**Tanggal**: 31 Maret 2026  
**Status Backend**: ✅ SUDAH FIX  
**Status FE Web**: ✅ SUDAH UPDATE  
**Status Mobile**: 🔄 SEKARANG GILIRAN MOBILE

---

## 🎯 Problem Yang Sudah Fix

**Sebelum**: Setelah admin verifikasi simpatisan di web, role user tetap `simpatisan` di mobile  
**Sekarang**: Role akan berubah jadi `kader` (backend sudah fix)

---

## ✅ Yang Harus Mobile Lakukan (3 Hal Penting)

### 1️⃣ JANGAN BACA ROLE DARI JWT

```dart
// ❌ SALAH — role di JWT bisa outdated
String userRole = jwtPayload['role'];  // bisa masih "simpatisan"

// ✅ BENAR — baca dari API response
String userRole = loginResponse['data']['user']['role'];  // dari DB
```

**Alasan**: Backend sekarang read role dari database real-time, bukan dari JWT payload. Setelah admin verify, role di DB berubah ke `kader`, tapi JWT payload masih punya `simpatisan`. So ALWAYS baca dari API response.

---

### 2️⃣ SIMPAN ROLE KE LOCALSTORAGE

```dart
// Setelah login
String userRole = loginResponse['data']['user']['role'];
await localStorage.setString('user_role', userRole);

// Untuk feature access control
bool canAccessKaderFeatures() {
  String? userRole = localStorage.getString('user_role');
  return userRole == 'kader';
}
```

**Alasan**: Biar bisa cepat cek akses fitur tanpa setiap kali call API. Update localStorage saat user refresh profile.

---

### 3️⃣ REFRESH PROFILE SETELAH VERIFIKASI

Pilih 1 dari 3 opsi:

#### Option A: Push Notification (Recommended ⭐)
```dart
// Backend kirim push notif saat user diverifikasi
// Mobile terima & auto refresh
FirebaseMessaging.onMessage.listen((message) {
  if (message.data['type'] == 'verification_approved') {
    refreshUserProfile();
  }
});

refreshUserProfile() async {
  final response = await apiClient.get('/api/users/profile');
  String newRole = response['data']['role'];
  await localStorage.setString('user_role', newRole);
  
  // Update UI
  setState(() { userRole = newRole; });
}
```

#### Option B: Periodic Refresh
```dart
// Background task setiap 30 detik
Timer.periodic(Duration(seconds: 30), (_) async {
  final response = await apiClient.get('/api/users/profile');
  String newRole = response['data']['role'];
  
  // Update jika role berubah
  if (newRole != currentUserRole) {
    await localStorage.setString('user_role', newRole);
    setState(() { userRole = newRole; });
  }
});
```

#### Option C: Manual Refresh Button
```dart
// Tombol refresh di UI
ElevatedButton(
  onPressed: () async {
    final response = await apiClient.get('/api/users/profile');
    String newRole = response['data']['role'];
    await localStorage.setString('user_role', newRole);
    setState(() { userRole = newRole; });
    showSnackBar('Profile diperbarui!');
  },
  child: Text('Refresh'),
)
```

**Alasan**: Setelah admin verify, role di DB sudah berubah. Mobile perlu refresh untuk lihat role baru.

---

## 📋 Checklist Implementasi

### Login Screen
- [ ] Parse response: `loginResponse['data']['user']['role']`
- [ ] Simpan ke localStorage: `localStorage.setString('user_role', role)`
- [ ] **JANGAN** decode JWT untuk ambil role

### Feature Access Control
```dart
// Ganti semua yang baca role dari JWT, jadi ambil dari localStorage
bool canAccessKaderFeatures() {
  String? userRole = localStorage.getString('user_role');
  return userRole == 'kader';
}
```
- [ ] Audit semua file yang check role
- [ ] Update semua ke pakai localStorage

### Profile Refresh
- [ ] Pilih 1 opsi dari 3 di atas (push notification recommended)
- [ ] Implement refresh logic
- [ ] Test refresh berhasil update role di localStorage

### Testing
- [ ] Login as simpatisan → cek localStorage user_role = "simpatisan"
- [ ] Refresh profile → cek response role = "simpatisan" (belum ada perubahan)
- [ ] Web admin verify simpatisan
- [ ] Mobile refresh → cek response role = "kader"
- [ ] Cek localStorage user_role = "kader"
- [ ] Cek bisa akses kader features ✅

---

## 🔗 Endpoint yang Dipakai

### Login
```
POST /api/auth/login
Response: { data: { token, user: { role, activeRoles } } }
```

### Get Profile
```
GET /api/users/profile
Response: { data: { role, activeRoles, roles } }
```

---

## ⚠️ Important

1. **Role = "kader"** → dapat akses semua fitur kader
2. **Role = "simpatisan"** → akses fitur terbatas
3. **Tidak perlu logout** → token lama masih valid, cukup refresh profile
4. **Baca dari API** → bukan dari JWT decode

---

## 📞 Pertanyaan?

Tanya ke FE Web Admin Team atau Backend Team.

---

**Status**: Mobile team siap implementasi 🚀
