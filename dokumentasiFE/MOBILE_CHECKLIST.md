# Mobile Checklist — Role Change Implementation

**Tanggal**: 31 Maret 2026  
**Status Backend**: ✅ SIAP (authMiddleware fix sudah di-push ke `heri01`)

---

## ✅ Mobile To-Do List

### 1️⃣ Bagian Login & Token Handling

- [ ] **Update login response parsing**
  - [ ] Baca field `role` dari login response
  - [ ] Baca field `activeRoles` dari login response
  - [ ] Simpan ke local storage: `localStorage['user_role']`
  - [ ] Simpan token dengan aman

- [ ] **Cek JWT decoding logic**
  - [ ] Jangan gunakan `role` dari JWT payload untuk kontrol akses
  - [ ] Gunakan `role` dari database response saja
  - [ ] JWT role mungkin outdated setelah admin verifikasi

---

### 2️⃣ Bagian Feature Access Control

- [ ] **Update method `canAccessKaderFeatures()`**
  ```dart
  bool canAccessKaderFeatures() {
    String? userRole = localStorage.getString('user_role');
    return userRole == 'kader';
  }
  ```

- [ ] **Update method `canAccessSimpatisanFeatures()`**
  ```dart
  bool canAccessSimpatisanFeatures() {
    String? userRole = localStorage.getString('user_role');
    return userRole == 'simpatisan' || userRole == 'kader';
  }
  ```

- [ ] **Audit semua feature screens**
  - [ ] Kader features (akses hanya jika role == 'kader')
  - [ ] Simpatisan features (akses jika role == 'simpatisan' atau 'kader')
  - [ ] Admin features (akses hanya jika role == 'admin')

---

### 3️⃣ Bagian Profile Refresh

- [ ] **Implement refresh profile function**
  ```dart
  refreshUserProfile() async {
    try {
      final response = await apiClient.get('/api/users/profile');
      final profile = response.data['data'];
      
      // Update local role
      String newRole = profile['role'];
      await localStorage.setString('user_role', newRole);
      
      // Update UI
      setState(() { userRole = newRole; });
      
      return true;
    } catch (e) {
      return false;
    }
  }
  ```

- [ ] **Pilih 1 dari 3 opsi refresh strategy**:
  - [ ] **Option A**: Push notification (recommended)
    - [ ] Backend kirim push notif saat user diverifikasi
    - [ ] Mobile terima notif → auto refresh profile
  
  - [ ] **Option B**: Periodic refresh
    - [ ] Background task refresh profile setiap 30 detik
    - [ ] Check if role changed → update UI
  
  - [ ] **Option C**: Manual refresh button
    - [ ] Tambah "Refresh" button di UI
    - [ ] User bisa manual refresh kapan saja

---

### 4️⃣ Bagian Push Notification (Optional tapi Recommended)

- [ ] **Setup FCM (Firebase Cloud Messaging)**
  - [ ] Register device token saat login
  - [ ] Send device token ke backend
  - [ ] Backend store device token untuk send notif

- [ ] **Handle verification notification**
  ```dart
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data['type'] == 'verification_approved') {
      // Refresh profile
      await refreshUserProfile();
      
      // Show dialog
      showDialog(
        title: 'Selamat!',
        message: 'Anda sekarang menjadi Kader',
        actions: [
          TextButton(
            onPressed: () => navigateToKaderFeatures(),
            child: Text('Lihat Fitur Kader')
          )
        ]
      );
    }
  });
  ```

---

### 5️⃣ Bagian Testing

#### Pre-Testing
- [ ] Backend `heri01` sudah deployed
- [ ] Bisa test ke `http://103.127.96.136:3030`
- [ ] Koordinasi dengan web admin team untuk test bersama

#### Test Login
- [ ] Login sebagai simpatisan
  - [ ] Cek response: `role: "simpatisan"`
  - [ ] Cek localStorage: `user_role = "simpatisan"`
  - [ ] Cek fitur simpatisan accessible ✅

