# 📡 Radar Feature - Complete Analysis & Requirements

**Date:** 8 Januari 2026  
**Status:** ✅ Ready for Implementation  
**Priority:** HIGH  
**Timeline:** 4 Weeks (Phase 1)

---

## ✅ DECISIONS FINALIZED (8 Jan 2026)

**Keputusan implementasi yang sudah disetujui:**

1. **Map Provider: OpenStreetMap (flutter_map)** ✅
   - FREE, unlimited usage, no API key needed
   - Package: `flutter_map` + `latlong2`
   - Tile source: OpenStreetMap contributors

2. **Location History: YES (Admin Only)** ✅
   - Database: `location_history` table will be created
   - UI: Tidak ditampilkan di mobile app
   - Access: Admin only via web dashboard (future)
   - Purpose: Analytics, monitoring, dan audit trail

3. **Privacy & Access Control: Role-Based** ✅
   - **Simpatisan:** Hanya lihat sesama simpatisan
   - **Kader:** Bisa lihat semua kader + simpatisan
   - **Admin:** Full access + location history
   - Filtering dilakukan di backend berdasarkan `user.role`

4. **Update Frequency: 1 Hour Auto + Manual** ✅
   - Background auto-update: Setiap 1 jam (saat switch ON)
   - Manual refresh: Button tersedia kapan saja
   - Battery friendly & tidak membebani device
   - User punya kontrol penuh (ON/OFF via switch)

5. **Implementation Phase: Phase 1 (4 Weeks)** ✅
   - Week 1-2: MVP (map display, manual refresh, toggle switch)
   - Week 3-4: Background service, filters, polish UI
   - **Advanced features (Phase 2):** Deferred until after Phase 1 launch
   - **Strategy:** Launch → Get feedback → Iterate → Decide Phase 2

**Rationale for Phase 1 First:**
- Get real user feedback on core features before investing in advanced features
- Faster time-to-market (4 weeks vs 6 weeks)
- Validate concept with owner and users
- Learn from actual usage patterns
- Lower development risk
- Easier to pivot if needed based on feedback

---

## 📋 Executive Summary

Fitur Radar akan menampilkan peta interaktif yang menunjukkan lokasi real-time para kader Gerindra di wilayah tertentu. Fitur ini menggunakan GPS tracking dengan auto-update setiap 1 jam, dan memberikan user kontrol penuh untuk share/hide lokasi mereka.

**Map Technology:** OpenStreetMap (FREE, open source)  
**Access Control:** Role-based (Simpatisan vs Kader)  
**Update Method:** Auto (1 hour) + Manual refresh

---

## 🎯 Feature Requirements

### 1. **Core Functionality**

| Feature | Description | Priority |
|---------|-------------|----------|
| **Map Display** | Tampilkan peta interaktif Indonesia/Regional | ⭐⭐⭐ Critical |
| **User Markers** | Show avatar/icon kader di peta berdasarkan lat/long | ⭐⭐⭐ Critical |
| **Auto Update** | Background location update setiap 1 jam | ⭐⭐⭐ Critical |
| **Location Toggle** | Switch ON/OFF untuk share lokasi | ⭐⭐⭐ Critical |
| **Manual Refresh** | Button untuk force update lokasi sekarang | ⭐⭐ High |
| **User Info** | Tap marker untuk lihat info kader (nama, jabatan, dll) | ⭐⭐ High |
| **Filter** | Filter by wilayah/region/jabatan | ⭐ Medium |
| **Clustering** | Group markers ketika zoom out (banyak kader) | ⭐ Medium |

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      RADAR FEATURE                          │
└─────────────────────────────────────────────────────────────┘

┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Flutter    │  HTTP   │   Backend    │  Query  │   Database   │
│   Frontend   │ ◄─────► │   API        │ ◄─────► │   MySQL      │
└──────────────┘         └──────────────┘         └──────────────┘
       │                         │
       │ GPS                     │ Store
       ▼                         ▼
