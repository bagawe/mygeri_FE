import 'package:intl/intl.dart';

/// Model untuk data KTA (Kartu Tanda Anggota)
class KTAData {
  final int userId;
  final String name;
  final String email;
  final String role;
  final bool ktaVerified;
  final DateTime? ktaVerifiedAt;
  final VerifiedBy? verifiedBy;
  final String cardNumber;
  final bool canPrint;
  final String message;
  final String? fotoProfil;
  final String? tanggalLahir;
  final String? alamatLengkap;
  final String? jenisKelamin;

  KTAData({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.ktaVerified,
    this.ktaVerifiedAt,
    this.verifiedBy,
    required this.cardNumber,
    required this.canPrint,
    required this.message,
    this.fotoProfil,
    this.tanggalLahir,
    this.alamatLengkap,
    this.jenisKelamin,
  });

  factory KTAData.fromJson(Map<String, dynamic> json) {
    return KTAData(
      userId: json['user_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      ktaVerified: json['kta_verified'] ?? false,
      ktaVerifiedAt: json['kta_verified_at'] != null
          ? DateTime.parse(json['kta_verified_at'])
          : null,
      verifiedBy: json['verified_by'] != null
          ? VerifiedBy.fromJson(json['verified_by'])
          : null,
      cardNumber: json['card_number'] ?? '',
      canPrint: json['can_print'] ?? false,
      message: json['message'] ?? '',
      fotoProfil: json['fotoProfil'],
      tanggalLahir: json['tanggal_lahir'],
      alamatLengkap: json['alamat_lengkap'],
      jenisKelamin: json['jenis_kelamin'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'kta_verified': ktaVerified,
      'kta_verified_at': ktaVerifiedAt?.toIso8601String(),
      'verified_by': verifiedBy?.toJson(),
      'card_number': cardNumber,
      'can_print': canPrint,
      'message': message,
      'fotoProfil': fotoProfil,
      'tanggal_lahir': tanggalLahir,
      'alamat_lengkap': alamatLengkap,
      'jenis_kelamin': jenisKelamin,
    };
  }

  String get formattedVerifiedDate {
    if (ktaVerifiedAt == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id').format(ktaVerifiedAt!);
  }

  String get formattedTanggalLahir {
    if (tanggalLahir == null) return '-';
    try {
      final date = DateTime.parse(tanggalLahir!);
      return DateFormat('dd MMMM yyyy', 'id').format(date);
    } catch (e) {
      return tanggalLahir!;
    }
  }

  String get qrCodeData => userId.toString();

  String get printDate {
    return DateFormat('dd MMMM yyyy', 'id').format(DateTime.now());
  }
}

/// Model untuk data admin yang melakukan verifikasi
class VerifiedBy {
  final int id;
  final String name;
  final String? email;

  VerifiedBy({
    required this.id,
    required this.name,
    this.email,
  });

  factory VerifiedBy.fromJson(Map<String, dynamic> json) {
    return VerifiedBy(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

/// Model untuk list user (admin view)
class KTAUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool ktaVerified;
  final DateTime? ktaVerifiedAt;
  final VerifiedBy? verifiedBy;
  final String cardNumber;
  final DateTime createdAt;

  KTAUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.ktaVerified,
    this.ktaVerifiedAt,
    this.verifiedBy,
    required this.cardNumber,
    required this.createdAt,
  });

  factory KTAUser.fromJson(Map<String, dynamic> json) {
    return KTAUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      ktaVerified: json['kta_verified'] ?? false,
      ktaVerifiedAt: json['kta_verified_at'] != null
          ? DateTime.parse(json['kta_verified_at'])
          : null,
      verifiedBy: json['verified_by'] != null
          ? VerifiedBy.fromJson(json['verified_by'])
          : null,
      cardNumber: json['card_number'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get formattedCreatedAt {
    return DateFormat('dd MMM yyyy').format(createdAt);
  }

  String get formattedVerifiedAt {
    if (ktaVerifiedAt == null) return '-';
    return DateFormat('dd MMM yyyy').format(ktaVerifiedAt!);
  }
}

/// Model untuk pagination
class Pagination {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  Pagination({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      hasMore: json['has_more'],
    );
  }

  int get currentPage => (offset / limit).floor() + 1;
  int get totalPages => (total / limit).ceil();
}

/// Model untuk statistik (admin view)
class KTAStatistics {
  final int totalUsers;
  final int verifiedUsers;
  final int unverifiedUsers;
  final String verificationRate;
  final Map<String, RoleStats> byRole;
  final List<RecentVerification> recentVerifications;

  KTAStatistics({
    required this.totalUsers,
    required this.verifiedUsers,
    required this.unverifiedUsers,
    required this.verificationRate,
    required this.byRole,
    required this.recentVerifications,
  });

  factory KTAStatistics.fromJson(Map<String, dynamic> json) {
    final byRoleJson = json['by_role'] as Map<String, dynamic>? ?? {};
    final byRole = <String, RoleStats>{};
    byRoleJson.forEach((key, value) {
      byRole[key] = RoleStats.fromJson(value);
    });

    return KTAStatistics(
      totalUsers: json['total_users'] ?? 0,
      verifiedUsers: json['verified_users'] ?? 0,
      unverifiedUsers: json['unverified_users'] ?? 0,
      verificationRate: json['verification_rate'] ?? '0',
      byRole: byRole,
      recentVerifications: (json['recent_verifications'] as List<dynamic>?)
              ?.map((v) => RecentVerification.fromJson(v))
              .toList() ??
          [],
    );
  }
}

/// Model untuk statistik per role
class RoleStats {
  final int total;
  final int verified;
  final int unverified;

  RoleStats({
    required this.total,
    required this.verified,
    required this.unverified,
  });

  factory RoleStats.fromJson(Map<String, dynamic> json) {
    return RoleStats(
      total: json['total'] ?? 0,
      verified: json['verified'] ?? 0,
      unverified: json['unverified'] ?? 0,
    );
  }

  double get verificationRate {
    if (total == 0) return 0;
    return (verified / total) * 100;
  }
}

/// Model untuk recent verification
class RecentVerification {
  final int userId;
  final String name;
  final bool verified;
  final DateTime verifiedAt;
  final VerifiedBy verifiedBy;

  RecentVerification({
    required this.userId,
    required this.name,
    required this.verified,
    required this.verifiedAt,
    required this.verifiedBy,
  });

  factory RecentVerification.fromJson(Map<String, dynamic> json) {
    return RecentVerification(
      userId: json['user_id'],
      name: json['name'],
      verified: json['verified'] ?? true,
      verifiedAt: DateTime.parse(json['verified_at']),
      verifiedBy: VerifiedBy.fromJson(json['verified_by']),
    );
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy, HH:mm').format(verifiedAt);
  }
}

/// Model untuk QR verification result
class QRVerificationResult {
  final bool valid;
  final bool verified;
  final String message;
  final QRUserInfo? user;

  QRVerificationResult({
    required this.valid,
    required this.verified,
    required this.message,
    this.user,
  });

  factory QRVerificationResult.fromJson(Map<String, dynamic> json) {
    return QRVerificationResult(
      valid: json['valid'] ?? false,
      verified: json['verified'] ?? false,
      message: json['message'] ?? '',
      user:
          json['user'] != null ? QRUserInfo.fromJson(json['user']) : null,
    );
  }
}

/// Model untuk user info dari QR scan
class QRUserInfo {
  final String name;
  final String role;
  final String cardNumber;
  final DateTime? verifiedAt;

  QRUserInfo({
    required this.name,
    required this.role,
    required this.cardNumber,
    this.verifiedAt,
  });

  factory QRUserInfo.fromJson(Map<String, dynamic> json) {
    return QRUserInfo(
      name: json['name'],
      role: json['role'],
      cardNumber: json['card_number'],
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
    );
  }
}
