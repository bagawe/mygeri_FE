class RegisterRequest {
  final String name;
  final String email;
  final String username;
  final String password;
  
  // Data tambahan untuk kader (opsional)
  final String? nik;
  final String? jenisKelamin;
  final String? statusKawin;
  final String? tempatLahir;
  final String? tanggalLahir;
  final String? provinsi;
  final String? kota;
  final String? kecamatan;
  final String? kelurahan;
  final String? rt;
  final String? rw;
  final String? jalan;
  final String? pekerjaan;
  final String? pendidikan;
  final String? underbow;
  final String? kegiatan;
  final String? fotoKtp;
  final String? fotoProfil;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    this.nik,
    this.jenisKelamin,
    this.statusKawin,
    this.tempatLahir,
    this.tanggalLahir,
    this.provinsi,
    this.kota,
    this.kecamatan,
    this.kelurahan,
    this.rt,
    this.rw,
    this.jalan,
    this.pekerjaan,
    this.pendidikan,
    this.underbow,
    this.kegiatan,
    this.fotoKtp,
    this.fotoProfil,
  }) {
    // Validation untuk required fields
    if (name.trim().isEmpty) throw ArgumentError('Name cannot be empty');
    if (email.trim().isEmpty) throw ArgumentError('Email cannot be empty');
    if (username.trim().isEmpty) throw ArgumentError('Username cannot be empty');
    if (password.isEmpty) throw ArgumentError('Password cannot be empty');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'email': email,
      'username': username,
      'password': password,
    };

    // Tambahkan field opsional jika ada dan tidak empty
    if (nik != null && nik!.isNotEmpty) json['nik'] = nik;
    if (jenisKelamin != null && jenisKelamin!.isNotEmpty) json['jenis_kelamin'] = jenisKelamin;
    if (statusKawin != null && statusKawin!.isNotEmpty) json['status_kawin'] = statusKawin;
    if (tempatLahir != null && tempatLahir!.isNotEmpty) json['tempat_lahir'] = tempatLahir;
    if (tanggalLahir != null && tanggalLahir!.isNotEmpty) json['tanggal_lahir'] = tanggalLahir;
    if (provinsi != null && provinsi!.isNotEmpty) json['provinsi'] = provinsi;
    if (kota != null && kota!.isNotEmpty) json['kota'] = kota;
    if (kecamatan != null && kecamatan!.isNotEmpty) json['kecamatan'] = kecamatan;
    if (kelurahan != null && kelurahan!.isNotEmpty) json['kelurahan'] = kelurahan;
    if (rt != null && rt!.isNotEmpty) json['rt'] = rt;
    if (rw != null && rw!.isNotEmpty) json['rw'] = rw;
    if (jalan != null && jalan!.isNotEmpty) json['jalan'] = jalan;
    if (pekerjaan != null && pekerjaan!.isNotEmpty) json['pekerjaan'] = pekerjaan;
    if (pendidikan != null && pendidikan!.isNotEmpty) json['pendidikan'] = pendidikan;
    if (underbow != null && underbow!.isNotEmpty) json['underbow'] = underbow;
    if (kegiatan != null && kegiatan!.isNotEmpty) json['kegiatan'] = kegiatan;
    if (fotoKtp != null && fotoKtp!.isNotEmpty) json['foto_ktp'] = fotoKtp;
    if (fotoProfil != null && fotoProfil!.isNotEmpty) json['foto_profil'] = fotoProfil;

    return json;
  }
}
