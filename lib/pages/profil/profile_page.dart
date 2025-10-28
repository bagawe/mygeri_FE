import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data, replace with provider/model if available
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
                  Image.asset('assets/images/mygeri_logo.png', height: 40),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: AssetImage('assets/images/profile_sinta.jpeg'),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Selamat Datang ${user['nama']} !',
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
                  TableRow(children: [const Text('Username'), Text(': ${user['username']}')]),
                  TableRow(children: [const Text('Email'), Text(': ${user['email']}')]),
                  TableRow(children: [const Text('Nomor KTA'), Text(': ${user['nomorKta']}')]),
                  TableRow(children: [const Text('TTL'), Text(': ${user['ttl']}')]),
                  TableRow(children: [const Text('Alamat'), Text(': ${user['alamat']}')]),
                  TableRow(children: [const Text('Kelurahan'), Text(': ${user['kelurahan']}')]),
                  TableRow(children: [const Text('Kecamatan'), Text(': ${user['kecamatan']}')]),
                  TableRow(children: [const Text('Kota/Kab'), Text(': ${user['kota']}')]),
                  TableRow(children: [const Text('Propinsi'), Text(': ${user['provinsi']}')]),
                  TableRow(children: [const Text('Kelamin'), Text(': ${user['kelamin']}')]),
                  TableRow(children: [const Text('Status Partai'), Text(': ${user['statusPartai']}')]),
                  TableRow(children: [const Text('Jabatan'), Text(': ${user['jabatan']}')]),
                  TableRow(children: [const Text('Underbow'), Text(': ${user['underbow']}')]),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 44,
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
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/ekta');
                      },
                      child: const Text('Lihat EKTA', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Kegiatan :', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
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
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(kegiatan[i], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white, size: 22),
                          onPressed: () {
                            // Placeholder: open comment dialog
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
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
