import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import '../feed/feed_page.dart';
import '../feed/create_post_page.dart';
import '../hashtag/trending_hashtags_widget.dart';
import '../radar/radar_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final ProfileService _profileService = ProfileService(ApiService());
  UserProfile? _userProfile;
  bool _isLoading = true;
  
  // Key untuk refresh feed
  int _feedRefreshKey = 0;

  void _refreshFeed() {
    setState(() {
      _feedRefreshKey++;
    });
  }

  @override
  void initState() {
    super.initState();
    // Load profile async (non-blocking) - UI shows immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final profile = await _profileService.getProfile().timeout(
        const Duration(seconds: 5), // Reduced from 10s to 5s
        onTimeout: () {
          throw TimeoutException('Profile loading timeout');
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      // Show error but don't block UI
      if (e is TimeoutException) {
        print('⚠️ Profile load timeout - continuing with cached/placeholder data');
      }
    }
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.construction, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Text('Coming Soon'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur $featureName sedang dalam pengembangan.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'Kami akan segera meluncurkan fitur ini untuk Anda!',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Menu icon data
    final List<Map<String, dynamic>> menuItems = [
      {'icon': 'assets/icons/gerinda.png', 'isAsset': true, 'label': 'My Gerindra'},
      {'icon': 'assets/icons/profil.jpeg', 'isAsset': true, 'label': 'KTA'},
      {'icon': 'assets/icons/radar.png', 'isAsset': true, 'label': 'Radar'},
      {'icon': 'assets/icons/agenda.jpeg', 'isAsset': true, 'label': 'Agenda'},
      {'icon': 'assets/icons/voting.jpeg', 'isAsset': true, 'label': 'Voting'},
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Foto profil
                  _isLoading
                      ? const CircleAvatar(radius: 22, backgroundColor: Colors.grey)
                      : (_userProfile?.fotoProfil != null && _userProfile!.fotoProfil!.isNotEmpty)
                          ? CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: NetworkImage('${ApiService.baseUrl}${_userProfile!.fotoProfil}'),
                            )
                          : const CircleAvatar(radius: 22, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white, size: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoading
                            ? Container(width: 80, height: 16, color: Colors.grey[300])
                            : Text(
                                _userProfile?.name ?? '-',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                        _isLoading
                            ? Container(width: 60, height: 14, color: Colors.grey[200])
                            : Text(
                                _userProfile?.username != null ? '@${_userProfile!.username}' : '-',
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                      ],
                    ),
                  ),
                  // Search button
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.grey[700], size: 28),
                    onPressed: () {
                      Navigator.pushNamed(context, '/search_posts');
                    },
                  ),
                ],
              ),
            ),
            // Menu ikon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: menuItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  
                  return GestureDetector(
                    onTap: () {
                      // Radar menu (index 2) navigates to RadarPage
                      if (index == 2 && item['label'] == 'Radar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RadarPage()),
                        );
                      } else {
                        _showComingSoonDialog(item['label']);
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: item['isAsset'] == true
                              ? Image.asset(
                                  item['icon'],
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: Colors.grey[600]),
                                )
                              : Icon(item['icon'], size: 36, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 6),
                        Text(item['label'], style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            
            // Trending Hashtags
            const TrendingHashtagsWidget(limit: 10),
            const SizedBox(height: 10),
            
            // Section konten - Feed Postingan
            Expanded(
              key: ValueKey(_feedRefreshKey),
              child: const FeedPage(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
          
          // Jika postingan berhasil dibuat, refresh feed
          if (result == true) {
            _refreshFeed();
          }
        },
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        elevation: 4,
        tooltip: 'Buat Postingan',
        child: const Icon(Icons.add),
      ),
    );
  }
}
