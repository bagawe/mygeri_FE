# 🔧 Troubleshooting: Registration Failed - Validation Error

## ❌ Error yang Muncul
```
Pendaftaran gagal: Exception: Registration failed: Validation error
```

---

## 🎯 Penyebab Umum & Solusi

### 1. **Password Tidak Memenuhi Syarat** (Paling Sering)

#### ❌ Validation Rules:
- ✅ Minimal **8 karakter**
- ✅ Harus ada **huruf kecil** (a-z)
- ✅ Harus ada **huruf BESAR** (A-Z)
- ✅ Harus ada **angka** (0-9)

#### ❌ Contoh Password SALAH:
```dart
'password'       // ❌ Tidak ada huruf besar & angka
'Password'       // ❌ Tidak ada angka
'password123'    // ❌ Tidak ada huruf besar
'PASSWORD123'    // ❌ Tidak ada huruf kecil
'Pass12'         // ❌ Kurang dari 8 karakter
```

#### ✅ Contoh Password BENAR:
```dart
'Password123'    // ✅ Ada besar, kecil, angka, 8+ karakter
'MyPass123'      // ✅
'SecurePass1'    // ✅
'Admin123!'      // ✅ (symbol opsional, tapi boleh)
```

---

### 2. **Name Tidak Valid**

#### ❌ Validation Rules:
- ✅ Minimal **1 karakter**
- ✅ Maksimal **100 karakter**
- ✅ **Hanya boleh huruf dan spasi** (tidak boleh angka atau symbol)

#### ❌ Contoh Name SALAH:
```dart
'John123'        // ❌ Ada angka
'John_Doe'       // ❌ Ada underscore
'John@Doe'       // ❌ Ada symbol @
''               // ❌ Kosong
```

#### ✅ Contoh Name BENAR:
```dart
'John Doe'       // ✅
'John'           // ✅
'Maria Garcia'   // ✅
'Muhammad Ali'   // ✅
```

---

### 3. **Username Tidak Valid**

#### ❌ Validation Rules:
- ✅ Minimal **3 karakter**
- ✅ Maksimal **30 karakter**
- ✅ Hanya boleh **huruf (a-z, A-Z), angka (0-9), dan underscore (_)**
- ✅ Tidak boleh spasi

#### ❌ Contoh Username SALAH:
```dart
'jo'             // ❌ Kurang dari 3 karakter
'john doe'       // ❌ Ada spasi
'john@doe'       // ❌ Ada symbol @
'john-doe'       // ❌ Ada dash (-)
```

#### ✅ Contoh Username BENAR:
```dart
'johndoe'        // ✅
'john_doe'       // ✅
'john123'        // ✅
'JohnDoe123'     // ✅
'user_123'       // ✅
```

---

### 4. **Email Tidak Valid**

#### ❌ Validation Rules:
- ✅ Format email valid
- ✅ Maksimal **255 karakter**

#### ❌ Contoh Email SALAH:
```dart
'invalidemail'           // ❌ Tidak ada @
'user@'                  // ❌ Tidak ada domain
'@example.com'           // ❌ Tidak ada user
'user @example.com'      // ❌ Ada spasi
```

#### ✅ Contoh Email BENAR:
```dart
'john@example.com'       // ✅
'user.name@domain.co.id' // ✅
'test123@gmail.com'      // ✅
```

---

## 🔍 Cara Debug di Flutter

### 1. **Tampilkan Error Detail**

```dart
// Modifikasi auth_service.dart
Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String username,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'username': username,
        'password': password,
      }),
    );
    
    final data = json.decode(response.body);
    
    print('Status Code: ${response.statusCode}'); // DEBUG
    print('Response: $data'); // DEBUG
    
    if (response.statusCode == 201) {
      return data;
    } else {
      // Tampilkan detail error
      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        final errorMessages = errors.map((e) => 
          '${e['field']}: ${e['message']}'
        ).join('\n');
        throw Exception('Validation failed:\n$errorMessages');
      }
      throw Exception(data['message'] ?? 'Registration failed');
    }
  } catch (e) {
    print('Error: $e'); // DEBUG
    rethrow;
  }
}
```

---

### 2. **Validasi di Flutter Sebelum Kirim**

```dart
// lib/utils/validators.dart
class Validators {
  // Password validator
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }
  
  // Name validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length > 100) {
      return 'Name cannot exceed 100 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }
  
  // Username validator
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Username cannot exceed 30 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
  
  // Email validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Invalid email format';
    }
    if (value.length > 255) {
      return 'Email cannot exceed 255 characters';
    }
    return null;
  }
}
```

---

### 3. **Gunakan Validator di Form**

```dart
// lib/screens/register_screen.dart
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                hintText: 'John Doe',
                helperText: 'Letters and spaces only',
              ),
              validator: Validators.validateName,
            ),
            SizedBox(height: 16),
            
            // Email field
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'john@example.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ),
            SizedBox(height: 16),
            
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                hintText: 'johndoe',
                helperText: 'Letters, numbers, underscore only (min 3 chars)',
              ),
              validator: Validators.validateUsername,
            ),
            SizedBox(height: 16),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Password123',
                helperText: 'Min 8 chars, must have: a-z, A-Z, 0-9',
              ),
              obscureText: true,
              validator: Validators.validatePassword,
            ),
            SizedBox(height: 24),
            
            // Register button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return; // Form not valid
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await AuthService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pop(context); // Go back to login
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

---

## 📝 Test Data yang Valid

Gunakan data test ini untuk memastikan registrasi berhasil:

```dart
// Test data yang PASTI VALID
final testData = {
  'name': 'John Doe',           // ✅ Huruf dan spasi saja
  'email': 'john@example.com',  // ✅ Email valid
  'username': 'johndoe',        // ✅ 7 karakter, huruf saja
  'password': 'Password123',    // ✅ 8+ char, a-z, A-Z, 0-9
};
```

---

## 🧪 Test di Backend Langsung

Test dulu di backend untuk memastikan validation rules:

```bash
# Test dengan curl
curl -X POST http://localhost:3030/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "test@example.com",
    "username": "testuser",
    "password": "Password123"
  }'
```

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": 2,
    "uuid": "...",
    "name": "John Doe",
    "email": "test@example.com",
    "username": "testuser",
    "isActive": true,
    "createdAt": "..."
  }
}
```

**Expected Response (Validation Error):**
```json
{
  "success": false,
  "message": "Validation error",
  "errors": [
    {
      "field": "password",
      "message": "Password must contain at least one lowercase letter, one uppercase letter, and one number",
      "code": "invalid_string"
    }
  ]
}
```

---

## ✅ Checklist Debug

- [ ] Password memenuhi syarat (min 8, a-z, A-Z, 0-9)?
- [ ] Name hanya huruf dan spasi?
- [ ] Username min 3 karakter, hanya huruf/angka/underscore?
- [ ] Email format valid?
- [ ] Test dengan curl dari terminal berhasil?
- [ ] Tambahkan print() di Flutter untuk lihat error detail
- [ ] Gunakan validator di Flutter form
- [ ] Backend server running?
- [ ] Network connection OK?

---

## 📞 Quick Fix

Jika masih error, gunakan data test yang pasti valid:

```dart
// Hardcode test data dulu untuk memastikan masalahnya
await authService.register(
  name: 'Test User',        // Simple, pasti valid
  email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com', // Unique email
  username: 'testuser${DateTime.now().millisecondsSinceEpoch}',      // Unique username
  password: 'Password123',  // Pasti valid
);
```

Jika ini berhasil, berarti masalahnya ada di input user yang tidak memenuhi validation rules.

---

**Happy Debugging! 🐛🔧**
