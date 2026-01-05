# 📚 API RIWAYAT AKTIVITAS (USER HISTORY) - MyGeri

**Tanggal:** 24 Desember 2025  
**Status:** ✅ IMPLEMENTED & TESTED  
**Backend Version:** 1.0.0

---

## 1. OVERVIEW

Fitur ini mencatat dan menampilkan riwayat aktivitas penting user di aplikasi:
- Login
- Logout
- Buka aplikasi
- Edit profil
- Pencarian user

---

## 2. ENDPOINTS

### 2.1. Catat Riwayat

**Endpoint:** `POST /api/history`

**Headers:**
- Authorization: Bearer {accessToken}
- Content-Type: application/json

**Request Body:**
```json
{
  "type": "login", // "logout", "open_app", "edit_profile", "search_user"
  "description": "Login berhasil dari device Android",
  "metadata": {
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

**Validasi:**
- `type` wajib, hanya enum: `login`, `logout`, `open_app`, `edit_profile`, `search_user`
- `description` opsional
- `metadata` opsional (bisa null/object)

---

### 2.2. Ambil Riwayat User

**Endpoint:** `GET /api/history?limit=50&page=1`

**Headers:**
- Authorization: Bearer {accessToken}

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

**Catatan:**
- Hanya riwayat milik user yang sedang login yang bisa diambil
- Pagination: `limit` (default 50), `page` (default 1)
- Data diurutkan terbaru → terlama

---

## 3. ENUM TYPE YANG DIDUKUNG

```js
login | logout | open_app | edit_profile | search_user
```

Jika ingin menambah type baru, cukup minta ke backend (tinggal tambah di enum).

---

## 4. FLUTTER INTEGRATION EXAMPLE

### 4.1. Catat Riwayat
```dart
Future<void> logHistory(String type, {String? description, Map<String, dynamic>? metadata}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final response = await http.post(
    Uri.parse('http://localhost:3030/api/history'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'type': type,
      if (description != null) 'description': description,
      if (metadata != null) 'metadata': metadata,
    }),
  );
  if (response.statusCode != 201) {
    throw Exception('Gagal mencatat riwayat');
  }
}
```

### 4.2. Ambil Riwayat User
```dart
Future<List<UserHistory>> getHistory({int page = 1, int limit = 50}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('accessToken');
  final response = await http.get(
    Uri.parse('http://localhost:3030/api/history?page=$page&limit=$limit'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((e) => UserHistory.fromJson(e))
        .toList();
  } else {
    throw Exception('Gagal mengambil riwayat');
  }
}

class UserHistory {
  final int id;
  final String type;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  UserHistory({
    required this.id,
    required this.type,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  factory UserHistory.fromJson(Map<String, dynamic> json) {
    return UserHistory(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
```

---

## 5. TESTING CHECKLIST

- [x] Riwayat tercatat setiap aksi (login, logout, open app, edit profil, search user)
- [x] GET riwayat hanya mengembalikan milik user yang sedang login
- [x] Pagination berjalan
- [x] Data metadata bisa null/tidak
- [x] Validasi type enum

---

## 6. CATATAN

- Jika ingin menambah type baru, cukup minta ke backend
- Data diurutkan terbaru → terlama
- Metadata bisa null/object
- Hanya user sendiri yang bisa akses riwayatnya

---

**Dokumen dibuat:** 24 Desember 2025  
**Backend Developer:** AI Assistant  
**Status:** IMPLEMENTED & TESTED
