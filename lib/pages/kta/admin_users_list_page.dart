import 'package:flutter/material.dart';
import '../../models/kta_models.dart';
import '../../services/kta_api_service.dart';
import 'admin_verify_page.dart';

/// Halaman untuk admin melihat daftar user dan status KTA mereka
class AdminUsersListPage extends StatefulWidget {
  const AdminUsersListPage({Key? key}) : super(key: key);

  @override
  State<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends State<AdminUsersListPage> {
  final KTAApiService _ktaApi = KTAApiService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<KTAUser> _users = [];
  Pagination? _pagination;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Filters
  String? _statusFilter; // null='all', 'verified', 'unverified'
  String? _roleFilter; // null='all', or specific role

  @override
  void initState() {
    super.initState();
    _loadUsers();
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
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _pagination?.hasMore == true) {
        _loadMore();
      }
    }
  }

  Future<void> _loadUsers({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _users.clear();
      });
    }

    try {
      final result = await _ktaApi.getUsersList(
        status: _statusFilter ?? 'all',
        role: _roleFilter ?? 'all',
        search: _searchController.text.isEmpty ? null : _searchController.text,
        limit: 20,
        offset: 0,
      );

      setState(() {
        _users = result['users'];
        _pagination = result['pagination'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _pagination?.hasMore != true) return;

    setState(() => _isLoadingMore = true);

    try {
      final result = await _ktaApi.getUsersList(
        status: _statusFilter ?? 'all',
        role: _roleFilter ?? 'all',
        search: _searchController.text.isEmpty ? null : _searchController.text,
        limit: 20,
        offset: _users.length,
      );

      setState(() {
        _users.addAll(result['users']);
        _pagination = result['pagination'];
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat lebih banyak: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Daftar User KTA'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUsers(reset: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadUsers(reset: true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _loadUsers(reset: true),
                ),

                const SizedBox(height: 12),

                // Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Status filter
                      _buildFilterChip(
                        label: 'Semua Status',
                        selected: _statusFilter == null,
                        onSelected: () {
                          setState(() => _statusFilter = null);
                          _loadUsers(reset: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Terverifikasi',
                        selected: _statusFilter == 'verified',
                        onSelected: () {
                          setState(() => _statusFilter = 'verified');
                          _loadUsers(reset: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Belum Verifikasi',
                        selected: _statusFilter == 'unverified',
                        onSelected: () {
                          setState(() => _statusFilter = 'unverified');
                          _loadUsers(reset: true);
                        },
                      ),
                      const SizedBox(width: 16),
                      // Role filter
                      _buildFilterChip(
                        label: 'Semua Role',
                        selected: _roleFilter == null,
                        onSelected: () {
                          setState(() => _roleFilter = null);
                          _loadUsers(reset: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Simpatisan',
                        selected: _roleFilter == 'simpatisan',
                        onSelected: () {
                          setState(() => _roleFilter = 'simpatisan');
                          _loadUsers(reset: true);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Kader',
                        selected: _roleFilter == 'kader',
                        onSelected: () {
                          setState(() => _roleFilter = 'kader');
                          _loadUsers(reset: true);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Users list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.red.shade100,
      checkmarkColor: Colors.red,
      labelStyle: TextStyle(
        color: selected ? Colors.red : Colors.grey[700],
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _loadUsers(reset: true),
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada user ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadUsers(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final user = _users[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(KTAUser user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openVerifyPage(user),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: user.ktaVerified
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: user.ktaVerified ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user.ktaVerified ? Icons.check_circle : Icons.pending,
                      size: 16,
                      color: user.ktaVerified ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.ktaVerified ? 'Verified' : 'Pending',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: user.ktaVerified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openVerifyPage(KTAUser user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminVerifyKTAPage(
          userId: user.id,
          userName: user.name,
        ),
      ),
    );

    if (result == true) {
      // Refresh list after verification
      _loadUsers(reset: true);
    }
  }
}
