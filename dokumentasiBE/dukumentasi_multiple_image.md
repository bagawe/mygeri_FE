# 📸 Multiple Images Upload - Implementation Guide

**Feature:** Support upload multiple images per post (Instagram carousel style)  
**Date:** 27 Desember 2025  
**Status:** ✅ Production Ready  
**Backend:** Node.js + Express + Prisma + PostgreSQL

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Database Schema](#database-schema)
3. [File Structure](#file-structure)
4. [Implementation Details](#implementation-details)
5. [API Endpoints](#api-endpoints)
6. [Testing](#testing)
7. [Frontend Integration](#frontend-integration)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

### Features
- ✅ Upload 1-10 images per post
- ✅ Max 5MB per image
- ✅ Supported formats: JPEG, JPG, PNG, GIF, WEBP
- ✅ Backward compatible (existing single image posts still work)
- ✅ Auto file naming with counter
- ✅ Error handling & validation
- ✅ File cleanup on error

### Tech Stack
- **Multer** - File upload handling
- **Prisma** - ORM
- **PostgreSQL** - Database with JSON support
- **Express** - REST API framework

---

## 🗄️ Database Schema

### Migration

```prisma
model Post {
  id         Int           @id @default(autoincrement())
  userId     Int
  content    String?       @db.Text
  imageUrl   String?       @db.VarChar(255)  // Legacy: first image (backward compatibility)
  imageUrls  Json?         // NEW: Array of all images
  createdAt  DateTime      @default(now())
  updatedAt  DateTime      @updatedAt
  
  user       User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  likes      PostLike[]
  comments   PostComment[]

  @@index([userId])
  @@index([createdAt])
}
```

### Run Migration

```bash
npx prisma migrate dev --name add_multiple_images_support
npx prisma generate
```

### Data Format

**Database stored JSON:**
```json
{
  "imageUrls": [
    "/uploads/posts/post-1-1766841808673-1.jpg",
    "/uploads/posts/post-1-1766841808674-2.jpg",
    "/uploads/posts/post-1-1766841808674-3.jpg"
  ]
}
```

---

## 📁 File Structure

```
mygery_BE/
├── src/
│   ├── middlewares/
│   │   └── uploadMiddleware.js          # ✅ Updated
│   ├── modules/
│   │   └── post/
│   │       ├── post.routes.js           # ✅ Updated
│   │       ├── post.controller.js       # ✅ Updated
│   │       └── post.service.js          # ✅ Updated
│   └── server.js
├── uploads/
│   ├── profiles/                        # User profile photos
│   ├── ktp/                             # KTP/ID photos
│   └── posts/                           # 📸 POST IMAGES HERE
│       ├── post-1-1766841808673-1.jpg
│       ├── post-1-1766841808674-2.jpg
│       └── post-1-1766841808674-3.jpg
├── prisma/
│   └── schema.prisma                    # ✅ Updated
└── package.json
```

---

## 🔧 Implementation Details

### 1. Upload Middleware (`uploadMiddleware.js`)

**Key Changes:**

```javascript
// NEW: Export for multiple files
export const uploadPostImages = upload.array('images', 10);

// Filename with counter
filename: (req, file, cb) => {
  if (!req.uploadCounter) {
    req.uploadCounter = 0;
  }
  req.uploadCounter++;
  
  const filename = `post-${userId}-${timestamp}-${req.uploadCounter}${ext}`;
  cb(null, filename);
}

// Limits
limits: {
  fileSize: 5 * 1024 * 1024, // 5MB per file
  files: 10                   // Max 10 files
}
```

**Error Handler:**

```javascript
export const handleUploadError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        message: 'File too large. Maximum 5MB per file'
      });
    }
    if (err.code === 'LIMIT_FILE_COUNT') {
      return res.status(400).json({
        success: false,
        message: 'Too many files. Maximum 10 images allowed'
      });
    }
  }
  next();
};
```

---

### 2. Routes (`post.routes.js`)

```javascript
import { uploadPostImages, handleUploadError } from '../../middlewares/uploadMiddleware.js';

// Create post with multiple images
router.post('/', 
  auth, 
  uploadPostImages,      // Handle multiple files
  handleUploadError,     // Handle errors
  postController.createPost
);
```

---

### 3. Controller (`post.controller.js`)

**Key Changes:**

```javascript
export const createPost = async (req, res) => {
  try {
    const userId = req.user.id;
    const { content } = req.body;
    const files = req.files || [];  // Array of uploaded files
    
    // Build imageUrls array
    let imageUrls = [];
    if (files.length > 0) {
      imageUrls = files.map(file => `/uploads/posts/${file.filename}`);
    }
    
    // Validation: content OR images must exist
    if (!content && imageUrls.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Content or images are required'
      });
    }
    
    // Create post
    const post = await postService.createPost(userId, content, imageUrls);
    
    res.status(201).json({
      success: true,
      message: 'Post created successfully',
      data: post
    });
  } catch (error) {
    // Clean up uploaded files on error
    if (req.files) {
      req.files.forEach(file => {
        try {
          fs.unlinkSync(file.path);
        } catch (err) {
          console.error('Failed to delete file:', err);
        }
      });
    }
    
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
```

**Delete Post (with cleanup):**

```javascript
export const deletePost = async (req, res) => {
  try {
    const post = await postService.getPostById(postId);
    
    // Delete multiple images
    if (post.imageUrls && Array.isArray(post.imageUrls)) {
      post.imageUrls.forEach(imageUrl => {
        const imagePath = imageUrl.replace('/uploads/', 'uploads/');
        if (fs.existsSync(imagePath)) {
          fs.unlinkSync(imagePath);
        }
      });
    }
    
    await postService.deletePost(postId);
    
    res.json({
      success: true,
      message: 'Post deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
```

---

### 4. Service (`post.service.js`)

**Create Post:**

```javascript
async createPost(userId, content, imageUrls) {
  const post = await prisma.post.create({
    data: {
      userId,
      content: content || null,
      imageUrl: imageUrls.length > 0 ? imageUrls[0] : null,  // First image (legacy)
      imageUrls: imageUrls.length > 0 ? imageUrls : null,    // All images (new)
    },
    include: {
      user: {
        select: {
          id: true,
          username: true,
          fotoProfil: true
        }
      },
      _count: {
        select: {
          likes: true,
          comments: true
        }
      }
    }
  });

  return {
    id: post.id,
    content: post.content,
    imageUrl: post.imageUrl,      // Legacy field
    imageUrls: post.imageUrls,    // NEW field
    createdAt: post.createdAt,
    updatedAt: post.updatedAt,
    user: post.user,
    likeCount: post._count.likes,
    commentCount: post._count.comments,
    likedByMe: false
  };
}
```

**Get Feed:**

```javascript
async getFeed(userId, page = 1, limit = 10) {
  const posts = await prisma.post.findMany({
    // ...query
  });

  const formattedPosts = posts.map(post => ({
    id: post.id,
    content: post.content,
    imageUrl: post.imageUrl,      // Legacy: single image
    imageUrls: post.imageUrls,    // NEW: multiple images
    user: post.user,
    likeCount: post._count.likes,
    commentCount: post._count.comments,
    likedByMe: post.likes.length > 0
  }));

  return { data: formattedPosts, meta: { page, limit, total } };
}
```

---

## 🔌 API Endpoints

### Create Post with Images

**Endpoint:** `POST /api/posts`

**Headers:**
```
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data
```

**Body (FormData):**
```
content: "Post with multiple images"
images: [file1.jpg, file2.jpg, file3.jpg]  // Max 10 files
```

**Response:**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "id": 15,
    "content": "Post with multiple images",
    "imageUrl": "/uploads/posts/post-1-1766841808673-1.jpg",
    "imageUrls": [
      "/uploads/posts/post-1-1766841808673-1.jpg",
      "/uploads/posts/post-1-1766841808674-2.jpg",
      "/uploads/posts/post-1-1766841808674-3.jpg"
    ],
    "createdAt": "2025-12-27T13:23:28.677Z",
    "user": {
      "id": 1,
      "username": "admin",
      "fotoProfil": null
    },
    "likeCount": 0,
    "commentCount": 0,
    "likedByMe": false
  }
}
```

---

### Get Feed

**Endpoint:** `GET /api/posts?page=1&limit=10`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "imageUrl": "/uploads/posts/post-1-...-1.jpg",
      "imageUrls": [
        "/uploads/posts/post-1-...-1.jpg",
        "/uploads/posts/post-1-...-2.jpg",
        "/uploads/posts/post-1-...-3.jpg"
      ]
    },
    {
      "id": 14,
      "imageUrl": "/uploads/posts/post-1-...-1.jpg",
      "imageUrls": [
        "/uploads/posts/post-1-...-1.jpg"
      ]
    },
    {
      "id": 13,
      "imageUrl": "/uploads/posts/post-12-....jpg",
      "imageUrls": null  // Old post before migration
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 15,
    "hasMore": true
  }
}
```

---

## 🧪 Testing

### Setup Test Images

```bash
# Create test folder
mkdir test-images
cd test-images

# Download test images
curl -L -o test1.jpg "https://picsum.photos/800/600?random=1"
curl -L -o test2.jpg "https://picsum.photos/800/600?random=2"
curl -L -o test3.jpg "https://picsum.photos/800/600?random=3"

# Verify
ls -lah test*.jpg
```

---

### Test 1: Login

```bash
curl -X POST http://localhost:3030/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "identifier": "admin@example.com",
    "password": "Admin123!"
  }'
```

**Save the `accessToken` from response.**

---

### Test 2: Upload Single Image

```bash
curl -X POST http://localhost:3030/api/posts \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -F "content=Test single image" \
  -F "images=@test1.jpg"
```

**Expected:** `imageUrls` with 1 element.

---

### Test 3: Upload Multiple Images

```bash
curl -X POST http://localhost:3030/api/posts \
  -H "Authorization: Bearer {YOUR_TOKEN}" \
  -F "content=Test multiple images" \
  -F "images=@test1.jpg" \
  -F "images=@test2.jpg" \
  -F "images=@test3.jpg"
```

**Expected:** `imageUrls` with 3 elements.

---

### Test 4: Get Feed

```bash
curl -X GET "http://localhost:3030/api/posts?page=1&limit=10" \
  -H "Authorization: Bearer {YOUR_TOKEN}"
```

**Expected:** Feed with both single and multiple image posts.

---

### Test 5: Verify Files

```bash
ls -lah uploads/posts/
```

**Expected:**
```
-rw-r--r--  1 user  staff  16K Dec 27 20:23 post-1-1766841808673-1.jpg
-rw-r--r--  1 user  staff  16K Dec 27 20:23 post-1-1766841808674-2.jpg
-rw-r--r--  1 user  staff  16K Dec 27 20:23 post-1-1766841808674-3.jpg
```

---

### Test 6: Access Image in Browser

```
http://localhost:3030/uploads/posts/post-1-1766841808673-1.jpg
```

**Expected:** Image displays in browser.

---

## 📱 Frontend Integration

### Flutter/Dart Example

```dart
import 'package:dio/dio.dart';

Future<void> createPostWithImages(List<String> imagePaths, String content) async {
  final dio = Dio();
  
  // Build FormData
  FormData formData = FormData.fromMap({
    'content': content,
    'images': [
      for (var path in imagePaths)
        await MultipartFile.fromFile(path, filename: path.split('/').last)
    ],
  });
  
  try {
    final response = await dio.post(
      'http://localhost:3030/api/posts',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    
    print('Post created: ${response.data}');
  } catch (e) {
    print('Error: $e');
  }
}
```

---

### JavaScript/React Example

```javascript
async function createPost(files, content) {
  const formData = new FormData();
  formData.append('content', content);
  
  // Append multiple files
  files.forEach(file => {
    formData.append('images', file);
  });
  
  const response = await fetch('http://localhost:3030/api/posts', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    },
    body: formData
  });
  
  const data = await response.json();
  console.log('Post created:', data);
}

// Usage
const files = document.querySelector('input[type="file"]').files;
createPost(Array.from(files), 'My post with images');
```

---

### Display Multiple Images (Flutter)

```dart
Widget buildPostImages(List<String> imageUrls) {
  if (imageUrls == null || imageUrls.isEmpty) {
    return SizedBox.shrink();
  }
  
  return SizedBox(
    height: 300,
    child: PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Image.network(
          'http://localhost:3030${imageUrls[index]}',
          fit: BoxFit.cover,
        );
      },
    ),
  );
}
```

---

## 🐛 Troubleshooting

### Issue 1: Files Upload but 0 Bytes

**Symptoms:**
```bash
-rw-r--r--  1 user  staff  0B  post-1-xxx-1.jpg
```

**Solution:**
```bash
# Check test images size
ls -lah test*.jpg

# If 0B, re-download:
rm test*.jpg
curl -L -o test1.jpg "https://picsum.photos/800/600?random=1"
```

---

### Issue 2: "File too large" Error

**Response:**
```json
{
  "success": false,
  "message": "File too large. Maximum 5MB per file"
}
```

**Solution:**
- Compress images before upload
- Or increase limit in `uploadMiddleware.js`:
```javascript
limits: {
  fileSize: 10 * 1024 * 1024, // Increase to 10MB
}
```

---

### Issue 3: "Too many files" Error

**Response:**
```json
{
  "success": false,
  "message": "Too many files. Maximum 10 images allowed"
}
```

**Solution:**
- Upload max 10 images
- Or increase limit in `uploadMiddleware.js`:
```javascript
export const uploadPostImages = upload.array('images', 15); // Increase to 15
```

---

### Issue 4: Old Posts Show `imageUrls: null`

**This is normal!** Old posts created before migration don't have `imageUrls`.

**Frontend handling:**
```dart
List<String> getImageUrls(Post post) {
  // Use imageUrls if available (new posts)
  if (post.imageUrls != null && post.imageUrls.isNotEmpty) {
    return post.imageUrls;
  }
  
  // Fallback to single imageUrl (old posts)
  if (post.imageUrl != null) {
    return [post.imageUrl];
  }
  
  return [];
}
```

---

### Issue 5: 404 on Image Access

**Check:**
1. File exists: `ls uploads/posts/`
2. Static file serving enabled in `server.js`:
```javascript
app.use('/uploads', express.static('uploads'));
```

---

## 📊 Performance Considerations

### File Size Limits
- **Current:** 5MB per file, 10 files max = 50MB total
- **Recommendation:** Add file compression on frontend before upload

### Database
- JSON field `imageUrls` is efficient for queries
- Index on `createdAt` for feed performance

### Storage
- Consider CDN for production (AWS S3, Cloudinary, etc.)
- Implement image optimization (resize, WebP conversion)

---

## 🔐 Security Considerations

### File Validation
- ✅ File type validation (JPEG, PNG, GIF, WEBP only)
- ✅ File size limit (5MB)
- ✅ File count limit (10 files)
- ✅ Sanitized filenames (no user input in filename)

### Authentication
- ✅ JWT token required for upload
- ✅ Only post owner can delete

### File Cleanup
- ✅ Cleanup on upload error
- ✅ Cleanup on post deletion

---

## 📝 Migration Notes

### Backward Compatibility

✅ **Old posts still work!**
- Posts with `imageUrl` (single image) display correctly
- Posts with `imageUrls: null` handled gracefully
- No data migration needed for existing posts

### Data Flow

```
Frontend                Backend              Database
--------                -------              --------
images[] ──────────▶ files[] ──────────▶ imageUrls: JSON
                        │
                        └──────────────▶ imageUrl: string (first image)
```

---

## ✅ Checklist

- [x] Database schema updated
- [x] Migration applied
- [x] Upload middleware updated
- [x] Routes configured
- [x] Controller handles multiple files
- [x] Service saves to database
- [x] Error handling implemented
- [x] File cleanup on error
- [x] Testing completed
- [x] Documentation created

---

## 🚀 Deployment

### Environment Variables

No additional env vars needed. Existing setup works.

### Build & Deploy

```bash
# Install dependencies
npm install

# Run migration
npx prisma migrate deploy

# Generate Prisma Client
npx prisma generate

# Start production
npm start
```

---

## 📞 Support

**Questions?** Contact backend team or create issue in repository.

**Date:** 27 Desember 2025  
**Version:** 1.0.0  
**Status:** ✅ Production Ready

---

*Happy Coding! 🎉*