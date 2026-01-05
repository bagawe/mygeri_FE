# 📱 Testing MyGeri API di Physical Device (iPhone/Android)

## 🎯 Problem
Ketika develop Flutter di physical device, `localhost:3030` tidak bisa diakses karena localhost merujuk ke device itu sendiri, bukan ke laptop.

## ✅ Solution
Gunakan IP Address laptop di jaringan yang sama.

---

## 📝 Step-by-Step Guide

### Step 1: Cari IP Address Laptop

#### macOS
```bash
# Terminal
ifconfig | grep "inet "

# Atau lebih spesifik untuk Wi-Fi
ipconfig getifaddr en0

# Output contoh: 192.168.1.100
```

#### Alternative - System Preferences
1. Buka **System Preferences** → **Network**
2. Pilih **Wi-Fi** (yang connected)
3. Lihat IP Address di sebelah kanan

---

### Step 2: Update Flutter Code

```dart
// lib/services/api_service.dart

class ApiService {
  // ❌ JANGAN gunakan localhost untuk physical device
  // static const String baseUrl = 'http://localhost:3030';
  
  // ✅ GUNAKAN IP Address laptop
  static const String baseUrl = 'http://192.168.1.100:3030';  // Ganti dengan IP laptop Anda
  
  // 💡 Atau gunakan environment-based config:
  static String get baseUrl {
    // Cek apakah running di emulator atau physical device
    if (Platform.isAndroid) {
      // Android Emulator: gunakan 10.0.2.2
      // Physical Device: gunakan IP laptop
      return 'http://192.168.1.100:3030';  // Ganti dengan IP laptop
    } else if (Platform.isIOS) {
      // iOS Simulator: bisa gunakan localhost
      // Physical Device: gunakan IP laptop
      return 'http://192.168.1.100:3030';  // Ganti dengan IP laptop
    }
    return 'http://localhost:3030';
  }
}
```

---

### Step 3: Pastikan Laptop & Device di Jaringan yang Sama

- Laptop dan iPhone/Android **harus connected ke Wi-Fi yang sama**
- Jangan gunakan VPN di laptop atau device
- Pastikan firewall tidak memblokir port 3030

---

### Step 4: Test Connection

#### A. Test di Browser (di Physical Device)
Buka browser di iPhone/Android:
```
http://192.168.1.100:3030/health
```

Jika berhasil, akan muncul:
```json
{
  "success": true,
  "timestamp": "2025-12-17T...",
  "version": "1.0.0",
  "environment": "development"
}
```

#### B. Test di Flutter App
```dart
// Test health check
final response = await http.get(
  Uri.parse('http://192.168.1.100:3030/health'),
);

print('Status: ${response.statusCode}');
print('Body: ${response.body}');
```

---

## 🔥 Advanced: Environment-Based Configuration

### 1. Create Environment Config

```dart
// lib/config/environment.dart
import 'dart:io';

enum AppEnvironment { development, staging, production }

class EnvironmentConfig {
  static AppEnvironment _current = AppEnvironment.development;
  
  static void setEnvironment(AppEnvironment env) {
    _current = env;
  }
  
  static String get apiBaseUrl {
    switch (_current) {
      case AppEnvironment.development:
        return _getDevUrl();
      case AppEnvironment.staging:
        return 'https://staging-api.mygeri.com';
      case AppEnvironment.production:
        return 'https://api.mygeri.com';
    }
  }
  
  static String _getDevUrl() {
    // Auto-detect emulator vs physical device
    if (Platform.isAndroid) {
      // Check if running on emulator
      // Emulator: 10.0.2.2 maps to localhost
      // Physical: use laptop IP
      // TODO: Change this to your laptop IP
      return 'http://192.168.1.100:3030';
    } else if (Platform.isIOS) {
      // iOS Simulator can use localhost
      // Physical device needs laptop IP
      // TODO: Change this to your laptop IP
      return 'http://192.168.1.100:3030';
    }
    return 'http://localhost:3030';
  }
  
  static bool get isDebugMode => _current == AppEnvironment.development;
}
```

### 2. Use in API Service

```dart
// lib/services/api_service.dart
import '../config/environment.dart';

class ApiService {
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  
  // ... rest of code
}
```

### 3. Setup in main.dart

```dart
// lib/main.dart
void main() {
  // Set environment
  EnvironmentConfig.setEnvironment(AppEnvironment.development);
  
  runApp(MyApp());
}
```

---

## 🛡️ iOS Specific Configuration

### Allow Local Network (iOS)

