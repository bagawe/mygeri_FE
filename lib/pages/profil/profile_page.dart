import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = {
      'nama': 'Sinta Silalahi',
      'username': '@sintasilalahi',
      'email': 'sintasari08@gmail.com',
      'nomorKta': '3276047658400027',
      'ttl': 'Jakarta, 12 Oktober 1998',
      'alamat': 'Jl. Mawar  No.10 RT.05/RW.01',
      'kelurahan': 'Kalibata Utara',
      'kecamatan': 'Klibata',
      'kota': 'Jakarta Selatan',
      'provinsi': 'DKI Jakarta',
      'kelamin': 'Perempuan',
      'statusPartai': 'Pengurus DPC Jakarta Selatan',
      'jabatan': 'Wakil Walikota Jakarta Selatan',
      'underbow': '-',
    };
    final kegiatan = [
      'assets/images/kegiatan1.jpg',
      'assets/images/kegiatan2.jpg',
      'assets/images/kegiatan3.jpg',
      'assets/images/kegiatan4.jpg',
      'assets/images/kegiatan5.jpg',
      'assets/images/kegiatan6.jpg',
    ];
    String getData(String? val) => (val == null || val.isEmpty) ? '-' : val;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/my geri trans.png',
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/images/sinta.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 60, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selamat Datang ${getData(user['nama'])} !',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(),
                  1: FlexColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(children: [const Text('Username'), Text(': ${getData(user['username'])}')]),
                  TableRow(children: [const Text('Email'), Text(': ${getData(user['email'])}')]),
                  TableRow(children: [const Text('Nomor KTA'), Text(': ${getData(user['nomorKta'])}')]),
                  TableRow(children: [const Text('TTL'), Text(': ${getData(user['ttl'])}')]),
                  TableRow(children: [const Text('Alamat'), Text(': ${getData(user['alamat'])}')]),
                  TableRow(children: [const Text('Kelurahan'), Text(': ${getData(user['kelurahan'])}')]),
                  TableRow(children: [const Text('Kecamatan'), Text(': ${getData(user['kecamatan'])}')]),
                  TableRow(children: [const Text('Kota/Kab'), Text(': ${getData(user['kota'])}')]),
                  TableRow(children: [const Text('Propinsi'), Text(': ${getData(user['provinsi'])}')]),
                  TableRow(children: [const Text('Kelamin'), Text(': ${getData(user['kelamin'])}')]),
                  TableRow(children: [const Text('Status Partai'), Text(': ${getData(user['statusPartai'])}')]),
                  TableRow(children: [const Text('Jabatan'), Text(': ${getData(user['jabatan'])}')]),
                  TableRow(children: [const Text('Underbow'), Text(': ${getData(user['underbow'])}')]),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit-profil');
                  },
                  child: const Text('Update Profile'),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Kegiatan :', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              if (kegiatan.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: kegiatan.length,
                  itemBuilder: (context, i) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        kegiatan[i],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    );
                  },
                )
              else
                const Text('-', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    // Placeholder: upload kegiatan
                  },
                  child: const Text('Upload Kegiatan', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
