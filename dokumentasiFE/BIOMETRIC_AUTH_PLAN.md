# 🔐 Biometric Authentication - Implementation Plan

## ⏳ **STATUS: PENDING** (After Phase 1 Testing Complete)

**Prerequisite:**
- ✅ Update Profile tested & working
- ✅ Change Password tested & working
- ⬜ **Then start Biometric implementation**

---

## 📋 **Implementation Overview**

### **What is Biometric Authentication?**
Biometric authentication menggunakan Face ID (iOS) atau fingerprint/face unlock (Android) untuk:
- 🔐 Login ke app (replace password)
- 🔒 Protect sensitive operations (change password, view sensitive data)
- ✅ Better UX (no need to type password every time)

---

## 🎯 **Use Cases**

### **Use Case 1: Biometric Login** ⭐⭐⭐⭐⭐
**Priority:** HIGH

**Flow:**
```
1. User membuka app
2. App checks: Biometric enabled? & Device supports biometric?
3. If YES:
   - Show biometric prompt (Face ID/Touch ID)
   - If authenticated → Login automatically
   - If failed → Show password login
4. If NO:
   - Show normal login page
```

**Benefit:**
- ✅ Fast login (1-2 seconds vs 10+ seconds typing)
- ✅ Secure (biometric tied to device)
- ✅ Better UX

---

### **Use Case 2: Protect Change Password** ⭐⭐⭐⭐
**Priority:** HIGH

**Flow:**
```
1. User tap "Ubah Password"
2. App shows biometric prompt: "Authenticate to change password"
3. If authenticated → Show change password form
4. If failed → Return to settings
```

**Benefit:**
- ✅ Extra security layer
- ✅ Prevent unauthorized password change (if device borrowed)

---

### **Use Case 3: Protect Sensitive Data** ⭐⭐⭐
**Priority:** MEDIUM

**Flow:**
```
1. User view profile
2. Sensitive fields (NIK, KK) initially blurred/masked
3. Tap "Show" → Biometric prompt
4. If authenticated → Show full data
```

**Benefit:**
- ✅ Privacy protection
- ✅ Safe to view profile in public

---

## 🛠️ **Implementation Steps**

### **Step 1: Add Dependencies**

#### pubspec.yaml
```yaml
dependencies:
  # Existing dependencies
  flutter_secure_storage: ^9.0.0
  http: ^1.1.0
  
  # NEW: Add biometric authentication
  local_auth: ^2.1.7
  local_auth_android: ^1.0.32
  local_auth_ios: ^1.1.4
```

#### Install
```bash
flutter pub get
```

---

### **Step 2: Configure iOS (Info.plist)**

#### ios/Runner/Info.plist
```xml
<key>NSFaceIDUsageDescription</key>
<string>Gunakan Face ID untuk login cepat dan aman ke MyGeri</string>
```

---

### **Step 3: Configure Android (Manifest)**

#### android/app/src/main/AndroidManifest.xml
```xml
<manifest>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
    <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
    
    <application>
        <!-- Existing config -->
        
        <!-- Add MainActivity attribute -->
        <activity
            android:name=".MainActivity"
            android:windowSoftInputMode="adjustResize"
            android:theme="@style/LaunchTheme">
            
            <!-- Enable biometric authentication -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"/>
        </activity>
    </application>
</manifest>
```

---

### **Step 4: Create BiometricService**

