# Analisis & Spesifikasi Fitur Messaging System

**Tanggal**: 24 Desember 2025  
**Aplikasi**: MyGeri  
**Fitur**: Real-time Messaging dengan User Search  
**Status**: ✅ **IMPLEMENTED & TESTED**

---

## 1. OVERVIEW FITUR

Fitur messaging memungkinkan user untuk:
- **Mencari user lain** berdasarkan username/nama
- **Memulai percakapan baru** dengan user yang dipilih
- **Mengirim dan menerima pesan** real-time
- **Melihat daftar percakapan** yang sudah ada
- **Melihat status pesan** (terkirim, dibaca)
- **Notifikasi pesan baru**

---

## 2. USER FLOW

```
1. User klik icon "Add Message" (💬+) di AppBar PesanPa## 11. TESTING CHECKLIST

### Backend: ✅ A## 12. PRIORITAS IMPLEMENTASI

### Phase 1 (MVP): ✅ COMPLETE
1. ✅ User search API (dengan block filter) - TESTED
2. ✅ Get/Create conversation API - TESTED
3. ✅ Get conversations list API - TESTED
4. ✅ Get messages API - TESTED
5. ✅ Send message API - TESTED
6. ✅ Block/Unblock user APIs - TESTED
7. ✅ Frontend implementation - READY (Documentation provided)- [x] User search returns correct results
- [x] User search excludes current user
- [x] User search excludes blocked users
- [x] Cannot create duplicate conversations
- [x] Messages are ordered by timestamp
- [x] Mark as read updates unread count
- [x] Block user works correctly
- [x] Unblock user works correctly
- [x] Cannot send message to blocked user
- [x] Blocked users don't appear in search
- [x] Authorization checks work correctlyUP/MODAL "Cari Pengguna" muncul
   ↓
3. User ketik username di search bar
   ↓
4. Sistem tampilkan hasil pencarian (real-time)
   ↓
5. User klik salah satu user dari hasil pencarian
   ↓
6. POPUP DETAIL USER muncul, menampilkan:
   - Foto profil
   - Nama lengkap
   - Username
   - Tombol icon CHAT (💬)
   - Tombol BLOK (🚫)
   ↓
7. User pilih aksi:
   A. Klik tombol CHAT:
      - Sistem cek: apakah sudah ada conversation?
        * Jika YA: Buka conversation yang sudah ada
        * Jika TIDAK: Buat conversation baru
      - User masuk ke ChatPage
      - User bisa kirim pesan langsung
   
   B. Klik tombol BLOK:
      - Sistem simpan user ke blocked list
      - User tersebut tidak bisa kirim pesan ke kita
      - Kita tidak bisa kirim pesan ke user tersebut
      - Popup tertutup
```

---

## 3. KEBUTUHAN BACKEND API

### 3.1. Search Users API

**Catatan**: API ini harus **exclude user yang sudah diblok** oleh current user

**Endpoint**: `GET /api/users/search`

**Query Parameters**:
- `q` (required): String - keyword pencarian (username/nama)
- `limit` (optional): Number - maksimal hasil (default: 20)
- `excludeSelf` (optional): Boolean - exclude current user (default: true)

