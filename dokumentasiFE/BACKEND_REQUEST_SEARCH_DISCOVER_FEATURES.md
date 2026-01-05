# 🔍 BACKEND API REQUEST - FITUR PENCARIAN & DISCOVER

**Date:** December 29, 2025  
**Project:** mygeri - Job Seeker & Networking App  
**Priority:** HIGH  
**Estimated Timeline:** 2-3 weeks untuk semua fitur

---

## 📋 OVERVIEW

Request untuk implementasi 4 fitur besar yang akan meningkatkan user engagement dan experience:

1. **🔎 Search Posts by Content** - Pencarian postingan berdasarkan keyword
2. **#️⃣ Hashtags System** - Kategorisasi konten dengan hashtags
3. **🏷️ Mentions/Tags (@username)** - Tag user dalam postingan + notifikasi
4. **🔥 Trending Posts** - Tampilkan postingan paling populer/viral

---

## 🎯 IMPLEMENTATION PRIORITY

### **Phase 1: Search Posts** ⭐⭐⭐ (HIGHEST)
**Why:** Paling dibutuhkan user, implementasi tercepat  
**Timeline:** 2-3 hari  
**Complexity:** Low

### **Phase 2: Hashtags** ⭐⭐ (HIGH)
**Why:** Memudahkan kategorisasi & discovery  
**Timeline:** 3-4 hari  
**Complexity:** Medium

### **Phase 3: Mentions** ⭐ (MEDIUM)
**Why:** Meningkatkan interaksi, butuh notification system  
**Timeline:** 4-5 hari  
**Complexity:** High

### **Phase 4: Trending Posts** ⭐ (NICE TO HAVE)
**Why:** Analytics & engagement feature  
**Timeline:** 2-3 hari  
**Complexity:** Medium

---

# 1️⃣ SEARCH POSTS BY CONTENT

## 📌 Feature Description

User dapat search postingan berdasarkan keyword dalam content. Mirip search di Twitter/Instagram.

**Use Case:**
```
User ketik: "lowongan developer"
→ System cari semua posts yang mengandung kata tersebut
→ Tampilkan hasil dengan pagination
```

---

## 🔧 Backend Requirements

### **A. New Endpoint**

```
GET /api/posts/search
```

**Query Parameters:**
- `q` (string, required) - Search query
- `page` (integer, optional, default: 1)
- `limit` (integer, optional, default: 10)

**Headers:**
```
Authorization: Bearer {accessToken}
```

---

### **B. Request Example**

```bash
GET /api/posts/search?q=lowongan%20developer&page=1&limit=10
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

### **C. Response Format**

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "content": "Info lowongan developer di Jakarta, fresh graduate welcome!",
      "imageUrl": "/uploads/posts/post-1-123.jpg",
      "imageUrls": [
        "/uploads/posts/post-1-123.jpg",
        "/uploads/posts/post-1-124.jpg"
      ],
      "createdAt": "2025-12-29T10:00:00.000Z",
      "updatedAt": "2025-12-29T10:00:00.000Z",
      "user": {
        "id": 5,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/profiles/profil-5.jpg"
      },
      "likeCount": 45,
      "commentCount": 12,
      "likedByMe": false
    },
    {
      "id": 124,
      "content": "Butuh developer untuk project startup...",
      ...
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 156,
    "totalPages": 16,
    "hasMore": true,
    "query": "lowongan developer"
  }
}
```

**Empty Result (200):**
```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "totalPages": 0,
    "hasMore": false,
    "query": "keyword tidak ditemukan"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Search query is required",
  "errors": {
    "q": "Query parameter 'q' cannot be empty"
  }
}
```

---

### **D. Implementation Notes**

**Database Query (PostgreSQL):**
```sql
SELECT p.*, u.username, u.name, u.fotoProfil,
       COUNT(DISTINCT l.id) as likeCount,
       COUNT(DISTINCT c.id) as commentCount,
       EXISTS(SELECT 1 FROM post_likes WHERE post_id = p.id AND user_id = $userId) as likedByMe
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN post_likes l ON p.id = l.post_id
LEFT JOIN post_comments c ON p.id = c.post_id
WHERE p.content ILIKE '%' || $query || '%'  -- Case-insensitive search
GROUP BY p.id, u.id
ORDER BY p.created_at DESC
LIMIT $limit OFFSET $offset;
```

