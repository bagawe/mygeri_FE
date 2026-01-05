DOCUMENTATION - POST API WITH HASHTAGS & TRENDING

# 📱 Mygery Post API - Hashtags, Trending & Tags Documentation

**Base URL:** `http://localhost:3030/api`  
**Version:** 1.0.0  
**Last Updated:** December 30, 2025

---

## 🔐 Authentication

Semua endpoint (kecuali yang ditandai PUBLIC) memerlukan Bearer Token di header:

Authorization: Bearer YOUR_ACCESS_TOKEN


### Get Access Token

**Endpoint:** `POST /auth/login`

**Request Body:**
```json
{
  "identifier": "admin@example.com",
  "password": "Admin123!"
}

{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "uuid": "97cfb130-f8d3-496c-bde3-67bd68c80d7b",
      "name": "Admin",
      "email": "admin@example.com"
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "e16f135ff3a3bf08b5fc2c5c9a6af5c6...",
    "expiresIn": "1d"
  }
}

📊 1. GET TRENDING HASHTAGS
Mendapatkan daftar hashtag yang sedang trending (7 hari terakhir).

PUBLIC ENDPOINT - Tidak perlu authentication
Endpoint: GET /posts/hashtags/trending

Query Parameters:📊 
Query Parameters:

Parameter	Type	Required	Default	Description
limit	integer	No	10	Jumlah hashtag yang ditampilkan
Request Example:

curl -X GET "http://localhost:3030/api/posts/hashtags/trending?limit=10"

Success Response (200):
{
  "success": true,
  "message": "Trending hashtags retrieved successfully",
  "data": [
    {
      "hashtag": "hello",
      "count": 15
    },
    {
      "hashtag": "world",
      "count": 12
    },
    {
      "hashtag": "test",
      "count": 8
    },
    {
      "hashtag": "awesome",
      "count": 5
    },
    {
      "hashtag": "flutter",
      "count": 3
    }
  ]
}

Error Response (500):

{
  "success": false,
  "message": "Failed to retrieve trending hashtags"
}

Notes:

Hashtag dihitung dari post 7 hari terakhir
Hashtag diurutkan berdasarkan count (descending)
Format hashtag tanpa symbol #
Case insensitive (hello, Hello, HELLO dihitung sama)
🔍 2. GET POSTS BY HASHTAG
Mendapatkan semua post yang mengandung hashtag tertentu.

Endpoint: GET /posts/hashtag/:hashtag

Headers:

Authorization: Bearer YOUR_ACCESS_TOKEN

Path Parameters:

Parameter	Type	Required	Description
hashtag	string	Yes	Hashtag tanpa symbol #
Query Parameters:

Parameter	Type	Required	Default	Description
page	integer	No	1	Halaman pagination
limit	integer	No	10	Jumlah post per halaman
Request Example:
curl -X GET "http://localhost:3030/api/posts/hashtag/hello?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

  Success Response (200):
  {
  "success": true,
  "message": "Posts retrieved successfully",
  "data": [
    {
      "id": 1,
      "userId": 1,
      "content": "Hello world! This is my first post #hello #world #test @admin 🚀",
      "imageUrl": null,
      "imageUrls": [],
      "createdAt": "2025-12-30T01:23:33.141Z",
      "updatedAt": "2025-12-30T01:23:33.141Z",
      "user": {
        "id": 1,
        "uuid": "97cfb130-f8d3-496c-bde3-67bd68c80d7b",
        "name": "Admin",
        "username": "admin",
        "fotoProfil": null
      },
      "likedByMe": true,
      "likeCount": 5,
      "commentCount": 3
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 15,
    "totalPages": 2
  }
}

Error Response (401):
{
  "success": false,
  "message": "Unauthorized"
}

Notes:

Hashtag case insensitive
Hashtag parameter tanpa # symbol
Response include likedByMe untuk user yang sedang login
Post diurutkan dari yang terbaru
🔥 3. GET TRENDING POSTS
Mendapatkan post yang sedang trending berdasarkan like dan comment (7 hari terakhir).

Endpoint: GET /posts/trending

Headers:

Authorization: Bearer YOUR_ACCESS_TOKEN

Query Parameters:

Parameter	Type	Required	Default	Description
page	integer	No	1	Halaman pagination
limit	integer	No	10	Jumlah post per halaman
Request Example:
curl -X GET "http://localhost:3030/api/posts/trending?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

Success Response (200):
{
  "success": true,
  "message": "Trending posts retrieved successfully",
  "data": [
    {
      "id": 5,
      "userId": 3,
      "content": "This is trending! #viral #trending 🔥",
      "imageUrl": "http://localhost:3030/uploads/posts/post-3-1735524213141-1.jpg",
      "imageUrls": [
        "http://localhost:3030/uploads/posts/post-3-1735524213141-1.jpg",
        "http://localhost:3030/uploads/posts/post-3-1735524213141-2.jpg"
      ],
      "createdAt": "2025-12-29T10:30:13.141Z",
      "updatedAt": "2025-12-29T10:30:13.141Z",
      "user": {
        "id": 3,
        "uuid": "abc123-def456-ghi789",
        "name": "John Doe",
        "username": "johndoe",
        "fotoProfil": "http://localhost:3030/uploads/profiles/profil-3-1735520123456-1.jpg"
      },
      "likedByMe": false,
      "likeCount": 25,
      "commentCount": 12
    },
    {
      "id": 3,
      "userId": 2,
      "content": "Amazing content! #awesome #cool",
      "imageUrl": null,
      "imageUrls": [],
      "createdAt": "2025-12-28T15:20:33.141Z",
      "updatedAt": "2025-12-28T15:20:33.141Z",
      "user": {
        "id": 2,
        "uuid": "xyz789-abc123-def456",
        "name": "Jane Smith",
        "username": "janesmith",
        "fotoProfil": null
      },
      "likedByMe": true,
      "likeCount": 18,
      "commentCount": 8
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "totalPages": 3
  }
}


Error Response (401):
{
  "success": false,
  "message": "Unauthorized"
}

Notes:
Hanya post dari 7 hari terakhir
Sorting berdasarkan: likeCount DESC, commentCount DESC, createdAt DESC
Response include likedByMe untuk user yang sedang login
Image URL full path (siap dipakai di Flutter)


4. SEARCH POSTS
Mencari post berdasarkan konten (support hashtag dan mention).

Endpoint: GET /posts/search

Headers:
Authorization: Bearer YOUR_ACCESS_TOKEN

Query Parameters:

Parameter	Type	Required	Default	Description
q	string	Yes	-	Keyword pencarian
page	integer	No	1	Halaman pagination
limit	integer	No	10	Jumlah post per halaman
Request Example:

# Search by keyword
curl -X GET "http://localhost:3030/api/posts/search?q=hello&page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Search by hashtag
curl -X GET "http://localhost:3030/api/posts/search?q=%23hello" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# Search by mention
curl -X GET "http://localhost:3030/api/posts/search?q=%40admin" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

  Success Response (200):
  {
  "success": true,
  "message": "Search completed successfully",
  "data": [
    {
      "id": 1,
      "userId": 1,
      "content": "Hello world! This is my first post #hello #world #test @admin 🚀",
      "imageUrl": null,
      "imageUrls": [],
      "createdAt": "2025-12-30T01:23:33.141Z",
      "updatedAt": "2025-12-30T01:23:33.141Z",
      "user": {
        "id": 1,
        "uuid": "97cfb130-f8d3-496c-bde3-67bd68c80d7b",
        "name": "Admin",
        "username": "admin",
        "fotoProfil": null
      },
      "likedByMe": true,
      "likeCount": 5,
      "commentCount": 3
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 1,
    "totalPages": 1
  }
}

Error Response (400):
{
  "success": false,
  "message": "Search query is required"
}

Error Response (401):
{
  "success": false,
  "message": "Unauthorized"
}

Notes:

Search case insensitive
Support search hashtag (dengan atau tanpa #)
Support search mention (dengan atau tanpa @)
Result diurutkan dari yang terbaru
📬 5. GET MENTIONED POSTS
Mendapatkan post yang mention username user yang sedang login.

Endpoint: GET /posts/mentions

Headers:
Authorization: Bearer YOUR_ACCESS_TOKEN

Query Parameters:

Parameter	Type	Required	Default	Description
page	integer	No	1	Halaman pagination
limit	integer	No	10	Jumlah post per halaman
Request Example:

curl -X GET "http://localhost:3030/api/posts/mentions?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

  {
  "success": true,
  "message": "Mentioned posts retrieved successfully",
  "data": [
    {
      "id": 2,
      "userId": 3,
      "content": "Hey @admin check this out! #cool #awesome",
      "imageUrl": null,
      "imageUrls": [],
      "createdAt": "2025-12-29T14:23:33.141Z",
      "updatedAt": "2025-12-29T14:23:33.141Z",
      "user": {
        "id": 3,
        "uuid": "abc123-def456-ghi789",
        "name": "John Doe",
        "username": "johndoe",
        "fotoProfil": null
      },
      "likedByMe": false,
      "likeCount": 2,
      "commentCount": 1
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 5,
    "totalPages": 1
  }
}

{
  "success": false,
  "message": "Unauthorized"
}

Notes:

Hanya menampilkan post yang mention username user yang sedang login
Exclude post dari user sendiri
Diurutkan dari yang terbaru
Format mention: @username

📝 6. CREATE POST (with Hashtags)
Membuat post baru dengan support hashtag otomatis.

Endpoint: POST /posts

Headers:

Form Data:

Field	Type	Required	Description
content	string	Yes	Konten post (support hashtag & mention)
images	file[]	No	Array of images (max 5, 5MB each)
Request Example:

# Text only
curl -X POST "http://localhost:3030/api/posts" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "content=Hello world! #hello #world #test @admin 🚀"

# With images
curl -X POST "http://localhost:3030/api/posts" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "content=Check this out! #awesome #photo" \
  -F "images=@/path/to/image1.jpg" \
  -F "images=@/path/to/image2.jpg"

Success Response (201):
{
  "success": true,
  "message": "Post created successfully",
  "data": {
    "id": 10,
    "userId": 1,
    "content": "Hello world! #hello #world #test @admin 🚀",
    "imageUrl": "http://localhost:3030/uploads/posts/post-1-1735524213141-1.jpg",
    "imageUrls": [
      "http://localhost:3030/uploads/posts/post-1-1735524213141-1.jpg",
      "http://localhost:3030/uploads/posts/post-1-1735524213141-2.jpg"
    ],
    "createdAt": "2025-12-30T02:30:13.141Z",
    "updatedAt": "2025-12-30T02:30:13.141Z",
    "user": {
      "id": 1,
      "uuid": "97cfb130-f8d3-496c-bde3-67bd68c80d7b",
      "name": "Admin",
      "username": "admin",
      "fotoProfil": null
    }
  }
}

Error Response (400):
{
  "success": false,
  "message": "Content is required"
}

Error Response (400) - File too large:
{
  "success": false,
  "message": "File too large. Maximum 5MB per file"
}

Error Response (401):
{
  "success": false,
  "message": "Unauthorized"
}

Notes:

Hashtag otomatis ter-track untuk trending
Format hashtag: #word (alphanumeric + unicode)
Format mention: @username
Max 5 images per post
Max 5MB per image
Allowed formats: jpg, jpeg, png, gif, webp

📊 Data Structure Reference
Post Object
{
  id: number;
  userId: number;
  content: string;
  imageUrl: string | null;        // First image URL
  imageUrls: string[];            // All image URLs
  createdAt: string;              // ISO 8601
  updatedAt: string;              // ISO 8601
  user: User;
  likedByMe: boolean;             // Current user like status
  likeCount: number;
  commentCount: number;
}

User Object
{
  id: number;
  uuid: string;
  name: string;
  username: string;
  fotoProfil: string | null;      // Profile picture URL
}

Pagination Meta Object
{
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

Hashtag Object
{
  hashtag: string;
  count: number;
}

⚠️ Error Codes
Status Code	Meaning
200	Success
201	Created
400	Bad Request / Validation Error
401	Unauthorized (Token invalid/missing)
403	Forbidden (Token expired)
404	Not Found
500	Internal Server Error
🔄 Rate Limiting
Currently no rate limiting implemented. Best practice:

Cache trending hashtags for 5-10 minutes
Debounce search queries (300ms)
Implement pagination for better performance
💡 Best Practices for Flutter Integration
1. Hashtag Display
// Detect hashtags in text
RegExp hashtagRegex = RegExp(r'#[\w\u0080-\uFFFF]+');
List<String> hashtags = hashtagRegex.allMatches(text)
    .map((m) => m.group(0)!)
    .toList();

// Make hashtags clickable
RichText(
  text: TextSpan(
    children: _buildTextSpans(content),
  ),
);

2. Mention Display
// Detect mentions in text
RegExp mentionRegex = RegExp(r'@[\w]+');
List<String> mentions = mentionRegex.allMatches(text)
    .map((m) => m.group(0)!)
    .toList();

3. Image Loading
// Use cached_network_image
CachedNetworkImage(
  imageUrl: post.imageUrls[0],
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);

4. Trending Hashtags Widget
// Horizontal scrollable chips
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: trendingHashtags.map((tag) => 
      Chip(
        label: Text('#${tag.hashtag}'),
        onPressed: () => navigateToHashtag(tag.hashtag),
      )
    ).toList(),
  ),
);

5. Search with Debounce
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    performSearch(query);
  });
}

🧪 Testing Examples
Test 1: Get Trending Hashtags
curl -X GET "http://localhost:3030/api/posts/hashtags/trending?limit=5"
Test 2: Get Posts by Hashtag
export TOKEN="your_token_here"
curl -X GET "http://localhost:3030/api/posts/hashtag/hello" \
  -H "Authorization: Bearer $TOKEN"
Test 3: Search Posts
curl -X GET "http://localhost:3030/api/posts/search?q=hello" \
  -H "Authorization: Bearer $TOKEN"
Test 4: Get Trending Posts
curl -X GET "http://localhost:3030/api/posts/trending" \
  -H "Authorization: Bearer $TOKEN"
Test 5: Get Mentions
curl -X GET "http://localhost:3030/api/posts/mentions" \
  -H "Authorization: Bearer $TOKEN"
Test 6: Create Post with Hashtagscurl -X POST "http://localhost:3030/api/posts" \
  -H "Authorization: Bearer $TOKEN" \
  -F "content=Testing hashtags #test #flutter #awesome 🚀"


API Base URL: http://localhost:3030/api
Environment: Development
📅 Changelog
Version 1.0.0 (December 30, 2025)
✅ Initial release
✅ Trending hashtags feature
✅ Posts by hashtag
✅ Trending posts
✅ Search with hashtag support
✅ Mentions feature
✅ Auto hashtag tracking
END OF DOCUMENTATION

