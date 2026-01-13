import 'package:flutter/material.dart';
import '../../models/kta_models.dart';

/// Widget untuk menampilkan KTA Card Belakang
class KTACardBack extends StatelessWidget {
  final KTAData ktaData;
  final double cardWidth;
  final double cardHeight;

  const KTACardBack({
    Key? key,
    required this.ktaData,
    this.cardWidth = 340,
    this.cardHeight = 214,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE31E24), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              height: 30,
              child: const Text(
                'GERINDRA',
                style: TextStyle(
                  color: Color(0xFFE31E24),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title
            const Text(
              'KARTU TANDA ANGGOTA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE31E24),
              ),
            ),
            const SizedBox(height: 12),

            // Profile Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Nama', ktaData.name),
                  _buildDetailRow('Tanggal Lahir', ktaData.formattedTanggalLahir),
                  _buildDetailRow('Alamat', ktaData.alamatLengkap ?? '-'),
                  _buildDetailRow('Jenis Kelamin', ktaData.jenisKelamin ?? '-'),
                ],
              ),
            ),

            // Print Date
            Text(
              'Jakarta, ${ktaData.printDate}',
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),

            // Signatures (hanya muncul jika verified)
            if (ktaData.ktaVerified)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSignature(
                    'Prabowo Subianto',
                    'Ketua Umum',
                  ),
                  _buildSignature(
                    'Sufmi Dasco',
                    'Sekretaris Jenderal',
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Belum Diverifikasi',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 10),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignature(String name, String title) {
    return Column(
      children: [
        // Signature placeholder (will be replaced with actual signature image)
        Container(
          width: 80,
          height: 30,
          child: Center(
            child: Text(
              '[ TTD ]',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          name,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 7,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