┌──────────────┐         ┌──────────────┐
│   Device     │         │   Location   │
│   Location   │         │   Table      │
└──────────────┘         └──────────────┘
```

---

## 📱 Flutter Implementation Requirements

### **A. Dependencies (pubspec.yaml)**

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Map Display - USING OPENSTREETMAP (FREE)
  flutter_map: ^6.1.0            # OpenStreetMap renderer
  latlong2: ^0.9.0               # Latitude/Longitude utilities
  
  # Location Services
  geolocator: ^10.1.0            # Get GPS coordinates
  permission_handler: ^11.1.0    # Request location permission
  
  # Background Tasks
  workmanager: ^0.5.1            # Periodic background updates (1 hour)
  
  # HTTP & State
  http: ^1.1.0                   # API calls
  provider: ^6.1.1               # State management (or existing solution)
  flutter_secure_storage: ^9.0.0 # Already have this
  
  # Optional - Advanced Features (Phase 2)
  flutter_map_marker_cluster: ^1.3.0  # Cluster markers
  cached_network_image: ^3.3.0        # Cache user avatars
```

**Note:** Tidak perlu Google Maps API key, hemat biaya!

---

### **B. Required Permissions**

#### **Android (android/app/src/main/AndroidManifest.xml)**

```xml
<manifest>
    <!-- Location Permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <!-- Internet (already have) -->
    <uses-permission android:name="android.permission.INTERNET" />
    
    <!-- Wake Lock for background tasks -->
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    
    <application>
        <!-- ... existing config ... -->
        
        <!-- Background Work Manager -->
        <service
            android:name="androidx.work.impl.background.systemjob.SystemJobService"
            android:permission="android.permission.BIND_JOB_SERVICE" />
    </application>
</manifest>
```

#### **iOS (ios/Runner/Info.plist)**

```xml
<dict>
    <!-- Location Permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>MyGeri membutuhkan akses lokasi untuk menampilkan posisi Anda di peta Radar</string>
    
    <key>NSLocationAlwaysUsageDescription</key>
    <string>MyGeri perlu akses lokasi background untuk update otomatis posisi Anda di Radar</string>
    
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>MyGeri membutuhkan akses lokasi untuk fitur Radar agar kader lain bisa melihat posisi Anda</string>
    
    <!-- Background Modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>fetch</string>
        <string>processing</string>
    </array>
</dict>
```

---

### **C. File Structure**

```
lib/
├── pages/
│   └── radar/
│       ├── radar_page.dart               # Main page with map
│       ├── widgets/
│       │   ├── map_view.dart             # Google Map widget
│       │   ├── location_toggle.dart      # Share location switch
│       │   ├── refresh_button.dart       # Manual refresh button
│       │   └── user_marker_info.dart     # Info card when tap marker
│       └── models/
│           └── kader_location.dart       # Location data model
├── services/
│   ├── location_service.dart             # GPS logic
│   ├── radar_api_service.dart            # API calls
│   └── background_location_service.dart  # Auto-update every 1 hour
├── providers/
│   └── radar_provider.dart               # State management
└── utils/
    └── map_utils.dart                    # Map helpers
```

---

### **D. Core Implementation Logic**

#### **1. Location Service (services/location_service.dart)**

```dart
class LocationService {
  final Geolocator _geolocator = Geolocator();
  
  // Check if location permission granted
  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }
  
  // Get current location
  Future<Position?> getCurrentLocation() async {
    if (!await hasPermission()) return null;
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
  
  // Get coordinates
  Future<Map<String, double>?> getCoordinates() async {
    final position = await getCurrentLocation();
    if (position == null) return null;
    
    return {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
  }
}
```

#### **2. Background Auto-Update (services/background_location_service.dart)**

```dart
class BackgroundLocationService {
  static const String taskName = "radarLocationUpdate";
  
  // Initialize background task
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }
  
  // Register periodic task (every 1 hour)
  static Future<void> registerPeriodicUpdate() async {
    await Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
  
  // Cancel task when user turns OFF location sharing
  static Future<void> cancelPeriodicUpdate() async {
    await Workmanager().cancelByUniqueName(taskName);
  }
}

// Background callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Get current location
      final locationService = LocationService();
      final coords = await locationService.getCoordinates();
      
      if (coords != null) {
        // Send to backend
        final radarApi = RadarApiService();
        await radarApi.updateMyLocation(
          latitude: coords['latitude']!,
          longitude: coords['longitude']!,
        );
      }
      
      return Future.value(true);
    } catch (e) {
      print('Background location update failed: $e');
      return Future.value(false);
    }
  });
}
```

