# Implementasi Session Management & Logout Error Handling
**Tanggal:** 24 Desember 2025  
**Tipe:** Bug Fix & Enhancement

## Masalah yang Diselesaikan

### 1. Logout Tidak Responsif
**Gejala:**
- Aplikasi hang/tidak merespons ketika tombol logout diklik
- Khususnya terjadi ketika session sudah expired di backend
- Tidak ada feedback kepada user

**Root Cause:**
- Tidak ada timeout pada API call logout
- Tidak ada fallback jika backend sudah logout
- Tidak ada koordinasi global untuk session management

### 2. Session Expired Tidak Tertangani
**Gejala:**
- Ketika session expired saat navigasi antar menu
- User tidak otomatis dialihkan ke login page
- SessionExpiredException dilempar tapi tidak ada handler global

## Solusi yang Diimplementasikan

### 1. SessionManager Service (Baru)
**File:** `lib/services/session_manager.dart`

Singleton service untuk menangani:
- Session expiration handling
- Logout dengan error handling
- Context registration untuk navigation
- Prevent duplicate logout attempts

**Fitur Utama:**
```dart
// Register context untuk navigation
SessionManager().registerContext(context);

// Handle session expired (auto-redirect ke login)
SessionManager().handleSessionExpired(
  message: 'Sesi Anda telah berakhir'
);

// Perform logout dengan error handling
await SessionManager().performLogout();

// Check session validity
bool isValid = await SessionManager().checkSession();
```

**Keunggulan:**
- ✅ Selalu navigasi ke login bahkan jika API fail
- ✅ Timeout handling (inherited dari AuthService)
- ✅ Prevent duplicate logout dengan `_isLoggingOut` flag
- ✅ Clear local storage even on error
- ✅ Show user-friendly messages
- ✅ Context safety checks (mounted)

### 2. HomePage Integration
**File:** `lib/pages/home_page.dart`

