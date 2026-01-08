import 'package:flutter/material.dart';
import '../../services/session_manager.dart';
import 'ganti_password_page.dart';
import 'blocked_users_page.dart';

class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final SessionManager _sessionManager = SessionManager();
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    if (_isLoggingOut) return; // Prevent double-tap
    
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _sessionManager.performLogout();
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: const Text('Ubah Password'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GantiPasswordPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Akun yang Diblokir'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BlockedUsersPage()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.red),
            title: const Text('Notifikasi'),
            value: true,
            onChanged: (val) {
              _showComingSoonDialog('Notifikasi');
            },
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.red),
            title: const Text('Bahasa'),
            trailing: const Text('Indonesia'),
            onTap: () {
              _showComingSoonDialog('Bahasa');
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.red),
            title: const Text('Tema'),
            trailing: const Text('Terang'),
            onTap: () {
              _showComingSoonDialog('Tema');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.red),
            title: const Text('Bantuan & FAQ'),
            onTap: () {
              _showComingSoonDialog('Bantuan & FAQ');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.red),
            title: const Text('Tentang aplikasi'),
            onTap: () {
              _showComingSoonDialog('Tentang Aplikasi');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: _isLoggingOut ? Colors.grey : Colors.red,
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: _isLoggingOut ? Colors.grey : Colors.black,
              ),
            ),
            enabled: !_isLoggingOut,
            onTap: _isLoggingOut
                ? null
                : () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Yakin ingin keluar dari aplikasi?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _handleLogout();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
          ),
          if (_isLoggingOut)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