#### lib/services/biometric_service.dart
```dart
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      
      return canCheck && isDeviceSupported;
    } catch (e) {
      print('❌ BiometricService: Error checking support - $e');
      return false;
    }
  }

  /// Get available biometric types (Face ID, Touch ID, Fingerprint, etc.)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('❌ BiometricService: Error getting types - $e');
      return [];
    }
  }

  /// Check if Face ID is available (iOS)
  Future<bool> hasFaceID() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if Touch ID / Fingerprint is available
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Authenticate user with biometric
  /// 
  /// Returns true if authenticated successfully
  /// Returns false if failed or cancelled
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = true,
  }) async {
    try {
      // Check if biometric is available
      if (!await canUseBiometrics()) {
        print('⚠️ BiometricService: Biometric not available on this device');
        return false;
      }

      print('🔐 BiometricService: Authenticating with biometric...');

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'MyGeri - Autentikasi',
            cancelButton: 'Batal',
            biometricHint: 'Sentuh sensor sidik jari',
            biometricNotRecognized: 'Sidik jari tidak dikenali',
            biometricSuccess: 'Berhasil',
            deviceCredentialsRequiredTitle: 'Autentikasi Diperlukan',
          ),
          IOSAuthMessages(
            cancelButton: 'Batal',
            goToSettingsButton: 'Pengaturan',
            goToSettingsDescription: 'Biometric tidak diatur. Silakan atur di Pengaturan.',
            lockOut: 'Biometric dikunci. Silakan coba lagi nanti.',
          ),
        ],
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
          sensitiveTransaction: true,
        ),
      );

      if (authenticated) {
        print('✅ BiometricService: Authentication successful');
      } else {
        print('❌ BiometricService: Authentication failed');
      }

      return authenticated;
    } on PlatformException catch (e) {
      print('❌ BiometricService: Platform exception - ${e.code}: ${e.message}');
      
      if (e.code == 'NotAvailable') {
        print('⚠️ Biometric not available');
      } else if (e.code == 'NotEnrolled') {
        print('⚠️ Biometric not enrolled');
      } else if (e.code == 'LockedOut') {
        print('⚠️ Biometric locked out');
      } else if (e.code == 'PermanentlyLockedOut') {
        print('⚠️ Biometric permanently locked out');
      }
      
      return false;
    } catch (e) {
      print('❌ BiometricService: Unexpected error - $e');
      return false;
    }
  }

  /// Get biometric type name for display
  Future<String> getBiometricTypeName() async {
    if (await hasFaceID()) {
      return 'Face ID';
    } else if (await hasFingerprint()) {
      return 'Sidik Jari';
    } else {
      return 'Biometrik';
    }
  }
}
```

---

### **Step 5: Create BiometricSettingsService**

Store user preference untuk enable/disable biometric login.

#### lib/services/biometric_settings_service.dart
```dart
import 'storage_service.dart';

class BiometricSettingsService {
  final StorageService _storage = StorageService();
  static const _biometricEnabledKey = 'biometric_enabled';

  /// Check if user enabled biometric login
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(_biometricEnabledKey);
    return value == 'true';
  }

  /// Enable biometric login
  Future<void> enableBiometric() async {
    await _storage.write(_biometricEnabledKey, 'true');
    print('✅ Biometric login enabled');
  }

  /// Disable biometric login
  Future<void> disableBiometric() async {
    await _storage.write(_biometricEnabledKey, 'false');
    print('❌ Biometric login disabled');
  }

  /// Toggle biometric setting
  Future<void> toggleBiometric() async {
    final current = await isBiometricEnabled();
    if (current) {
      await disableBiometric();
    } else {
      await enableBiometric();
    }
  }
}
```

---

### **Step 6: Update StorageService**

Add helper method to read/write generic key-value.

#### lib/services/storage_service.dart
```dart
class StorageService {
  // ...existing code...

  // NEW: Generic read
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  // NEW: Generic write
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // NEW: Generic delete
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }
}
```

---

### **Step 7: Update Login Page - Add Biometric Option**