**Performance Optimization:**
1. Add full-text search index (recommended):
```sql
-- Create GIN index for full-text search
CREATE INDEX idx_posts_content_search 
ON posts 
USING gin(to_tsvector('indonesian', content));

-- Query dengan full-text search (lebih cepat)
WHERE to_tsvector('indonesian', p.content) @@ plainto_tsquery('indonesian', $query)
```

2. Alternative: Use LIKE with index
```sql
CREATE INDEX idx_posts_content ON posts(content);
```

**Search Features:**
- Case-insensitive (ILIKE atau to_tsvector)
- Partial match (kata sebagian juga match)
- Multiple words support ("lowongan developer" → cari keduanya)
- Sort by: relevance atau created_at DESC

---

# 2️⃣ HASHTAGS SYSTEM

## 📌 Feature Description

User dapat menggunakan hashtags (#keyword) dalam postingan untuk kategorisasi. Hashtag bisa diklik untuk melihat semua post dengan hashtag yang sama.

**Use Case:**
```
User buat post: "Halo! #lowongankerja untuk #developer di #Jakarta"
→ System extract: ["lowongankerja", "developer", "Jakarta"]
→ Simpan ke database
→ User lain click #lowongankerja → lihat semua post dengan hashtag tsb
```

---

## 🔧 Backend Requirements

### **A. Database Schema**

**1. Table: `hashtags`**
```sql
CREATE TABLE hashtags (
  id SERIAL PRIMARY KEY,
  tag VARCHAR(100) UNIQUE NOT NULL,  -- lowercase, tanpa # (contoh: "lowongankerja")
  post_count INTEGER DEFAULT 0,      -- counter untuk performa
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Index untuk performa
CREATE INDEX idx_hashtags_tag ON hashtags(tag);
CREATE INDEX idx_hashtags_post_count ON hashtags(post_count DESC);
```

**2. Table: `post_hashtags` (Many-to-Many)**
```sql
CREATE TABLE post_hashtags (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  hashtag_id INTEGER NOT NULL REFERENCES hashtags(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(post_id, hashtag_id)  -- Prevent duplicate
);

-- Indexes
CREATE INDEX idx_post_hashtags_post ON post_hashtags(post_id);
CREATE INDEX idx_post_hashtags_hashtag ON post_hashtags(hashtag_id);
```

---

### **B. Hashtag Extraction Logic**

**Regex Pattern:**
```javascript
// Extract all hashtags from content
const hashtagRegex = /#(\w+)/g;
const content = "Halo #lowongankerja untuk #developer";
const hashtags = [...content.matchAll(hashtagRegex)].map(m => m[1].toLowerCase());
// Result: ["lowongankerja", "developer"]
```

**When to Extract:**
1. POST `/api/posts` - Saat create post baru
2. PUT `/api/posts/{id}` - Saat edit post (update hashtags)

**Process Flow:**
```javascript
// Pseudocode
async function createPost(content, userId) {
  // 1. Create post
  const post = await Post.create({ content, userId });
  
  // 2. Extract hashtags
  const hashtags = extractHashtags(content);
  
  // 3. For each hashtag
  for (const tag of hashtags) {
    // 3a. Get or create hashtag
    let hashtag = await Hashtag.findOne({ tag });
    if (!hashtag) {
      hashtag = await Hashtag.create({ tag, post_count: 0 });
    }
    
    // 3b. Create relation
    await PostHashtag.create({ post_id: post.id, hashtag_id: hashtag.id });
    
    // 3c. Increment counter
    await Hashtag.increment('post_count', { where: { id: hashtag.id } });
  }
  
  return post;
}
```

---

### **C. New Endpoints**

#### **1. Get Posts by Hashtag**

```
GET /api/posts/hashtag/{tag}
```

**Parameters:**
- `tag` (string, in path) - Hashtag name (without #)
- `page` (integer, query, optional)
- `limit` (integer, query, optional)

**Request Example:**
```bash
GET /api/posts/hashtag/lowongankerja?page=1&limit=10
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "content": "Info #lowongankerja untuk developer...",
      "imageUrl": "/uploads/...",
      "imageUrls": [...],
      "createdAt": "2025-12-29T10:00:00Z",
      "user": {
        "id": 5,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/..."
      },
      "likeCount": 45,
      "commentCount": 12,
      "likedByMe": false,
      "hashtags": ["lowongankerja", "developer", "jakarta"]
    }
  ],
  "meta": {
    "hashtag": "lowongankerja",
    "page": 1,
    "limit": 10,
    "total": 89,
    "hasMore": true
  }
}
```

**Query:**
```sql
SELECT p.*, u.username, u.name, u.fotoProfil,
       array_agg(h.tag) as hashtags
FROM posts p
JOIN post_hashtags ph ON p.id = ph.post_id
JOIN hashtags h ON ph.hashtag_id = h.id
JOIN users u ON p.user_id = u.id
WHERE h.tag = $tag
GROUP BY p.id, u.id
ORDER BY p.created_at DESC
LIMIT $limit OFFSET $offset;
```

---

#### **2. Get Trending Hashtags**

```
GET /api/hashtags/trending
```

**Parameters:**
- `limit` (integer, optional, default: 10)
- `period` (string, optional: 24h/7d/30d, default: 24h)

**Request Example:**
```bash
GET /api/hashtags/trending?limit=10&period=24h
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "tag": "lowongankerja",
      "postCount": 245,
      "recentPosts": 34,  // posts in last 24h
      "growth": "+12%"     // optional: growth rate
    },
    {
      "tag": "fresgraduate",
      "postCount": 189,
      "recentPosts": 28,
      "growth": "+8%"
    },
    {
      "tag": "jakarta",
      "postCount": 567,
      "recentPosts": 45,
      "growth": "+15%"
    }
  ],
  "meta": {
    "period": "24h",
    "limit": 10
  }
}
```

**Query:**
```sql
SELECT h.tag, h.post_count,
       COUNT(ph.id) FILTER (WHERE p.created_at >= NOW() - INTERVAL '24 hours') as recent_posts
FROM hashtags h
JOIN post_hashtags ph ON h.id = ph.hashtag_id
JOIN posts p ON ph.post_id = p.id
GROUP BY h.id
ORDER BY recent_posts DESC, h.post_count DESC
LIMIT $limit;
```

---

#### **3. Search Hashtags**

```
GET /api/hashtags/search
```

**Parameters:**
- `q` (string, required) - Search query
- `limit` (integer, optional, default: 20)

**Request Example:**
```bash
GET /api/hashtags/search?q=lowongan
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "tag": "lowongankerja",
      "postCount": 245
    },
    {
      "tag": "lowongankerjait",
      "postCount": 45
    },
    {
      "tag": "lowongandesigner",
      "postCount": 23
    }
  ],
  "meta": {
    "query": "lowongan",
    "total": 3
  }
}
```

**Query:**
```sql
SELECT tag, post_count
FROM hashtags
WHERE tag ILIKE $query || '%'
ORDER BY post_count DESC
LIMIT $limit;
```

---

### **D. Update Existing Endpoints**

**POST /api/posts & PUT /api/posts/{id}**

Response harus include field `hashtags`:

```json
{
  "id": 123,
  "content": "Post dengan #hashtag #example",
  "hashtags": ["hashtag", "example"],  // ← TAMBAHKAN INI (array of strings)
  "user": {...},
  "likeCount": 0,
  "commentCount": 0
}
```

**GET /api/posts (feed) & GET /api/posts/{id}**

Semua post response harus include hashtags:

```sql
-- Add to existing query
SELECT p.*,
       array_agg(DISTINCT h.tag) FILTER (WHERE h.tag IS NOT NULL) as hashtags
FROM posts p
LEFT JOIN post_hashtags ph ON p.id = ph.post_id
LEFT JOIN hashtags h ON ph.hashtag_id = h.id
GROUP BY p.id;
```

---

# 3️⃣ MENTIONS/TAGS (@username)

## 📌 Feature Description

User dapat mention/tag user lain dengan @username. User yang di-mention akan mendapat notifikasi.

**Use Case:**
```
User A posting: "Thanks @yayat123 for the info!"
→ System extract: ["yayat123"]
→ Validate user exists
→ Save to post_mentions
→ Send notification to @yayat123
→ @yayat123 dapat notif: "johndoe mentioned you in a post"
```

---

## 🔧 Backend Requirements

### **A. Database Schema**

**1. Table: `post_mentions`**
```sql
CREATE TABLE post_mentions (
  id SERIAL PRIMARY KEY,
  post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  mentioned_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(post_id, mentioned_user_id)
);

-- Indexes
CREATE INDEX idx_post_mentions_post ON post_mentions(post_id);
CREATE INDEX idx_post_mentions_user ON post_mentions(mentioned_user_id);
```

**2. Table: `notifications` (create if not exists)**
```sql
CREATE TABLE notifications (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL,  -- 'mention', 'like', 'comment', 'follow', dll
  post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
  comment_id INTEGER REFERENCES post_comments(id) ON DELETE CASCADE,
  actor_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
CREATE INDEX idx_notifications_type ON notifications(type);
```

---

### **B. Mention Extraction Logic**

**Regex Pattern:**
```javascript
// Extract all mentions from content
const mentionRegex = /@(\w+)/g;
const content = "Thanks @yayat123 and @heri123 for help!";
const mentions = [...content.matchAll(mentionRegex)].map(m => m[1]);
// Result: ["yayat123", "heri123"]
```

**Process Flow:**
```javascript
// Pseudocode
async function createPost(content, userId) {
  // 1. Create post
  const post = await Post.create({ content, userId });
  
  // 2. Extract mentions
  const usernames = extractMentions(content);
  
  // 3. For each mention
  for (const username of usernames) {
    // 3a. Find user by username
    const mentionedUser = await User.findOne({ username });
    
    if (mentionedUser && mentionedUser.id !== userId) {
      // 3b. Create mention record
      await PostMention.create({
        post_id: post.id,
        mentioned_user_id: mentionedUser.id
      });
      
      // 3c. Create notification
      await Notification.create({
        user_id: mentionedUser.id,
        type: 'mention',
        post_id: post.id,
        actor_user_id: userId,
        is_read: false
      });
    }
  }
  
  return post;
}
```

---

### **C. New Endpoints**

#### **1. Get Posts Where User is Mentioned**

```
GET /api/posts/mentions/me
```

**Parameters:**
- `page` (integer, optional)
- `limit` (integer, optional)

**Request Example:**
```bash
GET /api/posts/mentions/me?page=1&limit=10
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "content": "Thanks @yayat123 for the information!",
      "imageUrl": null,
      "createdAt": "2025-12-29T10:00:00Z",
      "user": {
        "id": 5,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/..."
      },
      "mentions": [
        {
          "id": 12,
          "username": "yayat123",
          "name": "yayat"
        }
      ],
      "likeCount": 15,
      "commentCount": 3
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 5,
    "hasMore": false
  }
}
```

---

#### **2. Get Notifications**

```
GET /api/notifications
```

**Parameters:**
- `page` (integer, optional, default: 1)
- `limit` (integer, optional, default: 20)
- `type` (string, optional) - Filter by type: 'mention', 'like', 'comment'
- `unread` (boolean, optional) - Filter unread only

**Request Example:**
```bash
GET /api/notifications?page=1&limit=20
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "type": "mention",
      "isRead": false,
      "post": {
        "id": 123,
        "content": "Thanks @yayat123 for..."
      },
      "actor": {
        "id": 5,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/..."
      },
      "createdAt": "2025-12-29T10:00:00Z"
    },
    {
      "id": 2,
      "type": "like",
      "isRead": true,
      "post": {
        "id": 122,
        "content": "My latest post..."
      },
      "actor": {
        "id": 7,
        "username": "janedoe",
        "name": "Jane Doe",
        "fotoProfil": null
      },
      "createdAt": "2025-12-29T09:30:00Z"
    },
    {
      "id": 3,
      "type": "comment",
      "isRead": false,
      "post": {
        "id": 121,
        "content": "Another post..."
      },
      "comment": {
        "id": 456,
        "content": "Great post!"
      },
      "actor": {
        "id": 8,
        "username": "bob",
        "name": "Bob Smith",
        "fotoProfil": "/uploads/..."
      },
      "createdAt": "2025-12-29T08:15:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "unreadCount": 12,
    "hasMore": true
  }
}
```

---

#### **3. Mark Notification as Read**

```
PUT /api/notifications/{id}/read
```

**Request Example:**
```bash
PUT /api/notifications/123/read
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Notification marked as read",
  "data": {
    "id": 123,
    "isRead": true
  }
}
```

---

#### **4. Mark All Notifications as Read**

```
PUT /api/notifications/read-all
```

**Request Example:**
```bash
PUT /api/notifications/read-all
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "All notifications marked as read",
  "data": {
    "updatedCount": 12
  }
}
```

---

#### **5. Get Unread Notification Count**

```
GET /api/notifications/unread-count
```

**Request Example:**
```bash
GET /api/notifications/unread-count
Authorization: Bearer {token}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "unreadCount": 12
  }
}
```

---

### **D. Update Existing Endpoints**

**POST /api/posts & PUT /api/posts/{id}**

Response harus include field `mentions`:

```json
{
  "id": 123,
  "content": "Thanks @johndoe for sharing",
  "mentions": [  // ← TAMBAHKAN INI (array of user objects)
    {
      "id": 5,
      "username": "johndoe",
      "name": "John Doe",
      "fotoProfil": "/uploads/..."
    }
  ],
  "user": {...}
}
```

**GET /api/posts (feed) & GET /api/posts/{id}**

Include mentions in response:

```sql
SELECT p.*,
       json_agg(DISTINCT jsonb_build_object(
         'id', mu.id,
         'username', mu.username,
         'name', mu.name,
         'fotoProfil', mu.fotoProfil
       )) FILTER (WHERE mu.id IS NOT NULL) as mentions
FROM posts p
LEFT JOIN post_mentions pm ON p.id = pm.post_id
LEFT JOIN users mu ON pm.mentioned_user_id = mu.id
GROUP BY p.id;
```

---

### **E. Notification Types**

Support minimal notification types:

1. **mention** - User mentioned you in a post
2. **like** - User liked your post
3. **comment** - User commented on your post
4. **follow** - User followed you (optional)

---

# 4️⃣ TRENDING POSTS

## 📌 Feature Description

Tampilkan postingan yang paling populer/viral dalam periode tertentu (24 jam, 7 hari, 30 hari).

**Use Case:**
```
User buka tab "Trending"
→ System hitung trending score untuk semua post
→ Sort by score (like*2 + comment*5) / age
→ Tampilkan top posts
```

---

## 🔧 Backend Requirements

### **A. New Endpoint**

```
GET /api/posts/trending
```

**Parameters:**
- `period` (string, optional: '24h' | '7d' | '30d', default: '24h')
- `page` (integer, optional, default: 1)
- `limit` (integer, optional, default: 10)

**Request Example:**
```bash
GET /api/posts/trending?period=24h&page=1&limit=10
Authorization: Bearer {token}
```

---

### **B. Response Format**

**Success Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 123,
      "content": "Viral post about...",
      "imageUrl": "/uploads/...",
      "imageUrls": [...],
      "createdAt": "2025-12-28T15:00:00Z",
      "user": {
        "id": 5,
        "username": "johndoe",
        "name": "John Doe",
        "fotoProfil": "/uploads/..."
      },
      "likeCount": 1245,
      "commentCount": 234,
      "shareCount": 89,
      "trendingScore": 1568.5,
      "likedByMe": false,
      "hashtags": ["trending", "viral"],
      "mentions": []
    },
    {
      "id": 124,
      "content": "Another trending post...",
      "likeCount": 890,
      "commentCount": 156,
      "trendingScore": 1246.3,
      ...
    }
  ],
  "meta": {
    "period": "24h",
    "page": 1,
    "limit": 10,
    "total": 50,
    "hasMore": true
  }
}
```

---

### **C. Trending Score Algorithm**

**Formula:**
```
trendingScore = (
  (likeCount * LIKE_WEIGHT) +
  (commentCount * COMMENT_WEIGHT) +
  (shareCount * SHARE_WEIGHT)
) / ageInHours

