import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/register_request.dart';
import '../../utils/validators.dart';

class RegisterSimpatisanPage extends StatefulWidget {
  const RegisterSimpatisanPage({super.key});

  @override
  State<RegisterSimpatisanPage> createState() => _RegisterSimpatisanPageState();
}

class _RegisterSimpatisanPageState extends State<RegisterSimpatisanPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ulangiPasswordController = TextEditingController();
  
  bool _isLoading = false;
  
  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _ulangiPasswordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_passwordController.text != _ulangiPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak cocok')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final request = RegisterRequest(
        name: _namaController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      // Debug: Print data yang akan dikirim
      print('Registration data: ${request.toJson()}');
      
      await _authService.register(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Kembali ke halaman login
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        // Extract error message
        String errorMessage = e.toString();
        errorMessage = errorMessage.replaceFirst('Exception: Registration failed: ', '');
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
        
        // Show error in a dialog for better visibility
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Pendaftaran Gagal'),
            content: SingleChildScrollView(
              child: Text(errorMessage),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  const Text(
                    'Pendaftaran Simpatisan Partai',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Nama :', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _namaController,
                              decoration: const InputDecoration(
                                hintText: 'Nama Lengkap (hanya huruf dan spasi)',
                                helperText: 'Contoh: John Doe',
                              ),
                              validator: Validators.validateName,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email :', style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'user@email.com',
                                helperText: 'Contoh: john@example.com',
                              ),
                              validator: Validators.validateEmail,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Username :', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'Username (min 3 karakter)',
                          helperText: 'Hanya huruf, angka, underscore. Contoh: johndoe123',
                        ),
                        validator: Validators.validateUsername,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Buat Password :', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Min 8 karakter: huruf besar, kecil, angka',
                          helperText: 'Contoh: Password123 (WAJIB: a-z, A-Z, 0-9)',
                        ),
                        validator: Validators.validatePassword,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ulangi Password :', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ulangiPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Ulangi password',
                        ),
                        validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading ? null : _handleRegister,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Daftar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 32),
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
        ),
      ),
    );
  }
}
