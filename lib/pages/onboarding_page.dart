import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<String> _titles = [
    'Selamat Datang di mygeri!',
    'Aplikasi untuk kemudahan Anda',
    'Mulai pengalaman baru bersama kami',
  ];
  final List<String> _descriptions = [
    'Aplikasi mygeri membantu Anda mengelola kebutuhan harian.',
    'Nikmati fitur-fitur terbaik untuk kenyamanan Anda.',
    'Tekan lanjut untuk masuk ke halaman utama.',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.announcement, size: size.width * 0.22, color: Colors.red),
                            const SizedBox(height: 32),
                            Text(
                              _titles[index],
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _descriptions[index],
                              style: const TextStyle(fontSize: 16, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 24,
                        right: 24,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            if (index < 2) {
                              _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                            } else {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          },
                          child: const Text('Lanjut', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) =>
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
