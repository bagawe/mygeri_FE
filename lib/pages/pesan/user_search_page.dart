import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/user_search_result.dart';
import '../../services/user_service.dart';
import '../../services/conversation_service.dart';
import '../../services/block_service.dart';
import '../../services/api_service.dart';
import '../../services/history_service.dart';
import 'chat_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final UserService _userService;
  late final ConversationService _conversationService;
  late final BlockService _blockService;
  
  List<UserSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  String? _errorMessage;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Initialize services - reuse same ApiService instance
    final apiService = ApiService();
    _userService = UserService(apiService);
    _conversationService = ConversationService(apiService);
    _blockService = BlockService(apiService);
    print('✅ UserSearchPage services initialized');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous debounce timer
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      if (_searchResults.isNotEmpty || _hasSearched || _errorMessage != null) {
        setState(() {
          _searchResults = [];
          _hasSearched = false;
          _errorMessage = null;
        });
      }
      return;
    }

    // Set debounce timer (800ms - increased to reduce CPU load)
    _debounce = Timer(const Duration(milliseconds: 800), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });
    
    // Catat riwayat pencarian user (non-blocking, fire and forget)
    HistoryService()
        .logHistory('search_user', description: 'Cari user: $query')
        .timeout(const Duration(seconds: 3))
        .catchError((e) {
          print('❌ Gagal mencatat riwayat search_user: $e');
        });
    
    try {
      final results = await _userService.searchUsers(query).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Pencarian terlalu lama, silakan coba lagi');
        },
      );
      
      if (!mounted) return;
      
      setState(() {
        _searchResults = results;
        _hasSearched = true;
        _isSearching = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = 'Gagal mencari pengguna: $e';
        _isSearching = false;
        _hasSearched = true;
      });
    }
  }

  Future<void> _onUserTap(UserSearchResult user) async {
    // Show user detail popup
    _showUserDetailDialog(user);
  }

  void _showUserDetailDialog(UserSearchResult user) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              user.fotoProfil != null
                  ? CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        '${ApiService.baseUrl}${user.fotoProfil}',
                      ),
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.red.shade100,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              
              // Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              // Username
              Text(
                '@${user.username}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              
              // Bio (if available)
              if (user.bio != null && user.bio!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  user.bio!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Block Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        await _handleBlockUser(user);
                      },
                      icon: const Icon(Icons.block, size: 20),
                      label: const Text('Blok'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Chat Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        await _handleStartChat(user);
                      },
                      icon: const Icon(Icons.chat, size: 20),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBlockUser(UserSearchResult user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Blok Pengguna'),
        content: Text(
          'Apakah Anda yakin ingin memblokir ${user.name}?\n\n'
          'Setelah diblokir:\n'
          '• ${user.name} tidak bisa mengirim pesan ke Anda\n'
          '• Anda tidak bisa mengirim pesan ke ${user.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Blok'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await _blockService.blockUser(user.id);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user.name} berhasil diblokir'),
          backgroundColor: Colors.green,
        ),
      );

      // Remove from search results
      setState(() {
        _searchResults.removeWhere((u) => u.id == user.id);
      });
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memblokir user: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleStartChat(UserSearchResult user) async {
    // Show loading dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get or create conversation
      final conversationResponse = await _conversationService.getOrCreateConversation(user.id);
      
      if (!mounted) return;
      
      // Close loading dialog first
      Navigator.pop(context);
      
      // Small delay to ensure dialog is fully closed
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      // Find the other participant
      final otherParticipant = conversationResponse.participants
          .firstWhere((p) => p.id == user.id);
      
      // Navigate to ChatPage (use push instead of pushReplacement to keep back button)
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationResponse.id,
            otherParticipant: otherParticipant,
          ),
        ),
      );
      
      // Pop back to PesanPage after chat is closed
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh conversations
      }
    } catch (e) {
      print('❌ Error starting chat: $e');
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka percakapan: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Pengguna'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: true,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000), // 10% black
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, child) {
                return TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan username atau nama...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFAFAFA),
                  ),
                );
              },
            ),
          ),

          // Search Results
          Expanded(
            child: RepaintBoundary(
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
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
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Cari pengguna untuk memulai percakapan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pengguna ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba kata kunci lain',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: user.fotoProfil != null && user.fotoProfil!.isNotEmpty
                ? NetworkImage('${ApiService.baseUrl}${user.fotoProfil}')
                : null,
            child: user.fotoProfil == null || user.fotoProfil!.isEmpty
                ? Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${user.username}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              if (user.bio != null && user.bio!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    user.bio!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _onUserTap(user),
        );
      },
    );
  }
}
