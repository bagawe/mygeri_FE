# Setup Fitur Posting - MyGeri Flutter

## 1. Tambahkan Dependencies

Buka file `pubspec.yaml` dan tambahkan dependencies berikut:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing dependencies
  http: ^1.1.0
  shared_preferences: ^2.2.2
  
  # NEW: Tambahkan dependencies ini untuk fitur posting
  image_picker: ^1.0.7
  http_parser: ^4.0.2
  timeago: ^3.6.0
```

Setelah menambahkan, jalankan:
```bash
flutter pub get
```

## 2. Konfigurasi Platform

### iOS (Info.plist)

Buka `ios/Runner/Info.plist` dan tambahkan:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Aplikasi memerlukan akses galeri untuk memilih foto untuk postingan</string>

<key>NSCameraUsageDescription</key>
<string>Aplikasi memerlukan akses kamera untuk mengambil foto untuk postingan</string>

<key>NSMicrophoneUsageDescription</key>
<string>Aplikasi memerlukan akses mikrofon</string>
```

### Android (AndroidManifest.xml)

File `android/app/src/main/AndroidManifest.xml` sudah memiliki permission INTERNET, pastikan ada:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

Juga pastikan ada permission untuk kamera di dalam tag `<manifest>`:

```xml
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

## 3. File yang Sudah Dibuat

Struktur file baru untuk fitur posting:

```
lib/
├── models/
│   └── post.dart                          # Model untuk Post, Comment, Pagination
├── services/
│   └── post_service.dart                  # Service untuk API posting
└── pages/
    └── feed/
        ├── feed_page.dart                 # Halaman feed (list postingan)
        ├── create_post_page.dart          # Halaman buat postingan
        └── post_detail_page.dart          # Halaman detail postingan & komentar
```

## 4. Integrasi di Beranda

File `lib/pages/beranda/beranda_page.dart` sudah diupdate untuk:
- Menampilkan FeedPage sebagai pengganti carousel agenda
- Menambahkan FloatingActionButton untuk membuat postingan baru
- Data profil user (foto, nama, username) diambil dari backend

## 5. Testing

### a. Pastikan Backend Running

Backend harus berjalan di:
- `http://localhost:3030` (untuk testing di Mac/PC)
- `http://10.0.2.2:3030` (untuk Android Emulator)

### b. Test Flow

1. **Login** ke aplikasi
2. **Buka tab Beranda** - akan tampil feed postingan
3. **Klik FAB (+)** di kanan bawah untuk buat postingan
4. **Buat postingan**:
   - Tulis teks saja, atau
   - Pilih gambar dari galeri, atau
   - Ambil foto dengan kamera
5. **Klik Posting** untuk publish
6. **Lihat feed** - postingan baru muncul
7. **Like postingan** - klik icon love
8. **Komentar** - klik postingan untuk detail, lalu tambah komentar

## 6. Troubleshooting

### Error: "Target of URI doesn't exist: 'package:timeago/timeago.dart'"
Solusi: Jalankan `flutter pub get`

### Error: "No permission to access gallery/camera"
Solusi: 
- iOS: Cek Info.plist sudah ada permission
- Android: Cek AndroidManifest.xml dan minta permission di runtime

### Error: "Failed to load image"
Solusi:
- Cek backend running dan bisa diakses
- Cek URL image di network inspector
- Pastikan base URL benar (`10.0.2.2` untuk emulator)

### Postingan tidak muncul
Solusi:
- Cek token autentikasi valid
- Cek log backend untuk error
- Cek network request di debug console Flutter

## 7. Fitur yang Tersedia

✅ Create post (text only)
✅ Create post with image
✅ Feed with infinite scroll
✅ Like/Unlike post
✅ Comment on post
✅ View post detail
✅ Delete post (owner only)
✅ Delete comment (owner only)
✅ Block user integration (user yang diblokir tidak tampil di feed)

## 8. Next Steps (Optional)

- [ ] Edit postingan
- [ ] Share postingan
- [ ] Report postingan
- [ ] Filter feed (by date, most liked, etc)
- [ ] Notifikasi untuk like/comment
- [ ] Hashtag dan mention
- [ ] Video support

---

**Selamat mencoba! 🚀**

Jika ada pertanyaan atau kendala, silakan cek dokumentasi API di `FLUTTER_POSTING_API.MD`.