#### lib/pages/login_page.dart
```dart
import '../services/biometric_service.dart';
import '../services/biometric_settings_service.dart';

class _LoginPageState extends State<LoginPage> {
  final BiometricService _biometricService = BiometricService();
  final BiometricSettingsService _biometricSettings = BiometricSettingsService();
  
  bool _canUseBiometric = false;
  bool _biometricEnabled = false;
  String _biometricTypeName = 'Biometrik';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canUse = await _biometricService.canUseBiometrics();
    final enabled = await _biometricSettings.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    
    setState(() {
      _canUseBiometric = canUse;
      _biometricEnabled = enabled;
      _biometricTypeName = typeName;
    });

    // Auto-trigger biometric if enabled
    if (_canUseBiometric && _biometricEnabled) {
      await _loginWithBiometric();
    }
  }

  Future<void> _loginWithBiometric() async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Login ke MyGeri dengan $_biometricTypeName',
    );

    if (authenticated) {
      // Biometric success - now get credentials from secure storage
      final credentials = await _storage.getUserData();
      
      if (credentials != null && 
          credentials['email'] != null && 
          credentials['password'] != null) {
        
        // Auto login with stored credentials
        await _loginWithCredentials(
          credentials['email']!,
          credentials['password']!,
        );
      } else {
        // No stored credentials - ask user to login normally
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Silakan login dengan email dan password'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _loginWithCredentials(String email, String password) async {
    // Existing login logic
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...existing build code...
      
      body: Column(
        children: [
          // ...existing form fields...
          
          // Login Button
          ElevatedButton(
            onPressed: _login,
            child: Text('Login'),
          ),
          
          // NEW: Biometric Login Button
          if (_canUseBiometric)
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: OutlinedButton.icon(
                onPressed: _loginWithBiometric,
                icon: Icon(
                  _biometricTypeName == 'Face ID' 
                    ? Icons.face 
                    : Icons.fingerprint
                ),
                label: Text('Login dengan $_biometricTypeName'),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### **Step 8: Add Biometric Settings to Pengaturan Page**

#### lib/pages/pengaturan/pengaturan_page.dart
```dart
import '../../services/biometric_service.dart';
import '../../services/biometric_settings_service.dart';

class _PengaturanPageState extends State<PengaturanPage> {
  final BiometricService _biometricService = BiometricService();
  final BiometricSettingsService _biometricSettings = BiometricSettingsService();
  
  bool _canUseBiometric = false;
  bool _biometricEnabled = false;
  String _biometricTypeName = 'Biometrik';

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final canUse = await _biometricService.canUseBiometrics();
    final enabled = await _biometricSettings.isBiometricEnabled();
    final typeName = await _biometricService.getBiometricTypeName();
    
