import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'ekta_depan_page.dart';
import 'ekta_belakang_page.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({Key? key}) : super(key: key);

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _tempatLahirController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _jalanController = TextEditingController();
  final TextEditingController _pekerjaanController = TextEditingController();
  final TextEditingController _underbowController = TextEditingController();
  final TextEditingController _kegiatanController = TextEditingController();

  String? _selectedGender;
  String? _selectedStatus;
  String? _selectedProvinsi;
  String? _selectedKota;
  String? _selectedKecamatan;
  String? _selectedKelurahan;
  String? _selectedPendidikan;
  bool _isChecked1 = false;
  bool _isChecked2 = false;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.red),
            onPressed: () {},
          ),
        ],
      ),
      body: LayoutBuilder(
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
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Selamat Datang Dani Setiawan !',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Silahkan lengkapi data Anda.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('NIK :'),
                                TextFormField(
                                  controller: _nikController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: 'NIK 16 digit',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
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
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Kawin/Belum :'),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  items: const [
                                    DropdownMenuItem(value: 'Kawin', child: Text('Kawin')),
                                    DropdownMenuItem(value: 'Belum', child: Text('Belum')),
                                  ],
                                  onChanged: (val) => setState(() => _selectedStatus = val),
                                  decoration: const InputDecoration(hintText: 'Kawin/Belum'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
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
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Alamat Sesuai KTP :'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedProvinsi,
                              items: const [DropdownMenuItem(value: 'Jawa Barat', child: Text('Jawa Barat'))],
                              onChanged: (val) => setState(() => _selectedProvinsi = val),
                              decoration: const InputDecoration(hintText: 'Provinsi'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKota,
                              items: const [DropdownMenuItem(value: 'Bandung', child: Text('Bandung'))],
                              onChanged: (val) => setState(() => _selectedKota = val),
                              decoration: const InputDecoration(hintText: 'Kota/Kabupaten'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKecamatan,
                              items: const [DropdownMenuItem(value: 'Cicendo', child: Text('Cicendo'))],
                              onChanged: (val) => setState(() => _selectedKecamatan = val),
                              decoration: const InputDecoration(hintText: 'Kecamatan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKelurahan,
                              items: const [DropdownMenuItem(value: 'Sukajadi', child: Text('Sukajadi'))],
                              onChanged: (val) => setState(() => _selectedKelurahan = val),
                              decoration: const InputDecoration(hintText: 'Kelurahan/Desa'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(hintText: 'RT'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
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
                      Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 10),
                          Expanded(
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
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
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
                          const SizedBox(width: 10),
                          Expanded(
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
                        ],
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
                              onTap: () {},
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Foto KTP', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
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
                          onPressed: () {},
                          child: const Text('Update', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.credit_card, color: Colors.amber, size: 36),
                            onPressed: _showEKtaDepan,
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.print, color: Colors.blue, size: 36),
                            onPressed: _showEKtaBelakang,
                          ),
                        ],
                      ),
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
