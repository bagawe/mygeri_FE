import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/kta_models.dart';
import '../../services/kta_api_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/kta/kta_card_front.dart';
import '../../widgets/kta/kta_card_back.dart';

/// Halaman KTA untuk user melihat kartu mereka
class KTAPage extends StatefulWidget {
  const KTAPage({Key? key}) : super(key: key);

  @override
  State<KTAPage> createState() => _KTAPageState();
}

class _KTAPageState extends State<KTAPage> {
  final KTAApiService _ktaApi = KTAApiService();
  final StorageService _storage = StorageService();

  KTAData? _ktaData;
  bool _isLoading = true;
  bool _showFront = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadKTAData();
  }

  Future<void> _loadKTAData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to get from API first
      final ktaData = await _ktaApi.getMyStatus();
      setState(() {
        _ktaData = ktaData;
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ Error loading from API, trying local storage: $e');
      
      // Fallback: get from local storage
      try {
        final userData = await _storage.getUserData();
        // getUserData() returns Map<String, String?> - parse the JSON string from it
        final userDataString = userData['user_data'];
        if (userDataString != null) {
          final userJson = jsonDecode(userDataString);
          setState(() {
            _ktaData = KTAData(
              userId: userJson['id'],
              name: userJson['name'],
              email: userJson['email'],
              role: (userJson['roles'] as List).first['role'],
              ktaVerified: userJson['kta_verified'] ?? false,
              ktaVerifiedAt: userJson['kta_verified_at'] != null
                  ? DateTime.parse(userJson['kta_verified_at'])
                  : null,
              cardNumber: 'KTA-${DateTime.now().year}-${userJson['id'].toString().padLeft(6, '0')}',
              canPrint: userJson['kta_verified'] ?? false,
              message: userJson['kta_verified'] ?? false
                  ? 'KTA Anda telah diverifikasi'
                  : 'KTA Anda belum diverifikasi. Silakan hubungi admin.',
              fotoProfil: userJson['fotoProfil'],
              tanggalLahir: userJson['tanggal_lahir'],
              alamatLengkap: userJson['alamat_lengkap'],
              jenisKelamin: userJson['jenis_kelamin'],
            );
            _isLoading = false;
          });
        } else {
          throw Exception('Data user tidak ditemukan');
        }
      } catch (localError) {
        print('❌ Error loading from local storage: $localError');
        setState(() {
          _errorMessage = 'Gagal memuat data KTA: $localError';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kartu Tanda Anggota'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKTAData,
            tooltip: 'Refresh',
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
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
                onPressed: _loadKTAData,
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

    if (_ktaData == null) {
      return const Center(
        child: Text('Data KTA tidak tersedia'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Badge
          _buildStatusBadge(),
          const SizedBox(height: 16),

          // Card Display
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() => _showFront = !_showFront);
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showFront
                    ? KTACardFront(
                        key: const ValueKey('front'),
                        ktaData: _ktaData!,
                      )
                    : KTACardBack(
                        key: const ValueKey('back'),
                        ktaData: _ktaData!,
                      ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Flip instruction
          Center(
            child: Text(
              'Tap kartu untuk melihat sisi lain',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Message
          _buildMessageCard(),

          const SizedBox(height: 16),

          // Action Buttons
          if (_ktaData!.canPrint) ...[
            ElevatedButton.icon(
              onPressed: _downloadKTA,
              icon: const Icon(Icons.download),
              label: const Text('Download KTA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kartu akan disimpan untuk print',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.lock),
              label: const Text('Download Tidak Tersedia'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

          const SizedBox(height: 32),

          // Verification Details
          _buildVerificationDetails(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isVerified = _ktaData!.ktaVerified;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerified ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.pending,
            color: isVerified ? Colors.green : Colors.orange,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isVerified ? 'KTA Terverifikasi' : 'Menunggu Verifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isVerified ? Colors.green : Colors.orange,
                  ),
                ),
                if (isVerified && _ktaData!.ktaVerifiedAt != null)
                  Text(
                    'Diverifikasi: ${_ktaData!.formattedVerifiedDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _ktaData!.message,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail KTA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Nomor KTA', _ktaData!.cardNumber),
            _buildDetailRow('Nama', _ktaData!.name),
            _buildDetailRow('Email', _ktaData!.email),
            _buildDetailRow('Role', _ktaData!.role.toUpperCase()),
            if (_ktaData!.ktaVerified && _ktaData!.verifiedBy != null) ...[
              const Divider(height: 24),
              _buildDetailRow(
                'Diverifikasi oleh',
                _ktaData!.verifiedBy!.name,
              ),
              _buildDetailRow(
                'Tanggal verifikasi',
                _ktaData!.formattedVerifiedDate,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
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

  Future<void> _downloadKTA() async {
    // TODO: Implement download functionality using screenshot package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur download akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
