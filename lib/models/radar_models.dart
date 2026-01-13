class RadarLocationUser {
  final int id;
  final String name;
  final String? fotoProfil;
  final String? pekerjaan;
  final String? provinsi;
  final List<RadarUserRole> roles;

  RadarLocationUser({
    required this.id,
    required this.name,
    this.fotoProfil,
    this.pekerjaan,
    this.provinsi,
    required this.roles,
  });

  factory RadarLocationUser.fromJson(Map<String, dynamic> json) {
    return RadarLocationUser(
      id: json['id'],
      name: json['name'],
      fotoProfil: json['fotoProfil'],
      pekerjaan: json['pekerjaan'],
      provinsi: json['provinsi'],
      roles: (json['roles'] as List?)
              ?.map((role) => RadarUserRole.fromJson(role))
              .toList() ??
          [],
    );
  }

  String get primaryRole {
    if (roles.isEmpty) return 'user';
    return roles.first.role;
  }

  bool get isSimpatisan => roles.any((r) => r.role == 'simpatisan');
  bool get isKader => roles.any((r) => r.role == 'kader');
  bool get isAdmin => roles.any((r) => r.role == 'admin');
}

class RadarUserRole {
  final String role;

  RadarUserRole({required this.role});

  factory RadarUserRole.fromJson(Map<String, dynamic> json) {
    return RadarUserRole(
      role: json['role'],
    );
  }
}

class UserLocation {
  final int id;
  final double latitude;
  final double longitude;
  final double? distance;
  final DateTime lastUpdate;
  final RadarLocationUser user;
  final bool isSharingEnabled; // ⭐ Online status
  final bool isSavedLocation; // ⭐ Manual save flag

  UserLocation({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.distance,
    required this.lastUpdate,
    required this.user,
    this.isSharingEnabled = false,
    this.isSavedLocation = false,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      distance: json['distance']?.toDouble(),
      lastUpdate: DateTime.parse(json['last_update']),
      user: RadarLocationUser.fromJson(json['user']),
      isSharingEnabled: json['is_sharing_enabled'] ?? false,
      isSavedLocation: json['is_saved_location'] ?? false,
    );
  }

  String get distanceText {
    if (distance == null) return '';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)}m';
    }
    return '${distance!.toStringAsFixed(1)}km';
  }

  String get lastUpdateText {
    final now = DateTime.now();
    final diff = now.difference(lastUpdate);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  // Status helper
  bool get isOnline => isSharingEnabled;
  bool get isOffline => !isSharingEnabled;
}

class MyLocationStatus {
  final bool isSharingEnabled;
  final bool isSavedLocation; // ⭐ Last action was manual save
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime? lastUpdate;

  MyLocationStatus({
    required this.isSharingEnabled,
    this.isSavedLocation = false,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.lastUpdate,
  });

  factory MyLocationStatus.fromJson(Map<String, dynamic> json) {
    return MyLocationStatus(
      isSharingEnabled: json['is_sharing_enabled'] ?? false,
      isSavedLocation: json['is_saved_location'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      lastUpdate: json['last_update'] != null
          ? DateTime.parse(json['last_update'])
          : null,
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
}

class LocationHistoryItem {
  final int id;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  LocationHistoryItem({
    required this.id,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  factory LocationHistoryItem.fromJson(Map<String, dynamic> json) {
    return LocationHistoryItem(
      id: json['id'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      accuracy: json['accuracy']?.toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class LocationHistory {
  final int userId;
  final String userName;
  final List<LocationHistoryItem> history;
  final int total;

  LocationHistory({
    required this.userId,
    required this.userName,
    required this.history,
    required this.total,
  });

  factory LocationHistory.fromJson(Map<String, dynamic> json) {
    return LocationHistory(
      userId: json['userId'],
      userName: json['userName'],
      history: (json['history'] as List)
          .map((item) => LocationHistoryItem.fromJson(item))
          .toList(),
      total: json['total'],
    );
  }
}

class RadarStats {
  final int totalUsersWithLocation;
  final int totalSharingEnabled;
  final int totalLocationsLast24h;
  final int totalLocationHistoryRecords;
  final int activeUsersLastHour;
  final List<RegionCount> regions;

  RadarStats({
    required this.totalUsersWithLocation,
    required this.totalSharingEnabled,
    required this.totalLocationsLast24h,
    required this.totalLocationHistoryRecords,
    required this.activeUsersLastHour,
    required this.regions,
  });

  factory RadarStats.fromJson(Map<String, dynamic> json) {
    return RadarStats(
      totalUsersWithLocation: json['total_users_with_location'],
      totalSharingEnabled: json['total_sharing_enabled'],
      totalLocationsLast24h: json['total_locations_last_24h'],
      totalLocationHistoryRecords: json['total_location_history_records'],
      activeUsersLastHour: json['active_users_last_hour'],
      regions: (json['regions'] as List)
          .map((region) => RegionCount.fromJson(region))
          .toList(),
    );
  }
}

class RegionCount {
  final String provinsi;
  final int count;

  RegionCount({
    required this.provinsi,
    required this.count,
  });

  factory RegionCount.fromJson(Map<String, dynamic> json) {
    return RegionCount(
      provinsi: json['provinsi'],
      count: json['count'],
    );
  }
}
