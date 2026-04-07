import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/user_profile.dart';
import '../../services/profile_service.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../feed/feed_page.dart';
import '../feed/create_post_page.dart';
import '../hashtag/trending_hashtags_widget.dart';
import '../radar/radar_page.dart';
import '../kta/kta_page.dart';
import '../agenda/agenda_page.dart';
import '../announcement/announcement_page.dart';
import '../maintenance/maintenance_page.dart';
import '../voting/voting_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  final ProfileService _profileService = ProfileService(ApiService());
  final StorageService _storageService = StorageService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _userRole = 'simpatisan'; // Role dari storage, selalu up-to-date

  // Periodic refresh timer (setiap 30 detik cek perubahan role)
  Timer? _roleRefreshTimer;

  // Key untuk refresh feed
  int _feedRefreshKey = 0;

  void _refreshFeed() {
    setState(() {
      _feedRefreshKey++;
    });
  }

  Future<void> _onRefresh() async {
    await _loadProfile();
    setState(() {
      _feedRefreshKey++;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load role dari storage terlebih dahulu (instant, tanpa API call)
      final cachedRole = await _storageService.getUserRole();
      if (mounted) {
        setState(() {
          _userRole = cachedRole;
        });
      }
      // Load profile dari API (update role ke yang terbaru)
      await _loadProfile();
      // Mulai periodic refresh untuk deteksi perubahan role
      _startRoleRefreshTimer();
    });
  }

  @override
  void dispose() {
    _roleRefreshTimer?.cancel();
    super.dispose();
  }

  /// Periodic refresh setiap 30 detik untuk mendeteksi perubahan role
  void _startRoleRefreshTimer() {
    _roleRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!mounted) return;
      try {
        final result = await _profileService.refreshUserProfile();
        if (!mounted) return;

        final newRole = result['newRole'] as String;
        final roleChanged = result['roleChanged'] as bool;

        if (roleChanged) {
          setState(() {
            _userRole = newRole;
            _userProfile = result['profile'] as UserProfile;
          });

          // Tampilkan dialog selamat jika naik dari simpatisan ke kader
          if (result['oldRole'] == 'simpatisan' && newRole == 'kader') {
            _showRoleUpgradeDialog();
          }
        }
      } catch (e) {
        // Silent fail — tidak ganggu UX jika periodic refresh gagal
        print('⚠️ Periodic role refresh failed: $e');
      }
    });
  }

  /// Dialog selamat saat role berubah dari simpatisan → kader
  void _showRoleUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber[700], size: 28),
            const SizedBox(width: 12),
            const Text('Selamat! 🎉'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun Anda telah diverifikasi oleh admin!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Anda sekarang menjadi Kader dan dapat mengakses semua fitur aplikasi.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE41E26),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Lihat Fitur Kader'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _profileService.refreshUserProfile().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Profile loading timeout');
        },
      );

      if (!mounted) return;

      final newRole = result['newRole'] as String;
      final roleChanged = result['roleChanged'] as bool;

      setState(() {
        _userProfile = result['profile'] as UserProfile;
        _userRole = newRole;
        _isLoading = false;
      });

      // Tampilkan dialog jika role baru saja naik ke kader
      if (roleChanged && result['oldRole'] == 'simpatisan' && newRole == 'kader') {
        _showRoleUpgradeDialog();
      }
    } catch (e) {
      print('❌ Error loading profile: $e');

      // Cek apakah ini network error (Connection refused)
      if (e.toString().contains('Connection refused') ||
          e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MaintenancePage()),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (e is TimeoutException) {
        print('⚠️ Profile load timeout - continuing with cached/placeholder data');
      }
    }
  }

  // Cek akses fitur berdasarkan role dari storage (BUKAN dari JWT)
  bool _hasAccessToFeature(String featureName) {
    if (featureName == 'Agenda' || featureName == 'My Gerindra' || featureName == 'Voting') {
      return _userRole == 'kader' || _userRole == 'admin';
    }
    return true;
  }

  // Popup akses terbatas
  void _showAccessDeniedDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.red[700], size: 28),
            const SizedBox(width: 12),
            const Text('Akses Terbatas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitur $featureName hanya tersedia untuk Kader dan Admin.',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Role Anda: ${_userRole.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Akun Anda masih dalam proses verifikasi oleh admin. Setelah diverifikasi, Anda akan otomatis mendapatkan akses penuh sebagai Kader.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFFE41E26),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Header profil
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          _isLoading
                              ? const CircleAvatar(radius: 22, backgroundColor: Colors.grey)
                              : (_userProfile?.fotoProfil != null && _userProfile!.fotoProfil!.isNotEmpty)
                                  ? CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: NetworkImage('${ApiService.baseUrl}${_userProfile!.fotoProfil}'),
                                    )
                                  : const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Colors.grey,
                                      child: Icon(Icons.person, color: Colors.white, size: 28),
                                    ),
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
                              if (index == 0 && item['label'] == 'My Gerindra') {
                                if (_hasAccessToFeature('My Gerindra')) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AnnouncementPage()));
                                } else {
                                  _showAccessDeniedDialog('My Gerindra');
                                }
                              } else if (index == 1 && item['label'] == 'KTA') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const KTAPage()));
                              } else if (index == 2 && item['label'] == 'Radar') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RadarPage()));
                              } else if (index == 3 && item['label'] == 'Agenda') {
                                if (_hasAccessToFeature('Agenda')) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AgendaPage()));
                                } else {
                                  _showAccessDeniedDialog('Agenda');
                                }
                              } else if (index == 4 && item['label'] == 'Voting') {
                                if (_hasAccessToFeature('Voting')) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VotingPage()));
                                } else {
                                  _showAccessDeniedDialog('Voting');
                                }
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
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.image, color: Colors.grey[600]),
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
                  ],
                ),
              ),
            ],
            body: FeedPage(key: ValueKey(_feedRefreshKey)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePostPage()),
          );
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
