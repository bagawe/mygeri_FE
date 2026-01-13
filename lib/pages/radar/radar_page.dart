import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/radar_models.dart';
import '../../services/radar_api_service.dart';
import '../../services/location_service.dart';
import '../../services/background_location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadarPage extends StatefulWidget {
  const RadarPage({Key? key}) : super(key: key);

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  final MapController _mapController = MapController();
  final RadarApiService _radarApi = RadarApiService();
  final LocationService _locationService = LocationService();

  List<UserLocation> _userLocations = [];
  Position? _myPosition;
  bool _isLocationSharingEnabled = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSavingLocation = false; // ⭐ For manual save
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeRadar();
    _initializeBackgroundService();
  }

  Future<void> _initializeBackgroundService() async {
    try {
      await BackgroundLocationService.initialize();
      print('✅ Background service initialized');
    } catch (e) {
      print('⚠️ Error initializing background service: $e');
    }
  }

  Future<void> _initializeRadar() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Load sharing status from preferences
      await _loadSharingStatus();

      // 2. Get my location status from backend
      await _getMyStatus();

      // 3. Get my current location
      await _getMyLocation();

      // 4. Load nearby locations
      await _loadNearbyLocations();
    } catch (e) {
      print('❌ Error initializing radar: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadSharingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLocationSharingEnabled = prefs.getBool('radar_sharing_enabled') ?? false;
    });
    print('📍 Sharing status from prefs: $_isLocationSharingEnabled');
  }

  Future<void> _getMyStatus() async {
    try {
      final status = await _radarApi.getMyStatus();
      setState(() {
        _isLocationSharingEnabled = status.isSharingEnabled;
        if (status.hasLocation) {
          // Update map center to my location if available
          _myPosition = Position(
            latitude: status.latitude!,
            longitude: status.longitude!,
            timestamp: DateTime.now(),
            accuracy: status.accuracy ?? 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      });
      print('✅ Got my status: sharing=${status.isSharingEnabled}');
    } catch (e) {
      print('⚠️ Error getting my status (will use local): $e');
    }
  }

  Future<void> _getMyLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _myPosition = position;
        });
        print('✅ Got my location: ${position.latitude}, ${position.longitude}');

        // Move map to my location
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          13.0,
        );
      }
    } catch (e) {
      print('⚠️ Error getting my location: $e');
    }
  }

  Future<void> _loadNearbyLocations() async {
    try {
      final locations = await _radarApi.getLocations(
        latitude: _myPosition?.latitude,
        longitude: _myPosition?.longitude,
        radius: 50, // 50km radius
      );

      setState(() {
        _userLocations = locations;
      });
      print('✅ Loaded ${locations.length} nearby locations');
    } catch (e) {
      print('❌ Error loading nearby locations: $e');
      // Don't show error for this, just log it
    }
  }

  Future<void> _toggleSharing(bool enabled) async {
    try {
      print('🔄 Toggling sharing to: $enabled');

      // Update backend
      final result = await _radarApi.toggleSharing(enabled);

      // Save to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('radar_sharing_enabled', result);

      setState(() {
        _isLocationSharingEnabled = result;
      });

      // Start or stop background service
      if (result) {
        await BackgroundLocationService.startPeriodicUpdates();
      } else {
        await BackgroundLocationService.stopPeriodicUpdates();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result
                ? 'Location sharing diaktifkan (auto-update setiap 1 jam)'
                : 'Location sharing dinonaktifkan',
          ),
          backgroundColor: result ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // If enabled, update location immediately
      if (result) {
        await _refreshLocation();
      }
    } catch (e) {
      print('❌ Error toggling sharing: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah setting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Save Location - Create permanent marker at current position
  Future<void> _saveLocationManually() async {
    if (_isSavingLocation) return;

    setState(() {
      _isSavingLocation = true;
    });

    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Tidak bisa mendapatkan lokasi');
      }

      setState(() {
        _myPosition = position;
      });

      // Save to backend - this creates a permanent marker
      // Orang lain akan lihat marker di lokasi ini
      final result = await _radarApi.saveLocationManually(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      print('✅ Location saved: ${result['is_saved_location']}');
      print('📍 Marker akan tertanam di map pada lokasi ini');

      // Reload nearby locations to show the saved marker
      await _loadNearbyLocations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Lokasi disimpan! Marker tertanam di map'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan lokasi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSavingLocation = false;
        });
      }
    }
  }

  // Old refresh method - renamed for clarity
  Future<void> _refreshLocation() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw Exception('Tidak bisa mendapatkan lokasi');
      }

      setState(() {
        _myPosition = position;
      });

      // Update to backend (with sharing enabled)
      await _radarApi.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        isSavedOnly: false, // Enable sharing
      );

      // Reload nearby locations
      await _loadNearbyLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil diupdate!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error refreshing location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal update lokasi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showUserInfo(UserLocation location) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            CircleAvatar(
              radius: 40,
              backgroundImage: location.user.fotoProfil != null
                  ? NetworkImage(location.user.fotoProfil!)
                  : null,
              child: location.user.fotoProfil == null
                  ? Text(
                      location.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              location.user.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Role
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(location.user.primaryRole),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRoleText(location.user.primaryRole),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Details
            if (location.user.pekerjaan != null)
              _buildInfoRow(Icons.work, location.user.pekerjaan!),
            if (location.user.provinsi != null)
              _buildInfoRow(Icons.location_city, location.user.provinsi!),
            if (location.distance != null)
              _buildInfoRow(Icons.social_distance, location.distanceText),
            _buildInfoRow(Icons.access_time, location.lastUpdateText),

            const SizedBox(height: 16),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.purple;
      case 'kader':
        return Colors.blue;
      case 'simpatisan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'kader':
        return 'Kader';
      case 'simpatisan':
        return 'Simpatisan';
      default:
        return role.toUpperCase();
    }
  }

  List<Marker> _buildMarkers() {
    return _userLocations.map((location) {
      final isOnline = location.isSharingEnabled;
      final isSaved = location.isSavedLocation;
      
      return Marker(
        point: LatLng(location.latitude, location.longitude),
        width: 60,
        height: 75,
        child: GestureDetector(
          onTap: () => _showUserInfo(location),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getRoleColor(location.user.primaryRole),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: location.user.fotoProfil != null
                          ? NetworkImage(location.user.fotoProfil!)
                          : null,
                      child: location.user.fotoProfil == null
                          ? Text(
                              location.user.name[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                  // Online/Saved indicator
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOnline 
                          ? Colors.green 
                          : (isSaved ? Colors.orange : Colors.grey),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: isSaved && !isOnline
                        ? const Icon(
                            Icons.push_pin,
                            size: 8,
                            color: Colors.white,
                          )
                        : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isOnline 
                    ? Colors.green 
                    : (isSaved ? Colors.orange : Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isOnline 
                    ? 'Online' 
                    : (isSaved ? 'Saved' : location.lastUpdateText),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Radar'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Radar'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Terjadi kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _initializeRadar,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _initializeRadar,
            tooltip: 'Refresh semua',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(
                _myPosition?.latitude ?? -6.2088,
                _myPosition?.longitude ?? 106.8456,
              ),
              initialZoom: 13.0,
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

              // User Markers
              MarkerLayer(
                markers: _buildMarkers(),
              ),

              // My Location Marker
              if (_myPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_myPosition!.latitude, _myPosition!.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.3),
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Control Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Share Lokasi Saya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isLocationSharingEnabled,
                          onChanged: _toggleSharing,
                          activeColor: Colors.red,
                        ),
                      ],
                    ),
                    
                    // Status indicator
                    const Divider(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isLocationSharingEnabled
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isLocationSharingEnabled
                                ? 'Real-time ON: Lokasi ikut gerak'
                                : 'Real-time OFF: Marker tetap di lokasi terakhir',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Info text
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Simpan" untuk tandai lokasi di map',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    // Save Location Button (always available)
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSavingLocation ? null : _saveLocationManually,
                        icon: _isSavingLocation
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.push_pin),
                        label: Text(
                          _isSavingLocation
                              ? 'Menyimpan...'
                              : 'Simpan Lokasi Saya',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats Card
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.people, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_userLocations.length} user online',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_myPosition != null) ...[
                      Icon(Icons.gps_fixed, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${_myPosition!.accuracy.toStringAsFixed(0)}m',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
