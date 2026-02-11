# Session Management Fix

## Problem
Sesi user terlalu cepat expire, tidak sesuai kebutuhan yaitu 1 bulan.

## Root Cause
Method `StorageService.isLoggedIn()` **hanya mengecek keberadaan token**, tidak memvalidasi session expiry timestamp. Akibatnya:
- Session expiry sudah diset 30 hari saat login ✅
- Tapi tidak pernah divalidasi ❌
- User bisa logout tanpa alasan karena session dianggap invalid

## Solution Applied

### 1. Update `isLoggedIn()` Method
**File**: `lib/services/storage_service.dart`

**Sebelum**:
```dart
Future<bool> isLoggedIn() async {
  final token = await getAccessToken();
  final isLoggedIn = token != null && token.isNotEmpty;
  return isLoggedIn;
}
```

**Sesudah**:
```dart
Future<bool> isLoggedIn() async {
  final token = await getAccessToken();
  final hasToken = token != null && token.isNotEmpty;
  
  if (!hasToken) {
    print('🔍 StorageService.isLoggedIn(): false (no token)');
    return false;
  }
  
  // Check if session has expired
  final sessionValid = await isSessionValid();
  
  if (!sessionValid) {
    print('🔍 StorageService.isLoggedIn(): false (session expired)');
    // Clear expired session
    await clearAll();
    return false;
  }
  
  print('🔍 StorageService.isLoggedIn(): true (token valid & session active)');
  return true;
}
```

### 2. Simplify Splash Screen Logic
**File**: `lib/pages/splash_screen.dart`

**Perubahan**:
- Remove duplikasi pengecekan session (sudah di-handle oleh `isLoggedIn()`)
- Tetap extend session setiap kali app dibuka
- Lebih clean dan maintainable

## How It Works Now

### Login Flow:
1. User login berhasil
2. `AuthService.login()` memanggil `_storage.setSessionExpiry()`
3. Session expiry diset ke **30 hari dari sekarang**
4. Session tersimpan di secure storage

### Session Validation:
1. Setiap kali app check `isLoggedIn()`:
   - ✅ Cek token ada
   - ✅ Cek session belum expired (< 30 hari)
   - ❌ Jika expired: auto-clear storage & return false

### Auto-Extend (Sliding Window):
1. Setiap kali user buka app (splash screen):
   - Jika `isLoggedIn() == true` (session valid)
   - Call `extendSessionExpiry()`
   - Session di-reset ke **30 hari dari sekarang**

### Result:
- User yang aktif (buka app < 30 hari): session **terus diperpanjang**
- User yang inactive (tidak buka app > 30 hari): session **auto-expired**
- Sesuai kebutuhan: **1 bulan sliding window** ✅

## Testing Checklist

- [ ] Login berhasil dan session ter-set
- [ ] Tutup app, buka lagi → session masih valid (extended)
- [ ] Manual set session expiry ke masa lalu → auto-logout
- [ ] Session valid selama user aktif (< 30 hari)
- [ ] Session expired jika tidak buka app > 30 hari

## Files Modified

1. `lib/services/storage_service.dart`
   - Update `isLoggedIn()` method

2. `lib/pages/splash_screen.dart`
   - Simplify session validation logic
   - Remove duplicate checks

## Additional Notes

### Session Duration
- Default: **30 hari** (Duration(days: 30))
- Dapat diubah di `StorageService.setSessionExpiry()` dan `extendSessionExpiry()`

### Secure Storage Keys
- `session_expiry`: ISO8601 timestamp (e.g., "2026-02-12T10:30:00.000")

### Debug Logs
Session management sekarang punya comprehensive logging:
- ✅ Session set/extended
- 🔍 Session validation
- ❌ Session expired
- 🕐 Remaining days

Monitor logs untuk troubleshooting!
