# Feature: Search Posts

## Overview
Fitur pencarian postingan yang memungkinkan user mencari postingan berdasarkan kata kunci dengan pagination support.

## Status
✅ **COMPLETE** - Implemented and Ready for Testing

## Implementation Date
January 2025

## Backend API
- **Endpoint**: `GET /api/posts/search`
- **Auth**: Bearer token required
- **Parameters**:
  - `q` atau `query` (required): Kata kunci pencarian, minimal 2 karakter
  - `page` (optional, default: 1): Halaman hasil
  - `limit` (optional, default: 10): Jumlah hasil per halaman
- **Response Format**:
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "content": "Post content...",
      "user": {
        "id": 1,
        "username": "username",
        "fotoProfil": "/uploads/..."
      },
      "likeCount": 10,
      "commentCount": 5,
      "likedByMe": false,
      "image1": "/uploads/...",
      "image2": null,
      "createdAt": "2025-01-15T10:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10,
    "hasMore": true,
    "query": "search term"
  }
}
```

## Architecture

### 1. Service Layer
**File**: `lib/services/search_service.dart`

**Classes**:
- `SearchService`: Main service class
  - Dependencies: `ApiService`
  - Method: `searchPosts({required String query, int page, int limit})`
  
- `SearchResult`: Container for search results
  - Properties: `List<PostModel> posts`, `SearchPagination pagination`
  
- `SearchPagination`: Pagination metadata
  - Properties: `page`, `limit`, `total`, `totalPages`, `hasMore`, `query`

**Features**:
- ✅ Query validation (not empty, min 2 chars)
- ✅ URI encoding for safe API calls
- ✅ Automatic token authentication
- ✅ Error handling with developer logs
- ✅ Pagination support

**Code Sample**:
```dart
final searchService = SearchService(ApiService());
final result = await searchService.searchPosts(
  query: 'flutter',
  page: 1,
  limit: 10,
);

print('Found ${result.pagination.total} posts');
print('Has more: ${result.pagination.hasMore}');
```

### 2. UI Layer
**File**: `lib/pages/feed/search_posts_page.dart`

**Components**:
- Search bar with TextField
- Results list with post cards
- Pagination with auto-load on scroll
- Empty states (no query, no results)
- Loading indicators (initial, load more)
- Error handling with messages

**Features**:
- ✅ Real-time search bar with clear button
- ✅ Search on Enter/Submit
- ✅ Validation feedback (min 2 chars)
- ✅ Post card with user info, content, images
- ✅ Image carousel for multiple images
- ✅ Navigation to post detail
- ✅ Like/comment counts display
- ✅ Relative time display (timeago)
- ✅ Infinite scroll pagination
- ✅ Pull-to-refresh (via scroll)
- ✅ Empty state with search icon
- ✅ No results state with "Cari Lagi" button
- ✅ Result count and page info display

**States Handled**:
1. **Initial State**: Empty with search icon and instructions
2. **Loading State**: CircularProgressIndicator during search
3. **Results State**: List of post cards with pagination info
4. **Empty Results State**: "Tidak ada hasil" message with retry button
5. **Error State**: Red error banner at top
6. **Loading More State**: Loading indicator at bottom during pagination

### 3. Navigation Integration
**Files Updated**:
- `lib/pages/beranda/beranda_page.dart`: Added search icon button in header
- `lib/routes.dart`: Added `/search_posts` route

**User Flow**:
1. User taps search icon in BerandaPage header (red search icon)
2. Navigates to SearchPostsPage
3. User types query in search bar
4. Press Enter or search button
5. Results displayed with pagination info
6. Scroll to load more (auto-load near bottom)
7. Tap post card to view detail
8. Clear button to reset search

## UI/UX Specifications

### Search Bar
- **Location**: Top of screen, below AppBar
- **Style**: White background, rounded corners (12px), red accent
- **Components**:
  - Prefix: Red search icon
  - Input: "Cari postingan..." placeholder
  - Suffix: Clear button (X) when text exists
- **Behavior**:
  - Submit on Enter key
  - Clear resets entire search state
  - Real-time validation feedback

### Post Card
- **Style**: White card with shadow, 16px margin horizontal, 8px vertical
- **Components**:
  - User avatar (circular, 20px radius)
  - Username (bold, 16px)
  - Username handle (@username, grey, 14px)
  - Relative time (grey, 12px)
  - Content text (15px)
  - Image carousel (rounded 12px, 150px height)
  - Image counter badge (1/3 format)
  - Like/comment counts with icons
- **Interaction**: Tap anywhere to open post detail

### Pagination Info
- **Location**: Below search bar, above results
- **Display**: "Ditemukan X hasil" | "Halaman Y dari Z"
- **Style**: Grey text, 16px horizontal padding

### Empty States
- **Initial**: Large search icon (80px), "Cari Postingan" title, instructions
- **No Results**: Large search-off icon (80px), "Tidak ada hasil" title, query display, "Cari Lagi" button

### Loading States
- **Initial Search**: Center CircularProgressIndicator
- **Load More**: Bottom CircularProgressIndicator with 16px padding

### Error State
- **Display**: Red banner at top with error icon and message
- **Style**: Red background (light red-50), red text, error icon

## Technical Implementation

### Query Validation
```dart
// Minimum 2 characters
if (query.length < 2) {
  setState(() {
    _errorMessage = 'Minimal 2 karakter untuk pencarian';
  });
  return;
}

