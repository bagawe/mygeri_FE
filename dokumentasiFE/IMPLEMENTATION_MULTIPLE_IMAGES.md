# 📱 Flutter Implementation: Multiple Images Upload

**Backend Status:** ✅ Ready (Node.js + Express + Prisma)  
**Frontend Status:** 🔄 Implementation Guide  
**Date:** 27 Desember 2025

---

## 📋 Progress Checklist

### Phase 1: Model Update ✅
- [x] Update `PostModel` with `imageUrls` field
- [x] Add `getAllImageUrls()` helper
- [x] Add `getFullImageUrls()` helper
- [x] Backward compatible with old posts

### Phase 2: Service Layer (TO DO)
- [ ] Add `createPostWithMultipleImages()` method
- [ ] Update upload logic to handle File array
- [ ] Add proper error handling

### Phase 3: Create Post UI (TO DO)
- [ ] Change `File?` to `List<File>`
- [ ] Add `pickMultiImage()` functionality
- [ ] Create grid preview for multiple images
- [ ] Add remove image button per item
- [ ] Show counter (e.g., "3/10 images")

### Phase 4: Display UI (TO DO)
- [ ] Add `carousel_slider` package
- [ ] Update `feed_page.dart` with carousel
- [ ] Update `post_detail_page.dart` with carousel
- [ ] Add image indicator dots (1/3, 2/3)

### Phase 5: Testing (TO DO)
- [ ] Test upload 1 image (backward compatible)
- [ ] Test upload 3 images
- [ ] Test upload 10 images (max)
- [ ] Test error: 11 images (should fail)
- [ ] Test display old posts (imageUrl only)
- [ ] Test display new posts (imageUrls array)
- [ ] Test fullscreen viewer with multiple images

---

## 🎯 Implementation Steps

### Step 1: Update Model ✅ DONE

**File:** `lib/models/post.dart`

```dart
class PostModel {
  final List<String>? imageUrls;  // ✅ Added
  
  // Helpers
  List<String> getAllImageUrls() { }     // ✅ Added
  List<String> getFullImageUrls() { }    // ✅ Added
}
```

**Status:** ✅ Complete

---

### Step 2: Add Dependencies

**File:** `pubspec.yaml`

```yaml
dependencies:
  # ...existing dependencies...
  carousel_slider: ^4.2.1  # ← Add this
```

**Command:**
```bash
cd /Users/mac/development/mygeri
flutter pub add carousel_slider
```

---

### Step 3: Update Post Service

**File:** `lib/services/post_service.dart`