Where:
- LIKE_WEIGHT = 2
- COMMENT_WEIGHT = 5
- SHARE_WEIGHT = 10 (if share feature exists)
- ageInHours = (NOW - post.createdAt) in hours
```

**Example Calculation:**
```
Post A: 100 likes, 20 comments, 2 hours old
Score = (100*2 + 20*5) / 2 = (200 + 100) / 2 = 150

Post B: 50 likes, 30 comments, 1 hour old  
Score = (50*2 + 30*5) / 1 = (100 + 150) / 1 = 250

→ Post B is more trending (higher score)
```

---

### **D. Implementation Options**

#### **Option 1: Real-time Calculation** (Simple, for MVP)

```sql
SELECT p.*,
       u.username, u.name, u.fotoProfil,
       COUNT(DISTINCT l.id) as like_count,
       COUNT(DISTINCT c.id) as comment_count,
       (
         (COUNT(DISTINCT l.id) * 2 + COUNT(DISTINCT c.id) * 5) /
         GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600, 0.5)
       ) as trending_score
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN post_likes l ON p.id = l.post_id
LEFT JOIN post_comments c ON p.id = c.post_id
WHERE p.created_at >= NOW() - INTERVAL $period  -- '24 hours', '7 days', '30 days'
GROUP BY p.id, u.id
ORDER BY trending_score DESC
LIMIT $limit OFFSET $offset;
```

**Pros:**
- Simple to implement
- Always up-to-date
- No caching needed

**Cons:**
- Slower for large datasets
- Heavy database load

---

#### **Option 2: Cached with Scheduled Job** (Recommended for Production)

**Setup:**
1. Create cron job yang jalan setiap 15 menit atau 1 jam
2. Calculate trending score untuk semua posts
3. Store results di Redis atau cache table

**Implementation:**
```javascript
// Cron job (runs every 15 minutes)
async function calculateTrendingPosts() {
  const periods = ['24h', '7d', '30d'];
  
  for (const period of periods) {
    const posts = await calculateTrendingForPeriod(period);
    await redis.setex(
      `trending:${period}`,
      900,  // cache for 15 minutes
      JSON.stringify(posts)
    );
  }
}

