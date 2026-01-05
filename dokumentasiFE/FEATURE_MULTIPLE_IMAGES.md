# 📸 Multiple Images Upload - Dokumentasi & Panduan

## 📊 Current State

### ✅ **Saat Ini (Single Image):**
- **1 gambar** per post
- Upload via `image_picker`
- Disimpan sebagai `imageUrl` (String) di database
- Display sederhana di feed

### 📝 **Struktur Data Saat Ini:**
```dart
class PostModel {
  final int id;
  final String? content;
  final String? imageUrl;  // ← Hanya 1 URL (String)
  // ...
}
```

---

## 🎯 Multiple Images Feature

### **Untuk Support Multiple Images, Perlu:**

1. ✅ **Backend Changes** (PENTING!)
2. ✅ **Model Changes** (Flutter)
3. ✅ **UI Changes** (Flutter)
4. ✅ **Upload Logic** (Flutter)
5. ✅ **Display Logic** (Flutter)

---

## 🔧 Implementation Plan

### **1. Backend Changes (PRIORITAS TINGGI)**

#### **Database Schema:**
```sql
-- Option A: Array of strings (PostgreSQL, modern DBs)
ALTER TABLE posts 
MODIFY COLUMN imageUrl JSON;  -- Store array: ["/uploads/...", "/uploads/..."]

-- Option B: Separate table (traditional)
CREATE TABLE post_images (
  id INT PRIMARY KEY AUTO_INCREMENT,
  post_id INT NOT NULL,
  image_url VARCHAR(255) NOT NULL,
  order_index INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(id) ON DELETE CASCADE,
  INDEX idx_post_id (post_id)
);
```

#### **API Changes:**

**Upload Endpoint (Support Multiple Files):**
```javascript
// POST /api/posts
router.post('/posts', 
  authenticate,
  upload.array('images', 5), // Max 5 images
  async (req, res) => {
    const { content } = req.body;
    const files = req.files; // Array of uploaded files
    
    // Save URLs
    const imageUrls = files.map(file => `/uploads/posts/${file.filename}`);
    
    // Save to DB
    const post = await Post.create({
      userId: req.user.id,
      content,
      imageUrls: JSON.stringify(imageUrls) // or use separate table
    });
    
    res.json({ success: true, data: post });
  }
);
```

**Response Format:**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "content": "Post dengan multiple images",
    "imageUrls": [
      "/uploads/posts/post-12-123456-1.jpg",
      "/uploads/posts/post-12-123456-2.jpg",
      "/uploads/posts/post-12-123456-3.jpg"
    ],
    "user": { ... },
    "likeCount": 0,
    "commentCount": 0
  }
}
```

---

### **2. Flutter Model Changes**

```dart
// filepath: lib/models/post.dart

class PostModel {
  final int id;
  final String? content;
  
  // OLD: Single image
  // final String? imageUrl;
  
  // NEW: Multiple images
  final List<String>? imageUrls;  // ← Changed to List
  
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel user;
  int likeCount;
  int commentCount;
  bool likedByMe;

  PostModel({
    required this.id,
    this.content,
    this.imageUrls,  // ← Now List
    required this.createdAt,
    required this.updatedAt,
    required this.user,
    required this.likeCount,
    required this.commentCount,
    required this.likedByMe,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse imageUrls - could be JSON array or separate field
    List<String>? imageUrls;
    if (json['imageUrls'] != null) {
      if (json['imageUrls'] is List) {
        imageUrls = (json['imageUrls'] as List)
            .map((e) => e.toString())
            .toList();
      } else if (json['imageUrls'] is String) {
        // If backend sends JSON string, parse it
        imageUrls = List<String>.from(jsonDecode(json['imageUrls']));
      }
    }
    
    return PostModel(
      id: json['id'] as int? ?? 0,
      content: json['content'] as String?,
      imageUrls: imageUrls,  // ← List
      // ...existing code...
    );
  }

  // Helper untuk full URLs
  List<String>? getFullImageUrls(String baseUrl) {
    if (imageUrls == null || imageUrls!.isEmpty) return null;
    return imageUrls!.map((url) => '$baseUrl$url').toList();
  }

  // Helper untuk backward compatibility
  String? get firstImageUrl => imageUrls?.isNotEmpty == true ? imageUrls!.first : null;
}
```

---

### **3. Flutter Upload UI Changes**

```dart
// filepath: lib/pages/feed/create_post_page.dart

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  // OLD: Single image
  // File? _selectedImage;
  
  // NEW: Multiple images
  List<File> _selectedImages = [];  // ← Changed to List
  
  final int _maxImages = 5;  // Limit 5 images
  bool _isPosting = false;

  // Pick multiple images
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        setState(() {
          // Add new images, respect max limit
          for (var file in pickedFiles) {
            if (_selectedImages.length < _maxImages) {
              _selectedImages.add(File(file.path));
            }
          }
        });
        
