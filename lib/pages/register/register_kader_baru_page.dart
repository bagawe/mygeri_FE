import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../models/register_request.dart';

class RegisterKaderBaruPage extends StatefulWidget {
  const RegisterKaderBaruPage({super.key});

  @override
  State<RegisterKaderBaruPage> createState() => _RegisterKaderBaruPageState();
}

class _RegisterKaderBaruPageState extends State<RegisterKaderBaruPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
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
  
  File? _fotoKTP;
  File? _fotoSelfie;
  bool _isChecked1 = false;
  bool _isChecked2 = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _nikController.dispose();
    _genderController.dispose();
    _statusController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _provinsiController.dispose();
    _kotaController.dispose();
    _kecamatanController.dispose();
    _kelurahanController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _alamatJalanController.dispose();
    _pekerjaanController.dispose();
    _pendidikanController.dispose();
    _passwordController.dispose();
    _ulangiPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isKTP) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isKTP) {
            _fotoKTP = File(image.path);
          } else {
            _fotoSelfie = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isChecked1 || !_isChecked2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap centang semua pernyataan')),
      );
      return;
    }

    if (_fotoKTP == null || _fotoSelfie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap upload foto KTP dan selfie')),
      );
      return;
    }

    if (_passwordController.text != _ulangiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = RegisterRequest(
        name: _namaController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        nik: _nikController.text.trim(),
        jenisKelamin: _genderController.text.trim(),
        statusKawin: _statusController.text.trim(),
        tempatLahir: _tempatLahirController.text.trim(),
        tanggalLahir: _tanggalLahirController.text.trim(),
        provinsi: _provinsiController.text.trim(),
        kota: _kotaController.text.trim(),
        kecamatan: _kecamatanController.text.trim(),
        kelurahan: _kelurahanController.text.trim(),
        rt: _rtController.text.trim(),
        rw: _rwController.text.trim(),
        jalan: _alamatJalanController.text.trim(),
        pekerjaan: _pekerjaanController.text.trim(),
        pendidikan: _pendidikanController.text.trim(),
        fotoKtp: _fotoKTP!.path, // TODO: Upload ke server
        fotoProfil: _fotoSelfie!.path, // TODO: Upload ke server
      );

      await _authService.register(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Menunggu verifikasi admin.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pendaftaran gagal: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _imageBox(String label, File? image, bool isKTP) {
    return GestureDetector(
      onTap: () => _pickImage(isKTP),
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(image, fit: BoxFit.cover),
              ),
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
            child: Form(
              key: _formKey,
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
                          _imageBox('Foto KTP', _fotoKTP, true),
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
                          _imageBox('Foto Selfie', _fotoSelfie, false),
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
                    onPressed: (_isLoading || !_isChecked1 || !_isChecked2) ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Daftar', style: TextStyle(fontSize: 18)),
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
      ),
    );
  }
}
