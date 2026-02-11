import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_profile.dart';
import '../../models/post.dart';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import '../../services/post_service.dart';
import 'edit_profil_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _profileService = ProfileService(ApiService());
  final PostService _postService = PostService(ApiService());
  
  UserProfile? _userProfile;
  List<PostModel> _userPosts = [];
  bool _isLoading = true;
  bool _isLoadingPosts = false;
  String? _errorMessage;
  bool _isLoadingInProgress = false; // Prevent multiple simultaneous loads

  @override
  void initState() {
    super.initState();
    // Load profile and posts immediately when page is opened
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Prevent multiple simultaneous loads
    if (_isLoadingInProgress) {
      print('⚠️ Profile load already in progress, skipping...');
      return;
    }

    _isLoadingInProgress = true;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileService.getProfile();
      if (mounted) {
        // Clear image cache to force reload of profile picture
        if (profile.fotoProfil != null && profile.fotoProfil!.isNotEmpty) {
          try {
            await PaintingBinding.instance.imageCache.evict(NetworkImage(profile.fotoProfil!));
            print('🔄 Image cache cleared for profile picture');
          } catch (e) {
            print('⚠️ Error clearing image cache: $e');
          }
        }
        
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
        
        // Load user posts after profile is loaded
        _loadUserPosts();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat profil: $e';
          _isLoading = false;
        });
      }
      print('❌ Error loading profile: $e');
    } finally {
      _isLoadingInProgress = false;
    }
  }

  Future<void> _loadUserPosts() async {
    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final response = await _postService.getUserPosts(page: 1, limit: 20);
      if (mounted) {
        setState(() {
          _userPosts = response.data ?? [];
          _isLoadingPosts = false;
        });
        print('✅ Loaded ${_userPosts.length} user posts');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPosts = false;
        });
      }
      print('❌ Error loading user posts: $e');
    }
  }

  String _getData(String? val) => (val == null || val.isEmpty) ? '-' : val;
  
  String _formatTanggal(DateTime? tanggal) {
    if (tanggal == null) return '-';
    
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    return '${tanggal.day} ${months[tanggal.month - 1]} ${tanggal.year}';
  }
  
  String _formatTTL() {
    if (_userProfile == null) return '-';
    
    final tempat = _userProfile!.tempatLahir;
    final tanggal = _userProfile!.tanggalLahir;
    
    if (tempat == null && tanggal == null) return '-';
    if (tanggal == null) return tempat ?? '-';
    
    return '${tempat ?? ''}, ${_formatTanggal(tanggal)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          if (_userProfile != null) // Only show edit button when profile is loaded
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () async {
                // Navigate to EditProfilPage
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfilPage(),
                  ),
                );
                
                // Reload profile if edit was successful
                if (result == true) {
                  _loadProfile();
                }
              },
              tooltip: 'Edit Profil',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_userProfile == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Profil belum tersedia'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header tanpa logo
            const SizedBox(height: 20),
            
            // Profile Picture
            Center(
              child: ClipOval(
                child: _userProfile!.fotoProfil != null && _userProfile!.fotoProfil!.isNotEmpty
                    ? Image.network(
                        '${ApiService.baseUrl}${_userProfile!.fotoProfil}',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        cacheWidth: 120,
                        cacheHeight: 120,
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Error loading image: ${ApiService.baseUrl}${_userProfile!.fotoProfil}');
                          print('❌ Error: $error');
                          return _defaultAvatar();
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      )
                    : _defaultAvatar(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Welcome Text
            Text(
              'Selamat Datang ${_getData(_userProfile!.name)}!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            
            // Profile Details
            _buildProfileCard(),
            
            // Posts Section
            if (_userPosts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Text(
                      'Postingan Saya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._userPosts.map((post) => _buildPostCard(post)).toList(),
                ],
              )
            else if (!_isLoadingPosts)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.post_add_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada postingan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 30),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 60, color: Colors.white),
    );
  }

  Widget _buildProfileCard() {
    return Card(
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
          children: [
            _buildInfoRow('NIK', _getData(_userProfile!.nik)),
            const Divider(),
            _buildInfoRow('Nama Lengkap', _getData(_userProfile!.name)),
            const Divider(),
            _buildInfoRow('Email', _getData(_userProfile!.email)),
            const Divider(),
            _buildInfoRow('No HP', _getData(_userProfile!.phone)),
            const Divider(),
            _buildInfoRow('Tempat, Tanggal Lahir', _formatTTL()),
            const Divider(),
            _buildInfoRow('Jenis Kelamin', _getData(_userProfile!.jenisKelamin)),
            const Divider(),
            _buildInfoRow('Status Perkawinan', _getData(_userProfile!.statusKawin)),
            const Divider(),
            _buildInfoRow('Pekerjaan', _getData(_userProfile!.pekerjaan)),
            const Divider(),
            _buildInfoRow('Pendidikan', _getData(_userProfile!.pendidikan)),
            const Divider(),
            _buildInfoRow('Alamat', _buildAlamatLengkap()),
            const Divider(),
            _buildInfoRow('Underbow', _getData(_userProfile!.underbow)),
            const Divider(),
            _buildInfoRow('Kegiatan', _getData(_userProfile!.kegiatan)),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildAlamatLengkap() {
    if (_userProfile == null) return '-';
    
    final parts = <String>[];
    
    if (_userProfile!.jalan != null && _userProfile!.jalan!.isNotEmpty) {
      parts.add(_userProfile!.jalan!);
    }
    
    if (_userProfile!.rt != null && _userProfile!.rw != null) {
      parts.add('RT ${_userProfile!.rt}/RW ${_userProfile!.rw}');
    }
    
    if (_userProfile!.kelurahan != null && _userProfile!.kelurahan!.isNotEmpty) {
      parts.add(_userProfile!.kelurahan!);
    }
    
    if (_userProfile!.kecamatan != null && _userProfile!.kecamatan!.isNotEmpty) {
      parts.add(_userProfile!.kecamatan!);
    }
    
    if (_userProfile!.kota != null && _userProfile!.kota!.isNotEmpty) {
      parts.add(_userProfile!.kota!);
    }
    
    if (_userProfile!.provinsi != null && _userProfile!.provinsi!.isNotEmpty) {
      parts.add(_userProfile!.provinsi!);
    }
    
    return parts.isEmpty ? '-' : parts.join(', ');
  }

  Widget _buildPostCard(PostModel post) {
    final timeAgo = _getTimeAgo(post.createdAt);
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header dengan waktu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.user.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Post content
            if (post.content != null && post.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  post.content!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            
            // Post images
            if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildImageGallery(post.imageUrls!),
              ),
            
            // Location
            if (post.location != null && post.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      post.location!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Action buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: post.likeCount.toString(),
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: post.commentCount.toString(),
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.share_outlined,
                  label: 'Bagikan',
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> imageUrls) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();
    
    if (imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          '${ApiService.baseUrl}${imageUrls[0]}',
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            );
          },
        ),
      );
    }
    
    // Grid untuk multiple images
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            '${ApiService.baseUrl}${imageUrls[index]}',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }
}

