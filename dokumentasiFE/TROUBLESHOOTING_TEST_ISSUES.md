# 🐛 TROUBLESHOOTING GUIDE - Issues Found During Testing

**Date:** 8 Januari 2026  
**Status:** 🔍 Under Investigation

---

## 📋 Issues Reported

### Issue 1: Riwayat - Only Mention Shown, Click Not Working ❌
**Reported:** 8 Januari 2026  
**Symptom:** 
- Login, logout, search history tidak muncul
- Hanya mention yang muncul
- Tap pada mention tidak mengarah ke postingan

### Issue 2: Session Not Persisting After Force Close ❌
**Reported:** 8 Januari 2026  
**Symptom:**
- App keluar paksa (bukan logout)
- Ketika buka lagi, harus login ulang
- Seharusnya tetap login sampai token expire (1 bulan)

---

## 🔍 DEBUGGING STEPS

### For Issue 1: Mention Not Clickable

#### Step 1: Check Console Log Saat Buka Riwayat

Buka app dan tap tab Riwayat, lalu cari output ini di console:

```
📜 RiwayatPage: Loaded X history items
  - Type: mention, postId: 123, isClickable: true   ← HARUS TRUE
  - Type: login, postId: null, isClickable: false
```

**❓ Question 1:** Apakah `postId` ada nilai (bukan null)?
- ✅ **YES, ada angka** → Lanjut ke Step 2
- ❌ **NO, null** → **ROOT CAUSE: Backend tidak kirim postId!**

---

#### Step 2: Check Backend Response

Test API backend langsung dengan curl:

```bash
curl -X GET "http://103.127.138.40:3030/api/history" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Cari field `postId` dalam response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "mention",
      "postId": 123,    ← HARUS ADA untuk mention
      "description": "..."
    },
    {
      "id": 2,
      "type": "login",
      "postId": null     ← null untuk non-postingan (normal)
    }
  ]
}
```

**❓ Question 2:** Apakah response punya field `postId`?
- ✅ **YES** → Lanjut ke Step 3
- ❌ **NO** → **ROOT CAUSE: Backend belum implementasi fitur ini!**

**🔧 Solution jika Backend belum ready:**
Backend harus di branch `heri01` dan sudah implement mention notification.

---

#### Step 3: Test Tap Action

Tap pada item mention di riwayat, cari output ini:

```
👆 Tapped on history: type=mention, postId=123, isClickable=true
🔍 Navigating to post ID: 123
📡 Fetching post detail for ID: 123
✅ Post loaded successfully: ...
🚀 Navigating to PostDetailPage
```

**❓ Question 3:** Apa yang muncul di console?

- **Scenario A:** Tidak ada output
  - **ROOT CAUSE:** onTap tidak dipanggil (isClickable = false)
  - **Fix:** Check postId dari backend

- **Scenario B:** Muncul "Tapped" tapi error saat fetch
  - **ROOT CAUSE:** Post tidak ditemukan atau API error
  - **Fix:** Check endpoint `GET /api/posts/{id}`

- **Scenario C:** Semua log muncul tapi tidak navigate
  - **ROOT CAUSE:** Navigation issue
  - **Fix:** Check PostDetailPage

---

### For Issue 2: Session Not Persisting

#### Step 1: Check Console Log Saat App Start

Buka app (setelah force close), cari output ini di console:

```
=== SPLASH SCREEN: Checking auto-login ===
⏰ Current time: 2026-01-08 ...
🔐 Is logged in: true/false     ← Check ini!
```

**❓ Question 1:** Apa nilai "Is logged in"?
- ✅ **true** → Lanjut ke Step 2
- ❌ **false** → **ROOT CAUSE: Token tidak tersimpan!**

---

#### Step 2: Check Token Persistence

Jika "Is logged in: false", tambahkan debug di login:

Edit `lib/pages/login_page.dart`, cari method login success, tambahkan log:

```dart
// After successful login
print('✅ Login success!');
print('💾 Saving tokens...');
await StorageService().saveTokens(accessToken, refreshToken);
print('✅ Tokens saved!');
```

**Test flow:**
1. Login
2. Cek console: Harus muncul "✅ Tokens saved!"
3. Force close app (swipe up di recent apps)
4. Buka app lagi
5. Cek console saat splash screen

