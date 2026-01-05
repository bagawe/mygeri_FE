# Analisis & Kebutuhan Fitur Posting (Feed) MyGeri

## 1. Deskripsi Fitur
Fitur posting (feed) memungkinkan user membuat postingan berupa teks dan/atau gambar dengan keterangan. Postingan dapat dilihat, di-like, dan dikomentari oleh user lain (kecuali yang diblokir). Feed menampilkan postingan terbaru dari setiap user.

## 2. Kebutuhan Backend
### a. Model/Database
- **Tabel posts**
  - id (PK)
  - user_id (FK ke users)
  - content (text, optional)
  - image_url (string, optional)
  - created_at (datetime)
  - updated_at (datetime)
- **Tabel post_likes**
  - id (PK)
  - post_id (FK ke posts)
  - user_id (FK ke users)
  - created_at (datetime)
- **Tabel post_comments**
  - id (PK)
  - post_id (FK ke posts)
  - user_id (FK ke users)
  - comment (text)
  - created_at (datetime)
- **Relasi blokir**
  - Pastikan user yang diblokir tidak bisa melihat/melakukan aksi pada postingan user yang memblokir.

### b. Endpoint REST API
- `POST /api/posts` — Membuat postingan baru (text/gambar)
- `GET /api/posts` — Mendapatkan feed postingan terbaru (dengan filter blokir)
- `GET /api/posts/:id` — Mendapatkan detail postingan
- `POST /api/posts/:id/like` — Like/unlike postingan
- `POST /api/posts/:id/comment` — Menambah komentar
- `GET /api/posts/:id/comments` — List komentar pada postingan
- `DELETE /api/posts/:id` — Hapus postingan (hanya owner)
- `DELETE /api/posts/:id/comment/:commentId` — Hapus komentar (hanya owner/author)

### c. Fitur & Validasi
- Hanya user login yang bisa membuat, like, dan komen.
- Tidak bisa like/komen postingan user yang memblokir atau diblokir.
- Feed hanya menampilkan postingan user yang tidak saling blokir.
- Mendukung upload gambar (gunakan multipart/form-data).
- Pagination pada feed dan komentar.
- Like hanya bisa sekali per user per post (toggle like/unlike).

## 3. Kebutuhan Frontend
- Halaman feed: tampilkan postingan terbaru, nama user, foto profil, isi, gambar, jumlah like, jumlah komentar, tombol like & komentar.
- Halaman buat postingan: form text, upload gambar opsional.
- Halaman detail postingan: lihat postingan, semua komentar, tambah komentar.
- Fitur like/unlike, tambah komentar, hapus postingan/komentar (jika owner).
- Validasi blokir: tidak tampil jika diblokir.

## 4. Kebutuhan Lain
- Dokumentasi API untuk integrasi frontend-backend.
- Penanganan error & validasi input.

---

**Catatan:**
- Pastikan endpoint dan response konsisten dengan standar REST.
- Gunakan autentikasi JWT/token untuk semua aksi user.
- Siapkan endpoint upload gambar jika belum ada.
