import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../models/register_request.dart';
import '../../utils/validators.dart';

class RegisterKaderLamaPage extends StatefulWidget {
  const RegisterKaderLamaPage({super.key});

  @override
  State<RegisterKaderLamaPage> createState() => _RegisterKaderLamaPageState();
}

class _RegisterKaderLamaPageState extends State<RegisterKaderLamaPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ulangiPasswordController = TextEditingController();
  
  File? _fotoKTA;
  File? _fotoSelfie;
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
  
  Future<void> _pickImage(bool isKTA) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          if (isKTA) {
            _fotoKTA = File(image.path);
          } else {
            _fotoSelfie = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }
  
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Foto KTA dan Selfie OPTIONAL (belum ada di backend)
    // if (_fotoKTA == null || _fotoSelfie == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Harap upload foto KTA dan selfie')),
    //   );
    //   return;
    // }
    
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
      // TODO: Upload gambar ke server jika backend sudah support
      // Untuk sementara, foto diabaikan karena backend belum ada field foto
      
      // Debug: Print data sebelum create request
      print('=== REGISTER DATA ===');
      print('Name: "${_namaController.text.trim()}"');
      print('Email: "${_emailController.text.trim()}"');
      print('Username: "${_usernameController.text.trim()}"');
      print('Password length: ${_passwordController.text.length}');
      
      final request = RegisterRequest(
        name: _namaController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        // fotoKtp: _fotoKTA?.path, // TODO: Uncomment jika backend sudah support
        // fotoProfil: _fotoSelfie?.path, // TODO: Uncomment jika backend sudah support
      );
      
      // Debug: Print JSON yang akan dikirim
      print('Request JSON: ${request.toJson()}');
      
      await _authService.register(request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran berhasil! Menunggu verifikasi admin.'),
            backgroundColor: Colors.green,
          ),
        );
        
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
  
  Widget _imageBox(String label, File? image, bool isKTA) {
    return GestureDetector(
      onTap: () => _pickImage(isKTA),
      child: Container(
        width: 150,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(image, fit: BoxFit.cover),
              ),
      ),
    );
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
                  'Pendaftaran Kader Lama',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
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
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email :', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'user@email.com',
                      ),
                      validator: Validators.validateEmail,
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Upload KTA :', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              Text('(Opsional)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _imageBox('Foto KTA', _fotoKTA, true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Foto Selfie :', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              Text('(Opsional)', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _imageBox('Foto Selfie', _fotoSelfie, false),
                        ],
                      ),
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