// URI encoding
final encodedQuery = Uri.encodeComponent(query);
```

### Pagination Logic
```dart
// Auto-load when near bottom
void _onScroll() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 200) {
    _loadMore();
  }
}

// Append results, don't replace
setState(() {
  _posts.addAll(result.posts);
  _pagination = result.pagination;
});
```

### Image Handling
```dart
// Single image: Direct display
// Multiple images: Carousel with indicator

if (images.length == 1) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(images[0], ...),
  );
}

// Carousel for multiple images
return _ImageCarouselWithIndicator(images: images);
```

### Navigation
```dart
// From BerandaPage header
IconButton(
  icon: const Icon(Icons.search, color: Colors.red, size: 28),
  onPressed: () {
    Navigator.pushNamed(context, '/search_posts');
  },
),

// From post card tap
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostDetailPage(post: post),
      ),
    );
  },
  child: ...,
)
```

## Dependencies
- `flutter/material.dart`: UI framework
- `timeago`: Relative time display ("2 jam yang lalu")
- `carousel_slider`: Image carousel for multiple images
- `http`: HTTP client (via ApiService)
- Existing models: `PostModel`, `UserModel`
- Existing services: `ApiService`, `SearchService`
- Existing pages: `PostDetailPage`

## Testing Checklist

### Functional Testing
- [ ] Search with valid query (>= 2 chars) returns results
- [ ] Search with invalid query (< 2 chars) shows validation error
- [ ] Empty query shows validation error
- [ ] Search icon in BerandaPage navigates to SearchPostsPage
- [ ] Clear button resets search state
- [ ] Pagination loads more results on scroll
- [ ] Last page stops pagination (no infinite loop)
- [ ] Post card tap navigates to PostDetailPage
- [ ] Back button returns to search results (state preserved)

### UI/UX Testing
- [ ] Search bar displays correctly with icons
- [ ] Initial empty state shows search icon and instructions
- [ ] No results state shows search-off icon and "Cari Lagi" button
- [ ] Post cards display user info correctly
- [ ] Avatar fallback shows first letter of username
- [ ] Image URLs construct correctly (baseUrl + path)
- [ ] Single image displays without carousel
- [ ] Multiple images show carousel with counter badge
- [ ] Like/comment icons and counts display
- [ ] Relative time displays in Indonesian
- [ ] Pagination info displays correctly
- [ ] Loading indicators show during fetch

### Performance Testing
- [ ] Search doesn't freeze UI
- [ ] Pagination is smooth (no lag on scroll)
- [ ] Images load without blocking
- [ ] Large result sets handled efficiently
- [ ] Memory doesn't leak on repeated searches
- [ ] Scroll position maintained during pagination

### Error Handling Testing
- [ ] Network error shows error banner
- [ ] Timeout shows appropriate message
- [ ] 401 unauthorized handled (token refresh)
- [ ] 400 bad request shows validation error
- [ ] 500 server error shows generic error
- [ ] Error banner dismissible (via clear/new search)

### Edge Cases
- [ ] Special characters in query (encoded correctly)
- [ ] Very long query (doesn't break UI)
- [ ] Empty content post (doesn't crash)
- [ ] Posts without images (displays correctly)
- [ ] Posts with 10 images (carousel works)
- [ ] User without avatar (fallback works)
- [ ] Blocked users filtered (by backend)
- [ ] Very long content (scrollable in card)

### Integration Testing
- [ ] Works with existing ApiService token refresh
- [ ] Works with existing PostDetailPage navigation
- [ ] Works with existing PostModel data structure
- [ ] Works with existing navigation system
- [ ] Works with existing user session

## Known Issues
- None (feature just implemented)

## Future Enhancements
1. **Debounced Search**: Add debouncing to search input (500ms delay)
2. **Search History**: Show recent searches
3. **Search Suggestions**: Auto-complete suggestions
4. **Filter Options**: Filter by date, user, etc.
5. **Sort Options**: Sort by relevance, date, likes
6. **Advanced Search**: Search by hashtags, mentions (when implemented)
7. **Save Search**: Bookmark favorite searches
8. **Search Highlights**: Highlight matching text in results

## Backend Requirements Met
✅ All requirements from `post_search_api_doc.md` implemented:
- Query parameter with URI encoding
- Pagination support (page, limit)
- Bearer token authentication
- Case-insensitive search handled by backend
- Blocked users filtered by backend
- Error handling for all response codes

## Related Features
- **Next Phase**: Hashtags Feature (requires backend implementation)
- **Next Phase**: Mentions/Tags Feature (requires backend implementation)
- **Next Phase**: Trending Posts Feature (requires backend implementation)

All features documented in: `dokumentasiFE/BACKEND_REQUEST_SEARCH_DISCOVER_FEATURES.md`

## Developer Notes
- Search query is encoded with `Uri.encodeComponent()` for safety
- Pagination auto-loads 200px before bottom of scroll
- PostModel reused from existing feed implementation
- Image carousel logic extracted to separate widget for reusability
- Developer logs added for debugging (search 'DV' prefix)
- Follow existing patterns from FeedPage for consistency

## Support
For issues or questions, refer to:
- Backend API: `post_search_api_doc.md`
- Backend Spec: `dokumentasiFE/BACKEND_REQUEST_SEARCH_DISCOVER_FEATURES.md`
- Service Code: `lib/services/search_service.dart`
- UI Code: `lib/pages/feed/search_posts_page.dart`
