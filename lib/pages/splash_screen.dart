import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'home_page.dart';
import 'onboarding_page.dart' show OnboardingScreen;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // Wait 2 seconds for splash screen
    await Future.delayed(const Duration(seconds: 2));

    try {
      print('=== SPLASH SCREEN: Checking auto-login ===');
      print('⏰ Current time: ${DateTime.now()}');
      
      // Check if user is logged in (includes session validation)
      final isLoggedIn = await _authService.isLoggedIn();
      print('🔐 Is logged in (with valid session): $isLoggedIn');

      if (isLoggedIn) {
        // Session valid - EXTEND IT (reset to 1 bulan dari sekarang)
        print('✅ Session valid - extending expiry to 30 days from now...');
        await _storage.extendSessionExpiry();
        
        // Try to refresh token to verify it's still valid
        try {
          print('🔄 Attempting to refresh token...');
          await _authService.refreshToken();
          print('✅ Token refreshed successfully - Session is VALID');

          // Token valid, navigate to home
          if (mounted) {
            print('🏠 Navigating to HomePage...');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } on SessionExpiredException catch (e) {
          // Token invalid/expired, go to onboarding
          print('❌ Session expired: $e');
          print('📱 Navigating to Onboarding...');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        } catch (e) {
          // Network error or other issues - try to stay logged in
          print('⚠️ Error refreshing token: $e');
          print('🔍 Checking if we should keep user logged in...');
          
          // If we have tokens, try to use them (maybe network is down)
          final hasTokens = await _authService.isLoggedIn();
          if (hasTokens) {
            print('💾 Tokens exist, keeping user logged in despite refresh error');
            print('🏠 Navigating to HomePage (with potentially stale token)...');
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          } else {
            print('❌ No tokens found, navigating to Onboarding...');
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const OnboardingScreen()),
              );
            }
          }
        }
      } else {
        // Not logged in, go to onboarding
        print('🚪 Not logged in, navigating to Onboarding...');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      // Error checking login status, go to onboarding
      print('❌ Error checking login status: $e');
      print('📱 Navigating to Onboarding as fallback...');
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/my geri trans.png',
                width: size.width * 0.4,
                height: size.width * 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Column(
              children: [
                const Text('Supported by :', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/gerinda.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
