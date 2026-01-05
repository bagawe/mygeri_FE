class UserProfile {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String username;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional fields
  final String? phone;
  final String? bio;

  // Identity
  final String? nik;
  final String? jenisKelamin;
  final String? statusKawin;
  final String? tempatLahir;
  final DateTime? tanggalLahir;

  // Address
  final String? provinsi;
  final String? kota;
  final String? kecamatan;
  final String? kelurahan;
  final String? rt;
  final String? rw;
  final String? jalan;

  // Profession & Education
  final String? pekerjaan;
  final String? pendidikan;

  // Political
  final String? underbow;
  final String? kegiatan;

  // Photos
  final String? fotoKtp;
  final String? fotoProfil;

  UserProfile({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.username,
    required this.isActive,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
    this.phone,
    this.bio,
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
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      lastLogin: json['lastLogin'] != null 
          ? DateTime.tryParse(json['lastLogin'] as String) 
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      nik: json['nik'] as String?,
      jenisKelamin: json['jenisKelamin'] as String?,
      statusKawin: json['statusKawin'] as String?,
      tempatLahir: json['tempatLahir'] as String?,
      tanggalLahir: json['tanggalLahir'] != null 
          ? DateTime.tryParse(json['tanggalLahir'] as String) 
          : null,
      provinsi: json['provinsi'] as String?,
      kota: json['kota'] as String?,
      kecamatan: json['kecamatan'] as String?,
      kelurahan: json['kelurahan'] as String?,
      rt: json['rt'] as String?,
      rw: json['rw'] as String?,
      jalan: json['jalan'] as String?,
      pekerjaan: json['pekerjaan'] as String?,
      pendidikan: json['pendidikan'] as String?,
      underbow: json['underbow'] as String?,
      kegiatan: json['kegiatan'] as String?,
      fotoKtp: json['fotoKtp'] as String?,
      fotoProfil: json['fotoProfil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'username': username,
    };

    // Only add non-null optional fields
    if (phone != null && phone!.isNotEmpty) map['phone'] = phone;
    if (bio != null && bio!.isNotEmpty) map['bio'] = bio;
    if (nik != null && nik!.isNotEmpty) map['nik'] = nik;
    if (jenisKelamin != null) map['jenisKelamin'] = jenisKelamin;
    if (statusKawin != null) map['statusKawin'] = statusKawin;
    if (tempatLahir != null && tempatLahir!.isNotEmpty) map['tempatLahir'] = tempatLahir;
    if (tanggalLahir != null) {
      map['tanggalLahir'] = tanggalLahir!.toIso8601String().split('T')[0]; // YYYY-MM-DD
    }
    if (provinsi != null) map['provinsi'] = provinsi;
    if (kota != null) map['kota'] = kota;
    if (kecamatan != null) map['kecamatan'] = kecamatan;
    if (kelurahan != null) map['kelurahan'] = kelurahan;
    if (rt != null && rt!.isNotEmpty) map['rt'] = rt;
    if (rw != null && rw!.isNotEmpty) map['rw'] = rw;
    if (jalan != null && jalan!.isNotEmpty) map['jalan'] = jalan;
    if (pekerjaan != null && pekerjaan!.isNotEmpty) map['pekerjaan'] = pekerjaan;
    if (pendidikan != null) map['pendidikan'] = pendidikan;
    if (underbow != null && underbow!.isNotEmpty) map['underbow'] = underbow;
    if (kegiatan != null && kegiatan!.isNotEmpty) map['kegiatan'] = kegiatan;

    return map;
  }

  // Helper untuk get full photo URL
  String? getFullPhotoUrl(String baseUrl) {
    if (fotoProfil == null) return null;
    return '$baseUrl$fotoProfil';
  }

  String? getFullKtpUrl(String baseUrl) {
    if (fotoKtp == null) return null;
    return '$baseUrl$fotoKtp';
  }

  // Copy with method untuk update local state
  UserProfile copyWith({
    String? phone,
    String? bio,
    String? nik,
    String? jenisKelamin,
    String? statusKawin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? provinsi,
    String? kota,
    String? kecamatan,
    String? kelurahan,
    String? rt,
    String? rw,
    String? jalan,
    String? pekerjaan,
    String? pendidikan,
    String? underbow,
    String? kegiatan,
    String? fotoKtp,
    String? fotoProfil,
  }) {
    return UserProfile(
      id: id,
      uuid: uuid,
      name: name,
      email: email,
      username: username,
      isActive: isActive,
      lastLogin: lastLogin,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      nik: nik ?? this.nik,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      statusKawin: statusKawin ?? this.statusKawin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      provinsi: provinsi ?? this.provinsi,
      kota: kota ?? this.kota,
      kecamatan: kecamatan ?? this.kecamatan,
      kelurahan: kelurahan ?? this.kelurahan,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      jalan: jalan ?? this.jalan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      pendidikan: pendidikan ?? this.pendidikan,
      underbow: underbow ?? this.underbow,
      kegiatan: kegiatan ?? this.kegiatan,
      fotoKtp: fotoKtp ?? this.fotoKtp,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }
}
