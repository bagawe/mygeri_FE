import 'package:flutter/material.dart';
import '../../models/hashtag.dart';
import '../../services/hashtag_service.dart';
import '../../services/api_service.dart';
import 'hashtag_posts_page.dart';

class TrendingHashtagsWidget extends StatefulWidget {
  final int limit;
  
  const TrendingHashtagsWidget({
    super.key,
    this.limit = 10,
  });

  @override
  State<TrendingHashtagsWidget> createState() => _TrendingHashtagsWidgetState();
}

class _TrendingHashtagsWidgetState extends State<TrendingHashtagsWidget> {
  final HashtagService _hashtagService = HashtagService(ApiService());
  List<Hashtag> _hashtags = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrendingHashtags();
  }

  Future<void> _loadTrendingHashtags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hashtags = await _hashtagService.getTrendingHashtags(
        limit: widget.limit,
      );
      
      if (mounted) {
        setState(() {
          _hashtags = hashtags;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat hashtag trending',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loadTrendingHashtags,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_hashtags.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Belum ada hashtag trending',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _hashtags.map((hashtag) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildHashtagChip(hashtag),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHashtagChip(Hashtag hashtag) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HashtagPostsPage(hashtag: hashtag.hashtag),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue[200]!, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tag,
              size: 18,
              color: Colors.blue[700],
            ),
            const SizedBox(width: 4),
            Text(
              '#${hashtag.hashtag}',
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${hashtag.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
