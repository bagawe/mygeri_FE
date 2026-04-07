import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../pages/beranda/beranda_page.dart';
import '../pages/riwayat/riwayat_page.dart';
import '../pages/profil/profile_page.dart';
import '../pages/pesan/pesan_page.dart';
import '../pages/pengaturan/pengaturan_page.dart';
import '../services/session_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget?> _pages = List.filled(5, null);
  final SessionManager _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    // Register this context for session management
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sessionManager.registerContext(context);
    });
  }

  @override
  void dispose() {
    _sessionManager.unregisterContext();
    super.dispose();
  }

  Widget _getPage(int index) {
    // Special handling for ProfilePage - only create when actually selected
    if (index == 2) {
      if (_selectedIndex == 2) {
        return const ProfilePage();
      } else {
        return Container(); // Return placeholder when not selected
      }
    }
    
    // Cache other pages
    if (_pages[index] != null) return _pages[index]!;
    switch (index) {
      case 0:
        _pages[0] = const BerandaPage();
        break;
      case 1:
        _pages[1] = const RiwayatPage();
        break;
      case 3:
        _pages[3] = const PesanPage();
        break;
      case 4:
        _pages[4] = const PengaturanPage();
        break;
    }
    return _pages[index]!;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _getPage(0),  // BerandaPage - always show
          _selectedIndex == 1 ? _getPage(1) : Container(),  // RiwayatPage - lazy
          _getPage(2),  // ProfilePage - controlled inside _getPage()
          _selectedIndex == 3 ? _getPage(3) : Container(),  // PesanPage - lazy
          _selectedIndex == 4 ? _getPage(4) : Container(),  // PengaturanPage - lazy
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        color: Colors.red[700]!,
        buttonBackgroundColor: Colors.red[700],
        height: 65,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          Icon(Icons.home, color: Colors.white, size: 28),
          Icon(Icons.history, color: Colors.white, size: 28),
          Icon(Icons.person, color: Colors.white, size: 28),
          Icon(Icons.mail, color: Colors.white, size: 28),
          Icon(Icons.settings, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
