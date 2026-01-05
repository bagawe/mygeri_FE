# 🔐 Security Analysis - Mygeri App

## ⚠️ **CRITICAL SECURITY QUESTION**

> **"Ketika aplikasi jebol oleh hacker, apakah Ahmad bisa edit akun Rina?"**

**JAWABAN:** 
- ✅ **Saat ini: TIDAK** - Backend sudah menggunakan JWT authentication yang mengekstrak user ID dari token
- ⚠️ **Tapi masih ada potensi vulnerability** jika implementasi tidak benar

---

## 📊 Current Security Status

### ✅ Security Features Yang Sudah Ada

#### 1. **JWT Authentication dengan User Context** ✅
```dart
// Backend mengekstrak user dari token JWT
// Endpoint: PUT /api/users/profile
// Authorization: Bearer <access_token>

// Backend controller:
const userId = req.user.id; // Dari JWT token, BUKAN dari request body
const user = await User.findById(userId);
```

**Artinya:**
- ✅ User ID diambil dari **JWT token** (tidak bisa dimanipulasi)
- ✅ Ahmad login → dapat token Ahmad → hanya bisa edit profile Ahmad
- ✅ Rina login → dapat token Rina → hanya bisa edit profile Rina
- ✅ Ahmad tidak bisa kirim token Ahmad untuk edit profile Rina

#### 2. **Token Expiration** ✅
```dart
// Access Token: 15 minutes
// Refresh Token: 7 days
```

**Artinya:**
- ✅ Token expired setelah 15 menit (limited window untuk attack)
- ✅ Harus refresh token secara berkala
- ✅ Mengurangi impact jika token dicuri

#### 3. **Token Revocation** ✅
```dart
// Setelah change password:
// - All refresh tokens di-revoke
// - User harus login ulang
```

**Artinya:**
- ✅ Jika password diubah (karena suspicious activity), semua session logout
- ✅ Hacker yang punya old token akan ter-logout

#### 4. **Secure Storage** ✅
```dart
// Flutter Secure Storage untuk simpan token
// - iOS: Keychain
// - Android: EncryptedSharedPreferences
```

**Artinya:**
- ✅ Token tidak disimpan di plain text
- ✅ OS-level encryption

---

## ⚠️ Vulnerability Analysis

### 🔴 **CRITICAL: Potential Vulnerabilities**

#### 1. **JWT Token Hijacking**
**Skenario Attack:**
```
1. Hacker intercept network traffic (Man-in-the-Middle)
2. Hacker dapat token JWT dari Ahmad
3. Hacker gunakan token Ahmad untuk API calls
4. Hacker bisa baca/edit profile Ahmad
```

**Current Status:** ⚠️ **VULNERABLE**
- Backend belum pakai HTTPS (masih HTTP)
- Token dikirim via plain HTTP headers
- Mudah di-intercept di public WiFi

**Impact:**
- 🔴 Hacker bisa impersonate Ahmad
- 🔴 Hacker bisa baca/edit profile Ahmad
- ⚠️ Hacker TIDAK bisa edit profile Rina (karena token Ahmad ≠ token Rina)

#### 2. **No HTTPS/SSL**
**Current:**
```dart
static const String baseUrl = 'http://10.191.38.178:3030'; // HTTP, not HTTPS
```

**Risk:**
- 🔴 Password dikirim plain text saat login
- 🔴 Token dikirim plain text di headers
- 🔴 Profile data (termasuk data sensitif) dikirim plain text

#### 3. **No Certificate Pinning**
**Risk:**
- ⚠️ Man-in-the-Middle attack masih mungkin bahkan dengan HTTPS
- ⚠️ Hacker bisa fake SSL certificate

#### 4. **No Request Rate Limiting (Frontend)**
**Risk:**
- ⚠️ Brute force password attack
- ⚠️ Spam API requests

#### 5. **No Biometric Authentication**
**Risk:**
- ⚠️ Jika device hilang/dicuri, siapa saja bisa akses (jika app masih login)

#### 6. **No Device Binding**
**Risk:**
- ⚠️ Token bisa dicopy ke device lain
- ⚠️ Tidak ada cara detect unauthorized device

#### 7. **No API Request Signing**
**Risk:**
- ⚠️ Request bisa dimodifikasi di-transit
- ⚠️ Tidak ada verification bahwa request asli dari app

---

## 🛡️ Security Recommendations

