import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/post.dart';
import '../../services/search_service.dart';
import '../../services/api_service.dart';
import '../../services/history_service.dart';
import '../feed/post_detail_page.dart';

class SearchPostsPage extends StatefulWidget {
  const SearchPostsPage({super.key});

  @override
  State<SearchPostsPage> createState() => _SearchPostsPageState();
}

class _SearchPostsPageState extends State<SearchPostsPage> {
  final SearchService _searchService = SearchService(ApiService());
  final HistoryService _historyService = HistoryService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _posts = [];
  SearchPagination? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String? _currentQuery;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _performSearch({bool isNewSearch = true}) async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan kata kunci pencarian';
      });
      return;
    }

    if (query.length < 2) {
      setState(() {
        _errorMessage = 'Minimal 2 karakter untuk pencarian';
      });
      return;
    }

    if (isNewSearch) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _posts = [];
        _pagination = null;
        _currentQuery = query;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final page = isNewSearch ? 1 : (_pagination?.page ?? 0) + 1;
      
      final result = await _searchService.searchPosts(
        query: query,
        page: page,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          if (isNewSearch) {
            _posts = result.posts;
          } else {
            _posts.addAll(result.posts);
          }
          _pagination = result.pagination;
          _isLoading = false;
          _isLoadingMore = false;
        });
        
        // Log riwayat hanya untuk pencarian baru (bukan load more)
        if (isNewSearch) {
          try {
            await _historyService.logHistory(
              'search_post',
              description: 'Mencari postingan: "$query"',
              metadata: {
                'query': query,
                'results_count': result.pagination.total,
                'page': 1,
              },
            );
          } catch (e) {
            print('⚠️ Gagal mencatat riwayat pencarian: $e');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !(_pagination?.hasMore ?? false)) return;
    await _performSearch(isNewSearch: false);
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari postingan...',
          prefixIcon: const Icon(Icons.search, color: Colors.red),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _posts = [];
                      _pagination = null;
                      _errorMessage = null;
                      _currentQuery = null;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          setState(() {}); // Update UI for clear button
        },
        onSubmitted: (value) {
          _performSearch();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_currentQuery == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Cari Postingan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Masukkan kata kunci untuk mencari postingan',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tidak ditemukan postingan untuk "$_currentQuery"',
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _posts = [];
                  _pagination = null;
                  _currentQuery = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Cari Lagi'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPostCard(PostModel post) {
    final baseUrl = ApiService.baseUrl;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.grey[50],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: post.user.fotoProfil != null
                        ? NetworkImage(
                            post.user.fotoProfil!.startsWith('http')
                                ? post.user.fotoProfil!
                                : '$baseUrl${post.user.fotoProfil}',
                          )
                        : null,
                    child: post.user.fotoProfil == null
                        ? Text(
                            post.user.username[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user.username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '@${post.user.username}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    timeago.format(post.createdAt, locale: 'id'),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Content
              if (post.content != null)
                Text(
                  post.content!,
                  style: const TextStyle(fontSize: 15),
                ),
              
              // Images
              if (post.getAllImageUrls().isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildImageCarousel(post),
              ],
              
              const SizedBox(height: 12),
              
              // Stats
              Row(
                children: [
                  Icon(
                    post.likedByMe ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: post.likedByMe ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likeCount}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${post.commentCount}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(PostModel post) {
    final images = post.getFullImageUrls(ApiService.baseUrl);
    
    if (images.isEmpty) return const SizedBox.shrink();
    if (images.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[0],
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    }

    return _ImageCarouselWithIndicator(images: images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Postingan'),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          
          if (_errorMessage != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_pagination != null && _posts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ditemukan ${_pagination!.total} hasil',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Halaman ${_pagination!.page} dari ${_pagination!.totalPages}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _posts.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _posts.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return _buildPostCard(_posts[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// Image carousel widget with indicator
class _ImageCarouselWithIndicator extends StatefulWidget {
  final List<String> images;

  const _ImageCarouselWithIndicator({required this.images});

  @override
  State<_ImageCarouselWithIndicator> createState() =>
      _ImageCarouselWithIndicatorState();
}

class _ImageCarouselWithIndicatorState
    extends State<_ImageCarouselWithIndicator> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.images.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_currentIndex + 1}/${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
