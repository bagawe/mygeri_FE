# 🔧 Backend Requirements: Multiple Images Upload

**Request dari:** Frontend Team  
**Tanggal:** 27 Desember 2025  
**Priority:** Medium (Enhancement)  
**Status:** Planning Phase

---

## 📋 Overview

Saat ini posting hanya support **1 gambar** per post. Request untuk support **multiple images** (seperti Instagram carousel).

---

## 🎯 Requirements

### **1. Database Schema Change**

#### **Option A: JSON Array (Recommended for modern DB)**
```sql
-- Ubah column imageUrl jadi JSON array
ALTER TABLE posts 
MODIFY COLUMN imageUrl JSON;

-- Atau rename untuk clarity:
ALTER TABLE posts 
CHANGE COLUMN imageUrl imageUrls JSON;
```

**Data format:**
```json
{
  "id": 123,
  "content": "Post with images",
  "imageUrls": [
    "/uploads/posts/post-12-1234567890-1.jpg",
    "/uploads/posts/post-12-1234567890-2.jpg",
    "/uploads/posts/post-12-1234567890-3.jpg"
  ]
}
```

#### **Option B: Separate Table (Traditional)**
```sql
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

**Which option?** → Terserah backend team, frontend bisa handle keduanya.

---

### **2. API Changes**

#### **A. POST /api/posts - Upload Multiple Images**

**Current:**
```javascript
upload.single('image')  // 1 image only
```

**Required:**
```javascript
upload.array('images', 10)  // Support up to 10 images
```

**Request:**
```
POST /api/posts
Content-Type: multipart/form-data
Authorization: Bearer {token}

Fields:
- content: "Post text" (optional if images exist)
- images: [File, File, File] (array of files, max 10)
```

**Response (Success):**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "id": 123,
    "content": "Check out these photos!",
    "imageUrls": [
      "/uploads/posts/post-12-1735300800000-1.jpg",
      "/uploads/posts/post-12-1735300800000-2.jpg",
      "/uploads/posts/post-12-1735300800000-3.jpg"
    ],
    "user": {
      "id": 12,
      "username": "yayat123",
      "fotoProfil": null
    },
    "likeCount": 0,
    "commentCount": 0,
    "likedByMe": false,
    "createdAt": "2025-12-27T12:00:00.000Z",
    "updatedAt": "2025-12-27T12:00:00.000Z"
  }
}
```

**Response (Error - No content):**
```json
{
  "success": false,
  "message": "Content or images required"
}
```

**Response (Error - Too many files):**
```json
{
  "success": false,
  "message": "Maximum 10 images allowed"
}
```

---

#### **B. GET /api/posts - Return Multiple Images**

**Current Response:**
```json
{
  "id": 123,
  "imageUrl": "/uploads/posts/post-12-123.jpg"  // Single string
}
```

**Required Response:**
```json
{
  "id": 123,
  "imageUrls": [  // Array of strings
    "/uploads/posts/post-12-123-1.jpg",
    "/uploads/posts/post-12-123-2.jpg"
  ]
}
```

**Untuk backward compatibility, bisa return both:**
```json
{
  "id": 123,
  "imageUrl": "/uploads/posts/post-12-123-1.jpg",  // First image (legacy)
  "imageUrls": [  // All images (new)
    "/uploads/posts/post-12-123-1.jpg",
    "/uploads/posts/post-12-123-2.jpg"
  ]
}
```

---

### **3. File Handling**

#### **Filename Convention:**
```
post-{userId}-{timestamp}-{index}.{ext}

Examples:
- post-12-1735300800000-1.jpg
- post-12-1735300800000-2.jpg
- post-12-1735300800000-3.jpg
```

#### **File Size & Type:**
```javascript
{
  fileSize: 5 * 1024 * 1024, // 5MB per file
  maxFiles: 10,               // Max 10 files per post
  allowedTypes: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
}
```

#### **Storage:**
- Path: `uploads/posts/`
- Auto-create folder if not exist
- Permission: 755

---

### **4. Validation Rules**

```javascript
// Post validation
{
  content: {
    type: String,
    minLength: 0,
    maxLength: 5000,
    optional: true  // Can be empty if images exist
  },
  images: {
    type: Array,
    minFiles: 0,    // Can post text-only
    maxFiles: 10,   // Max 10 images
    optional: true  // Can be empty if content exists
  }
}

// At least one must exist
if (!content && !images.length) {
  throw new Error('Content or images required');
}
```

---

## 📝 Implementation Example (Express.js)

