import 'package:flutter/material.dart';
import 'register_kader_lama_page.dart';
import 'register_kader_baru_page.dart';
import 'register_simpatisan_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int? _selectedOption;

  final List<String> _options = [
    'Saya adalah kader/anggota yang sudah terdaftar dan mempunyai kartu anggota.',
    'Saya ingin menjadi kader/anggota baru Partai Gerindra.',
    'Saya ingin menjadi simpatisan Partai Gerindra.',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Pendaftaran',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ...List.generate(_options.length, (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Radio<int>(
                      value: index,
                      groupValue: _selectedOption,
                      onChanged: (val) {
                        setState(() {
                          _selectedOption = val;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _options[index],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black.withOpacity(_selectedOption == index ? 1 : 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _selectedOption != null ? () {
                    if (_selectedOption == 0) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterKaderLamaPage()),
                      );
                    } else if (_selectedOption == 1) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterKaderBaruPage()),
                      );
                    } else if (_selectedOption == 2) {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterSimpatisanPage()),
                      );
                    }
                  } : null,
                  child: const Text('Daftar', style: TextStyle(fontSize: 18)),
                ),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/my geri trans.png',
                width: size.width * 0.35,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
