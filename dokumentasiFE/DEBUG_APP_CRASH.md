# 🔧 Debugging: App Crash on Launch

## Status
**Date:** December 27, 2025  
**Issue:** App crashes with "Lost connection to device"  
**Symptoms:** Skipped frames, UI freeze, connection lost

---

## 📋 Crash Log Analysis

### Symptoms dari Log:
```
I/Choreographer(14679): Skipped 203 frames!  The application may be doing too much work on its main thread.
I/Choreographer(14679): Skipped 47 frames!  The application may be doing too much work on its main thread.
Lost connection to device.
```

### Possible Causes:
1. ❌ **Heavy computation on main thread**
2. ❌ **Infinite loop in widget build**
3. ❌ **Network request blocking UI**
4. ❌ **Null safety violation**
5. ❌ **Invalid image URL causing crash**

---

## ✅ Fixes Applied

### 1. Fixed `getFullImageUrls()` Method
**Problem:** Method tidak cek apakah URL sudah full (dengan http/https)

**Before:**
```dart
List<String> getFullImageUrls(String baseUrl) {
  final urls = getAllImageUrls();
  return urls.map((url) => '$baseUrl$url').toList();
}
```

**After:**
```dart
List<String> getFullImageUrls(String baseUrl) {
  final urls = getAllImageUrls();
  return urls.map((url) {
    // Cek apakah URL sudah full
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    return '$baseUrl$url';
  }).toList();
}
```

**Impact:** Prevents double base URL (e.g., `http://...http://...`)

---

### 2. Fixed `getFullImageUrl()` Method (Deprecated)
**Problem:** Same issue untuk backward compatibility method

**After:**
```dart
@Deprecated('Use getAllImageUrls() instead')
String? getFullImageUrl(String baseUrl) {
  final urls = getAllImageUrls();
  if (urls.isEmpty) return null;
  final url = urls.first;
  // Cek apakah URL sudah full
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return '$baseUrl$url';
}
```

---

## 🧪 Testing Steps

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
```

### Step 2: Run with Verbose
```bash
flutter run -v
```

### Step 3: Check for Runtime Errors
Monitor console untuk:
- ❌ Null pointer exceptions
- ❌ Image load failures
- ❌ JSON parsing errors
- ❌ Network timeouts

### Step 4: Test Specific Screens
1. **Launch app** → Cek splash/home screen
2. **Navigate to Feed** → Cek feed loading
3. **View post with image** → Cek image display
4. **View post with multiple images** → Cek carousel
5. **Create new post** → Cek image picker

---

## 🔍 Debug Checklist

### If Still Crashing:

#### A. Check Backend Connection
```bash
# Test API endpoint
curl http://10.0.2.2:3030/api/posts
```

Pastikan:
- ✅ Backend running di port 3030
- ✅ Response valid JSON
- ✅ Image URLs dalam response valid

#### B. Check Image URLs in Response
Example valid response:
```json
{
  "id": 123,
  "content": "Test",
  "imageUrls": [
    "/uploads/posts/post-123-1.jpg",
    "/uploads/posts/post-123-2.jpg"
  ]
}
```

atau

```json
{
  "id": 123,
  "content": "Test",
  "imageUrl": "/uploads/posts/post-123.jpg"
}
```

#### C. Add Debug Prints
Tambahkan di `feed_page.dart`:
```dart
@override
Widget build(BuildContext context) {
  print('🔍 DEBUG: Building feed with ${_posts.length} posts');
  
  for (var post in _posts) {
    print('🔍 Post ${post.id}:');
    print('   - imageUrl: ${post.imageUrl}');
    print('   - imageUrls: ${post.imageUrls}');
    print('   - getAllImageUrls: ${post.getAllImageUrls()}');
    print('   - getFullImageUrls: ${post.getFullImageUrls(ApiService.baseUrl)}');
  }
  
  // ...existing code
}
```

#### D. Check for Null Values
Di `PostModel.fromJson()`:
```dart
factory PostModel.fromJson(Map<String, dynamic> json) {
  print('🔍 Parsing post JSON: $json');
  
  // Parse imageUrls array
  List<String>? imageUrls;
  if (json['imageUrls'] != null) {
    print('🔍 Found imageUrls: ${json['imageUrls']}');
    if (json['imageUrls'] is List) {
      imageUrls = (json['imageUrls'] as List)
          .map((e) => e.toString())
          .toList();
      print('🔍 Parsed imageUrls: $imageUrls');
    }
  }
  
  // ...rest of code
}
```

#### E. Check Carousel Slider
Pastikan tidak ada infinite build:
```dart
// Di _ImageCarouselWithIndicator
@override
Widget build(BuildContext context) {
  print('🔍 Building carousel with ${widget.imageUrls.length} images');
  print('🔍 Current index: $_currentIndex');
  
  // ...existing code
}
```

---

## 🚨 Common Issues & Solutions

### Issue 1: "Skipped frames"
**Cause:** Too much work on UI thread  
**Solution:**
- Use `Image.network` with `loadingBuilder` and `errorBuilder`
- Avoid synchronous heavy operations in build()
- Use `FutureBuilder` for async data

### Issue 2: "Lost connection to device"
**Cause:** App crash/exception  
**Solution:**
- Check logs for exception stack trace
- Add try-catch in critical sections
- Use Flutter DevTools for crash analysis

### Issue 3: Image Loading Infinite Loop
**Cause:** Wrong URL causing retry loop  
**Solution:**
- Add `errorBuilder` to Image.network
- Limit retry attempts
- Log failed URLs

### Issue 4: Carousel Build Infinite Loop
**Cause:** setState() called during build  
**Solution:**
- Use `StatefulBuilder` carefully
- Avoid setState in onPageChanged during build
- Check _currentIndex initialization

---

## 🛠️ Alternative Debugging

### Use Flutter DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

Then run app with:
```bash
flutter run --observatory-port=8888
```

### Check Android Logcat
```bash
adb logcat | grep flutter
```

### Check Specific Exception
```bash
adb logcat | grep -E "FATAL|AndroidRuntime|Exception"
```

---

## 📝 Next Steps

1. **Try fixes above** → Run `flutter clean && flutter pub get`
2. **Run with verbose** → `flutter run -v`
3. **Check console output** → Look for red error messages
4. **Test incrementally:**
   - Comment out carousel code
   - Test with single image only
   - Add carousel back gradually

5. **If still failing:**
   - Share full error log
   - Check backend response format
   - Test on different device/emulator

---

## ✅ Expected Behavior After Fix

- ✅ App launches successfully
- ✅ Feed loads without freeze
- ✅ Images display correctly
- ✅ Carousel swipes smoothly
- ✅ No frame skips
- ✅ No connection loss

---

## 📊 Performance Metrics

Target after fix:
- Frame rate: 60 FPS
- App launch: < 3 seconds
- Feed load: < 2 seconds
- Image load: < 1 second per image
- Carousel swipe: Smooth (no jank)