#### Test Role Change
- [ ] Keep mobile app terbuka dengan simpatisan user login
- [ ] Web admin verifikasi user simpatisan tsb
- [ ] Mobile refresh profile (manual or auto)
  - [ ] Cek response: `role: "kader"` ✅
  - [ ] Cek localStorage: `user_role = "kader"` ✅
  - [ ] Cek fitur kader accessible ✅

#### Test No Re-login Required
- [ ] User tetap login setelah role change ✅
- [ ] Token lama still valid (backend read role dari DB) ✅
- [ ] No need for logout & login ulang ✅

#### Test Multiple Roles (jika ada scenario admin)
- [ ] User dengan multiple roles (admin + kader)
  - [ ] Cek highest priority role selected (admin)
  - [ ] Cek akses ke semua fitur sesuai role priority

---

### 6️⃣ Bagian Code Review Checklist

- [ ] **Review login screen**
  - [ ] Parse response correctly: `response['data']['role']`
  - [ ] Save to localStorage correctly
  - [ ] No hardcoded role checks

- [ ] **Review feature guards**
  - [ ] All feature access control use `localStorage['user_role']`
  - [ ] No JWT role decoding for access control

- [ ] **Review profile refresh**
  - [ ] Endpoint: `GET /api/users/profile`
  - [ ] Headers: `Authorization: Bearer {token}`
  - [ ] Parse response: `response['data']['role']`
  - [ ] Update localStorage on success

- [ ] **Review push notification (if implemented)**
  - [ ] Listen to notification type: `'verification_approved'`
  - [ ] Call refresh profile on notification
  - [ ] Show user-friendly dialog
  - [ ] Navigate to relevant screen

---

## 📋 API Response Examples

### Login Response
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 25,
      "name": "Siti Rahayu",
      "email": "siti@example.com",
      "role": "simpatisan",
      "activeRoles": ["simpatisan"]
    }
  }
}
```

### Profile Response (Before Verification)
```json
{
  "success": true,
  "data": {
    "id": 25,
    "name": "Siti Rahayu",
    "email": "siti@example.com",
    "role": "simpatisan",
    "activeRoles": ["simpatisan"],
    "kaderPoint2Confirmed": false,
    "roles": [
      { "role": "simpatisan", "isActive": true }
    ]
  }
}
```

### Profile Response (After Admin Verification)
```json
{
  "success": true,
  "data": {
    "id": 25,
    "name": "Siti Rahayu",
    "email": "siti@example.com",
    "role": "kader",
    "activeRoles": ["kader"],
    "kaderPoint2Confirmed": true,
    "kaderPoint2ConfirmedAt": "2026-03-31T10:00:00.000Z",
    "roles": [
      { "role": "kader", "isActive": true },
      { "role": "simpatisan", "isActive": false }
    ]
  }
}
```

---

## 🚀 Quick Start for Mobile Dev

1. **Read**: `MOBILE_IMPLEMENTATION_GUIDE.md` (full detailed guide)
2. **Update**: Login screen to save `role` from response
3. **Update**: Feature access control to use localStorage role
4. **Implement**: Profile refresh (choose 1 of 3 options)
5. **Test**: With web admin team using test accounts
6. **Deploy**: After successful testing

---

## ❓ FAQ

**Q: Do I need to logout/login after role change?**  
A: No! Backend now reads role from DB real-time, not from JWT. Old token still works.

**Q: What if I don't implement push notifications?**  
A: Use periodic refresh (every 30s) as fallback, or user can manual refresh.

**Q: Where do I read the role from?**  
A: **ALWAYS** from API response (login or profile endpoint). Never from JWT decode.

**Q: What if role is missing from response?**  
A: Default to 'simpatisan'. Check with backend if response incomplete.

**Q: How to handle offline?**  
A: Use cached role from localStorage. When online, refresh to get latest.

---

*Dokumentasi ini untuk koordinasi Mobile Team. Hubungi Web Admin Team jika ada pertanyaan.*