// API endpoint
async function getTrendingPosts(period, page, limit) {
  // Try get from cache first
  const cached = await redis.get(`trending:${period}`);
  if (cached) {
    return JSON.parse(cached).slice((page-1)*limit, page*limit);
  }
  
  // Fallback to real-time calculation
  return await calculateTrendingForPeriod(period);
}
```

**Pros:**
- Fast response time
- Reduced database load
- Scalable

**Cons:**
- Slightly delayed data (15 min lag)
- More complex setup

---

#### **Option 3: Database Materialized View** (Alternative)

```sql
-- Create materialized view (refresh every 1 hour)
CREATE MATERIALIZED VIEW trending_posts_24h AS
SELECT 
  p.*,
  u.username, u.name, u.fotoProfil,
  COUNT(DISTINCT l.id) as like_count,
  COUNT(DISTINCT c.id) as comment_count,
  (
    (COUNT(DISTINCT l.id) * 2 + COUNT(DISTINCT c.id) * 5) /
    GREATEST(EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600, 0.5)
  ) as trending_score
FROM posts p
JOIN users u ON p.user_id = u.id
LEFT JOIN post_likes l ON p.id = l.post_id
LEFT JOIN post_comments c ON p.id = c.post_id
WHERE p.created_at >= NOW() - INTERVAL '24 hours'
GROUP BY p.id, u.id
ORDER BY trending_score DESC;

