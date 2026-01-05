# Post Search API Documentation

## Overview
API endpoint untuk mencari posts berdasarkan keyword dengan fitur pagination dan case-insensitive search.

---

## Endpoint

```
GET /api/posts/search
```

**Base URL:** `http://localhost:3030` (development)

---

## Authentication

**Required:** Yes

```http
Authorization: Bearer {access_token}
```

---

## Query Parameters

| Parameter | Type     | Required | Default | Description                          |
|-----------|----------|----------|---------|--------------------------------------|
| `q`       | string   | ✅ Yes   | -       | Search keyword (min 2 characters)    |
| `query`   | string   | ✅ Yes   | -       | Alternative to `q`                   |
| `page`    | integer  | ❌ No    | 1       | Page number (starts from 1)          |
| `limit`   | integer  | ❌ No    | 10      | Number of items per page             |

**Note:** Either `q` or `query` must be provided.

---

## Request Example

### Using Axios

```javascript
import axios from 'axios';

const searchPosts = async (keyword, page = 1, limit = 10) => {
  try {
    const response = await axios.get('http://localhost:3030/api/posts/search', {
      params: {
        q: keyword,
        page: page,
        limit: limit
      },
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('accessToken')}`
      }
    });
    
    return response.data;
  } catch (error) {
    console.error('Search error:', error.response?.data);
    throw error;
  }
};

// Usage
const results = await searchPosts('test', 1, 10);
```

### Using Fetch

```javascript
const searchPosts = async (keyword, page = 1, limit = 10) => {
  const url = new URL('http://localhost:3030/api/posts/search');
  url.searchParams.append('q', keyword);
  url.searchParams.append('page', page);
  url.searchParams.append('limit', limit);

  const response = await fetch(url, {
    method: 'GET',
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('accessToken')}`,
      'Content-Type': 'application/json'
    }
  });

  if (!response.ok) {
    throw new Error('Search failed');
  }

  return await response.json();
};
```

### Using cURL (for testing)

```bash
curl -X GET "http://localhost:3030/api/posts/search?q=test&page=1&limit=10" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

---

## Response Format

### Success Response (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": 17,
      "content": "Test post content",
      "imageUrl": "/uploads/posts/post-12-1766972187186-1.jpg",
      "imageUrls": [
        "/uploads/posts/post-12-1766972187186-1.jpg",
        "/uploads/posts/post-12-1766972187224-2.jpg",
        "/uploads/posts/post-12-1766972187274-3.jpg"
      ],
      "createdAt": "2025-12-29T01:36:27.329Z",
      "updatedAt": "2025-12-29T01:36:27.329Z",
      "user": {
        "id": 12,
        "username": "yayat123",
        "name": "yayat",
        "fotoProfil": "/uploads/profiles/profil-12-1766836576676-816058455.jpg"
      },
      "likeCount": 0,
      "commentCount": 0,
      "likedByMe": false
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 13,
    "totalPages": 2,
    "hasMore": true,
    "query": "test"
  }
}
```

### Error Responses

#### 400 Bad Request - Query Required
```json
{
  "success": false,
  "message": "Search query is required"
}
```

#### 400 Bad Request - Query Too Short
```json
{
  "success": false,
  "message": "Search query must be at least 2 characters"
}
```

#### 401 Unauthorized
```json
{
  "success": false,
  "message": "Unauthorized"
}
```

#### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error message here"
}
```

---

## Response Fields

### Post Object

| Field          | Type      | Description                                    |
|----------------|-----------|------------------------------------------------|
| `id`           | integer   | Unique post identifier                         |
| `content`      | string    | Post text content                              |
| `imageUrl`     | string    | Primary image URL (backward compatibility)     |
| `imageUrls`    | array     | Array of all image URLs                        |
| `createdAt`    | string    | ISO 8601 timestamp                             |
| `updatedAt`    | string    | ISO 8601 timestamp                             |
| `user`         | object    | User information                               |
| `likeCount`    | integer   | Total number of likes                          |
| `commentCount` | integer   | Total number of comments                       |
| `likedByMe`    | boolean   | Whether current user liked this post           |

### User Object

| Field        | Type    | Description                |
|--------------|---------|----------------------------|
| `id`         | integer | User ID                    |
| `username`   | string  | Username                   |
| `name`       | string  | Display name               |
| `fotoProfil` | string  | Profile picture URL        |

### Pagination Object

| Field         | Type    | Description                              |
|---------------|---------|------------------------------------------|
| `page`        | integer | Current page number                      |
| `limit`       | integer | Items per page                           |
| `total`       | integer | Total number of results                  |
| `totalPages`  | integer | Total number of pages                    |
| `hasMore`     | boolean | Whether there are more pages             |
| `query`       | string  | The search keyword used                  |

---

## Features

### ✅ Case-Insensitive Search
Search query is **case-insensitive**. Searching for "TEST", "test", or "TeSt" will return the same results.

```javascript
// All these queries return the same results
await searchPosts('test');
await searchPosts('TEST');
await searchPosts('TeSt');
```

### ✅ Blocked Users Filter
Posts from blocked users (and users who blocked you) are automatically excluded from search results.

### ✅ Pagination Support
Navigate through results using page and limit parameters.

```javascript
// Get first page
const page1 = await searchPosts('test', 1, 10);

// Get next page if available
if (page1.pagination.hasMore) {
  const page2 = await searchPosts('test', 2, 10);
}
```

---

## React Implementation Example

### Search Component

```jsx
import React, { useState, useEffect } from 'react';
import axios from 'axios';

const PostSearch = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [pagination, setPagination] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const searchPosts = async (page = 1) => {
    if (query.length < 2) {
      setError('Search query must be at least 2 characters');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const response = await axios.get('http://localhost:3030/api/posts/search', {
        params: { q: query, page, limit: 10 },
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('accessToken')}`
        }
      });

      setResults(response.data.data);
      setPagination(response.data.pagination);
    } catch (err) {
      setError(err.response?.data?.message || 'Search failed');
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e) => {
    e.preventDefault();
    searchPosts(1);
  };

  const handleLoadMore = () => {
    searchPosts(pagination.page + 1);
  };

  return (
    <div className="search-container">
      <form onSubmit={handleSearch}>
        <input
          type="text"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search posts..."
          minLength={2}
        />
        <button type="submit" disabled={loading}>
          {loading ? 'Searching...' : 'Search'}
        </button>
      </form>

      {error && <p className="error">{error}</p>}

      <div className="results">
        {results.map(post => (
          <div key={post.id} className="post-card">
            <div className="post-header">
              <img src={post.user.fotoProfil} alt={post.user.name} />
              <div>
                <h4>{post.user.name}</h4>
                <p>@{post.user.username}</p>
              </div>
            </div>
            <p>{post.content}</p>
            {post.imageUrls && (
              <div className="images">
                {post.imageUrls.map((url, idx) => (
                  <img key={idx} src={url} alt={`Post image ${idx + 1}`} />
                ))}
              </div>
            )}
            <div className="post-stats">
              <span>❤️ {post.likeCount}</span>
              <span>💬 {post.commentCount}</span>
            </div>
          </div>
        ))}
      </div>

      {pagination.hasMore && (
        <button onClick={handleLoadMore} disabled={loading}>
          Load More
        </button>
      )}

      {pagination.total > 0 && (
        <p className="pagination-info">
          Showing {results.length} of {pagination.total} results
          (Page {pagination.page} of {pagination.totalPages})
        </p>
      )}
    </div>
  );
};

export default PostSearch;
```

---

## Custom Hook Example

```javascript
import { useState, useCallback } from 'react';
import axios from 'axios';

export const usePostSearch = () => {
  const [results, setResults] = useState([]);
  const [pagination, setPagination] = useState({});
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const search = useCallback(async (query, page = 1, limit = 10) => {
    if (!query || query.length < 2) {
      setError('Search query must be at least 2 characters');
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const { data } = await axios.get('http://localhost:3030/api/posts/search', {
        params: { q: query, page, limit },
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('accessToken')}`
        }
      });

      if (page === 1) {
        setResults(data.data);
      } else {
        setResults(prev => [...prev, ...data.data]);
      }
      
      setPagination(data.pagination);
      return data;
    } catch (err) {
      const errorMsg = err.response?.data?.message || 'Search failed';
      setError(errorMsg);
      throw err;
    } finally {
      setLoading(false);
    }
  }, []);

  const reset = useCallback(() => {
    setResults([]);
    setPagination({});
    setError(null);
  }, []);

  return {
    results,
    pagination,
    loading,
    error,
    search,
    reset
  };
};