Edit `ios/Runner/Info.plist`:

```xml
<dict>
  <!-- Existing keys -->
  
  <!-- Add this for local network access -->
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
</dict>
```

**Note:** `NSAllowsArbitraryLoads` hanya untuk development! Hapus di production.

---

## 🤖 Android Specific Configuration

### Allow Cleartext Traffic (Android)

Untuk development, buat file `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Allow all cleartext traffic for development -->
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    
    <!-- Or allow specific domains -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">192.168.1.100</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
    </domain-config>
</network-security-config>
```

Lalu reference di `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:name=".Application"
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

## 📊 IP Address Reference

| Device Type | Use This URL |
|-------------|--------------|
| iOS Simulator | `http://localhost:3030` |
| Android Emulator | `http://10.0.2.2:3030` |
| iPhone (Physical) | `http://192.168.1.XXX:3030` |
| Android (Physical) | `http://192.168.1.XXX:3030` |
| Browser (Laptop) | `http://localhost:3030` |

**XXX** = IP Address laptop Anda

---

## 🔍 Troubleshooting

### ❌ "Failed to connect" / "Network unreachable"

**Checklist:**
- [ ] Laptop dan device di Wi-Fi yang sama?
- [ ] Backend server running? (`npm run dev`)
- [ ] IP address benar?
- [ ] Port 3030 tidak diblokir firewall?
- [ ] Tidak ada VPN aktif?

**Test:**
```bash
# Di laptop, cek server running
curl http://localhost:3030/health

# Cek firewall (macOS)
sudo pfctl -s rules

# Allow port 3030 jika perlu (macOS)
# System Preferences → Security & Privacy → Firewall → Firewall Options
```

---

### ❌ "Connection refused" di Android

**Solution:**
```dart
// Pastikan gunakan IP laptop, bukan localhost atau 10.0.2.2
static const String baseUrl = 'http://192.168.1.100:3030';
```

---

### ❌ "SSL Certificate error" (Production)

**Solution:**
```dart
// HANYA untuk development/testing
// JANGAN lakukan ini di production!
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides(); // DEV ONLY!
  runApp(MyApp());
}
```

---

## 📱 Quick Test Script

Gunakan ini untuk test connection dari Flutter:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NetworkTestScreen extends StatefulWidget {
  @override
  _NetworkTestScreenState createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  String _result = 'Not tested yet';
  bool _isLoading = false;
  
  // ⚠️ GANTI IP INI dengan IP laptop Anda!
  final String testUrl = 'http://192.168.1.100:3030/health';
  
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _result = 'Testing...';
    });
    
    try {
      final response = await http.get(Uri.parse(testUrl))
          .timeout(Duration(seconds: 10));
      
      setState(() {
        _result = '''
✅ SUCCESS!
Status: ${response.statusCode}
Response: ${response.body}
''';
      });
    } catch (e) {
      setState(() {
        _result = '''
❌ FAILED!
Error: $e

Troubleshooting:
1. Pastikan backend running (npm run dev)
2. Cek IP address laptop
3. Pastikan sama Wi-Fi
4. Cek firewall
''';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Network Test')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Testing URL:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(testUrl, style: TextStyle(color: Colors.blue)),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading 
                ? CircularProgressIndicator() 
                : Text('Test Connection'),
            ),
            SizedBox(height: 24),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(_result),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 Best Practice untuk Production

### 1. Environment Variables
Gunakan package `flutter_dotenv`:

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

```
# .env.development
API_BASE_URL=http://192.168.1.100:3030

# .env.production
API_BASE_URL=https://api.mygeri.com
```

### 2. Build Flavors
Setup different flavors untuk dev/staging/prod:

```bash
# Run with development flavor
flutter run --flavor development -t lib/main_dev.dart

# Run with production flavor
flutter run --flavor production -t lib/main_prod.dart
```

---

## 📝 Summary

1. **Cari IP laptop:** `ifconfig | grep inet` atau `ipconfig getifaddr en0`
2. **Update Flutter code:** Ganti `localhost` dengan IP laptop
3. **Test di browser device:** `http://192.168.1.XXX:3030/health`
4. **Sama Wi-Fi:** Pastikan laptop & device di jaringan sama
5. **iOS config:** Update `Info.plist` untuk local networking
6. **Android config:** Setup `network_security_config.xml`

---

**Tips:** Simpan IP laptop dan update di code setiap kali IP berubah (biasanya setelah connect ke Wi-Fi berbeda).

**Happy Testing! 📱🚀**