Add new method for multiple images upload:

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PostService {
  // ...existing methods...

  // NEW: Create post with multiple images
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
          'images', // Backend field name
          images[i].path,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(imageFile);
        print('📎 Added image ${i + 1}/${images.length}: ${images[i].path}');
      }

      print('🚀 Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Post created successfully');
        return ApiResponse<PostModel>(
          success: true,
          message: data['message'],
          data: PostModel.fromJson(data['data']),
        );
      } else {
        print('❌ Failed: ${data['message']}');
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

### Step 4: Update Create Post Page

**File:** `lib/pages/feed/create_post_page.dart`

Major changes needed:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService(ApiService());

  // OLD: File? _selectedImage;
  // NEW: List of images
  List<File> _selectedImages = [];
  final int _maxImages = 10;  // Max 10 images as per backend
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

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
        
        // Show warning if exceeded limit
        if (_selectedImages.length + pickedFiles.length > _maxImages) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Maksimal $_maxImages gambar'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  // Remove specific image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Create post
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
        // Upload with images (single or multiple)
        result = await _postService.createPostWithMultipleImages(
          content: content.isEmpty ? null : content,
          images: _selectedImages,
        );
      } else {
        // Text only
        result = await _postService.createPost(content: content);
      }

      if (result.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to refresh feed
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Gagal membuat post'),
            backgroundColor: Colors.red,
          ),
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
      appBar: AppBar(
        title: const Text('Buat Postingan'),
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    enabled: !_isPosting,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Image preview grid
                  if (_selectedImages.isNotEmpty) ...[
                    Text(
                      '${_selectedImages.length} gambar dipilih',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                            // Image number
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Add image button
                  if (_selectedImages.length < _maxImages)
                    OutlinedButton.icon(
                      onPressed: _isPosting ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: Text(
                        _selectedImages.isEmpty 
                          ? 'Tambah Gambar' 
                          : 'Tambah Gambar (${_selectedImages.length}/$_maxImages)'
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 45),
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
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey[300],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Posting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

### Step 5: Update Feed Display (Carousel)

**Install package first:**
```bash
flutter pub add carousel_slider
```

**File:** `lib/pages/feed/feed_page.dart`

Update `_PostCard` widget:

```dart
import 'package:carousel_slider/carousel_slider.dart';

class _PostCard extends StatefulWidget {
  // ...existing code...
}

class _PostCardState extends State<_PostCard> {
  int _currentImageIndex = 0;  // Track current image in carousel

  Widget _buildImageSection() {
    final imageUrls = widget.post.getFullImageUrls(ApiService.baseUrl);
    
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    // Single image
    if (imageUrls.length == 1) {
      return GestureDetector(
        onTap: () => showFullscreenImage(imageUrls[0]),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 150),
          alignment: Alignment.center,
          child: Image.network(
            imageUrls[0],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, size: 48),
                ),
              );
            },
          ),
        ),
      );
    }

    // Multiple images - Carousel
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          items: imageUrls.map((imageUrl) {
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
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }).toList(),
        ),
        
        // Image indicator dots
        if (imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imageUrls.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Header
          // ...existing header code...
          
          // Content text
          // ...existing content code...
          
          // Images (REPLACE OLD IMAGE CODE WITH THIS)
          _buildImageSection(),
          
          // Actions (like, comment)
          // ...existing actions code...
        ],
      ),
    );
  }
}
```

---

## 📊 Testing Plan

### Test 1: Single Image (Backward Compatible)
1. Open app
2. Click FAB (+)
3. Select 1 image
4. Add content
5. Click "Posting"
6. ✅ Should work like before

### Test 2: Multiple Images
1. Open app
2. Click FAB (+)
3. Select 3 images
4. ✅ Should show grid with 3 images
5. ✅ Each has number badge (1, 2, 3)
6. ✅ Each has X button to remove
7. Click "Posting"
8. ✅ Should upload all 3 images
9. ✅ Feed shows carousel with dots

### Test 3: Max Limit
1. Select 11 images
2. ✅ Should only add 10
3. ✅ Show warning "Maksimal 10 gambar"

### Test 4: Old Posts Display
1. View feed with old posts (imageUrl only)
2. ✅ Should display correctly
3. ✅ No carousel, just single image

### Test 5: Carousel Interaction
1. View post with 3 images
2. ✅ Swipe left/right to see all images
3. ✅ Dots indicate current image
4. Tap image
5. ✅ Opens fullscreen viewer

---

## 🎯 Next Actions

**Priority Order:**

1. ✅ **Model updated** - DONE
2. 📦 **Add carousel_slider package**
   ```bash
   cd /Users/mac/development/mygeri
   flutter pub add carousel_slider
   ```
3. 🔧 **Update post_service.dart** - Add `createPostWithMultipleImages()` method
4. 🎨 **Update create_post_page.dart** - Grid UI with multiple image picker
5. 📱 **Update feed_page.dart** - Carousel display
6. 🧪 **Testing** - Test all scenarios above

---

## 📝 Notes

- Backend ready dengan full support multiple images
- Max 10 images per post (sesuai spec backend)
- Max 5MB per file
- Backward compatible dengan post lama
- Menggunakan `carousel_slider` package untuk swipe gallery

---

**Status:** 🟡 Phase 1 Complete, Ready for Phase 2-4

**Last Updated:** 27 Desember 2025
