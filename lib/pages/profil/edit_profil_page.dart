import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/profile_service.dart';
import '../../services/api_service.dart';
import '../../models/user_profile.dart';
import 'ekta_depan_page.dart';
import 'ekta_belakang_page.dart';
import '../../services/history_service.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Services
  late final ProfileService _profileService;
  
  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingKtp = false;
  bool _isUploadingProfil = false;
  
  // User profile
  UserProfile? _profile;
  
  // Controllers
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _jalanController = TextEditingController();
  final TextEditingController _rtController = TextEditingController();
  final TextEditingController _rwController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _underbowController = TextEditingController();
  final TextEditingController _kegiatanController = TextEditingController();

  // Dropdowns
  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _selectedPendidikan;
  
  // Images
  File? _ktpImage;
  File? _profilImage;
  String? _ktpUrl;
  String? _profilUrl;
  
  bool _isChecked1 = false;
  bool _isChecked2 = false;

  @override
  void initState() {
    super.initState();
    _profileService = ProfileService(ApiService());
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      print('📥 Loading user profile...');
      final profile = await _profileService.getProfile();
      
      setState(() {
        _profile = profile;
        
        // Populate fields
        _nikController.text = profile.nik ?? '';
        _tempatLahirController.text = profile.tempatLahir ?? '';
        if (profile.tanggalLahir != null) {
          _tanggalLahirController.text = DateFormat('dd/MM/yyyy').format(profile.tanggalLahir!);
        }
        _jalanController.text = profile.jalan ?? '';
        _rtController.text = profile.rt ?? '';
        _rwController.text = profile.rw ?? '';
        _pekerjaanController.text = profile.pekerjaan ?? '';
        _underbowController.text = profile.underbow ?? '';
        _kegiatanController.text = profile.kegiatan ?? '';
        
        // Dropdowns
        _selectedGender = profile.jenisKelamin;
        _selectedStatus = profile.statusKawin;
        _selectedProvinsi = profile.provinsi;
        _selectedKota = profile.kota;
        _selectedKecamatan = profile.kecamatan;
        _selectedKelurahan = profile.kelurahan;
        _selectedPendidikan = profile.pendidikan;
        
        // Photo URLs
        _ktpUrl = profile.fotoKtp;
        _profilUrl = profile.fotoProfil;
      });
      
      print('✅ Profile loaded successfully');
    } catch (e) {
      print('❌ Error loading profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      print('💾 Saving profile...');
      
      // Parse tanggal lahir
      DateTime? tanggalLahir;
      if (_tanggalLahirController.text.isNotEmpty) {
        try {
          tanggalLahir = DateFormat('dd/MM/yyyy').parse(_tanggalLahirController.text);
        } catch (e) {
          print('⚠️ Error parsing tanggal lahir: $e');
        }
      }
      
      // Build profile data (only non-empty fields)
      final profileData = <String, dynamic>{};
      
      if (_nikController.text.isNotEmpty) profileData['nik'] = _nikController.text;
      if (_selectedGender != null) profileData['jenisKelamin'] = _selectedGender;
      if (_selectedStatus != null) profileData['statusKawin'] = _selectedStatus;
      if (_tempatLahirController.text.isNotEmpty) profileData['tempatLahir'] = _tempatLahirController.text;
      if (tanggalLahir != null) profileData['tanggalLahir'] = tanggalLahir.toIso8601String().split('T')[0];
      if (_selectedProvinsi != null) profileData['provinsi'] = _selectedProvinsi;
      if (_selectedKota != null) profileData['kota'] = _selectedKota;
      if (_selectedKecamatan != null) profileData['kecamatan'] = _selectedKecamatan;
      if (_selectedKelurahan != null) profileData['kelurahan'] = _selectedKelurahan;
      if (_rtController.text.isNotEmpty) profileData['rt'] = _rtController.text;
      if (_rwController.text.isNotEmpty) profileData['rw'] = _rwController.text;
      if (_jalanController.text.isNotEmpty) profileData['jalan'] = _jalanController.text;
      if (_pekerjaanController.text.isNotEmpty) profileData['pekerjaan'] = _pekerjaanController.text;
      if (_selectedPendidikan != null) profileData['pendidikan'] = _selectedPendidikan;
      if (_underbowController.text.isNotEmpty) profileData['underbow'] = _underbowController.text;
      if (_kegiatanController.text.isNotEmpty) profileData['kegiatan'] = _kegiatanController.text;
      
      // Include photo URLs if uploaded
      if (_profilUrl != null && _profilUrl!.isNotEmpty) {
        profileData['fotoProfil'] = _profilUrl;
        print('📸 Including profile photo: $_profilUrl');
      }
      if (_ktpUrl != null && _ktpUrl!.isNotEmpty) {
        profileData['fotoKtp'] = _ktpUrl;
        print('📸 Including KTP photo: $_ktpUrl');
      }

      print('📤 Sending data: ${jsonEncode(profileData)}');
      
      final updatedProfile = await _profileService.updateProfile(profileData);
      // Catat riwayat edit profil
      try {
        await HistoryService().logHistory(
          'edit_profile',
          description: 'Edit profil',
          metadata: {
            'device': 'Flutter',
            // Tambahkan info lain jika perlu
          },
        );
        print('✅ Riwayat edit profil tercatat');
      } catch (e) {
        print('❌ Gagal mencatat riwayat edit profil: $e');
      }
      
      setState(() {
        _profile = updatedProfile;
      });
      
      print('✅ Profile saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile berhasil diupdate!'), backgroundColor: Colors.green),
        );
        
        // Return true to signal ProfilePage to reload
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadImage(String fotoType) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    
    setState(() {
      if (fotoType == 'ktp') {
        _isUploadingKtp = true;
        _ktpImage = imageFile;
      } else {
        _isUploadingProfil = true;
        _profilImage = imageFile;
      }
    });

    try {
      print('📸 Uploading $fotoType photo...');
      final photoUrl = await _profileService.uploadFoto(imageFile, fotoType);
      
      setState(() {
        if (fotoType == 'ktp') {
          _ktpUrl = photoUrl;
        } else {
          _profilUrl = photoUrl;
        }
      });
      
      print('✅ Photo uploaded: $photoUrl');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Foto $fotoType berhasil diupload!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      print('❌ Error uploading photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error upload foto: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() {
        if (fotoType == 'ktp') {
          _isUploadingKtp = false;
        } else {
          _isUploadingProfil = false;
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahirController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showEKtaDepan() {
    final nama = _nikController.text.isNotEmpty ? _nikController.text : 'Dani Setiawan';
    final kodeAnggota = _nikController.text.isNotEmpty ? _nikController.text : '3276047658400027';
    final qrRaw = nama + kodeAnggota + (_tanggalLahirController.text);
    final qrHash = sha256.convert(utf8.encode(qrRaw)).toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EKtaDepanPage(
          nama: nama,
          qrData: qrHash,
          fotoPath: 'assets/images/profile_placeholder.png',
        ),
      ),
    );
  }

  void _showEKtaBelakang() {
    final nama = _nikController.text.isNotEmpty ? _nikController.text : 'Dani Setiawan';
    final kodeAnggota = _nikController.text.isNotEmpty ? _nikController.text : '3276047658400027';
    final qrRaw = nama + kodeAnggota + (_tanggalLahirController.text);
    final qrHash = sha256.convert(utf8.encode(qrRaw)).toString();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EKtaBelakangPage(
          nama: nama,
          nomorKta: kodeAnggota,
          ttl: _tanggalLahirController.text.isNotEmpty ? _tanggalLahirController.text : 'Jakarta, 14 Desember 1977',
          alamat: _jalanController.text.isNotEmpty ? _jalanController.text : 'Jl. H. Jaidi No.10 RT.05/RW.01',
          kelurahan: _selectedKelurahan ?? 'Pejaten Timur',
          kecamatan: _selectedKecamatan ?? 'Pasar Minggu',
          kota: _selectedKota ?? 'Jakarta Selatan',
          provinsi: _selectedProvinsi ?? 'DKI Jakarta',
          kelamin: _selectedGender ?? 'laki-laki',
          qrKetum: qrHash,
          qrSekretaris: qrHash,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: _isSaving 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                  )
                : const Icon(Icons.save, color: Colors.red),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            // Profile Photo
                            GestureDetector(
                              onTap: () => _pickAndUploadImage('profil'),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 45,
                                    backgroundImage: _profilImage != null
                                        ? FileImage(_profilImage!)
                                        : (_profilUrl != null
                                            ? NetworkImage('${ApiService.baseUrl}$_profilUrl')
                                            : const AssetImage('assets/images/profile_placeholder.png')) as ImageProvider,
                                  ),
                                  if (_isUploadingProfil)
                                    const Positioned.fill(
                                      child: CircleAvatar(
                                        radius: 45,
                                        backgroundColor: Colors.black54,
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Selamat Datang ${_profile?.name ?? 'User'} !',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Silahkan lengkapi data Anda.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            // NIK
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('NIK :'),
                                  TextFormField(
                                    controller: _nikController,
                                    keyboardType: TextInputType.number,
                                    maxLength: 16,
                                    decoration: const InputDecoration(hintText: 'NIK 16 digit'),
                                    validator: (value) {
                                      if (value != null && value.isNotEmpty) {
                                        if (value.length != 16) {
                                          return 'NIK harus 16 digit';
                                        }
                                        if (!RegExp(r'^\d+$').hasMatch(value)) {
                                          return 'NIK harus berupa angka';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                      const SizedBox(height: 10),
                      // Gender
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('L/P :'),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              items: const [
                                DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                                DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                              ],
                              onChanged: (val) => setState(() => _selectedGender = val),
                              decoration: const InputDecoration(hintText: 'Laki/Perempuan'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Status
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Status :'),
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              items: const [
                                DropdownMenuItem(value: 'Kawin', child: Text('Kawin')),
                                DropdownMenuItem(value: 'Belum Kawin', child: Text('Belum Kawin')),
                                DropdownMenuItem(value: 'Janda', child: Text('Janda')),
                                DropdownMenuItem(value: 'Duda', child: Text('Duda')),
                              ],
                              onChanged: (val) => setState(() => _selectedStatus = val),
                              decoration: const InputDecoration(hintText: 'Status'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tempat Lahir
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tempat Lahir :'),
                            TextFormField(
                              controller: _tempatLahirController,
                              decoration: const InputDecoration(hintText: 'Nama kota/kabupaten'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Tanggal Lahir
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tanggal Lahir :'),
                            TextFormField(
                              controller: _tanggalLahirController,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              decoration: const InputDecoration(hintText: 'Date Picker dd/mm/yyyy'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Alamat
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Alamat Sesuai KTP :'),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedProvinsi,
                        items: const [DropdownMenuItem(value: 'Jawa Barat', child: Text('Jawa Barat'))],
                        onChanged: (val) => setState(() => _selectedProvinsi = val),
                        decoration: const InputDecoration(hintText: 'Provinsi'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedKota,
                        items: const [DropdownMenuItem(value: 'Bandung', child: Text('Bandung'))],
                        onChanged: (val) => setState(() => _selectedKota = val),
                        decoration: const InputDecoration(hintText: 'Kota/Kabupaten'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedKecamatan,
                        items: const [DropdownMenuItem(value: 'Cicendo', child: Text('Cicendo'))],
                        onChanged: (val) => setState(() => _selectedKecamatan = val),
                        decoration: const InputDecoration(hintText: 'Kecamatan'),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedKelurahan,
                        items: const [DropdownMenuItem(value: 'Sukajadi', child: Text('Sukajadi'))],
                        onChanged: (val) => setState(() => _selectedKelurahan = val),
                        decoration: const InputDecoration(hintText: 'Kelurahan/Desa'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _rtController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              decoration: const InputDecoration(hintText: 'RT'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _rwController,
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              decoration: const InputDecoration(hintText: 'RW'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _jalanController,
                        decoration: const InputDecoration(hintText: 'Nama Jalan, Nomor Rumah'),
                      ),
                      const SizedBox(height: 10),
                      // Pekerjaan
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pekerjaan :'),
                            TextFormField(
                              controller: _pekerjaanController,
                              decoration: const InputDecoration(hintText: 'Pekerjaan'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Pendidikan
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pendidikan :'),
                            DropdownButtonFormField<String>(
                              value: _selectedPendidikan,
                              items: const [DropdownMenuItem(value: 'S1', child: Text('S1'))],
                              onChanged: (val) => setState(() => _selectedPendidikan = val),
                              decoration: const InputDecoration(hintText: 'Pendidikan'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Underbow
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Underbow Partai :'),
                            TextFormField(
                              controller: _underbowController,
                              decoration: const InputDecoration(hintText: 'underbow boleh lebih dari 1'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Kegiatan
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pelatihan/Kegiatan Partai :'),
                            TextFormField(
                              controller: _kegiatanController,
                              decoration: const InputDecoration(hintText: 'kegiatan yang pernah diikuti'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Upload KTP :'),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: _isUploadingKtp ? null : () => _pickAndUploadImage('ktp'),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                  image: _ktpImage != null
                                      ? DecorationImage(
                                          image: FileImage(_ktpImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : (_ktpUrl != null
                                          ? DecorationImage(
                                              image: NetworkImage('${ApiService.baseUrl}$_ktpUrl'),
                                              fit: BoxFit.cover,
                                            )
                                          : null),
                                ),
                                child: _isUploadingKtp
                                    ? const Center(child: CircularProgressIndicator())
                                    : (_ktpImage == null && _ktpUrl == null
                                        ? Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: const [
                                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                              SizedBox(height: 8),
                                              Text('Foto KTP', style: TextStyle(color: Colors.grey)),
                                            ],
                                          )
                                        : null),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked1,
                            onChanged: (val) => setState(() => _isChecked1 = val ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Dengan ini saya menyatakan bahwa saya bukan merupakan pengurus dari partai politik lain.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isChecked2,
                            onChanged: (val) => setState(() => _isChecked2 = val ?? false),
                          ),
                          const Expanded(
                            child: Text(
                              'Saya menyatakan bahwa semua data yang saya isi di atas adalah benar dan saya bertanggung jawab penuh atas keabsahan data tersebut.',
                              style: TextStyle(fontSize: 13),
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
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveProfile,
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text('Update Profile', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     IconButton(
                      //       icon: const Icon(Icons.credit_card, color: Colors.amber, size: 36),
                      //       onPressed: _showEKtaDepan,
                      //     ),
                      //     const SizedBox(width: 16),
                      //     IconButton(
                      //       icon: const Icon(Icons.print, color: Colors.blue, size: 36),
                      //       onPressed: _showEKtaBelakang,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
