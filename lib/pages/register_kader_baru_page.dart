import 'package:flutter/material.dart';

class RegisterKaderBaruPage extends StatefulWidget {
  const RegisterKaderBaruPage({super.key});

  @override
  State<RegisterKaderBaruPage> createState() => _RegisterKaderBaruPageState();
}

class _RegisterKaderBaruPageState extends State<RegisterKaderBaruPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _alamatJalanController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _pendidikanController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ulangiPasswordController = TextEditingController();
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  Widget _imageBox(String label) {
    return Container(
      width: 150,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Pendaftaran Kader Baru',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nama :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _namaController,
                            decoration: const InputDecoration(
                              hintText: 'Nama Lengkap',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'user@email.com',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NIK :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _nikController,
                            decoration: const InputDecoration(
                              hintText: 'NIK 16 digit',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('L/P :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _genderController,
                            decoration: const InputDecoration(
                              hintText: 'Laki/Perempuan',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kawin/Belum :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _statusController,
                            decoration: const InputDecoration(
                              hintText: 'Kawin/Belum',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tempat Lahir :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tempatLahirController,
                            decoration: const InputDecoration(
                              hintText: 'Nama kota/kabupaten',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tanggal Lahir :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _tanggalLahirController,
                            decoration: const InputDecoration(
                              hintText: 'Date Picker dd/mm/yyyy',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Alamat Sesuai KTP :', style: TextStyle(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _provinsiController,
                        decoration: const InputDecoration(hintText: 'Provinsi'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _kotaController,
                        decoration: const InputDecoration(hintText: 'Kota/Kabupaten'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _kecamatanController,
                        decoration: const InputDecoration(hintText: 'Kecamatan'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _kelurahanController,
                        decoration: const InputDecoration(hintText: 'Kelurahan/Desa'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _rtController,
                        decoration: const InputDecoration(hintText: 'RT'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _rwController,
                        decoration: const InputDecoration(hintText: 'RW'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _alamatJalanController,
                  decoration: const InputDecoration(hintText: 'Nama Jalan, Nomor Rumah'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pekerjaan :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pekerjaanController,
                            decoration: const InputDecoration(hintText: 'Pekerjaan'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pendidikan :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _pendidikanController,
                            decoration: const InputDecoration(hintText: 'Pendidikan'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Upload KTP :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _imageBox('Foto KTP'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Foto Selfie :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _imageBox('Foto Selfie'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Buat Password :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: 'Delapan huruf'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ulangi Password :', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _ulangiPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(hintText: 'Delapan huruf'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked1,
                      onChanged: (val) {
                        setState(() {
                          _isChecked1 = val ?? false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    const Expanded(
                      child: Text(
                        'Dengan ini saya menyatakan bahwa saya bukan merupakan pengurus dari partai politik lain.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked2,
                      onChanged: (val) {
                        setState(() {
                          _isChecked2 = val ?? false;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    const Expanded(
                      child: Text(
                        'Saya menyatakan bahwa semua data yang saya isi di atas adalah benar dan saya bertanggung jawab penuh atas keabsahan data tersebut.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // TODO: proses daftar
                    },
                    child: const Text('Daftar', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/my geri trans.png',
                  width: size.width * 0.35,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