    setState(() {
      _canUseBiometric = canUse;
      _biometricEnabled = enabled;
      _biometricTypeName = typeName;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      // Enable biometric - require authentication first
      final authenticated = await _biometricService.authenticate(
        reason: 'Aktifkan $_biometricTypeName untuk login',
      );
      
      if (authenticated) {
        await _biometricSettings.enableBiometric();
        
        setState(() {
          _biometricEnabled = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$_biometricTypeName berhasil diaktifkan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } else {
      // Disable biometric
      await _biometricSettings.disableBiometric();
      
      setState(() {
        _biometricEnabled = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$_biometricTypeName dinonaktifkan'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pengaturan')),
      body: ListView(
        children: [
          // ...existing settings...
          
          // NEW: Biometric Settings Section
          if (_canUseBiometric)
            Column(
              children: [
                Divider(),
                ListTile(
                  title: Text('Keamanan'),
                  subtitle: Text('Pengaturan keamanan akun'),
                  enabled: false,
                ),
                SwitchListTile(
                  title: Text('Login dengan $_biometricTypeName'),
                  subtitle: Text(
                    _biometricEnabled 
                      ? 'Login cepat dengan $_biometricTypeName aktif'
                      : 'Aktifkan untuk login lebih cepat dan aman'
                  ),
                  value: _biometricEnabled,
                  onChanged: _toggleBiometric,
                  secondary: Icon(
                    _biometricTypeName == 'Face ID' 
                      ? Icons.face 
                      : Icons.fingerprint,
                  ),
                ),
              ],
            ),
          
          Divider(),
          
          // Existing: Ubah Password
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Ubah Password'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GantiPasswordPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

### **Step 9: Protect Change Password with Biometric**

#### lib/pages/pengaturan/ganti_password_page.dart
```dart
import '../../services/biometric_service.dart';
import '../../services/biometric_settings_service.dart';

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final BiometricService _biometricService = BiometricService();
  final BiometricSettingsService _biometricSettings = BiometricSettingsService();
  
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkBiometricAuth();
  }

  Future<void> _checkBiometricAuth() async {
    final canUse = await _biometricService.canUseBiometrics();
    final enabled = await _biometricSettings.isBiometricEnabled();
    
    if (canUse && enabled) {
      // Require biometric authentication
      final typeName = await _biometricService.getBiometricTypeName();
      final authenticated = await _biometricService.authenticate(
        reason: 'Autentikasi untuk mengganti password',
      );
      
      setState(() {
        _isAuthenticated = authenticated;
        _isLoading = false;
      });
      
      if (!authenticated) {
        // Failed - go back
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$typeName diperlukan untuk mengganti password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // No biometric - allow directly
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Ganti Password')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: Text('Ganti Password')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Autentikasi diperlukan'),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: _checkBiometricAuth,
                child: Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // Show normal change password form
    return Scaffold(
      appBar: AppBar(title: Text('Ganti Password')),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
    // ...existing form code...
  }
}
```

---

## 🧪 **Testing Plan (After Implementation)**

### Test Cases:

1. **Device Support Check**
   - Test on device WITH biometric (iPhone with Face ID)
   - Test on device WITHOUT biometric (older Android)
   - Expected: Feature only shows on supported devices

2. **Enable Biometric**
   - Enable biometric in settings
   - App should request biometric authentication
   - Expected: Setting saved, biometric active

3. **Biometric Login**
   - Close app
   - Reopen app
   - Expected: Biometric prompt shows automatically
   - After auth: Login successful

4. **Biometric Login - Failed**
   - Trigger biometric login
   - Cancel or fail authentication
   - Expected: Fall back to password login

5. **Change Password with Biometric**
   - Tap "Ubah Password"
   - Expected: Biometric prompt before form
   - After auth: Form visible

6. **Disable Biometric**
   - Disable biometric in settings
   - Close and reopen app
   - Expected: No biometric prompt, show login form

---

## 📊 **Implementation Timeline**

**Total Estimated Time:** 1-2 days

| Task | Time | Status |
|------|------|--------|
| Add dependencies | 15 min | ⬜ |
| Configure iOS/Android | 30 min | ⬜ |
| Create BiometricService | 1 hour | ⬜ |
| Update StorageService | 30 min | ⬜ |
| Update Login Page | 2 hours | ⬜ |
| Add Settings UI | 1 hour | ⬜ |
| Protect Change Password | 1 hour | ⬜ |
| Testing | 2 hours | ⬜ |
| Bug fixes | 1 hour | ⬜ |

**Total:** ~8-10 hours (~1-2 work days)

---

## ⚠️ **Important Notes**

### **Security Considerations:**

1. **Never store password in plain text**
   - Even with biometric, password should be encrypted
   - Use secure storage with encryption

2. **Fallback to password login**
   - Always provide option to login with password
   - Biometric might fail (face mask, dirty fingerprint, etc.)

3. **Re-authenticate for sensitive operations**
   - Change password
   - View sensitive data
   - Delete account

4. **Handle biometric lockout**
   - After too many failed attempts, biometric locked
   - Must provide password login as fallback

---

## 🎯 **Next Steps**

### **After Phase 1 Testing Complete:**

1. ✅ Verify Update Profile working 100%
2. ✅ Verify Change Password working 100%
3. ✅ Fix any bugs found in testing
4. ✅ Get sign-off from QA/Product Owner
5. 🔄 **START** Biometric implementation
6. 🧪 Test biometric feature
7. 🚀 Deploy to production

---

## 📞 **Questions?**

If you have questions about biometric implementation:

1. Check Flutter `local_auth` documentation: https://pub.dev/packages/local_auth
2. Check iOS Face ID setup: https://developer.apple.com/documentation/localauthentication
3. Check Android Biometric: https://developer.android.com/training/sign-in/biometric-auth

---

**Status:** ⏳ **PENDING** - Waiting for Phase 1 testing complete  
**Priority:** 🟡 **HIGH** - Implement after Update Profile & Change Password stable  
**Last Updated:** 24 Desember 2025