        if (pickedFiles.length + _selectedImages.length > _maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maksimal $_maxImages gambar')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  // Remove specific image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Upload post with multiple images
  Future<void> _createPost() async {
    final content = _contentController.text.trim();
    
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis sesuatu atau pilih gambar')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      ApiResponse<PostModel> result;
      
      if (_selectedImages.isNotEmpty) {
        // Upload with multiple images
        result = await _postService.createPostWithMultipleImages(
          content: content.isEmpty ? null : content,
          images: _selectedImages,
        );
      } else {
        // Text only
        result = await _postService.createPost(content: content);
      }

      if (result.success && mounted) {
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Gagal membuat post')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Postingan')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Text input
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Apa yang Anda pikirkan?',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Image preview grid
                  if (_selectedImages.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // Image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(_selectedImages[index]),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Remove button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Add image button
                  if (_selectedImages.length < _maxImages)
                    OutlinedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        _selectedImages.isEmpty 
                          ? 'Tambah Gambar' 
                          : 'Tambah Gambar (${_selectedImages.length}/$_maxImages)'
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // Post button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Posting',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### **4. Flutter Service Changes**

```dart
// filepath: lib/services/post_service.dart

class PostService {
  // ...existing code...

  // NEW: Upload multiple images
  Future<ApiResponse<PostModel>> createPostWithMultipleImages({
    String? content,
    required List<File> images,
  }) async {
    try {
      print('📤 Creating post with ${images.length} images...');
      
      final token = await _storage.getToken();
      if (token == null) throw Exception('No token found');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiService.baseUrl}/api/posts'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add content
      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }

      // Add multiple images
      for (var i = 0; i < images.length; i++) {
        var imageFile = await http.MultipartFile.fromPath(
          'images', // Backend expects 'images' (array)
          images[i].path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
        print('📎 Added image ${i + 1}: ${images[i].path}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ApiResponse<PostModel>(
          success: true,
          message: data['message'],
          data: PostModel.fromJson(data['data']),
        );
      } else {
        return ApiResponse<PostModel>(
          success: false,
          message: data['message'] ?? 'Failed to create post',
        );
      }
    } catch (e, stackTrace) {
      print('❌ Create post error: $e');
      print('Stack trace: $stackTrace');
      return ApiResponse<PostModel>(
        success: false,
        message: 'Error: $e',
      );
    }
  }
}
```

---

### **5. Flutter Display Changes (Carousel)**

```dart
// filepath: lib/pages/feed/feed_page.dart

// Add dependency to pubspec.yaml:
// carousel_slider: ^4.2.1

import 'package:carousel_slider/carousel_slider.dart';

// In _PostCard widget:
Widget build(BuildContext context) {
  return Card(
    child: Column(
      children: [
        // ...header...
        
        // Multiple images carousel
        if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
          Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 150,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                ),
                items: post.getFullImageUrls(ApiService.baseUrl)!.map((imageUrl) {
                  return GestureDetector(
                    onTap: () => showFullscreenImage(imageUrl),
                    child: Container(
                      alignment: Alignment.center,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              // Image indicator (1/3, 2/3, etc)
              if (post.imageUrls!.length > 1)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      post.imageUrls!.length,
                      (index) => Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        
        // ...actions...
      ],
    ),
  );
}
```

---

## 📦 Required Packages

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  http_parser: ^4.0.2
  image_picker: ^1.0.4
  carousel_slider: ^4.2.1  # ← NEW: For image carousel
```

---

## ✅ Implementation Checklist

### **Backend (Required First):**
- [ ] Update database schema (imageUrl → imageUrls array)
- [ ] Update POST /api/posts to accept multiple files
- [ ] Update response to return array of URLs
- [ ] Test upload 5 images
- [ ] Update GET /api/posts response format

### **Frontend (After Backend Ready):**
- [ ] Update PostModel (imageUrl → imageUrls List)
- [ ] Update CreatePostPage UI (grid preview)
- [ ] Add pickMultiImage functionality
- [ ] Update PostService upload method
- [ ] Add carousel_slider package
- [ ] Update FeedPage display (carousel)
- [ ] Update PostDetailPage display
- [ ] Test end-to-end flow

---

## 🎯 Quick Summary

### **Current (Single Image):**
```dart
File? _selectedImage;          // 1 image
final String? imageUrl;        // 1 URL
```

### **Future (Multiple Images):**
```dart
List<File> _selectedImages;    // Multiple images
final List<String>? imageUrls; // Multiple URLs
```

---

## 🚀 Next Steps

1. **Backend Team**: Implement multiple image upload support
2. **Coordinate**: Agree on API contract (JSON format)
3. **Frontend**: Implement after backend ready
4. **Testing**: Test with 1, 3, 5 images

---

## 📞 Questions to Backend Team

Before implementing, tanyakan ke backend:

1. **Max images per post?** (Suggest: 5-10)
2. **Database structure?** (JSON array or separate table?)
3. **API endpoint?** (Same POST /api/posts or new endpoint?)
4. **Field name?** ('images[]' or 'images' or other?)
5. **Response format?** (Array of URLs?)

---

**Status:** 📝 **Planning Phase** - Butuh koordinasi dengan backend dulu

**Current:** ✅ Single image working perfectly

**Next:** 🔄 Multiple images (requires backend update)

**Date:** December 27, 2025
