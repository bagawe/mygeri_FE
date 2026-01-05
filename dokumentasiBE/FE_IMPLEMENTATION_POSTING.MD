# 🚀 Panduan Implementasi Fitur Posting untuk Flutter Developer

Dokumentasi ini berisi **langkah-langkah implementasi** dan **solusi untuk masalah 404 error** saat load gambar post.

---

## ✅ Status Backend

Backend **sudah 100% siap** dengan konfigurasi:

- ✅ Upload endpoint: `POST /api/posts`
- ✅ Static file serving: `GET /uploads/posts/{filename}`
- ✅ Auto-create folder `uploads/posts/`
- ✅ Support image: JPEG, JPG, PNG, GIF, WEBP
- ✅ Max file size: 5MB
- ✅ CORS enabled

Server running di: `http://localhost:3030`

---

## ⚠️ MASALAH UTAMA: Base URL

### ❌ **Yang SALAH (Akan 404 Error):**

```dart
// JANGAN pakai localhost di Android Emulator!
static const String baseUrl = 'http://localhost:3030/api';

// Image URL dari backend: "/uploads/posts/post-1-123456.jpg"
// Flutter akan request: "http://localhost:3030/uploads/posts/post-1-123456.jpg"
// Result: ❌ 404 Not Found (localhost di Android = device itself, bukan host machine)
```

### ✅ **Yang BENAR:**

```dart
class ApiConfig {
  // Untuk Android Emulator (10.0.2.2 = host machine)
  static const String baseUrl = 'http://10.0.2.2:3030/api';
  
  // Untuk iOS Simulator
  // static const String baseUrl = 'http://127.0.0.1:3030/api';
  
  // Untuk Real Device (ganti dengan IP komputer)
  // static const String baseUrl = 'http://192.168.1.100:3030/api';
}
```

---

## 📱 Cara Cek IP Komputer (untuk Real Device Testing)

### **MacOS:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### **Windows:**
```bash
ipconfig | findstr IPv4
```

### **Linux:**
```bash
hostname -I | awk '{print $1}'
```

**Expected output:** `192.168.1.100` (gunakan IP ini di Flutter)

---

## 🔧 Implementasi di Flutter

### **1. Update `ApiConfig`**

```dart
// filepath: lib/config/api_config.dart
class ApiConfig {
  // PILIH SALAH SATU sesuai environment testing
  
  // Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3030/api';
  static const String baseUrlNoApi = 'http://10.0.2.2:3030';
  
  // iOS Simulator
  // static const String baseUrl = 'http://127.0.0.1:3030/api';
  // static const String baseUrlNoApi = 'http://127.0.0.1:3030';
  
  // Real Device (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.1.100:3030/api';
  // static const String baseUrlNoApi = 'http://192.168.1.100:3030';
}
```

---

### **2. Update `PostModel` - Tambahkan Helper `fullImageUrl`**

```dart
// filepath: lib/models/post_model.dart
import 'package:your_app/config/api_config.dart';

class PostModel {
  final int id;
  final String? content;
  final String? imageUrl;  // Dari backend: "/uploads/posts/post-1-123456.jpg"
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;

  PostModel({
    required this.id,
    this.content,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  // ✅ PENTING: Helper untuk convert path relatif jadi full URL
  String? get fullImageUrl {
    if (imageUrl == null) return null;
    
    // Backend return: "/uploads/posts/post-1-123456.jpg"
    // Convert jadi: "http://10.0.2.2:3030/uploads/posts/post-1-123456.jpg"
    return '${ApiConfig.baseUrlNoApi}$imageUrl';
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      imageUrl: json['imageUrl'],  // Save path relatif
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: UserModel.fromJson(json['user']),
      likeCount: json['likeCount'],
      commentCount: json['commentCount'],
      likedByMe: json['likedByMe'],
    );
  }
}
```

---

### **3. Load Image di Widget - Gunakan `fullImageUrl`**

```dart
// filepath: lib/widgets/post_card.dart
import 'package:cached_network_image/cached_network_image.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header (user info)
          ListTile(
            leading: CircleAvatar(
              child: Text(post.user.username[0].toUpperCase()),
            ),
            title: Text(post.user.username),
            subtitle: Text(_formatDate(post.createdAt)),
          ),

          // Content text
          if (post.content != null)
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(post.content!),
            ),

          // ✅ Image - Gunakan fullImageUrl
          if (post.imageUrl != null)
            CachedNetworkImage(
              imageUrl: post.fullImageUrl!,  // ← Penting: pakai fullImageUrl
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) {
                print('❌ Image failed to load: $url');
                print('Error: $error');
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50),
                      SizedBox(height: 8),
                      Text('Failed to load image'),
                      Text(url, style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),

          // Actions (like, comment)
          Row(
            children: [
              IconButton(
                icon: Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  color: post.likedByMe ? Colors.red : null,
                ),
                onPressed: () => _onLike(),
              ),
              Text('${post.likeCount}'),
              SizedBox(width: 16),
              IconButton(
                icon: Icon(Icons.comment_outlined),
                onPressed: () => _onComment(),
              ),
              Text('${post.commentCount}'),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
```

---

### **4. Debug Helper - Tambahkan Log**

Untuk memudahkan debugging, tambahkan log di service:

```dart
// filepath: lib/services/post_service.dart
Future<ApiResponse<List<PostModel>>> getFeed({
  int page = 1,
  int limit = 10,
}) async {
  try {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/posts?page=$page&limit=$limit'),
      headers: _headers,
    );

    print('📡 GET Feed - Status: ${response.statusCode}');
    
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<PostModel> posts = (data['data'] as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      // Debug: Print image URLs
      for (var post in posts) {
        if (post.imageUrl != null) {
          print('🖼️ Post ${post.id}:');
          print('   - imageUrl: ${post.imageUrl}');
          print('   - fullImageUrl: ${post.fullImageUrl}');
        }
      }

      return ApiResponse<List<PostModel>>(
        success: data['success'],
        data: posts,
        pagination: PaginationModel.fromJson(data['pagination']),
      );
    }
    
    // ... error handling
  } catch (e) {
    print('❌ Get Feed Error: $e');
    // ... error handling
  }
}
```

---

## 🧪 Testing Checklist

### **Backend Test (dari Terminal):**

```bash
# 1. Cek server running
curl http://localhost:3030/health

# 2. Login
curl -X POST http://localhost:3030/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier": "admin@example.com", "password": "Admin123!"}'

# 3. Upload test post (ganti TOKEN)
curl -X POST http://localhost:3030/api/posts \
  -H "Authorization: Bearer TOKEN" \
  -F "image=@test.jpg" \
  -F "content=Test upload"

# 4. Test akses gambar langsung (ganti FILENAME)
curl -I http://localhost:3030/uploads/posts/FILENAME.jpg
# Expected: HTTP/1.1 200 OK
```

### **Flutter Test:**

- [ ] Update `ApiConfig.baseUrl` ke `http://10.0.2.2:3030/api`
- [ ] Tambahkan `fullImageUrl` helper di `PostModel`
- [ ] Gunakan `post.fullImageUrl` di widget (bukan `post.imageUrl`)
- [ ] Test upload image dari app
- [ ] Test load feed dengan gambar
- [ ] Check console log untuk URL yang di-request
- [ ] Verify 200 OK (bukan 404)

---

## 🐛 Troubleshooting

### **Problem 1: 404 Not Found**

**Symptom:**
```
❌ Image failed to load: HTTP request failed, statusCode: 404
```

**Solution:**
```dart
// ❌ SALAH
static const String baseUrl = 'http://localhost:3030/api';

// ✅ BENAR (Android Emulator)
static const String baseUrl = 'http://10.0.2.2:3030/api';
```

---

### **Problem 2: Connection Refused**

**Symptom:**
```
❌ SocketException: Connection refused
```

**Solution:**
1. Pastikan backend running: `npm run dev`
2. Cek port: `lsof -i:3030` (MacOS) atau `netstat -ano | findstr :3030` (Windows)
3. Cek firewall tidak block port 3030

---

### **Problem 3: Image URL Salah Format**

**Symptom:**
```
🖼️ Loading image URL: http://10.0.2.2:3030/api/uploads/posts/post-1.jpg
❌ 404 Not Found
```

**Issue:** Base URL salah (ada `/api` di URL gambar)

**Solution:**
```dart
// Pisahkan base URL untuk API dan static files
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3030/api';  // Untuk API
  static const String baseUrlNoApi = 'http://10.0.2.2:3030'; // Untuk static files
}

// Di PostModel
String? get fullImageUrl {
  if (imageUrl == null) return null;
  return '${ApiConfig.baseUrlNoApi}$imageUrl'; // ← Pakai baseUrlNoApi
}
```

---

### **Problem 4: CORS Error (Web only)**

Jika testing di Flutter Web:

**Solution:** Sudah handled di backend, pastikan origin di `.env`:
```env
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:3030
```

---

## 📦 Required Flutter Packages

Pastikan sudah install di `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  http_parser: ^4.0.2
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0  # Penting untuk caching
  path_provider: ^2.1.1         # Untuk file handling
```

Install:
```bash
flutter pub get
```

---

## 🎯 Quick Summary

### **3 Hal Penting:**

1. **Base URL:** Pakai `10.0.2.2` untuk Android Emulator (bukan `localhost`)
2. **Full URL:** Gunakan helper `fullImageUrl` (gabungan base + path relatif)
3. **Widget:** Pakai `CachedNetworkImage` dengan error handling

### **Flow Upload & Display:**

```
Flutter Upload → Backend Save → Return Path Relatif
    ↓                               ↓
"/uploads/posts/post-1.jpg" ← Database
    ↓
Flutter Get Feed → Dapat Path Relatif → Tambah Base URL
    ↓
"http://10.0.2.2:3030/uploads/posts/post-1.jpg"
    ↓
CachedNetworkImage → Load Success ✅
```

---

## 📞 Support

Jika masih ada masalah:

1. **Cek log backend:** Server akan log setiap request
2. **Cek log Flutter:** Print URL yang di-request
3. **Test manual:** Buka URL gambar di browser
4. **Verify file exists:** `ls -la uploads/posts/` di backend

---

## ✅ Final Checklist

Backend (Sudah Selesai):
- [x] Upload middleware support posts
- [x] Static files middleware aktif
- [x] Folder uploads/posts/ dibuat otomatis
- [x] CORS configured
- [x] Error handling

Flutter (Yang Perlu Dikerjakan):
- [ ] Update ApiConfig base URL
- [ ] Tambahkan fullImageUrl helper
- [ ] Gunakan CachedNetworkImage
- [ ] Test upload & display
- [ ] Handle error states

---

**Backend 100% ready! Tinggal sesuaikan Flutter dengan panduan di atas.** 🚀

---

**Dokumentasi Lengkap:** Lihat file `FLUTTER_POSTING_API.md` untuk detail API endpoints.

**Last Updated:** 2025-12-27
**Backend Version:** 1.0.0