#### **3. API Service (services/radar_api_service.dart)**

```dart
class RadarApiService {
  final String baseUrl = 'http://103.127.138.40:3030';
  final _storage = const FlutterSecureStorage();
  
  // Update my location to backend
  Future<void> updateMyLocation({
    required double latitude,
    required double longitude,
  }) async {
    final token = await _storage.read(key: 'access_token');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/radar/update-location'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update location');
    }
  }
  
  // Get all kader locations
  Future<List<KaderLocation>> getKaderLocations({
    String? region,
    String? jabatan,
  }) async {
    final token = await _storage.read(key: 'access_token');
    
    String url = '$baseUrl/api/radar/locations';
    if (region != null || jabatan != null) {
      url += '?';
      if (region != null) url += 'region=$region&';
      if (jabatan != null) url += 'jabatan=$jabatan';
    }
    
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => KaderLocation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load kader locations');
    }
  }
  
  // Toggle location sharing ON/OFF
  Future<void> toggleLocationSharing(bool enabled) async {
    final token = await _storage.read(key: 'access_token');
    
    await http.post(
      Uri.parse('$baseUrl/api/radar/toggle-sharing'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'enabled': enabled,
      }),
    );
  }
}
```

#### **4. Data Model (pages/radar/models/kader_location.dart)**

```dart
class KaderLocation {
  final int userId;
  final String name;
  final String? avatar;
  final double latitude;
  final double longitude;
  final String? jabatan;
  final String? region;
  final DateTime lastUpdate;
  
  KaderLocation({
    required this.userId,
    required this.name,
    this.avatar,
    required this.latitude,
    required this.longitude,
    this.jabatan,
    this.region,
    required this.lastUpdate,
  });
  
  factory KaderLocation.fromJson(Map<String, dynamic> json) {
    return KaderLocation(
      userId: json['user_id'],
      name: json['name'],
      avatar: json['avatar'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      jabatan: json['jabatan'],
      region: json['region'],
      lastUpdate: DateTime.parse(json['last_update']),
    );
  }
}
```