-- Create index
CREATE INDEX idx_trending_24h_score ON trending_posts_24h(trending_score DESC);

-- Refresh via cron
REFRESH MATERIALIZED VIEW trending_posts_24h;
```

**Query:**
```sql
SELECT * FROM trending_posts_24h
LIMIT $limit OFFSET $offset;
```

**Pros:**
- Very fast queries
- Database-level caching
- No external cache needed

**Cons:**
- PostgreSQL specific
- Requires scheduled refresh

---

### **E. Period Intervals**

**24h (Last 24 hours):**
```sql
WHERE p.created_at >= NOW() - INTERVAL '24 hours'
```

**7d (Last 7 days):**
```sql
WHERE p.created_at >= NOW() - INTERVAL '7 days'
```

**30d (Last 30 days):**
```sql
WHERE p.created_at >= NOW() - INTERVAL '30 days'
```

---

# 📊 COMPLETE IMPLEMENTATION CHECKLIST

## **Database Changes**

### **New Tables:**
- [ ] `hashtags` - Store unique hashtags
- [ ] `post_hashtags` - Many-to-many relation
- [ ] `post_mentions` - Store user mentions
- [ ] `notifications` - Notification system

### **Indexes:**
- [ ] `idx_posts_content` or GIN index for full-text search
- [ ] `idx_hashtags_tag` on hashtags(tag)
- [ ] `idx_hashtags_post_count` on hashtags(post_count DESC)
- [ ] `idx_post_hashtags_post` on post_hashtags(post_id)
- [ ] `idx_post_hashtags_hashtag` on post_hashtags(hashtag_id)
- [ ] `idx_post_mentions_post` on post_mentions(post_id)
- [ ] `idx_post_mentions_user` on post_mentions(mentioned_user_id)
- [ ] `idx_notifications_user` on notifications(user_id, is_read)

---

## **New Endpoints**

### **Search:**
- [ ] `GET /api/posts/search` - Search posts by content

### **Hashtags:**
- [ ] `GET /api/posts/hashtag/{tag}` - Get posts by hashtag
- [ ] `GET /api/hashtags/trending` - Get trending hashtags
- [ ] `GET /api/hashtags/search` - Search hashtags

### **Mentions:**
- [ ] `GET /api/posts/mentions/me` - Get posts mentioning current user
- [ ] `GET /api/notifications` - Get user notifications
- [ ] `GET /api/notifications/unread-count` - Get unread count
- [ ] `PUT /api/notifications/{id}/read` - Mark notification as read
- [ ] `PUT /api/notifications/read-all` - Mark all as read

### **Trending:**
- [ ] `GET /api/posts/trending` - Get trending posts

---

## **Updated Endpoints**

### **Post Endpoints:**
- [ ] `POST /api/posts` - Extract hashtags & mentions, include in response
- [ ] `PUT /api/posts/{id}` - Update hashtags & mentions
- [ ] `GET /api/posts` (feed) - Include `hashtags` and `mentions` fields
- [ ] `GET /api/posts/{id}` - Include `hashtags` and `mentions` fields

---

## **Backend Logic**

### **Text Processing:**
- [ ] Hashtag extraction: `#(\w+)` → lowercase, store in DB
- [ ] Mention extraction: `@(\w+)` → validate user exists
- [ ] Update counters on hashtag create/delete

