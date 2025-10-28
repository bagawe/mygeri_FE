import 'package:flutter/material.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Riwayat Kegiatan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.app_registration, color: Colors.red),
                    title: Text('Daftar aplikasi'),
                    subtitle: Text('26 Oktober 2025, 09:00'),
                  ),
                  ListTile(
                    leading: Icon(Icons.login, color: Colors.green),
                    title: Text('Masuk aplikasi'),
                    subtitle: Text('26 Oktober 2025, 09:05'),
                  ),
                  ListTile(
                    leading: Icon(Icons.how_to_vote, color: Colors.blue),
                    title: Text('Vote'),
                    subtitle: Text('26 Oktober 2025, 09:10'),
                  ),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.orange),
                    title: Text('Keluar aplikasi'),
                    subtitle: Text('26 Oktober 2025, 09:30'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