#### **5. Radar Page with OpenStreetMap (pages/radar/radar_page.dart)**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({Key? key}) : super(key: key);

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final LocationService _locationService = LocationService();
  final RadarApiService _radarApi = RadarApiService();
  final MapController _mapController = MapController();
  
  List<KaderLocation> _kaderLocations = [];
  Position? _myPosition;
  bool _isLocationSharingEnabled = false;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeRadar();
  }
  
  Future<void> _initializeRadar() async {
    // 1. Check permission
    final hasPermission = await _locationService.hasPermission();
    if (!hasPermission) {
      _showPermissionDialog();
      return;
    }
    
    // 2. Get my location
    _myPosition = await _locationService.getCurrentLocation();
    
    // 3. Load kader locations from backend
    await _loadKaderLocations();
    
    // 4. Load sharing status
    await _loadSharingStatus();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  Future<void> _loadKaderLocations() async {
    try {
      final locations = await _radarApi.getKaderLocations();
      setState(() {
        _kaderLocations = locations;
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }
  
  Future<void> _loadSharingStatus() async {
    // Load from SharedPreferences or backend
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocationSharingEnabled = prefs.getBool('location_sharing') ?? false;
    });
  }
  
  Future<void> _toggleLocationSharing(bool enabled) async {
    setState(() {
      _isLocationSharingEnabled = enabled;
    });
    
    // Save to preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_sharing', enabled);
    
    // Update backend
    await _radarApi.toggleLocationSharing(enabled);
    
    // Start/stop background updates
    if (enabled) {
      await BackgroundLocationService.registerPeriodicUpdate();
      // Update location immediately
      await _refreshMyLocation();
    } else {
      await BackgroundLocationService.cancelPeriodicUpdate();
    }
  }
  
  Future<void> _refreshMyLocation() async {
    final coords = await _locationService.getCoordinates();
    if (coords != null) {
      await _radarApi.updateMyLocation(
        latitude: coords['latitude']!,
        longitude: coords['longitude']!,
      );
      
      // Reload map
      await _loadKaderLocations();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi berhasil diupdate')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar Kader'),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap Display
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                _myPosition?.latitude ?? -6.2088,
                _myPosition?.longitude ?? 106.8456,
              ),
              initialZoom: 12.0,
              minZoom: 5.0,
              maxZoom: 18.0,
            ),
            children: [
              // OpenStreetMap Tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gerindra.mygeri',
                maxNativeZoom: 19,
              ),
              
              // Markers Layer
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          
          // Control Panel (top)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        const Text('Share Lokasi Saya'),
                        const Spacer(),
                        Switch(
                          value: _isLocationSharingEnabled,
                          onChanged: _toggleLocationSharing,
                        ),
                      ],
                    ),
                    if (_isLocationSharingEnabled)
                      ElevatedButton.icon(
                        onPressed: _refreshMyLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Lokasi Sekarang'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Stats (bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Total Online: ${_kaderLocations.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Marker> _buildMarkers() {
    return _kaderLocations.map((kader) {
      return Marker(
        point: LatLng(kader.latitude, kader.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showKaderInfo(kader),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getMarkerColor(kader.jabatan),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 17,
              backgroundImage: kader.avatar != null
                  ? NetworkImage(kader.avatar!)
                  : null,
              child: kader.avatar == null
                  ? Text(
                      kader.name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
        ),
      );
    }).toList();
  }
  
  Color _getMarkerColor(String? jabatan) {
    switch (jabatan?.toLowerCase()) {
      case 'ketua dpc':
      case 'ketua':
        return Colors.red;
      case 'sekretaris':
        return Colors.blue;
      case 'bendahara':
        return Colors.orange;
      default:
        return Colors.green; // Anggota/Simpatisan
    }
  }
  
  void _showKaderInfo(KaderLocation kader) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: kader.avatar != null
                  ? NetworkImage(kader.avatar!)
                  : null,
              child: kader.avatar == null
                  ? Text(kader.name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              kader.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (kader.jabatan != null)
              Text(kader.jabatan!),
            if (kader.region != null)
              Text('Region: ${kader.region}'),
            const SizedBox(height: 8),
            Text(
              'Last update: ${_formatTime(kader.lastUpdate)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
  
  void _showFilterDialog() {
    // Show filter options
  }
}
```

---

## 🔧 Backend Requirements

### **1. Database Schema**

```sql
-- Table: user_locations
CREATE TABLE user_locations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    accuracy FLOAT,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_sharing_enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_last_update (last_update),
    INDEX idx_sharing (is_sharing_enabled)
);

-- Table: location_history (optional - for analytics)
CREATE TABLE location_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_timestamp (user_id, timestamp)
);
```

### **2. Required API Endpoints**

#### **A. POST /api/radar/update-location**
Update user location (called every 1 hour or manual refresh)

**Request:**
```json
{
  "latitude": -6.2088,
  "longitude": 106.8456,
  "accuracy": 15.5,
  "timestamp": "2026-01-08T10:30:00Z"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location updated successfully"
}
```

**Logic:**
- Get user_id from JWT token
- Insert/update location in `user_locations` table
- Only update if `is_sharing_enabled = true`
- Optionally save to `location_history` for tracking

---

#### **B. GET /api/radar/locations**
Get all active kader locations

**Query Params:**
- `region` (optional): Filter by region
- `jabatan` (optional): Filter by position
- `radius` (optional): Get users within X km
- `lat` & `lng` (optional): Center point for radius filter

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "user_id": 123,
      "name": "John Doe",
      "avatar": "https://example.com/avatar.jpg",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "jabatan": "Ketua DPC",
      "region": "Jakarta Pusat",
      "last_update": "2026-01-08T10:30:00Z"
    },
    {
      "user_id": 456,
      "name": "Jane Smith",
      "avatar": null,
      "latitude": -6.2100,
      "longitude": 106.8470,
      "jabatan": "Sekretaris",
      "region": "Jakarta Selatan",
      "last_update": "2026-01-08T09:45:00Z"
    }
  ],
  "total": 2
}
```