### **Notifications:**
- [ ] Create notification on mention
- [ ] Create notification on like (optional)
- [ ] Create notification on comment (optional)
- [ ] Mark as read functionality

### **Performance:**
- [ ] Full-text search optimization (GIN index or similar)
- [ ] Trending calculation caching (Redis or materialized view)
- [ ] Pagination for all list endpoints
- [ ] Database query optimization

---

# 🧪 TESTING REQUIREMENTS

## **Test Data Needed**

Untuk testing frontend, tolong sediakan:

1. **Posts dengan Hashtags:**
```
- "Info #lowongankerja untuk #developer di #jakarta"
- "Tips #interview untuk #fresgraduate"
- "Remote #pekerjaan #freelance tersedia"
```

2. **Posts dengan Mentions:**
```
- "Thanks @yayat123 for the info!"
- "CC @heri123 @rina_wati untuk diskusi"
```

3. **Popular Posts (untuk trending):**
```
- Post dengan 100+ likes, 50+ comments (< 24 jam)
- Post dengan 50+ likes, 20+ comments (< 7 hari)
```

---

## **API Testing Checklist**

### **Search:**
- [ ] Search dengan 1 keyword
- [ ] Search dengan multiple keywords
- [ ] Search dengan special characters
- [ ] Empty search result
- [ ] Pagination working

