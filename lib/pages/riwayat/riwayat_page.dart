import 'package:flutter/material.dart';
import '../../models/user_history.dart';
import '../../services/history_service.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({super.key});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  late Future<List<UserHistory>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = HistoryService().getHistory();
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'open_app':
        return Icons.open_in_new;
      case 'edit_profile':
        return Icons.edit;
      case 'search_user':
        return Icons.search;
      case 'create_post':
        return Icons.post_add;
      case 'search_post':
        return Icons.search;
      default:
        return Icons.history;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'login':
        return Colors.green;
      case 'logout':
        return Colors.orange;
      case 'open_app':
        return Colors.blue;
      case 'edit_profile':
        return Colors.purple;
      case 'search_user':
        return Colors.teal;
      case 'create_post':
        return Colors.indigo;
      case 'search_post':
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'login':
        return 'Login aplikasi';
      case 'logout':
        return 'Logout aplikasi';
      case 'open_app':
        return 'Buka aplikasi';
      case 'edit_profile':
        return 'Edit profil';
      case 'search_user':
        return 'Pencarian user';
      case 'create_post':
        return 'Buat postingan';
      case 'search_post':
        return 'Pencarian postingan';
      default:
        return type;
    }
  }

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
              child: FutureBuilder<List<UserHistory>>(
                future: _futureHistory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    print('Error riwayat: \\${snapshot.error}');
                    return Center(child: Text('Gagal memuat riwayat'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Belum ada riwayat'));
                  }
                  final history = snapshot.data!;
                  return ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, i) {
                      final h = history[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.grey[50], // Warna putih keabuan lembut
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _colorForType(h.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(_iconForType(h.type), color: _colorForType(h.type)),
                            ),
                            title: Text(
                              _labelForType(h.type),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                if (h.description != null && h.description!.isNotEmpty)
                                  Text(h.description!),
                                if (h.metadata != null)
                                  Text('Device: ${h.metadata?['device'] ?? '-'} | IP: ${h.metadata?['ip'] ?? '-'}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(_formatDate(h.createdAt), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format: 24 Desember 2025, 10:30
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month]}, ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
