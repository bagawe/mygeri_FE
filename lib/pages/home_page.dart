import 'package:flutter/material.dart';
import '../pages/beranda/beranda_page.dart';
import '../pages/riwayat/riwayat_page.dart';
import '../pages/profil/profile_page.dart';
import '../pages/pesan/pesan_page.dart';
import '../pages/pengaturan/pengaturan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget?> _pages = List.filled(5, null);

  Widget _getPage(int index) {
    if (_pages[index] != null) return _pages[index]!;
    switch (index) {
      case 0:
        _pages[0] = const BerandaPage();
        break;
      case 1:
        _pages[1] = const RiwayatPage();
        break;
      case 2:
        _pages[2] = const ProfilePage();
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
        children: List.generate(_pages.length, (i) => _getPage(i)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Pesan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