**Logic:**
- Join `user_locations` with `users` table
- Filter only users with `is_sharing_enabled = true`
- Filter by region/jabatan if provided
- Optional: Calculate distance if radius filter used
- Return only locations updated within last 24 hours (fresh data)

---

#### **C. POST /api/radar/toggle-sharing**
Enable/disable location sharing

**Request:**
```json
{
  "enabled": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Location sharing enabled",
  "is_sharing_enabled": true
}
```

**Logic:**
- Update `is_sharing_enabled` in `user_locations` table
- If disabled, optionally clear lat/lng or keep for history

---

#### **D. GET /api/radar/my-status**
Get current user's sharing status and last update

**Response:**
```json
{
  "success": true,
  "data": {
    "is_sharing_enabled": true,
    "last_update": "2026-01-08T10:30:00Z",
    "latitude": -6.2088,
    "longitude": 106.8456
  }
}
```

---

### **3. Security Considerations**

```javascript
// Backend validation
const radarController = {
  updateLocation: async (req, res) => {
    const { latitude, longitude } = req.body;
    const userId = req.user.id; // From JWT
    
    // 1. Validate coordinates
    if (!isValidCoordinate(latitude, longitude)) {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }
    
    // 2. Rate limiting (max 1 update per minute)
    const lastUpdate = await getLastUpdate(userId);
    if (lastUpdate && Date.now() - lastUpdate < 60000) {
      return res.status(429).json({ error: 'Too many requests' });
    }
    
    // 3. Check sharing status
    const user = await User.findById(userId);
    if (!user.is_sharing_enabled) {
      return res.status(403).json({ error: 'Location sharing is disabled' });
    }
    
    // 4. Update location
    await updateUserLocation(userId, latitude, longitude);
    
    res.json({ success: true });
  },
  
  getLocations: async (req, res) => {
    const userId = req.user.id;
    
    // Only show locations to authenticated users
    // Optional: Only show to verified kader
    
    const locations = await getActiveLocations({
      region: req.query.region,
      jabatan: req.query.jabatan,
    });
    
    res.json({ success: true, data: locations });
  }
};

function isValidCoordinate(lat, lng) {
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}
```

---

## ⚡ Performance Optimization

### **1. Frontend**

```dart
// Cache locations locally to reduce API calls
class RadarCache {
  static const Duration cacheDuration = Duration(minutes: 5);
  static DateTime? _lastFetch;
  static List<KaderLocation>? _cachedLocations;
  
  static Future<List<KaderLocation>> getLocations(
    RadarApiService api,
  ) async {
    if (_cachedLocations != null && _lastFetch != null) {
      final timeSinceCache = DateTime.now().difference(_lastFetch!);
      if (timeSinceCache < cacheDuration) {
        return _cachedLocations!;
      }
    }
    
    // Fetch fresh data
    _cachedLocations = await api.getKaderLocations();
    _lastFetch = DateTime.now();
    return _cachedLocations!;
  }
}
```

### **2. Backend**

```javascript
// Add database indexes (already in schema above)
// Use Redis cache for frequently accessed data

const redis = require('redis');
const client = redis.createClient();

async function getActiveLocations() {
  // Try cache first
  const cached = await client.get('radar:locations');
  if (cached) {
    return JSON.parse(cached);
  }
  
  // Query database
  const locations = await db.query(`
    SELECT 
      u.id as user_id,
      u.name,
      u.avatar,
      ul.latitude,
      ul.longitude,
      u.jabatan,
      u.region,
      ul.last_update
    FROM user_locations ul
    JOIN users u ON ul.user_id = u.id
    WHERE ul.is_sharing_enabled = true
      AND ul.last_update > DATE_SUB(NOW(), INTERVAL 24 HOUR)
    ORDER BY ul.last_update DESC
  `);
  
  // Cache for 2 minutes
  await client.setex('radar:locations', 120, JSON.stringify(locations));
  
  return locations;
}
```