### **LEVEL 1: CRITICAL (Must Implement ASAP)** 🔴

#### 1.1. **Implement HTTPS/SSL** ⭐⭐⭐⭐⭐
**Priority:** 🔴 **CRITICAL**

**Backend:**
```javascript
// Use HTTPS with valid SSL certificate
// Production: https://api.mygeri.com
// Staging: https://staging-api.mygeri.com

const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('private-key.pem'),
  cert: fs.readFileSync('certificate.pem')
};

https.createServer(options, app).listen(443);
```

**Flutter:**
```dart
static const String baseUrl = 'https://api.mygeri.com'; // HTTPS
```

**Benefit:**
- ✅ Password encrypted in-transit
- ✅ Token encrypted in-transit
- ✅ All data encrypted in-transit

---

#### 1.2. **Certificate Pinning** ⭐⭐⭐⭐
**Priority:** 🔴 **HIGH**

**Implementation:**
```dart
// pubspec.yaml
dependencies:
  http_certificate_pinning: ^2.1.0

// api_service.dart
import 'package:http_certificate_pinning/http_certificate_pinning.dart';

class ApiService {
  static const String baseUrl = 'https://api.mygeri.com';
  
  // SHA256 fingerprint dari SSL certificate
  static const List<String> certificateFingerprints = [
    'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99',
  ];
  
  Future<http.Response> get(String endpoint) async {
    try {
      String url = '$baseUrl$endpoint';
      
      // Verify certificate before making request
      Map<String, String> headers = await _getHeaders(true);
      
      return await HttpCertificatePinning.check(
        serverURL: url,
        headerHttp: headers,
        sha: SHA.SHA256,
        allowedSHAFingerprints: certificateFingerprints,
        timeout: 60,
      );
    } catch (e) {
      print('❌ Certificate pinning failed: $e');
      throw Exception('Security check failed: Invalid certificate');
    }
  }
}
```

**Benefit:**
- ✅ Prevent Man-in-the-Middle attack
- ✅ Detect fake SSL certificates
- ✅ Only allow legitimate API server

---

#### 1.3. **Request Rate Limiting (Frontend)** ⭐⭐⭐
**Priority:** 🟡 **MEDIUM**

**Implementation:**
```dart
// lib/services/rate_limiter.dart
class RateLimiter {
  final Map<String, List<DateTime>> _requestTimestamps = {};
  final Duration _timeWindow = Duration(minutes: 1);
  final int _maxRequests = 10; // Max 10 requests per minute
  
  Future<void> checkLimit(String endpoint) async {
    final now = DateTime.now();
    final timestamps = _requestTimestamps[endpoint] ?? [];
    
    // Remove timestamps outside time window
    timestamps.removeWhere((t) => now.difference(t) > _timeWindow);
    
    if (timestamps.length >= _maxRequests) {
      throw Exception('Too many requests. Please try again later.');
    }
    
    timestamps.add(now);
    _requestTimestamps[endpoint] = timestamps;
  }
}

// Update ApiService
class ApiService {
  final RateLimiter _rateLimiter = RateLimiter();
  
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    // Check rate limit before making request
    await _rateLimiter.checkLimit(endpoint);
    
    // ... existing code
  }
}
```

**Benefit:**
- ✅ Prevent brute force attacks
- ✅ Limit API abuse
- ✅ Better user experience (no accidental spam clicks)

---

### **LEVEL 2: HIGH PRIORITY (Implement Soon)** 🟡

#### 2.1. **Biometric Authentication** ⭐⭐⭐⭐
**Priority:** 🟡 **HIGH**

**Implementation:**
```dart
// pubspec.yaml
dependencies:
  local_auth: ^2.1.7

// lib/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  
  Future<bool> canUseBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('❌ Biometric authentication failed: $e');
      return false;
    }
  }
}

// Usage in sensitive pages
class GantiPasswordPage extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _biometricService.authenticate(
        reason: 'Authenticate to change password',
      ),
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return Center(
            child: Text('Authentication required'),
          );
        }
        
        // Show change password form
        return _buildForm();
      },
    );
  }
}
```

**Benefit:**
- ✅ Protect sensitive operations (change password, view full profile)
- ✅ Extra layer of security even if device unlocked
- ✅ Better UX (no need to remember password for every action)

**Usage:**
- Change password → Require Face ID/Touch ID
- View sensitive data (e.g., full ID number) → Require biometric
- Delete account → Require biometric

---

