import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'onboarding_page.dart' show OnboardingScreen;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

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
      
      // Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();
      print('Is logged in: $isLoggedIn');

      if (isLoggedIn) {
        // Try to refresh token to verify it's still valid
        try {
          print('Attempting to refresh token...');
          await _authService.refreshToken();
          print('✅ Token refreshed successfully');

          // Token valid, navigate to home
          if (mounted) {
            print('Navigating to HomePage...');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        } on SessionExpiredException {
          // Token invalid/expired, go to onboarding
          print('❌ Session expired, navigating to Onboarding...');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        } catch (e) {
          // Any error, go to onboarding
          print('❌ Error refreshing token: $e, navigating to Onboarding...');
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        }
      } else {
        // Not logged in, go to onboarding
        print('Not logged in, navigating to Onboarding...');
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      // Error checking login status, go to onboarding
      print('❌ Error checking login status: $e, navigating to Onboarding...');
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