---

## 🔒 Privacy & GDPR Compliance

### **User Consent Requirements**

1. **Explicit Opt-In:**
   - Default: Location sharing OFF
   - Require user to manually enable switch
   - Show clear explanation dialog before enabling

2. **Data Retention:**
   - Delete location data older than 30 days
   - User can request full data deletion

3. **Privacy Settings Page:**
   ```dart
   // In Pengaturan page
   ListTile(
     leading: const Icon(Icons.radar),
     title: const Text('Radar & Lokasi'),
     subtitle: Text(_isSharingLocation 
       ? 'Lokasi dibagikan' 
       : 'Lokasi tidak dibagikan'),
     trailing: Switch(
       value: _isSharingLocation,
       onChanged: _toggleRadarSharing,
     ),
   ),
   ```

4. **Transparency:**
   - Show "Last updated: X hours ago" on map
   - Allow users to see who can see their location
   - Option to hide from specific users/groups

---

## 🎨 UI/UX Design Recommendations

### **1. Map Style**
- Use custom map styling (match brand colors)
- Dark mode support
- Smooth animations when markers update

### **2. Marker Design**
- Use user avatar as marker (circular)
- Add border color by jabatan:
  - Red: Ketua
  - Blue: Sekretaris
  - Green: Anggota
- Pulsing animation for recently updated (<5 min)

### **3. Info Card**
When tap marker, show bottom sheet with:
- Avatar
- Name
- Jabatan
- Region
- Last update time
- Button: "Lihat Profil" / "Chat"

### **4. Controls**
- Floating action buttons:
  - 📍 My Location
  - 🔄 Refresh All
  - 🔍 Search Kader
  - 📊 Statistics

---

## 📊 Analytics & Monitoring

### **Metrics to Track**

```dart
// Firebase Analytics or custom backend analytics

class RadarAnalytics {
  static void logLocationUpdate() {
    // Track how often users update location
    FirebaseAnalytics.instance.logEvent(
      name: 'radar_location_update',
      parameters: {'timestamp': DateTime.now().toString()},
    );
  }
  
  static void logMapView() {
    // Track map opens
    FirebaseAnalytics.instance.logEvent(name: 'radar_page_opened');
  }
  
  static void logMarkerTap(String userId) {
    // Track which kaders are viewed most
    FirebaseAnalytics.instance.logEvent(
      name: 'radar_marker_tap',
      parameters: {'user_id': userId},
    );
  }
}
```

**Backend Metrics:**
- Total active locations (sharing enabled)
- Average update frequency
- Most active regions
- Peak usage times

---

## 🚀 Implementation Phases

### **Phase 1: MVP (1-2 weeks)**
- ✅ Basic map display with Google Maps
- ✅ Manual location update button
- ✅ Toggle switch for sharing
- ✅ Backend API endpoints
- ✅ Database tables

### **Phase 2: Auto-Update (1 week)**
- ✅ Background service (WorkManager)
- ✅ Periodic updates every 1 hour
- ✅ Battery optimization
- ✅ Network retry logic

### **Phase 3: Enhanced Features (2 weeks)**
- ✅ Marker clustering
- ✅ Filter by region/jabatan
- ✅ Search kader by name
- ✅ Statistics dashboard
- ✅ Custom marker designs

### **Phase 4: Polish (1 week)**
- ✅ Dark mode support
- ✅ Animations
- ✅ Error handling improvements
- ✅ Performance optimization
- ✅ User testing & feedback

---

## ⚠️ Potential Challenges & Solutions

### **1. Battery Drain**
**Problem:** GPS + background updates = high battery usage  
**Solutions:**
- Use coarse location when possible
- Reduce update frequency (1 hour is good)
- Only update when device is charging (optional setting)
- Use geofencing instead of constant polling

### **2. Privacy Concerns**
**Problem:** Users may not want to share location  
**Solutions:**
- Make it opt-in (OFF by default)
- Clear privacy policy
- Show who can see location
- Allow temporary sharing (auto-disable after X hours)

