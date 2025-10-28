import 'package:flutter/material.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

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
            onTap: () {},
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications, color: Colors.red),
            title: const Text('Notifikasi'),
            value: true,
            onChanged: (val) {},
          ),
          ListTile(
            leading: const Icon(Icons.language, color: Colors.red),
            title: const Text('Bahasa'),
            trailing: const Text('Indonesia'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6, color: Colors.red),
            title: const Text('Tema'),
            trailing: const Text('Terang'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.red),
            title: const Text('Bantuan & FAQ'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.red),
            title: const Text('Tentang aplikasi'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Yakin ingin keluar dari aplikasi?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        // TODO: proses logout
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
