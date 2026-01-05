# Analisis & Spesifikasi Fitur Riwayat Aktivitas (History Tab)

**Tanggal:** 24 Desember 2025  
**Aplikasi:** MyGeri  
**Fitur:** Riwayat Aktivitas User (Login, Logout, Buka Aplikasi, Edit Profil, Pencarian User)

---

## 1. OVERVIEW FITUR

Fitur riwayat (history) mencatat semua aktivitas penting user di aplikasi, seperti:
- **Masuk (Login)**
- **Keluar (Logout)**
- **Buka aplikasi** (open app/foreground)
- **Edit profil**
- **Pencarian user** (search)

Fitur ini akan dikembangkan bertahap, riwayat lain bisa ditambah sesuai kebutuhan aplikasi ke depan.

---

## 2. USER FLOW

1. User melakukan aksi (login, logout, buka app, edit profil, search user)
2. Sistem backend mencatat aksi tersebut ke tabel riwayat
3. User dapat melihat daftar riwayat di tab "Riwayat" pada aplikasi

---

## 3. KEBUTUHAN BACKEND API

### 3.1. Endpoint Catat Riwayat

**Endpoint:** `POST /api/history`

**Request Body:**
```json
{
  "type": "login", // atau "logout", "open_app", "edit_profile", "search_user"
  "description": "Login berhasil dari device Android",
  "metadata": { // opsional, bisa null
    "device": "Android",
    "ip": "192.168.1.10"
  }
}
```

**Response Success (201):**
```json
{
  "success": true,
  "data": {
    "id": 123,
    "userId": 5,
    "type": "login",
    "description": "Login berhasil dari device Android",
    "metadata": { "device": "Android", "ip": "192.168.1.10" },
    "createdAt": "2025-12-24T10:30:00.000Z"
  }
}
```

### 3.2. Endpoint Ambil Riwayat User

**Endpoint:** `GET /api/history?limit=50&page=1`

**Response Success (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "type": "login",
      "description": "Login berhasil dari device Android",
      "metadata": { "device": "Android", "ip": "192.168.1.10" },
      "createdAt": "2025-12-24T10:30:00.000Z"
    },
    {
      "id": 124,
      "type": "edit_profile",
      "description": "Edit nama dan foto profil",
      "metadata": null,
      "createdAt": "2025-12-24T10:35:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 50,
    "total": 2,
    "hasMore": false
  }
}
```

---

## 4. DATABASE SCHEMA (SARAN)

### 4.1. Table: user_history

```sql
CREATE TABLE user_history (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(32) NOT NULL, -- login, logout, open_app, edit_profile, search_user, dst
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_user_history_user ON user_history(user_id);
CREATE INDEX idx_user_history_type ON user_history(type);
CREATE INDEX idx_user_history_created_at ON user_history(created_at DESC);
```

---

## 5. SECURITY & VALIDATION

- Hanya user yang sedang login bisa akses/melihat riwayat miliknya sendiri
- Input type harus valid (gunakan enum di backend)
- Metadata boleh null/opsional
- Pagination pada endpoint GET

---

## 6. TESTING CHECKLIST

- [ ] Riwayat tercatat setiap aksi (login, logout, open app, edit profil, search user)
- [ ] GET riwayat hanya mengembalikan milik user yang sedang login
- [ ] Pagination berjalan
- [ ] Data metadata bisa null/tidak
- [ ] Tidak ada duplikasi riwayat untuk aksi yang sama dalam waktu sangat singkat (opsional debounce di backend)

---

## 7. CATATAN PENTING

- Riwayat lain bisa ditambah dengan type baru (misal: kirim pesan, hapus akun, dsb)
- Frontend akan menampilkan riwayat dengan format waktu yang ramah user
- Backend bisa menambah kolom/fitur sesuai kebutuhan ke depan

---

**Dokumen ini siap diberikan ke Backend Developer untuk implementasi API riwayat.**