#### 2.2. **Token Refresh Optimization** ⭐⭐⭐
**Priority:** 🟡 **MEDIUM**

**Current Issue:**
- Token refresh hanya terjadi saat 401 error
- Tidak ada proactive refresh sebelum token expired

**Implementation:**
```dart
// lib/services/api_service.dart
class ApiService {
  Timer? _refreshTimer;
  
  Future<void> _scheduleTokenRefresh() async {
    // Cancel existing timer
    _refreshTimer?.cancel();
    
    // Get token expiry time
    final accessToken = await _storage.getAccessToken();
    if (accessToken == null) return;
    
    // Parse JWT to get expiry
    final parts = accessToken.split('.');
    if (parts.length != 3) return;
    
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
    );
    
    final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    final now = DateTime.now();
    
    // Refresh 1 minute before expiry
    final refreshTime = expiry.subtract(Duration(minutes: 1));
    
    if (refreshTime.isAfter(now)) {
      _refreshTimer = Timer(refreshTime.difference(now), () async {
        try {
          await _refreshToken();
          await _scheduleTokenRefresh(); // Schedule next refresh
        } catch (e) {
          print('❌ Auto refresh failed: $e');
        }
      });
    }
  }
  
  Future<void> _refreshToken() async {
    print('🔄 Auto refreshing token...');
    // ... existing refresh logic
  }
}
```

**Benefit:**
- ✅ Seamless UX (no sudden 401 errors)
- ✅ Token always fresh
- ✅ Reduced API errors

---

#### 2.3. **Device Binding & Multi-Device Management** ⭐⭐⭐⭐
**Priority:** 🟡 **HIGH**

**Implementation:**

**Backend:**
```javascript
// Add device tracking to refresh tokens
// Database: refresh_tokens table
{
  user_id: 1,
  token: 'xxx',
  device_id: 'iPhone-12-ABC123', // Unique device ID
  device_name: 'Ahmad's iPhone',
  device_type: 'iOS',
  last_used: '2025-12-24T10:00:00Z',
  created_at: '2025-12-20T08:00:00Z'
}

// New endpoint: GET /api/users/devices
router.get('/users/devices', authenticate, async (req, res) => {
  const devices = await RefreshToken.findAll({
    where: { user_id: req.user.id },
    attributes: ['device_id', 'device_name', 'device_type', 'last_used', 'created_at']
  });
  
  res.json({ success: true, data: devices });
});

// New endpoint: DELETE /api/users/devices/:deviceId
router.delete('/users/devices/:deviceId', authenticate, async (req, res) => {
  await RefreshToken.destroy({
    where: { 
      user_id: req.user.id,
      device_id: req.params.deviceId 
    }
  });
  
  res.json({ success: true, message: 'Device logged out' });
});
```

**Flutter:**
```dart
// lib/services/device_service.dart
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'device_id': iosInfo.identifierForVendor ?? 'unknown',
        'device_name': iosInfo.name,
        'device_type': 'iOS',
        'os_version': iosInfo.systemVersion,
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'device_id': androidInfo.id,
        'device_name': androidInfo.model,
        'device_type': 'Android',
        'os_version': androidInfo.version.release,
      };
    }
    
    return {};
  }
}

// Update login to send device info
class AuthService {
  Future<LoginResponse> login(String identifier, String password) async {
    final deviceInfo = await DeviceService.getDeviceInfo();
    
    final response = await _api.post('/api/auth/login', {
      'identifier': identifier,
      'password': password,
      'device_id': deviceInfo['device_id'],
      'device_name': deviceInfo['device_name'],
      'device_type': deviceInfo['device_type'],
    });
    
    // ... rest of login logic
  }
}

// New page: Device Management
class DeviceManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perangkat Terdaftar')),
      body: FutureBuilder<List<Device>>(
        future: _deviceService.getDevices(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final device = snapshot.data![index];
              return ListTile(
                leading: Icon(
                  device.type == 'iOS' ? Icons.phone_iphone : Icons.phone_android
                ),
                title: Text(device.name),
                subtitle: Text('Last active: ${device.lastUsed}'),
                trailing: device.isCurrentDevice
                    ? Chip(label: Text('This device'))
                    : IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: () => _logoutDevice(device.id),
                      ),
              );
            },
          );
        },
      ),
    );
  }
  
  void _logoutDevice(String deviceId) async {
    await _deviceService.logoutDevice(deviceId);
    setState(() {}); // Refresh list
  }
}
```

