import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  // In-memory cache untuk immediate access
  static String? _cachedAccessToken;
  static String? _cachedRefreshToken;

  // Keys
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _userUuidKey = 'user_uuid';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _savedAccountsKey = 'saved_accounts'; // JSON array of saved accounts

  // Save tokens - immediate memory cache + WAIT for secure storage
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    // IMMEDIATE: Save to memory cache (instant access)
    _cachedAccessToken = accessToken;
    _cachedRefreshToken = refreshToken;
    print('✅ Tokens cached in memory (instant)');
    
    // CRITICAL: AWAIT secure storage write (must complete before force close!)
    try {
      await Future.wait([
        _storage.write(key: _accessTokenKey, value: accessToken),
        _storage.write(key: _refreshTokenKey, value: refreshToken),
      ]);
      print('✅ Tokens persisted to secure storage (completed)');
    } catch (error) {
      print('❌ CRITICAL: Failed to persist tokens to storage: $error');
      // Clear memory cache since persist failed
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      rethrow; // Re-throw to notify caller
    }
  }

  // Get access token - from memory cache first, fallback to storage
  Future<String?> getAccessToken() async {
    // Try memory cache first (instant)
    if (_cachedAccessToken != null) {
      return _cachedAccessToken;
    }
    
    // Fallback to storage (slower)
    _cachedAccessToken = await _storage.read(key: _accessTokenKey);
    return _cachedAccessToken;
  }

  // Get refresh token - from memory cache first, fallback to storage
  Future<String?> getRefreshToken() async {
    // Try memory cache first (instant)
    if (_cachedRefreshToken != null) {
      return _cachedRefreshToken;
    }
    
    // Fallback to storage (slower)
    _cachedRefreshToken = await _storage.read(key: _refreshTokenKey);
    return _cachedRefreshToken;
  }

  // Save user data - WAIT for completion
  Future<void> saveUserData({
    required String id,
    required String uuid,
    required String name,
    required String email,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: id),
        _storage.write(key: _userUuidKey, value: uuid),
        _storage.write(key: _userNameKey, value: name),
        _storage.write(key: _userEmailKey, value: email),
      ]);
      print('✅ User data persisted to secure storage');
    } catch (error) {
      print('❌ Failed to save user data: $error');
      rethrow;
    }
  }

  // Get user data
  Future<Map<String, String?>> getUserData() async {
    return {
      'id': await _storage.read(key: _userIdKey),
      'uuid': await _storage.read(key: _userUuidKey),
      'name': await _storage.read(key: _userNameKey),
      'email': await _storage.read(key: _userEmailKey),
    };
  }

  // Save accounts - immediate memory cache + background secure storage
  Future<void> saveAccounts(List<String> accounts) async {
    // IMMEDIATE: Save to memory cache (instant access)
    // BACKGROUND: Save to secure storage (parallel writes)
    Future.wait([
      _storage.write(key: _savedAccountsKey, value: json.encode(accounts)),
    ]).then((_) {
      print('✅ Accounts persisted to secure storage (background)');
    }).catchError((error) {
      print('⚠️ Warning: Failed to persist accounts to storage: $error');
    });
  }

  // Get accounts - from storage
  Future<List<String>> getAccounts() async {
    // Fallback to storage (slower)
    final accountsJson = await _storage.read(key: _savedAccountsKey);
    if (accountsJson != null) {
      return List<String>.from(json.decode(accountsJson));
    }
    return [];
  }

  // Clear all data
  Future<void> clearAll() async {
    // Clear memory cache first (instant)
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    
    // Clear secure storage
    await _storage.deleteAll();
    print('✅ Storage cleared (memory + secure storage)');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    print('🔍 StorageService.isLoggedIn(): $isLoggedIn (token: ${token != null ? "${token.substring(0, 20)}..." : "null"})');
    return isLoggedIn;
  }

  // Save account credentials for quick login
  Future<void> saveAccountCredentials(String username, String password) async {
    try {
      print('💾 Saving account credentials for: $username');
      
      // Get existing saved accounts
      final savedAccountsJson = await _storage.read(key: _savedAccountsKey);
      List<Map<String, String>> accounts = [];
      
      if (savedAccountsJson != null && savedAccountsJson.isNotEmpty) {
        final decoded = jsonDecode(savedAccountsJson) as List;
        accounts = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
        print('📋 Found ${accounts.length} existing accounts');
      } else {
        print('📋 No existing accounts found');
      }
      
      // Remove duplicate if exists
      accounts.removeWhere((acc) => acc['username'] == username);
      
      // Add new account at the beginning (most recent first)
      accounts.insert(0, {
        'username': username,
        'password': password,
        'lastLogin': DateTime.now().toIso8601String(),
      });
      
      print('✅ Account added. Total accounts: ${accounts.length}');
      
      // Keep only last 5 accounts
      if (accounts.length > 5) {
        accounts = accounts.sublist(0, 5);
        print('⚠️ Trimmed to 5 accounts');
      }
      
      // Save back to storage
      await _storage.write(key: _savedAccountsKey, value: jsonEncode(accounts));
      print('✅ Account credentials saved to storage');
      
      // Verify save
      final verification = await _storage.read(key: _savedAccountsKey);
      print('🔍 Verification: ${verification != null ? "Data exists" : "Data is null"}');
    } catch (e) {
      print('❌ Failed to save account credentials: $e');
    }
  }
  
  // Get saved accounts
  Future<List<Map<String, String>>> getSavedAccounts() async {
    try {
      print('📖 Loading saved accounts...');
      final savedAccountsJson = await _storage.read(key: _savedAccountsKey);
      
      if (savedAccountsJson == null || savedAccountsJson.isEmpty) {
        print('📋 No saved accounts found (null or empty)');
        return [];
      }
      
      print('📋 Raw data: ${savedAccountsJson.substring(0, savedAccountsJson.length > 100 ? 100 : savedAccountsJson.length)}...');
      
      final decoded = jsonDecode(savedAccountsJson) as List;
      final accounts = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      
      print('✅ Loaded ${accounts.length} saved accounts');
      for (var i = 0; i < accounts.length; i++) {
        print('   ${i + 1}. ${accounts[i]['username']} (last login: ${accounts[i]['lastLogin']})');
      }
      
      return accounts;
    } catch (e) {
      print('❌ Failed to load saved accounts: $e');
      return [];
    }
  }
  
  // Remove a saved account
  Future<void> removeSavedAccount(String username) async {
    try {
      final savedAccountsJson = await _storage.read(key: _savedAccountsKey);
      if (savedAccountsJson == null || savedAccountsJson.isEmpty) return;
      
      final decoded = jsonDecode(savedAccountsJson) as List;
      List<Map<String, String>> accounts = decoded.map((e) => Map<String, String>.from(e as Map)).toList();
      
      accounts.removeWhere((acc) => acc['username'] == username);
      
      await _storage.write(key: _savedAccountsKey, value: jsonEncode(accounts));
      print('✅ Account removed');
    } catch (e) {
      print('⚠️ Failed to remove account: $e');
    }
  }
}