**❓ Question 2:** Apakah "Is logged in: true" setelah force close?
- ✅ **YES** → Lanjut ke Step 3
- ❌ **NO** → **ROOT CAUSE: Tokens tidak persist ke storage!**

**🔧 Possible Fixes:**
- Pastikan await saveTokens() sudah dipanggil sebelum navigate
- Check FlutterSecureStorage permission di device
- Test di device lain

---

#### Step 3: Check Token Refresh

Jika "Is logged in: true" tapi tetap ke onboarding, cari log ini:

```
🔄 Attempting to refresh token...
❌ Session expired: ...
```

**❓ Question 3:** Kenapa token refresh gagal?

**Possible causes:**
1. **Token expired (> 1 bulan)** - Normal, harus login ulang
2. **Backend error** - Server down atau API issue
3. **Network error** - Tidak ada internet

**🔧 Solution:**
Dengan update terbaru, jika refresh gagal karena network error, app akan tetap masuk ke HomePage (menggunakan token lama). Hanya logout jika token benar-benar expired.

---

## 🧪 TESTING SCENARIOS

### Test Case 1: Mention Clickable

**Prerequisites:**
- Backend running di branch `heri01`
- 2 user accounts (userA, userB)

**Steps:**
1. Login sebagai userA
2. Buat post: "Hello @userB check this!"
3. Login sebagai userB (device lain atau logout+login)
4. Buka tab Riwayat
5. **Expected:** Lihat mention dengan:
   - Icon @ orange
   - Chevron right
   - Hint text biru
6. Tap mention
7. **Expected:** Buka detail postingan dari userA

**Debug console output yang diharapkan:**
```
📜 RiwayatPage: Loaded 1 history items
  - Type: mention, postId: 123, isClickable: true
👆 Tapped on history: type=mention, postId=123, isClickable=true
🔍 Navigating to post ID: 123
📡 Fetching post detail for ID: 123
✅ Post loaded successfully: Hello @userB check...
🚀 Navigating to PostDetailPage
```

---

### Test Case 2: Session Persistence

**Steps:**
1. Login ke app
2. **Check console:** Lihat "✅ Tokens saved!"
3. Force close app (swipe up di recent apps)
4. Tunggu 5 detik
5. Buka app lagi
6. **Expected:** Langsung masuk ke HomePage (tidak ke login)

**Debug console output yang diharapkan:**
```
=== SPLASH SCREEN: Checking auto-login ===
⏰ Current time: 2026-01-08 ...
🔐 Is logged in: true
🔄 Attempting to refresh token...
✅ Token refreshed successfully - Session is VALID
🏠 Navigating to HomePage...
```

---

## 📊 DIAGNOSTIC CHECKLIST

### Before Reporting Issue:

- [ ] Backend running di branch `heri01`
- [ ] Device memiliki internet connection
- [ ] Console log tersedia (flutter run atau logcat)
- [ ] APK versi terbaru (setelah fix ini)

### Information to Collect:

1. **Console log lengkap** dari:
   - App start (splash screen)
   - Buka halaman Riwayat
   - Tap pada mention

2. **Backend version:**
   - Branch name: ?
   - Commit hash: ?

3. **Device info:**
   - Model: ?
   - Android version: ?
   - RAM: ?

4. **Specific error message** (jika ada)

---

## 🔧 QUICK FIXES

### Fix 1: Force Refresh Data

```dart
// In RiwayatPage, add pull-to-refresh
RefreshIndicator(
  onRefresh: () async {
    setState(() {
      _futureHistory = _loadHistory();
    });
  },
  child: ListView.builder(...)
)
```

### Fix 2: Clear Cache

Jika session issue persistent:

```bash
# Clear app data
adb shell pm clear com.example.mygeri  # Adjust package name

# Or uninstall+reinstall
flutter clean
flutter build apk --release
```

---

## 📞 NEXT STEPS

1. **Run app dengan `flutter run`** untuk dapat console log
2. **Test scenario di atas** dan catat output
3. **Share console log** untuk analysis lebih lanjut
4. **Check backend status** - pastikan branch `heri01` active

---

**Updated:** 8 Januari 2026  
**Status:** Debug logging added, waiting for test results