**Request Example**:
```http
GET /api/users/search?q=rina&limit=10
Authorization: Bearer {accessToken}
```

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "uuid": "16409e46-5ed8-4b56-bc03-fdbf9244a833",
      "username": "rinawati",
      "name": "Rina Wati",
      "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg",
      "email": "rina.wati@example.com",
      "bio": "Kader aktif di Kelurahan X"
    },
    {
      "id": 8,
      "username": "rinaputri",
      "name": "Rina Putri",
      "fotoProfil": null,
      "email": "rina.putri@example.com",
      "bio": null
    }
  ],
  "meta": {
    "total": 2,
    "limit": 10
  }
}
```

**Response Error** (400):
```json
{
  "success": false,
  "message": "Query parameter 'q' is required"
}
```

---

### 3.2. Get/Create Conversation API

**Endpoint**: `POST /api/conversations/get-or-create`

**Purpose**: Mendapatkan conversation yang sudah ada ATAU membuat baru jika belum ada

**Request Body**:
```json
{
  "participantId": 5
}
```

**Response Success** (200 - existing conversation):
```json
{
  "success": true,
  "data": {
    "id": 12,
    "uuid": "conv-uuid-123",
    "participants": [
      {
        "id": 3,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/profiles/profil-3-xxx.jpg"
      },
      {
        "id": 5,
        "username": "rinawati",
        "name": "Rina Wati",
        "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg"
      }
    ],
    "lastMessage": {
      "id": 45,
      "senderId": 5,
      "content": "Halo, apa kabar?",
      "createdAt": "2025-12-24T10:30:00.000Z",
      "isRead": false
    },
    "unreadCount": 2,
    "createdAt": "2025-12-20T08:00:00.000Z",
    "updatedAt": "2025-12-24T10:30:00.000Z"
  },
  "meta": {
    "isNew": false
  }
}
```

**Response Success** (201 - new conversation):
```json
{
  "success": true,
  "data": {
    "id": 15,
    "uuid": "conv-uuid-456",
    "participants": [
      {
        "id": 3,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/profiles/profil-3-xxx.jpg"
      },
      {
        "id": 5,
        "username": "rinawati",
        "name": "Rina Wati",
        "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg"
      }
    ],
    "lastMessage": null,
    "unreadCount": 0,
    "createdAt": "2025-12-24T11:00:00.000Z",
    "updatedAt": "2025-12-24T11:00:00.000Z"
  },
  "meta": {
    "isNew": true
  }
}
```

---

### 3.3. Get Conversations List API

**Endpoint**: `GET /api/conversations`

**Query Parameters**:
- `page` (optional): Number - halaman (default: 1)
- `limit` (optional): Number - items per page (default: 20)

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 12,
      "uuid": "conv-uuid-123",
      "otherParticipant": {
        "id": 5,
        "username": "rinawati",
        "name": "Rina Wati",
        "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg"
      },
      "lastMessage": {
        "id": 45,
        "senderId": 5,
        "senderName": "Rina Wati",
        "content": "Halo, apa kabar?",
        "createdAt": "2025-12-24T10:30:00.000Z",
        "isRead": false
      },
      "unreadCount": 2,
      "updatedAt": "2025-12-24T10:30:00.000Z"
    },
    {
      "id": 10,
      "uuid": "conv-uuid-789",
      "otherParticipant": {
        "id": 8,
        "username": "agussetiawan",
        "name": "Agus Setiawan",
        "fotoProfil": null
      },
      "lastMessage": {
        "id": 40,
        "senderId": 3,
        "senderName": "John Doe",
        "content": "Terima kasih atas informasinya",
        "createdAt": "2025-12-24T08:15:00.000Z",
        "isRead": true
      },
      "unreadCount": 0,
      "updatedAt": "2025-12-24T08:15:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 2,
    "hasMore": false
  }
}
```

---

### 3.4. Get Messages API

**Endpoint**: `GET /api/conversations/:conversationId/messages`