### **Hashtags:**
- [ ] Post dengan single hashtag
- [ ] Post dengan multiple hashtags
- [ ] Click hashtag returns correct posts
- [ ] Trending hashtags sorted correctly
- [ ] Hashtag counter updates correctly

### **Mentions:**
- [ ] Post dengan single mention
- [ ] Post dengan multiple mentions
- [ ] Notification created for mentioned user
- [ ] Mentioned user can see notification
- [ ] Mark as read working

### **Trending:**
- [ ] Trending calculation correct
- [ ] Period filter working (24h, 7d, 30d)
- [ ] Sorting by trending score
- [ ] Pagination working

---

# 📚 API DOCUMENTATION

Tolong provide:

1. **Postman Collection** atau **Swagger/OpenAPI Documentation**
2. **Example Requests & Responses** untuk setiap endpoint
3. **Error Codes & Messages** yang mungkin terjadi
4. **Authentication Requirements** untuk setiap endpoint

---

# 🚀 DEPLOYMENT NOTES

## **Database Migration**

```sql
-- Run these migrations in order:

-- 1. Create hashtags table
CREATE TABLE hashtags (...);

-- 2. Create post_hashtags table
CREATE TABLE post_hashtags (...);

-- 3. Create post_mentions table
CREATE TABLE post_mentions (...);

-- 4. Create notifications table
CREATE TABLE notifications (...);

-- 5. Create all indexes
CREATE INDEX idx_...;

-- 6. (Optional) Create materialized view for trending
CREATE MATERIALIZED VIEW trending_posts_24h AS ...;
```

