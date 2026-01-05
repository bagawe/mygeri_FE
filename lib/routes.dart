import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/onboarding_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/profil/profile_page.dart';
import 'pages/profil/edit_profil_page.dart';
import 'pages/profil/ekta_depan_page.dart';
import 'pages/profil/ekta_belakang_page.dart';
import 'pages/feed/search_posts_page.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomePage());
      case '/profil':
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case '/edit-profil':
        return MaterialPageRoute(builder: (_) => const EditProfilPage());
      case '/ekta':
        return MaterialPageRoute(builder: (_) => const EKtaDepanPage(
          nama: 'Sinta Silalahi',
          qrData: 'dummy',
          fotoPath: 'assets/images/logo myGeri Jpeg.jpg',
        ));
      case '/ekta-belakang':
        return MaterialPageRoute(builder: (_) => const EKtaBelakangPage(
          nama: 'Sinta Silalahi',
          nomorKta: '3276047658400027',
          ttl: 'Jakarta, 12 Oktober 1998',
          alamat: 'Jl. Mawar  No.10 RT.05/RW.01',
          kelurahan: 'Kalibata Utara',
          kecamatan: 'Klibata',
          kota: 'Jakarta Selatan',
          provinsi: 'DKI Jakarta',
          kelamin: 'Perempuan',
          qrKetum: 'dummy',
          qrSekretaris: 'dummy',
        ));
      case '/search_posts':
        return MaterialPageRoute(builder: (_) => const SearchPostsPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