**Query Parameters**:
- `page` (optional): Number - halaman (default: 1)
- `limit` (optional): Number - messages per page (default: 50)
- `before` (optional): String - message ID, ambil pesan sebelum ID ini (untuk pagination)

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 45,
      "conversationId": 12,
      "senderId": 5,
      "senderName": "Rina Wati",
      "senderPhoto": "/uploads/profiles/profil-5-xxx.jpg",
      "content": "Halo, apa kabar?",
      "isRead": false,
      "createdAt": "2025-12-24T10:30:00.000Z",
      "updatedAt": "2025-12-24T10:30:00.000Z"
    },
    {
      "id": 44,
      "conversationId": 12,
      "senderId": 3,
      "senderName": "John Doe",
      "senderPhoto": "/uploads/profiles/profil-3-xxx.jpg",
      "content": "Halo juga! Ada yang bisa dibantu?",
      "isRead": true,
      "createdAt": "2025-12-24T10:25:00.000Z",
      "updatedAt": "2025-12-24T10:26:00.000Z"
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

### 3.5. Send Message API

**Endpoint**: `POST /api/conversations/:conversationId/messages`

**Request Body**:
```json
{
  "content": "Halo, apa kabar?"
}
```

**Response Success** (201):
```json
{
  "success": true,
  "data": {
    "id": 46,
    "conversationId": 12,
    "senderId": 3,
    "senderName": "John Doe",
    "senderPhoto": "/uploads/profiles/profil-3-xxx.jpg",
    "content": "Halo, apa kabar?",
    "isRead": false,
    "createdAt": "2025-12-24T10:35:00.000Z",
    "updatedAt": "2025-12-24T10:35:00.000Z"
  },
  "message": "Message sent successfully"
}
```

---

### 3.6. Mark Messages as Read API

**Endpoint**: `PUT /api/conversations/:conversationId/read`

**Purpose**: Menandai semua pesan dalam conversation sebagai sudah dibaca

**Response Success** (200):
```json
{
  "success": true,
  "message": "Messages marked as read",
  "data": {
    "updatedCount": 2
  }
}
```

---

### 3.7. Block User API

**Endpoint**: `POST /api/users/block`

**Request Body**:
```json
{
  "blockedUserId": 5
}
```

**Response Success** (200):
```json
{
  "success": true,
  "message": "User blocked successfully",
  "data": {
    "id": 23,
    "blockerId": 3,
    "blockedUserId": 5,
    "createdAt": "2025-12-24T11:00:00.000Z"
  }
}
```

---

### 3.8. Unblock User API

**Endpoint**: `DELETE /api/users/block/:blockedUserId`

**Response Success** (200):
```json
{
  "success": true,
  "message": "User unblocked successfully"
}
```

---

### 3.9. Get Blocked Users API

**Endpoint**: `GET /api/users/blocked`

**Response Success** (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 5,
      "username": "rinawati",
      "name": "Rina Wati",
      "fotoProfil": "/uploads/profiles/profil-5-xxx.jpg",
      "blockedAt": "2025-12-24T11:00:00.000Z"
    }
  ]
}
```

---

### 3.10. Check Block Status API

**Endpoint**: `GET /api/users/block-status/:userId`

**Response Success** (200):
```json
{
  "success": true,
  "data": {
    "isBlockedByMe": false,
    "isBlockingMe": true
  }
}
```

---

## 4. DATABASE SCHEMA (Saran untuk Backend)

### 4.1. Table: conversations

```sql
CREATE TABLE conversations (
  id SERIAL PRIMARY KEY,
  uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_conversations_updated_at ON conversations(updated_at DESC);
```

### 4.2. Table: conversation_participants

```sql
CREATE TABLE conversation_participants (
  id SERIAL PRIMARY KEY,
  conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  joined_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conv_participants_user ON conversation_participants(user_id);
CREATE INDEX idx_conv_participants_conv ON conversation_participants(conversation_id);
```

### 4.3. Table: messages

```sql
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  uuid UUID DEFAULT uuid_generate_v4() UNIQUE NOT NULL,
  conversation_id INTEGER REFERENCES conversations(id) ON DELETE CASCADE,
  sender_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_unread ON messages(conversation_id, is_read) WHERE is_read = FALSE;
```

### 4.4. Table: user_blocks

```sql
CREATE TABLE user_blocks (
  id SERIAL PRIMARY KEY,
  blocker_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  blocked_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_user_id)
);

CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_user_blocks_blocked ON user_blocks(blocked_user_id);
```

---

## 5. FITUR FRONTEND YANG AKAN DIBUAT

### 5.1. File Struktur Baru

```
lib/
├── models/
│   ├── conversation.dart         [NEW]
│   ├── message.dart              [NEW]
│   └── user_search_result.dart   [NEW]
├── services/
│   ├── conversation_service.dart [NEW]
│   └── message_service.dart      [NEW]
└── pages/
    └── pesan/
        ├── pesan_page.dart       [UPDATE]
        ├── chat_page.dart        [UPDATE]
        └── user_search_page.dart [NEW]
```

### 5.2. Fitur yang Akan Diimplementasi

#### A. User Search Page
- Search bar dengan debouncing (delay 500ms)
- Loading indicator saat search
- Daftar hasil pencarian dengan avatar
- Empty state "Tidak ada hasil"
- Error handling
- **Klik user → Popup detail user**

#### B. User Detail Popup (NEW)
- Tampilkan foto profil (large)
- Tampilkan nama lengkap
- Tampilkan username
- Tombol icon CHAT (warna primary)
- Tombol BLOK (warna merah/warning)
- Loading state saat create conversation
- Error handling

#### C. Updated Pesan Page
- Load conversations dari API
- Tampilkan avatar user
- Tampilkan last message
- Tampilkan unread count (badge)
- Tampilkan timestamp
- Pull to refresh
- Loading skeleton
- Empty state "Belum ada percakapan"

#### D. Updated Chat Page
- Load messages dari API
- Kirim pesan ke backend
- Auto-scroll ke bawah
- Tampilkan avatar sender
- Tampilkan status "dibaca"
- Load more messages (pagination)
- Loading indicator
- Error handling
- **Check block status**: Jika user diblok, tampilkan pesan "Tidak bisa mengirim pesan"

---

## 6. SECURITY & VALIDATION

### Backend Harus Validasi:
1. **Authorization**: User hanya bisa akses conversation yang dia ikuti
2. **Input Validation**: Content tidak boleh kosong, max 5000 karakter
3. **Rate Limiting**: Max 60 messages per menit per user
4. **XSS Prevention**: Sanitize message content
5. **SQL Injection**: Gunakan parameterized queries
6. **Block Check**: Sebelum kirim pesan, cek apakah salah satu user memblokir yang lain
7. **Search Filter**: Jangan tampilkan user yang sudah diblok di hasil pencarian

---

## 7. OPTIONAL FEATURES (Future Enhancement)

1. **Real-time Updates**:
   - WebSocket untuk notifikasi pesan baru
   - Typing indicator
   - Online status

2. **Rich Messages**:
   - Kirim gambar
   - Kirim file
   - Voice message
   - Emoji reactions

3. **Message Management**:
   - Delete message
   - Edit message
   - Reply/Quote message

4. **Conversation Management**:
   - Mute conversation
   - Delete conversation
   - Archive conversation
   - Block user

5. **Notifications**:
   - Push notification untuk pesan baru
   - Badge count di app icon

---

## 8. TESTING CHECKLIST

### Backend:
- [ ] User search returns correct results
- [ ] User search excludes current user
- [ ] User search excludes blocked users
- [ ] Cannot create duplicate conversations
- [ ] Messages are ordered by timestamp
- [ ] Mark as read updates unread count
- [ ] Block user works correctly
- [ ] Unblock user works correctly
- [ ] Cannot send message to blocked user
- [ ] Blocked users don't appear in search
- [ ] Authorization checks work correctly

### Frontend:
- [ ] Search works with debouncing
- [ ] User detail popup displays correctly
- [ ] Can start new conversation from popup
- [ ] Can block user from popup
- [ ] Block confirmation dialog works
- [ ] Blocked user removed from search results
- [ ] Can open existing conversation
- [ ] Messages display correctly
- [ ] Can send message
- [ ] Unread count updates
- [ ] Error handling works
- [ ] Loading states display correctly

---

## 9. PRIORITAS IMPLEMENTASI

### Phase 1 (MVP):
1. ✅ User search API (dengan block filter)
2. ✅ Get/Create conversation API
3. ✅ Get conversations list API
4. ✅ Get messages API
5. ✅ Send message API
6. ✅ Block/Unblock user APIs
7. ✅ Frontend implementation

### Phase 2 (Enhancement):
1. Mark as read API
2. Check block status API
3. Pagination improvements
4. Real-time notifications
5. Better UI/UX

### Phase 3 (Advanced):
1. Rich media support
2. Message management (edit/delete)
3. WebSocket integration
4. Push notifications
5. Manage blocked users page

---

## 10. ESTIMASI WAKTU

### Backend Development:
- Database schema (4 tables): 2-3 jam
- User search API + block filter: 2-3 jam
- Conversation APIs: 2-3 jam
- Message APIs: 2-3 jam
- Block/Unblock APIs: 2-3 jam
- Testing: 3-4 jam
- **Total Backend**: ~13-19 jam

### Frontend Development:
- Models & Services: 3-4 jam (termasuk BlockService)
- User Search Page: 2-3 jam
- User Detail Popup: 1-2 jam
- Update Pesan Page: 2-3 jam
- Update Chat Page: 3-4 jam
- Block feature integration: 2-3 jam
- Testing & Bug fixes: 3-4 jam
- **Total Frontend**: ~16-23 jam

**Total Estimasi**: ~29-42 jam (4-5 hari kerja)

---

## 11. CATATAN PENTING

1. **Backend HARUS** membuat database schema terlebih dahulu
2. **Backend HARUS** implement authentication check di semua endpoint
3. **Frontend** akan gunakan pagination untuk efisiensi
4. **Testing** sangat penting sebelum deploy
5. **Error handling** harus comprehensive di kedua sisi

---

**Dokumen ini siap diberikan ke Backend Developer untuk implementasi API.**