**Benefit:**
- ✅ User dapat lihat semua device yang login
- ✅ User dapat logout device yang tidak dikenal
- ✅ Detect unauthorized access (e.g., "iPhone di Jakarta" padahal user di Surabaya)
- ✅ Security notification (email saat login dari device baru)

---

### **LEVEL 3: NICE TO HAVE (Future Enhancement)** 🟢

#### 3.1. **API Request Signing** ⭐⭐⭐
**Priority:** 🟢 **LOW**

**Concept:**
- Setiap request di-sign dengan private key
- Backend verify signature dengan public key
- Prevent request tampering

**Implementation:**
```dart
// lib/services/request_signer.dart
import 'package:crypto/crypto.dart';

class RequestSigner {
  static const String _secretKey = 'your-secret-key'; // Should be in env variable
  
  static String sign(Map<String, dynamic> data) {
    final payload = json.encode(data);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final message = '$payload:$timestamp';
    
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final digest = hmac.convert(utf8.encode(message));
    
    return '$digest:$timestamp';
  }
  
  static bool verify(String signature, Map<String, dynamic> data) {
    final parts = signature.split(':');
    if (parts.length != 2) return false;
    
    final receivedDigest = parts[0];
    final timestamp = int.parse(parts[1]);
    
    // Check timestamp (prevent replay attacks)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - timestamp > 300000) return false; // 5 minutes expiry
    
    // Verify signature
    final payload = json.encode(data);
    final message = '$payload:$timestamp';
    
    final hmac = Hmac(sha256, utf8.encode(_secretKey));
    final expectedDigest = hmac.convert(utf8.encode(message)).toString();
    
    return receivedDigest == expectedDigest;
  }
}

// Update ApiService to add signature
class ApiService {
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final signature = RequestSigner.sign(body);
    
    final headers = {
      ..._getHeaders(true),
      'X-Signature': signature,
    };
    
    // ... rest of request
  }
}
```

**Benefit:**
- ✅ Prevent request tampering
- ✅ Verify request authenticity
- ✅ Prevent replay attacks

---

#### 3.2. **Two-Factor Authentication (2FA)** ⭐⭐⭐⭐
**Priority:** 🟢 **MEDIUM**

**Implementation:**
- SMS OTP
- Email OTP
- Authenticator app (Google Authenticator, Authy)

**Benefit:**
- ✅ Extra security layer
- ✅ Protect against password compromise
- ✅ Industry standard for sensitive apps

---

#### 3.3. **Security Audit Logging** ⭐⭐⭐
**Priority:** 🟢 **LOW**

**Backend:**
```javascript
// Log all sensitive operations
const securityLog = {
  user_id: 1,
  action: 'CHANGE_PASSWORD',
  ip_address: '192.168.1.100',
  device_id: 'iPhone-12-ABC123',
  timestamp: '2025-12-24T10:30:00Z',
  success: true,
  details: { /* additional context */ }
};
```

**Benefit:**
- ✅ Audit trail untuk investigation
- ✅ Detect suspicious patterns
- ✅ Compliance requirements (GDPR, etc.)

---

## 🎯 Implementation Priority

### **Phase 1: IMMEDIATE (Week 1-2)** 🔴
1. ✅ Setup HTTPS/SSL certificate
2. ✅ Implement certificate pinning
3. ✅ Add rate limiting

**Estimated Time:** 2 weeks  
**Impact:** 🔴 **CRITICAL** - Prevent token hijacking

---

### **Phase 2: SHORT-TERM (Month 1)** 🟡
1. ✅ Biometric authentication for sensitive operations
2. ✅ Token refresh optimization
3. ✅ Device binding & management
4. ✅ Security notifications (email on login from new device)

**Estimated Time:** 3-4 weeks  
**Impact:** 🟡 **HIGH** - Enhanced security & better UX

---

### **Phase 3: LONG-TERM (Month 2-3)** 🟢
1. ✅ API request signing
2. ✅ Two-Factor Authentication (2FA)
3. ✅ Security audit logging
4. ✅ Anomaly detection (unusual login patterns)

**Estimated Time:** 6-8 weeks  
**Impact:** 🟢 **MEDIUM** - Enterprise-grade security

---

## 📊 Security Checklist

