import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
          child: const Text(
            'Isi syarat dan ketentuan ditampilkan di sini.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}
