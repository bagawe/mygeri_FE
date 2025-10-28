import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EKtaBelakangPage extends StatelessWidget {
  final String nama;
  final String nomorKta;
  final String ttl;
  final String alamat;
  final String kelurahan;
  final String kecamatan;
  final String kota;
  final String provinsi;
  final String kelamin;
  final String qrKetum;
  final String qrSekretaris;

  const EKtaBelakangPage({
    Key? key,
    required this.nama,
    required this.nomorKta,
    required this.ttl,
    required this.alamat,
    required this.kelurahan,
    required this.kecamatan,
    required this.kota,
    required this.provinsi,
    required this.kelamin,
    required this.qrKetum,
    required this.qrSekretaris,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('KTA Digital', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6F2),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/Logo myGeri kotak.png',
                        width: 60,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('PARTAI GERINDRA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Text('GERAKAN INDONESIA RAYA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.red)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('KARTU TANDA ANGGOTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 8),
                  Text('Nama           : $nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Nomor KTA  : $nomorKta'),
                  Text('TTL               : $ttl'),
                  Text('Alamat         : $alamat'),
                  Text('Kelurahan    : $kelurahan'),
                  Text('Kecamatan   : $kecamatan'),
                  Text('Kota/Kab     : $kota'),
                  Text('Propinsi        : $provinsi'),
                  Text('Kelamin        : $kelamin'),
                  const SizedBox(height: 12),
                  const Center(child: Text('Jakarta, 28 Oktober 2025,')),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey[300],
                            child: QrImageView(
                              data: qrKetum,
                              size: 54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('H. PRABOWO SUBIYANTO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          const Text('Ketua Umum', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            color: Colors.grey[300],
                            child: QrImageView(
                              data: qrSekretaris,
                              size: 54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text('H. AHMAD MUZANI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                          const Text('Sekretaris', style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