**Changes:**
- Added `WidgetsBindingObserver` untuk lifecycle management
- Register SessionManager context di `initState()`
- Unregister context di `dispose()`
- Check session ketika app resume dari background

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    _checkSession();
  }
}
```

### 3. ApiService Integration
**File:** `lib/services/api_service.dart`

**Changes:**
- Import SessionManager
- Call `SessionManager().handleSessionExpired()` ketika refresh token fails
- Automatic redirect ke login pada 401 errors

```dart
catch (e) {
  _isRefreshing = false;
  await _storage.clearAll();
  
  // Handle session expiration globally
  SessionManager().handleSessionExpired(
    message: 'Sesi Anda telah berakhir. Silakan login kembali.',
  );
  
  throw SessionExpiredException();
}
```

### 4. PengaturanPage Simplification
**File:** `lib/pages/pengaturan/pengaturan_page.dart`

**Changes:**
- Removed AuthService direct calls
- Simplified logout logic menggunakan SessionManager
- Removed manual navigation code
- Removed manual timeout handling

**Before:**
```dart
// 80+ lines of complex logout logic with timeout, navigation, etc
```

**After:**
```dart
Future<void> _handleLogout() async {
  if (_isLoggingOut) return;
  
  setState(() {
    _isLoggingOut = true;
  });

  try {
    await _sessionManager.performLogout();
  } finally {
    if (mounted) {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }
}
```

### 5. ProfilePage Overhaul
**File:** `lib/pages/profil/profile_page.dart`

**Changes:**
- Completely rewritten untuk fix field name errors
- Menggunakan field names yang benar dari UserProfile model:
  - `fotoProfil` (bukan `fotoProfile`)
  - `name` (bukan `namaLengkap`)
  - `phone` (bukan `noHp`)
  - `nik`, `jenisKelamin`, `statusKawin`, dll
- Added proper error handling
- Added pull-to-refresh
- Display "-" untuk empty values
- Format alamat lengkap dari components

**Features:**
- Loading state dengan CircularProgressIndicator
- Error state dengan retry button
- Empty state jika profil belum tersedia
- RefreshIndicator untuk pull-to-refresh
- Format tanggal Indonesia
- Build alamat lengkap dari jalan, RT/RW, kelurahan, kecamatan, kota, provinsi

## Testing Scenarios

### ✅ Normal Logout
1. User login
2. Navigasi ke Pengaturan
3. Klik Logout
4. Konfirmasi
5. **Expected:** Redirect ke login, show "Berhasil logout" message

### ✅ Logout Ketika Session Expired di BE
1. User login
2. Backend manually expire session (atau tunggu expired)
3. Klik Logout
4. **Expected:** Tetap redirect ke login, clear local storage, show success message

### ✅ Session Expired Saat Navigasi
1. User login
2. Backend manually expire session
3. Navigasi antar menu (akan trigger API call)
4. **Expected:** API detect 401, auto-redirect ke login dengan message "Sesi telah berakhir"

### ✅ App Resume Session Check
1. User login
2. Backend expire session
3. Switch ke app lain
4. Resume MyGeri app
5. **Expected:** Check session, detect expired, redirect to login

### ✅ Profile Page Display
1. User login
2. Navigasi ke Profile tab
3. **Expected:** Show profile data dari API
4. **If field empty:** Show "-"
5. Pull to refresh works
6. Error dengan retry button jika API gagal

## File Changes Summary

### New Files
- ✨ `lib/services/session_manager.dart` - Global session manager (171 lines)
- 📝 `dokumentasiFE/TESTING_RESULTS_DEC24.md` - Testing documentation
- 📝 `dokumentasiFE/SESSION_MANAGEMENT_IMPLEMENTATION.md` - This file

### Modified Files
- ♻️ `lib/pages/home_page.dart` - Added SessionManager integration + lifecycle
- ♻️ `lib/pages/pengaturan/pengaturan_page.dart` - Simplified logout using SessionManager
- ♻️ `lib/services/api_service.dart` - Added SessionManager call on 401
- 🔨 `lib/pages/profil/profile_page.dart` - Complete rewrite dengan field names yang benar

### Fixed Files
- ✅ `lib/services/profile_service.dart` - Fixed endpoints (/users/profile → /api/users/profile)

## Breaking Changes
None - All changes are backwards compatible

## Migration Guide
Tidak ada migration diperlukan. SessionManager automatic bekerja di background.

Untuk logout di page lain (future implementation):
```dart
final SessionManager _sessionManager = SessionManager();

Future<void> _handleLogout() async {
  await _sessionManager.performLogout();
}
```

## Performance Impact
- ✅ No significant performance impact
- ✅ SessionManager adalah singleton (efficient)
- ✅ Lifecycle checks hanya trigger saat app resume

## Security Improvements
- ✅ Always clear local storage on logout (even on error)
- ✅ Automatic session validation on app resume
- ✅ Global 401 handling dengan auto-redirect
- ✅ Prevent duplicate logout attempts

## Known Limitations
1. EditProfilePage belum dibuat (commented out)
2. ProfilePage tidak ada tombol edit sementara

## Next Steps
- [ ] Create EditProfilePage
- [ ] Add edit button di ProfilePage
- [ ] Integrate SessionManager di pages lain jika diperlukan
- [ ] Add unit tests untuk SessionManager
- [ ] Add integration tests untuk logout flow

## Technical Notes

### Why Singleton?
SessionManager menggunakan singleton pattern karena:
- Hanya perlu 1 instance untuk seluruh app
- Shared state (`_isLoggingOut` flag)
- Global context management

### Context Management
```dart
// Register di initState
WidgetsBinding.instance.addPostFrameCallback((_) {
  _sessionManager.registerContext(context);
});

// Unregister di dispose
_sessionManager.unregisterContext();
```

Ini penting untuk:
- Navigation yang aman
- Show SnackBar messages
- Prevent memory leaks

### Error Handling Philosophy
"Always succeed locally, show appropriate message to user"

Logout selalu return `true` dan navigate ke login bahkan jika:
- API call timeout
- Network error
- Backend already logged out
- Any other error

Karena dari perspective user, yang penting adalah:
1. Clear local data ✅
2. Navigate to login ✅
3. Show appropriate message ✅

## Code Quality Improvements
- Reduced code duplication (logout logic centralized)
- Better separation of concerns
- Improved error handling
- Better user experience
- More maintainable code

## Conclusion
Implementasi ini berhasil menyelesaikan:
1. ✅ Logout tidak responsif → Fixed dengan proper timeout & error handling
2. ✅ Session expired tidak tertangani → Fixed dengan global SessionManager
3. ✅ Profile page field errors → Fixed dengan field names yang benar
4. ✅ Poor UX pada errors → Fixed dengan proper messages & auto-redirect

Semua solusi production-ready dan sudah di-test scenario-nya.