### **Backend Security**
- [x] JWT authentication dengan user context dari token
- [x] Token expiration (15 min access, 7 days refresh)
- [x] Token revocation on password change
- [ ] **HTTPS/SSL** 🔴
- [ ] **Rate limiting** 🟡
- [ ] Device binding 🟡
- [ ] Security audit logging 🟢
- [ ] 2FA 🟢

### **Frontend Security**
- [x] Secure storage (Keychain/EncryptedSharedPreferences)
- [x] Token auto-refresh on 401
- [ ] **Certificate pinning** 🔴
- [ ] **Rate limiting** 🟡
- [ ] **Biometric authentication** 🟡
- [ ] Token refresh optimization 🟡
- [ ] Device management UI 🟡
- [ ] API request signing 🟢

---

## ❓ FAQ

### Q1: Apakah Ahmad bisa edit akun Rina?
**A:** **TIDAK**, karena:
- Backend mengekstrak user ID dari JWT token (bukan dari request body)
- Ahmad punya token Ahmad → hanya bisa edit profile Ahmad
- Rina punya token Rina → hanya bisa edit profile Rina
- Token tidak bisa dimanipulasi (signed dengan secret key di backend)

### Q2: Bagaimana kalau hacker steal token Ahmad?
**A:** Hacker bisa:
- ✅ Impersonate Ahmad
- ✅ Baca/edit profile Ahmad
- ❌ TIDAK bisa edit profile Rina (karena token Ahmad ≠ token Rina)

**Mitigation:**
- Implement HTTPS (prevent token stealing)
- Token expiration (15 min)
- Biometric auth untuk sensitive operations

### Q3: Bagaimana kalau hacker crack password Ahmad?
**A:** Hacker bisa:
- ✅ Login sebagai Ahmad
- ✅ Full access ke akun Ahmad
- ❌ TIDAK bisa akses akun Rina (harus tau password Rina juga)

**Mitigation:**
- Strong password policy (sudah ada: 8+ chars, A-Z, a-z, 0-9)
- 2FA (future enhancement)
- Account lockout after 5 failed attempts (backend)
- Security notification (email on suspicious login)

### Q4: Bagaimana kalau hacker punya akses ke device Ahmad yang sudah login?
**A:** Hacker bisa:
- ✅ Full access ke app (karena token masih valid)
- ✅ Baca/edit profile Ahmad
- ❌ TIDAK bisa akses akun Rina

**Mitigation:**
- Biometric auth untuk sensitive operations
- Auto logout after inactivity (e.g., 30 minutes)
- Device management (Ahmad bisa logout device dari web/app lain)

### Q5: Apakah aman simpan token di secure storage?
**A:** **YA**, karena:
- iOS: Keychain (OS-level encryption)
- Android: EncryptedSharedPreferences
- Tidak bisa diakses oleh app lain
- Butuh device unlock untuk akses

**Tapi:**
- Jailbroken/Rooted device → Less secure
- Backup/Restore bisa expose token (iOS iCloud backup)

**Mitigation:**
- Detect jailbreak/root → Force logout
- Exclude token dari backup (`NSURLIsExcludedFromBackupKey`)

---

## 🎯 Conclusion

### Current Status: ⚠️ **MODERATELY SECURE**

**Good:**
- ✅ JWT authentication dengan proper user context
- ✅ Token expiration
- ✅ Secure storage
- ✅ Token revocation on password change

**Critical Issues:**
- 🔴 No HTTPS (token & password sent in plain text)
- 🔴 No certificate pinning (vulnerable to MITM)

**Answer to your question:**
> **"Apakah Ahmad bisa edit akun Rina?"**

**NO** - Ahmad tidak bisa edit akun Rina karena:
1. Backend menggunakan JWT user context (user ID dari token)
2. Token Ahmad hanya bisa akses data Ahmad
3. Token tidak bisa dimanipulasi (cryptographically signed)

**BUT** - If hacker steals Ahmad's token:
- Hacker bisa **impersonate Ahmad**
- Hacker bisa **edit Ahmad's profile**
- Hacker TIDAK bisa edit Rina's profile (needs Rina's token)

**Recommendation:**
- 🔴 **URGENT:** Implement HTTPS + Certificate Pinning
- 🟡 **HIGH:** Add Biometric Auth + Device Management
- 🟢 **NICE:** Add 2FA + Request Signing

---

**Last Updated:** 24 Desember 2025  
**Status:** ⚠️ Security review complete - Action required  
**Next Step:** Implement Phase 1 (HTTPS + Certificate Pinning)
