import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import 'register/register_page.dart';
import 'terms_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isChecked = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  List<Map<String, String>> _savedAccounts = [];
  bool _showAccountSuggestions = false;
  final FocusNode _identifierFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    print('🔵 LoginPage: initState called');
    _loadSavedAccounts();
    
    // Show suggestions when identifier field is focused
    _identifierFocusNode.addListener(() {
      if (_identifierFocusNode.hasFocus && _savedAccounts.isNotEmpty) {
        setState(() {
          _showAccountSuggestions = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload accounts when page becomes visible again
    print('🔵 LoginPage: didChangeDependencies called');
    _loadSavedAccounts();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _identifierFocusNode.dispose();
    super.dispose();
  }
  
  Future<void> _loadSavedAccounts() async {
    print('🔍 LoginPage: Loading saved accounts...');
    final accounts = await _storageService.getSavedAccounts();
    print('🔍 LoginPage: Received ${accounts.length} accounts');
    setState(() {
      _savedAccounts = accounts;
    });
    print('🔍 LoginPage: State updated with ${_savedAccounts.length} accounts');
  }
  
  void _selectAccount(Map<String, String> account) {
    setState(() {
      _identifierController.text = account['username'] ?? '';
      _passwordController.text = account['password'] ?? '';
      _showAccountSuggestions = false;
      _isChecked = true; // Auto-check terms since they already agreed before
    });
    FocusScope.of(context).unfocus();
  }
  
  void _removeAccount(Map<String, String> account) async {
    await _storageService.removeSavedAccount(account['username'] ?? '');
    _loadSavedAccounts();
  }

  void _showTerms() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsPage()),
    );
  }

  Future<void> _login() async {
    // Validasi checkbox syarat & ketentuan
    if (!_isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus menyetujui syarat dan ketentuan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Login via API
      final response = await _authService.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      // Save credentials for future quick login
      await _storageService.saveAccountCredentials(
        _identifierController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Tampilkan success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${response.user.name}!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Tokens & user data already saved in AuthService.login() (awaited)
        // Small delay for better UX
        await Future.delayed(const Duration(milliseconds: 300));

        // Navigate ke home page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Parse error message
        String errorMessage = 'Login gagal';
        
        if (e.toString().contains('Invalid credentials')) {
          errorMessage = 'Email/Username atau password salah';
        } else if (e.toString().contains('Network error')) {
          errorMessage = 'Koneksi ke server gagal. Pastikan backend sudah berjalan.';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Email/Username atau password salah';
        } else {
          errorMessage = 'Login gagal: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange[700],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
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

  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }
  
  String _formatLastLogin(String? isoDate) {
    if (isoDate == null) return 'Tidak diketahui';
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/my geri trans.png',
                      width: size.width * 0.35,
                      height: size.width * 0.35,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 100);
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Username field with saved accounts dropdown
                  Stack(
                    children: [
                      TextFormField(
                        controller: _identifierController,
                        focusNode: _identifierFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        onChanged: (value) {
                          if (value.isEmpty && _savedAccounts.isNotEmpty) {
                            setState(() {
                              _showAccountSuggestions = true;
                            });
                          } else {
                            setState(() {
                              _showAccountSuggestions = false;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Email atau Username',
                          hintText: 'Masukkan email atau username',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                          suffixIcon: _savedAccounts.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    _showAccountSuggestions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showAccountSuggestions = !_showAccountSuggestions;
                                    });
                                  },
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email atau Username wajib diisi';
                          }
                          if (value.length < 3) {
                            return 'Minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      // Dropdown suggestions
                      if (_showAccountSuggestions && _savedAccounts.isNotEmpty)
                        Positioned(
                          top: 65,
                          left: 0,
                          right: 0,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _savedAccounts.length,
                                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey[200]),
                                itemBuilder: (context, index) {
                                  final account = _savedAccounts[index];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.red[700],
                                      child: Text(
                                        (account['username'] ?? '?')[0].toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      account['username'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    subtitle: Text(
                                      'Terakhir login: ${_formatLastLogin(account['lastLogin'])}',
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.close, size: 18),
                                      onPressed: () => _removeAccount(account),
                                      tooltip: 'Hapus akun',
                                    ),
                                    onTap: () => _selectAccount(account),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Masukkan password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (value.length < 8) {
                        return 'Password minimal 8 karakter';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (val) {
                        setState(() {
                          _isChecked = val ?? false;
                        });
                      },
                      activeColor: Colors.grey[700],
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Flexible(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _showTerms,
                            child: const Text('Saya setuju dengan '),
                          ),
                          GestureDetector(
                            onTap: _showTerms,
                            child: Text(
                              'Syarat & Ketentuan',
                              style: TextStyle(
                                color: Colors.grey[700],
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: _isLoading ? null : _goToRegister,
                      child: Text(
                        'Belum punya akun? Daftar',
                        style: TextStyle(
                          color: _isLoading ? Colors.grey : Colors.grey[700],
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