```javascript
const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer for multiple files
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadDir = 'uploads/posts';
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true });
    }
    cb(null, uploadDir);
  },
  filename: (req, file, cb) => {
    const userId = req.user.id;
    const timestamp = Date.now();
    const ext = path.extname(file.originalname);
    
    // Get current index (how many files already uploaded in this request)
    const index = req.fileIndex || 1;
    req.fileIndex = index + 1;
    
    cb(null, `post-${userId}-${timestamp}-${index}${ext}`);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB per file
    files: 10 // Max 10 files
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, WEBP allowed'));
    }
  }
});

// POST endpoint
router.post('/posts', 
  authenticate, 
  upload.array('images', 10), // Accept up to 10 files
  async (req, res) => {
    try {
      const { content } = req.body;
      const files = req.files || [];
      
      // Validation: at least content or images
      if (!content && files.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Content or images required'
        });
      }
      
      // Build image URLs array
      const imageUrls = files.map(file => `/uploads/posts/${file.filename}`);
      
      // Save to database
      const post = await Post.create({
        userId: req.user.id,
        content: content || null,
        imageUrls: JSON.stringify(imageUrls), // or save to separate table
        createdAt: new Date(),
        updatedAt: new Date()
      });
      
      // Fetch with relations
      const postWithRelations = await Post.findByPk(post.id, {
        include: [
          { model: User, attributes: ['id', 'username', 'fotoProfil'] },
          // If using separate table:
          // { model: PostImage, attributes: ['imageUrl', 'orderIndex'] }
        ]
      });
      
      // Format response
      const response = {
        id: postWithRelations.id,
        content: postWithRelations.content,
        imageUrls: JSON.parse(postWithRelations.imageUrls), // or map from PostImage
        user: postWithRelations.User,
        likeCount: 0,
        commentCount: 0,
        likedByMe: false,
        createdAt: postWithRelations.createdAt,
        updatedAt: postWithRelations.updatedAt
      };
      
      res.status(201).json({
        success: true,
        message: 'Post created successfully',
        data: response
      });
      
    } catch (error) {
      console.error('Create post error:', error);
      
      // Clean up uploaded files on error
      if (req.files) {
        req.files.forEach(file => {
          fs.unlinkSync(file.path);
        });
      }
      
      res.status(500).json({
        success: false,
        message: error.message || 'Failed to create post'
      });
    }
  }
);

// GET endpoint - update response format
router.get('/posts', authenticate, async (req, res) => {
  try {
    const posts = await Post.findAll({
      include: [{ model: User }],
      order: [['createdAt', 'DESC']]
    });
    
    // Format response with imageUrls array
    const formattedPosts = posts.map(post => ({
      id: post.id,
      content: post.content,
      imageUrls: post.imageUrls ? JSON.parse(post.imageUrls) : [],
      // For backward compatibility (optional):
      imageUrl: post.imageUrls ? JSON.parse(post.imageUrls)[0] : null,
      user: post.User,
      likeCount: post.likeCount,
      commentCount: post.commentCount,
      likedByMe: post.checkIfLiked(req.user.id),
      createdAt: post.createdAt,
      updatedAt: post.updatedAt
    }));
    
    res.json({
      success: true,
      data: formattedPosts
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});
```

---

## 🧪 Testing

### **Test Cases:**

1. **Single image upload** (backward compatibility)
   ```bash
   curl -X POST http://localhost:3030/api/posts \
     -H "Authorization: Bearer TOKEN" \
     -F "content=Test with 1 image" \
     -F "images=@image1.jpg"
   ```

2. **Multiple images upload**
   ```bash
   curl -X POST http://localhost:3030/api/posts \
     -H "Authorization: Bearer TOKEN" \
     -F "content=Test with 3 images" \
     -F "images=@image1.jpg" \
     -F "images=@image2.jpg" \
     -F "images=@image3.jpg"
   ```

3. **Max limit test** (should accept 10, reject 11)
   ```bash
   # Upload 11 images - should fail
   curl -X POST http://localhost:3030/api/posts \
     -H "Authorization: Bearer TOKEN" \
     -F "images=@img1.jpg" \
     -F "images=@img2.jpg" \
     ... (11 files)
   ```

4. **Images only (no content)**
   ```bash
   curl -X POST http://localhost:3030/api/posts \
     -H "Authorization: Bearer TOKEN" \
     -F "images=@image1.jpg"
   ```

5. **Content only (no images)** - should still work
   ```bash
   curl -X POST http://localhost:3030/api/posts \
     -H "Authorization: Bearer TOKEN" \
     -F "content=Text only post"
   ```

---

## ✅ Checklist

- [ ] Database schema updated (imageUrl → imageUrls)
- [ ] Multer configured for array upload (`upload.array()`)
- [ ] File naming with index (post-12-123-1.jpg, post-12-123-2.jpg)
- [ ] Validation: max 10 images, 5MB per file
- [ ] POST /api/posts returns `imageUrls` array
- [ ] GET /api/posts returns `imageUrls` array
- [ ] Error handling (too many files, file too large)
- [ ] Cleanup files on error
- [ ] Static file serving working for all images
- [ ] Tested with 1, 5, 10 images
- [ ] Tested with images only (no content)
- [ ] Tested with content only (no images)

---

## 📞 Questions?

**Contact Frontend Team:** @frontend-dev

**Expected Timeline:**
- Backend implementation: 2-3 hari
- Frontend implementation: 1 hari (after backend ready)
- Testing: 1 hari

**Total:** ~1 minggu

---

## 🔄 Migration Strategy

### **Phase 1: Database Migration**
```sql
-- Add new column
ALTER TABLE posts ADD COLUMN imageUrls JSON;

-- Migrate existing data
UPDATE posts 
SET imageUrls = JSON_ARRAY(imageUrl) 
WHERE imageUrl IS NOT NULL;

-- Optional: Keep old column for rollback
-- Or drop it after migration verified:
-- ALTER TABLE posts DROP COLUMN imageUrl;
```

### **Phase 2: API Update**
- Update POST endpoint
- Update GET endpoint
- Keep backward compatibility (return both fields temporarily)

### **Phase 3: Testing**
- Test all scenarios
- Verify old posts still display
- Verify new posts with multiple images work

### **Phase 4: Frontend Update**
- Update Flutter app after backend stable
- Deploy to production

---

**Priority:** Medium  
**Complexity:** Medium  
**Impact:** High (Better UX, feature parity with social media apps)

---

**Prepared by:** Frontend Team  
**Date:** 27 December 2025  
**Document Version:** 1.0
