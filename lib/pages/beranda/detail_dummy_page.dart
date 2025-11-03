import 'package:flutter/material.dart';
import 'dart:async';

class DetailDummyPage extends StatefulWidget {
  final List<Map<String, String>> items;
  final int initialIndex;
  final int autoPlayDuration; // dalam detik, 0 = tidak autoplay
  const DetailDummyPage({super.key, required this.items, this.initialIndex = 0, this.autoPlayDuration = 0});

  @override
  State<DetailDummyPage> createState() => _DetailDummyPageState();
}

class _DetailDummyPageState extends State<DetailDummyPage> {
  late PageController _controller;
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
    if (widget.autoPlayDuration > 0) {
      _timer = Timer.periodic(Duration(seconds: widget.autoPlayDuration), (timer) {
        if (!mounted) return;
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.items.length) nextPage = 0;
        _controller.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
      _controller.addListener(() {
        final idx = _controller.page?.round() ?? 0;
        if (_currentIndex != idx) {
          setState(() {
            _currentIndex = idx;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.items[_currentIndex]['title'] ?? '-'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.items.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (context, i) {
          final item = widget.items[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  item['image'] ?? '',
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 220,
                    child: const Icon(Icons.image, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                item['title'] ?? '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              const SizedBox(height: 12),
              const Text('Deskripsi konten di sini', style: TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );
  }
}
