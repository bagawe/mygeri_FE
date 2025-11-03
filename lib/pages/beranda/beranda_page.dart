import 'package:flutter/material.dart';
import 'package:mygeri/pages/beranda/detail_dummy_page.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user data
    final user = {
      'nama': 'Dani Setiawan',
      'username': '@thesetiawan',
      'photo': null, // null to test error handler
    };
    // Menu icon data
    final List<Map<String, dynamic>> menuItems = [
      {'icon': 'assets/icons/gerinda.png', 'isAsset': true, 'label': 'My Gerindra'},
      {'icon': 'assets/icons/profil.jpeg', 'isAsset': true, 'label': 'KTA'},
      {'icon': 'assets/icons/radar.png', 'isAsset': true, 'label': 'Radar'},
      {'icon': 'assets/icons/agenda.jpeg', 'isAsset': true, 'label': 'Agenda'},
      {'icon': 'assets/icons/voting.jpeg', 'isAsset': true, 'label': 'Voting'},
    ];
    // Dummy data untuk carousel
    final List<Map<String, String>> beritaList = [
      {'title': 'Berita 1', 'image': 'assets/images/kegiatan4.jpg'},
      {'title': 'Berita 2', 'image': 'assets/images/kegiatan2.jpg'},
      {'title': 'Berita 3', 'image': 'assets/images/kegiatan3.jpg'},
    ];
    final List<Map<String, String>> agendaList = [
      {'title': 'Agenda 1', 'image': 'assets/images/kegiatan4.jpg'},
      {'title': 'Agenda 2', 'image': 'assets/images/kegiatan2.jpg'},
      {'title': 'Agenda 3', 'image': 'assets/images/kegiatan6.jpg'},
    ];
    final List<Map<String, String>> votingList = [
      {'title': 'Voting 1', 'image': 'assets/images/kegiatan4.jpg'},
      {'title': 'Voting 2', 'image': 'assets/images/kegiatan5.jpg'},
      {'title': 'Voting 3', 'image': 'assets/images/kegiatan3.jpg'},
    ];
    Widget sectionCarousel(String title, List<Map<String, String>> items, void Function(int) onTap, {int autoPlayDuration = 0}) => _SectionCarousel(
      title: title,
      items: items,
      onTap: onTap,
      autoPlayDuration: autoPlayDuration,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  // Foto profil
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: (user['photo'] != null && user['photo'] != '')
                        ? AssetImage(user['photo']!)
                        : null,
                    child: (user['photo'] == null || user['photo'] == '')
                        ? const Icon(Icons.person, color: Colors.white, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['nama'] ?? '-',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user['username'] ?? '-',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu ikon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: menuItems.map((item) {
                  return Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: item['isAsset'] == true
                            ? Image.asset(
                                item['icon'],
                                width: 36,
                                height: 36,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.red),
                              )
                            : Icon(item['icon'], size: 36, color: Colors.red),
                      ),
                      const SizedBox(height: 6),
                      Text(item['label'], style: const TextStyle(fontSize: 13)),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),
            // Section konten
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionCarousel('Berita', beritaList, (i) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailDummyPage(items: beritaList, initialIndex: i, autoPlayDuration: 4),
                        ),
                      );
                    }, autoPlayDuration: 4),
                    sectionCarousel('Agenda', agendaList, (i) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailDummyPage(items: agendaList, initialIndex: i, autoPlayDuration: 5),
                        ),
                      );
                    }, autoPlayDuration: 5),
                    sectionCarousel('Voting', votingList, (i) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailDummyPage(items: votingList, initialIndex: i, autoPlayDuration: 6),
                        ),
                      );
                    }, autoPlayDuration: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCarousel extends StatefulWidget {
  final String title;
  final List<Map<String, String>> items;
  final void Function(int) onTap;
  final int autoPlayDuration;

  const _SectionCarousel({
    required this.title,
    required this.items,
    required this.onTap,
    this.autoPlayDuration = 0,
  });

  @override
  State<_SectionCarousel> createState() => __SectionCarouselState();
}

class __SectionCarouselState extends State<_SectionCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isAutoPlaying = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    if (widget.autoPlayDuration > 0) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    setState(() {
      _isAutoPlaying = true;
    });
    Future.delayed(Duration(seconds: widget.autoPlayDuration), () {
      if (_isAutoPlaying) {
        _currentIndex = (_currentIndex + 1) % widget.items.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  void _stopAutoPlay() {
    setState(() {
      _isAutoPlaying = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: PageView.builder(
            itemCount: widget.items.length,
            controller: _pageController,
            itemBuilder: (context, i) {
              final item = widget.items[i];
              return GestureDetector(
                onTap: () {
                  widget.onTap(i);
                  _stopAutoPlay();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Image.asset(
                          item['image']!,
                          width: double.infinity,
                          height: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            width: double.infinity,
                            height: 160,
                            child: const Icon(Icons.image, size: 40, color: Colors.white),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            color: Colors.black.withOpacity(0.4),
                            child: Text(
                              item['title'] ?? '-',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