### **3. Accuracy Issues**
**Problem:** GPS inaccurate indoors/urban areas  
**Solutions:**
- Show accuracy circle on map
- Filter out inaccurate readings (>50m)
- Use WiFi triangulation as fallback

### **4. Network Failures**
**Problem:** Update fails when no internet  
**Solutions:**
- Queue updates locally
- Retry with exponential backoff
- Show last successful update time

### **5. Map Costs**
**Problem:** Google Maps API not free (after quota)  
**Solutions:**
- Use flutter_map (OpenStreetMap) - FREE
- Set monthly budget limit
- Cache map tiles

---

## 💰 Cost Estimation

### **Google Maps API Pricing**
- Map loads: $7 per 1,000 requests
- Markers: Free
- Monthly free tier: $200 credit

**Estimated for 1000 active users:**
- Daily map opens: 1000 users × 3 opens = 3,000 loads
- Monthly: 90,000 loads = $630
- **With free tier: $430/month**

### **Alternative: OpenStreetMap (FREE)**
- Use `flutter_map` package
- No API key required
- Unlimited requests
- Self-host tiles (optional)

---

## 🔍 Testing Checklist

### **Functional Testing**
- [ ] Location permission request works
- [ ] Manual location update successful
- [ ] Toggle switch enables/disables sharing
- [ ] Background updates work every 1 hour
- [ ] Map displays all kader markers
- [ ] Tap marker shows correct info
- [ ] Filter by region works
- [ ] Refresh button updates immediately

### **Edge Cases**
- [ ] No GPS permission granted
- [ ] GPS disabled on device
- [ ] No internet connection
- [ ] Backend API down
- [ ] No kaders in range
- [ ] Location sharing disabled
- [ ] App force closed (background still works?)

### **Performance**
- [ ] Map loads in <3 seconds
- [ ] Smooth scrolling/zooming
- [ ] No memory leaks
- [ ] Battery usage acceptable (<5%/hour)

### **Privacy**
- [ ] Location not shared by default
- [ ] Can disable sharing anytime
- [ ] Location data deleted when disabled

---

## 📚 Resources & Documentation

### **Flutter Packages**
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- [flutter_map](https://pub.dev/packages/flutter_map) - Open source alternative
- [geolocator](https://pub.dev/packages/geolocator)
- [workmanager](https://pub.dev/packages/workmanager)
- [permission_handler](https://pub.dev/packages/permission_handler)

### **Tutorials**
- [Flutter Maps Tutorial](https://www.youtube.com/watch?v=sP2kWvNXJQM)
- [Background Location Tracking](https://www.youtube.com/watch?v=5M3L6LkfYro)
- [WorkManager Guide](https://medium.com/@qavvat.abdullah/background-tasks-in-flutter-7768c3f3e05e)

---

## 🎯 Success Metrics

### **User Engagement**
- % of users enabling location sharing (Target: >40%)
- Daily active map views (Target: >50% of users)
- Average session time on radar page (Target: >2 min)

### **Technical**
- Location update success rate (Target: >95%)
- Background task reliability (Target: >90%)
- API response time (Target: <500ms)

### **Business**
- Increased engagement in events/activities
- Better coordination between kaders
- Improved regional insights

---

## 📝 Next Steps

1. **Review & Approval:**
   - Stakeholder review this document
   - Confirm feature requirements
   - Approve budget (if using Google Maps)

2. **Backend Team:**
   - Create database tables
   - Implement API endpoints
   - Test endpoints with Postman

3. **Flutter Team (Us):**
   - Add dependencies to pubspec.yaml
   - Implement LocationService
   - Build RadarPage UI
   - Test on real devices

4. **Coordination:**
   - Weekly sync meetings
   - Shared testing environment
   - API documentation in Postman/Swagger

---

## 🔖 Status: Ready for Implementation

**Estimated Timeline:** 4-6 weeks for full feature  
**Priority:** HIGH  
**Dependencies:** Backend API must be ready first

**Contact for Questions:**
- Frontend: [Your Team]
- Backend: [Backend Team]
- DevOps: [DevOps Team]

---

**Last Updated:** 8 Januari 2026  
**Version:** 1.0  
**Author:** GitHub Copilot AI Assistant
