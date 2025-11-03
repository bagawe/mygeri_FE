import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class EKtaDepanPage extends StatelessWidget {
  final String nama;
  final String qrData;
  final String fotoPath;

  const EKtaDepanPage({
    super.key,
    required this.nama,
    required this.qrData,
    required this.fotoPath,
  });

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
        actions: [
          IconButton(
            icon: const Icon(Icons.print, color: Colors.blue),
            onPressed: () {
              // TODO: Implement print functionality
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            width: 340,
            height: 480,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Logo myGeri kotak.png',
                  width: 80,
                ),
                const SizedBox(height: 8),
                const Text(
                  'PARTAI GERINDRA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                const Text(
                  'GERAKAN INDONESIA RAYA',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
                ),
                const SizedBox(height: 12),
                CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage(fotoPath),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView(
                      data: qrData,
                      size: 54,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                            Icon(Icons.star, color: Colors.yellow, size: 20),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.red, size: 20),
                            Icon(Icons.star, color: Colors.red, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  nama,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
