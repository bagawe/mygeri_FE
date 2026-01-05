import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'api_service.dart';
import '../pages/login_page.dart';

/// Global session manager for handling session expiration
/// and automatic logout across the app
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final AuthService _authService = AuthService();
  BuildContext? _context;
  bool _isLoggingOut = false;

  /// Register the current context for navigation
  void registerContext(BuildContext context) {
    _context = context;
  }

  /// Unregister context when widget is disposed
  void unregisterContext() {
    _context = null;
  }

  /// Handle session expiration
  /// This will be called when API returns 401 and refresh token fails
  Future<void> handleSessionExpired({String? message}) async {
    if (_isLoggingOut) {
      print('⚠️ Already logging out, skipping duplicate');
      return;
    }

    _isLoggingOut = true;
    print('🚨 Session expired - forcing logout');

    try {
      // Clear all local data
      await _authService.logout();
    } catch (e) {
      print('⚠️ Error during forced logout: $e');
    }

    // Navigate to login page
    if (_context != null && _context!.mounted) {
      Navigator.of(_context!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
        (route) => false, // Remove all previous routes
      );

      // Show message to user
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_context != null && _context!.mounted) {
          ScaffoldMessenger.of(_context!).showSnackBar(
            SnackBar(
              content: Text(message ?? 'Sesi Anda telah berakhir. Silakan login kembali.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }

    _isLoggingOut = false;
  }

  /// Check if user session is still valid
  /// Returns true if valid, false if expired
  Future<bool> checkSession() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        print('⚠️ No active session found');
        return false;
      }
      return true;
    } catch (e) {
      print('⚠️ Session check failed: $e');
      return false;
    }
  }

  /// Perform logout with proper error handling
  Future<bool> performLogout() async {
    if (_isLoggingOut) {
      print('⚠️ Already logging out');
      return false;
    }

    _isLoggingOut = true;
    print('🚪 Performing logout...');

    try {
      // Call logout (with timeout and error handling)
      await _authService.logout();
      
      // Navigate to login
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );

        // Show success message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_context != null && _context!.mounted) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              const SnackBar(
                content: Text('Berhasil logout'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }

      _isLoggingOut = false;
      return true;
    } catch (e) {
      print('❌ Logout error: $e');
      
      // Still navigate to login even if API fails
      if (_context != null && _context!.mounted) {
        Navigator.of(_context!).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false,
        );

        Future.delayed(const Duration(milliseconds: 500), () {
          if (_context != null && _context!.mounted) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              const SnackBar(
                content: Text('Logout berhasil (session cleared)'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        });
      }

      _isLoggingOut = false;
      return true; // Return true because local logout succeeded
    }
  }

  /// Setup global error handler for API calls
  void setupApiErrorHandler() {
    // This will be called by ApiService when SessionExpiredException is thrown
    print('📡 API error handler setup');
  }
}

/// Extension to handle API errors globally
extension ApiErrorHandler on SessionExpiredException {
  void handle() {
    SessionManager().handleSessionExpired(
      message: 'Sesi Anda telah berakhir. Silakan login kembali.',
    );
  }
}