## **Environment Variables**

Jika ada config baru yang dibutuhkan:
```
NOTIFICATION_ENABLED=true
TRENDING_CACHE_TTL=900  # 15 minutes
SEARCH_RESULTS_LIMIT=50
HASHTAG_MAX_LENGTH=100
```

---

# 📞 COMMUNICATION

## **Questions or Clarifications?**

Jika ada yang tidak jelas atau butuh diskusi lebih lanjut:

1. **Timeline:** Berapa lama untuk implement semua ini?
2. **Priority:** Mana yang harus dikerjakan dulu?
3. **Existing Code:** Apakah ada konflik dengan code yang sudah ada?
4. **Testing:** Kapan bisa mulai testing di development environment?
5. **Documentation:** Bisa provide Postman collection atau Swagger docs?

---

## **Contact Frontend Team**

Setelah endpoint ready, tolong informasikan:
- ✅ Endpoint URL dan method
- ✅ Request/Response format
- ✅ Test credentials
- ✅ Sample data untuk testing

---

# ✅ APPROVAL & SIGN-OFF

**Frontend Team:** ✅ Ready to implement after backend APIs available  
**Backend Team:** _______________ (Date & Signature)

**Estimated Frontend Development Time:**
- Phase 1 (Search): 2-3 hari
- Phase 2 (Hashtags): 3-4 hari
- Phase 3 (Mentions): 4-5 hari
- Phase 4 (Trending): 2-3 hari

**Total:** ~2 minggu (setelah semua backend APIs ready)

---

**Document Version:** 1.0  
**Last Updated:** December 29, 2025  
**Prepared by:** Frontend Team - mygeri Project