// Usage
const SearchPage = () => {
  const { results, pagination, loading, error, search } = usePostSearch();
  const [query, setQuery] = useState('');

  const handleSearch = () => {
    search(query, 1);
  };

  const handleLoadMore = () => {
    search(query, pagination.page + 1);
  };

  // ... render component
};
```

---

## Validation Rules

| Rule                    | Requirement                  |
|-------------------------|------------------------------|
| Query length            | Minimum 2 characters         |
| Query required          | Must provide `q` or `query`  |
| Authentication          | Valid Bearer token required  |
| Page number             | Must be positive integer     |
| Limit                   | Must be positive integer     |

---

## Best Practices

### 1. Debounce Search Input
```javascript
import { debounce } from 'lodash';

const debouncedSearch = debounce((query) => {
  searchPosts(query);
}, 500);

<input onChange={(e) => debouncedSearch(e.target.value)} />
```

### 2. Handle Token Expiration
```javascript
const searchPosts = async (keyword) => {
  try {
    const response = await axios.get(/* ... */);
    return response.data;
  } catch (error) {
    if (error.response?.status === 401) {
      // Token expired, refresh or redirect to login
      refreshToken();
    }
    throw error;
  }
};
```

### 3. Loading States
```javascript
{loading && <Spinner />}
{!loading && results.length === 0 && <p>No results found</p>}
{!loading && results.length > 0 && <ResultsList />}
```

### 4. Error Handling
```javascript
try {
  await searchPosts(query);
} catch (error) {
  if (error.response?.status === 400) {
    toast.error(error.response.data.message);
  } else {
    toast.error('Something went wrong');
  }
}
```

---

## Testing Examples

### Test Search Query
```javascript
// Test minimum length
await searchPosts('a'); // Should fail
await searchPosts('ab'); // Should succeed

// Test case-insensitive
await searchPosts('TEST');
await searchPosts('test');
// Both should return same results
```

### Test Pagination
```javascript
const page1 = await searchPosts('test', 1, 10);
console.log(page1.pagination.hasMore); // true if more results

if (page1.pagination.hasMore) {
  const page2 = await searchPosts('test', 2, 10);
  console.log(page2.pagination.page); // 2
}
```

---

## Common Issues & Solutions

### Issue: "Invalid token"
**Solution:** Refresh access token or redirect to login

### Issue: Query too short error
**Solution:** Validate input before making request
```javascript
if (query.length < 2) {
  return; // Don't make request
}
```

### Issue: Empty results
**Possible causes:**
- No posts match the search query
- All matching posts are from blocked users
- Network issue

---

## Rate Limiting

Currently no rate limiting implemented. Consider implementing debounce on frontend to reduce API calls.

---

## Support

For issues or questions, contact backend team or check API logs.

**Last Updated:** December 29, 2025