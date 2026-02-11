# 🔧 Build Fix - Namespace Issue

**Date:** 13 Januari 2026  
**Issue:** image_gallery_saver package missing namespace

---

## ❌ Error:

```
A problem occurred configuring project ':image_gallery_saver'.
Namespace not specified. Specify a namespace in the module's build file
```

---

## ✅ Solution:

Package `image_gallery_saver: ^2.0.3` tidak support Android Gradle Plugin (AGP) terbaru yang require namespace.

### Fix Applied:

1. **Add namespace** ke build.gradle package:

```bash
# Location
/Users/mac/.pub-cache/hosted/pub.dev/image_gallery_saver-2.0.3/android/build.gradle

# Added line after "android {"
namespace "com.example.imagegallerysaver"
```

2. **Script untuk fix otomatis:**

```bash
#!/bin/bash
FILE="/Users/mac/.pub-cache/hosted/pub.dev/image_gallery_saver-2.0.3/android/build.gradle"
sed -i '' '/^android {$/a\
    namespace "com.example.imagegallerysaver"
' "$FILE"
echo "✅ Namespace added"
```

---

## 🔄 If Issue Persists:

### Option 1: Manual Edit
```bash
# Edit file
nano /Users/mac/.pub-cache/hosted/pub.dev/image_gallery_saver-2.0.3/android/build.gradle

# Add after "android {"
android {
    namespace "com.example.imagegallerysaver"  // ADD THIS
    compileSdkVersion 30
    ...
}
```

### Option 2: Update Package (Future)
```yaml
# pubspec.yaml - when newer version available
dependencies:
  image_gallery_saver: ^3.0.0  # Hopefully will have namespace
```

### Option 3: Alternative Package
```yaml
# Use gal package instead (more modern)
dependencies:
  gal: ^2.2.0
```

---

## 📝 Note:

Fix ini perlu **diulang** jika:
- Run `flutter clean`
- Run `flutter pub cache repair`
- Package ter-update

**Recommended:** Simpan script fix untuk re-apply jika diperlukan.

---

## ✅ Build Command After Fix:

```bash
flutter build apk --release --split-per-abi
```

Output location:
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk
├── app-arm64-v8a-release.apk
└── app-x86_64-release.apk
```

---

**Status:** ✅ Fixed and building...
