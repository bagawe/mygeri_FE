# Maintenance Page - Error Handling Documentation

## Overview
Implementasi halaman maintenance untuk menangani network error ketika backend sedang down atau tidak dapat diakses.

## Problem
Sebelumnya, ketika backend mati (Connection refused), aplikasi menampilkan error message yang tidak user-friendly di UI:
```
Exception: Network error: ClientException with SocketException: 
Connection refused (OS Error: Connection refused, errno = 111), 
address = 10.0.2.2, port = 51724
```

## Solution
Membuat halaman khusus `MaintenancePage` yang menampilkan:
- Icon maintenance yang friendly
- Pesan yang jelas dan mudah dipahami
- Informasi tentang apa yang terjadi
- Tombol "Coba Lagi" untuk retry
- Contact info untuk support

## Files Modified

### 1. `/lib/pages/maintenance/maintenance_page.dart` (NEW)
Halaman maintenance dengan UI yang clean:
- Icon construction besar di tengah
- Title "Sedang Maintenance"
- Deskripsi yang jelas
- Info card menjelaskan situasi
- Button "Coba Lagi" untuk kembali ke login
- Contact support info

### 2. `/lib/pages/beranda/beranda_page.dart`
**Changes:**
- Added import: `import '../maintenance/maintenance_page.dart';`
- Modified `_loadProfile()` error handling:
  ```dart
  catch (e) {
    // Cek network error
    if (e.toString().contains('Connection refused') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('Failed host lookup')) {
      
      // Navigate ke maintenance page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MaintenancePage(),
        ),
      );
      return;
    }
    // ... existing error handling
  }
  ```

### 3. `/lib/pages/feed/feed_page.dart`
**Changes:**
- Added import: `import '../maintenance/maintenance_page.dart';`
- Modified `_loadFeed()` error handling:
  ```dart
  catch (e) {
    // Navigate ke maintenance hanya jika belum ada post yang ter-load
    if ((e.toString().contains('Connection refused') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('Failed host lookup')) && _posts.isEmpty) {
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MaintenancePage(),
        ),
      );
      return;
    }
    // ... existing error handling
  }
  ```

### 4. `/lib/pages/hashtag/trending_hashtags_widget.dart`
**Changes:**
- Modified `_loadTrendingHashtags()` to silently hide widget on network error:
  ```dart
  catch (e) {
    if (e.toString().contains('Connection refused') || 
        e.toString().contains('SocketException') ||
        e.toString().contains('Failed host lookup')) {
      // Hide widget instead of showing error
      setState(() {
        _hashtags = [];
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }
  ```
- Modified empty state to return `SizedBox.shrink()` instead of message

## Network Error Detection
Error ditangani ketika string error mengandung salah satu dari:
- `"Connection refused"` - Backend tidak running
- `"SocketException"` - Network socket error
- `"Failed host lookup"` - DNS/hostname resolution error

## User Flow

### Scenario 1: Backend Down saat Login
1. User login berhasil (token saved)
2. App tries to load profile
3. Network error detected
4. **Redirected to Maintenance Page**
5. User clicks "Coba Lagi"
6. Returns to login page

### Scenario 2: Backend Down saat Browse Feed
1. User already in app
2. App tries to load feed
3. Network error detected
4. **Redirected to Maintenance Page**
5. User clicks "Coba Lagi"
6. Returns to login page

### Scenario 3: Hashtags Gagal Load
1. User already in app
2. App tries to load trending hashtags
3. Network error detected
4. **Hashtag widget hidden silently** (no error shown)
5. Rest of app continues working

## UI Design

### MaintenancePage Components:
1. **Icon Container**
   - 200x200 circular container
   - Orange background (Colors.orange[50])
   - Construction icon (120px, orange[700])

2. **Title**
   - "Sedang Maintenance"
   - 28px, bold, grey[800]

3. **Description**
   - "Mohon maaf, server sedang dalam maintenance..."
   - 16px, grey[600], centered

4. **Info Card**
   - White background with shadow
   - Icon + "Apa yang terjadi?"
   - Explanation text

5. **Retry Button**
   - Full width, 54px height
   - Gerindra red (#E41E26)
   - Refresh icon + "Coba Lagi"

6. **Contact Info**
   - Phone icon + support text
   - Grey color, 13px

## Testing Checklist

- [ ] Test dengan backend mati saat login
- [ ] Test dengan backend mati saat browse feed
- [ ] Test dengan backend hidup normal
- [ ] Test button "Coba Lagi" functionality
- [ ] Verify hashtag widget hides gracefully
- [ ] Verify error tidak muncul di UI
- [ ] Test pada device fisik
- [ ] Test pada emulator Android
- [ ] Test pada iOS simulator (jika applicable)

## Notes
- Maintenance page menggunakan `pushReplacement` untuk menghindari back button
- Button "Coba Lagi" navigates to `/login` route
- Hashtag widget tidak show error, just hides silently
- Feed page hanya redirect jika `_posts.isEmpty` (belum ada data ter-load)

## Future Improvements
1. Add retry mechanism dengan countdown timer
2. Show estimated maintenance completion time
3. Add in-app notification system
4. Implement service status check endpoint
5. Cache last successful data for offline viewing
