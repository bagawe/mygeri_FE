import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import '../../models/post.dart';
import '../../models/hashtag.dart';
import '../../services/hashtag_service.dart';
import '../../services/api_service.dart';
import '../feed/post_detail_page.dart';

class HashtagPostsPage extends StatefulWidget {
  final String hashtag;

  const HashtagPostsPage({
    super.key,
    required this.hashtag,
  });

  @override
  State<HashtagPostsPage> createState() => _HashtagPostsPageState();
}

class _HashtagPostsPageState extends State<HashtagPostsPage> {
  final HashtagService _hashtagService = HashtagService(ApiService());
  final ScrollController _scrollController = ScrollController();

  List<PostModel> _posts = [];
  PaginationMeta? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadPosts({bool isNewLoad = true}) async {
    if (isNewLoad) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _posts = [];
        _pagination = null;
      });
    } else {
      if (_isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final page = isNewLoad ? 1 : (_pagination?.page ?? 0) + 1;
      
      final result = await _hashtagService.getPostsByHashtag(
        hashtag: widget.hashtag,
        page: page,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          if (isNewLoad) {
            _posts = result['posts'] as List<PostModel>;
          } else {
            _posts.addAll(result['posts'] as List<PostModel>);
          }
          _pagination = result['meta'] as PaginationMeta;
          _isLoading = false;
          _isLoadingMore = false;
        });
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
    await _loadPosts(isNewLoad: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tag, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              '#${widget.hashtag}',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ],
        ),
        actions: [
          if (_pagination != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: Text(
                  '${_pagination!.total} posts',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(isNewLoad: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat postingan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadPosts(isNewLoad: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada postingan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada postingan dengan #${widget.hashtag}',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
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
    );
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
