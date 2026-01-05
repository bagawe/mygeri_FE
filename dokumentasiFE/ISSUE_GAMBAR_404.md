# ⚠️ ISSUE: Gambar Post Tidak Dapat Dimuat (404 Error)

## 📋 Ringkasan Masalah
Gambar yang di-upload saat membuat post berhasil ter-upload ke backend, tetapi ketika frontend mencoba memuat gambar tersebut, muncul error **404 Not Found**.

## 🔍 Detail Error

### Log dari Flutter
```
✅ PostService: Retrieved 10 posts
🖼️ Loading image URL: http://10.0.2.2:3030/uploads/posts/profil-12-1766836929466-756387548.jpg
🖼️ Original imageUrl: /uploads/posts/profil-12-1766836929466-756387548.jpg
❌ Image failed to load: HTTP request failed, statusCode: 404
```

### Status
- ✅ Upload gambar berhasil (frontend dapat mengirim file)
- ✅ Backend mengembalikan `imageUrl` di response
- ❌ File gambar tidak dapat diakses via HTTP (404)

## 🎯 Yang Perlu Dicek di Backend

### 1. Folder `uploads/posts/` Ada dan Writable
```bash
# Cek apakah folder ada
ls -la uploads/posts/

# Jika tidak ada, buat folder
mkdir -p uploads/posts
chmod 755 uploads/posts
```

### 2. File Gambar Benar-benar Tersimpan
```bash
# Cek isi folder uploads/posts
ls -la uploads/posts/

# Cek apakah file dengan nama yang sama ada
# Contoh: profil-12-1766836929466-756387548.jpg
```

### 3. Static File Serving Dikonfigurasi dengan Benar

#### Jika menggunakan Express.js:
```javascript
const express = require('express');
const path = require('path');
const app = express();

// Serve static files dari folder uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Atau dengan opsi lengkap:
app.use('/uploads', express.static('uploads', {
  maxAge: '1d',
  etag: true,
  lastModified: true
}));
```

#### Jika menggunakan Fastify:
```javascript
const fastify = require('fastify')();
const path = require('path');

// Register static plugin
fastify.register(require('@fastify/static'), {
  root: path.join(__dirname, 'uploads'),
  prefix: '/uploads/'
});
```

#### Jika menggunakan NestJS:
```typescript
// main.ts
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  
  // Serve static files
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });
  
  await app.listen(3030);
}
bootstrap();
```

### 4. Cek Konfigurasi Multer (File Upload Middleware)

```javascript
const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    // Pastikan path ini benar dan folder ada
    cb(null, 'uploads/posts/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const originalName = file.originalname.replace(/\s+/g, '-');
    cb(null, file.fieldname + '-' + req.user.id + '-' + uniqueSuffix + path.extname(originalName));
  }
});

const upload = multer({ 
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});
```

### 5. Response API Mengembalikan Path yang Benar

```javascript
// Contoh response setelah upload
res.json({
  success: true,
  message: 'Post created successfully',
  data: {
    id: post.id,
    content: post.content,
    imageUrl: '/uploads/posts/profil-12-1766836929466-756387548.jpg', // ✅ Harus dengan /
    // BUKAN: 'uploads/posts/...' (tanpa slash di awal)
    // BUKAN: '/path/to/server/uploads/...' (path absolut server)
    createdAt: post.createdAt,
    user: { ... }
  }
});
```

## 🧪 Cara Testing

### 1. Test Upload File
```bash
curl -X POST http://localhost:3030/api/posts \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/test.jpg" \
  -F "content=Test post"
```

### 2. Test Akses File Langsung
```bash
# Setelah upload, copy imageUrl dari response
# Contoh: /uploads/posts/profil-12-1766836929466-756387548.jpg

# Test akses dengan curl
curl -I http://localhost:3030/uploads/posts/profil-12-1766836929466-756387548.jpg

# Seharusnya return:
# HTTP/1.1 200 OK
# Content-Type: image/jpeg
```

### 3. Test dari Browser
Buka di browser:
```
http://localhost:3030/uploads/posts/profil-12-1766836929466-756387548.jpg
```

Seharusnya gambar langsung tampil, BUKAN 404.

## ✅ Checklist untuk Backend Developer

- [ ] Folder `uploads/posts/` sudah dibuat
- [ ] Folder memiliki permission yang benar (755)
- [ ] Static file middleware sudah dikonfigurasi
- [ ] File benar-benar tersimpan saat upload
- [ ] Path di response API benar (dimulai dengan `/uploads/...`)
- [ ] Test akses file langsung via browser berhasil (200 OK)
- [ ] CORS dikonfigurasi untuk mengizinkan akses gambar

## 🔧 Solusi Cepat (Quick Fix)

### Jika menggunakan Express.js:
```javascript
// Di file server utama (misal: index.js, server.js, atau app.js)

const express = require('express');
const path = require('path');
const app = express();

// TAMBAHKAN BARIS INI sebelum route definitions
app.use('/uploads', express.static('uploads'));

// Pastikan folder uploads/posts/ ada
const fs = require('fs');
const uploadDir = path.join(__dirname, 'uploads/posts');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// ... rest of your code
```

## 📸 Screenshot Error dari Frontend
![Error 404](../dokumentasiFE/screenshots/image-404-error.png)

Log menunjukkan:
- URL: `http://10.0.2.2:3030/uploads/posts/profil-12-1766836929466-756387548.jpg`
- Status: `404 Not Found`
- Original path dari backend: `/uploads/posts/profil-12-1766836929466-756387548.jpg`

## 🆘 Jika Masih Gagal

1. **Restart server backend** setelah menambahkan konfigurasi static files
2. **Cek console/log backend** saat upload file untuk memastikan tidak ada error
3. **Cek permission folder** dengan `ls -la uploads/posts/`
4. **Test langsung di browser** dengan URL: `http://localhost:3030/uploads/posts/[filename].jpg`

---

**Update:** 27 Desember 2025
**Status:** 🔴 BLOCKING - Fitur posting tidak dapat digunakan sepenuhnya sampai gambar dapat ditampilkan
**Priority:** HIGH
**Assigned to:** Backend Team
