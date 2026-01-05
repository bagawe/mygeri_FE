/// Validators untuk form registration
/// Sesuai dengan validation rules dari Backend API
class Validators {
  /// Validate password
  /// Rules:
  /// - Min 8 characters
  /// - Must contain lowercase (a-z)
  /// - Must contain uppercase (A-Z)
  /// - Must contain number (0-9)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password harus mengandung huruf kecil (a-z)';
    }
    
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password harus mengandung huruf besar (A-Z)';
    }
    
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password harus mengandung angka (0-9)';
    }
    
    return null;
  }
  
  /// Validate name
  /// Rules:
  /// - Min 1 character
  /// - Max 100 characters
  /// - Only letters and spaces
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama wajib diisi';
    }
    
    if (value.length > 100) {
      return 'Nama maksimal 100 karakter';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Nama hanya boleh huruf dan spasi';
    }
    
    return null;
  }
  
  /// Validate username
  /// Rules:
  /// - Min 3 characters
  /// - Max 30 characters
  /// - Only letters, numbers, and underscore
  /// - No spaces
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username wajib diisi';
    }
    
    if (value.length < 3) {
      return 'Username minimal 3 karakter';
    }
    
    if (value.length > 30) {
      return 'Username maksimal 30 karakter';
    }
    
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username hanya boleh huruf, angka, dan underscore';
    }
    
    return null;
  }
  
  /// Validate email
  /// Rules:
  /// - Valid email format
  /// - Max 255 characters
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    
    if (value.length > 255) {
      return 'Email maksimal 255 karakter';
    }
    
    // Regex untuk email format
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value)) {
      return 'Format email tidak valid';
    }
    
    return null;
  }
  
  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    
    if (value != password) {
      return 'Password tidak cocok';
    }
    
    return null;
  }
  
  /// Helper: Show password strength
  static String getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    
    int strength = 0;
    
    if (password.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'\d').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    
    if (strength <= 2) return 'Lemah';
    if (strength == 3) return 'Sedang';
    if (strength == 4) return 'Kuat';
    return 'Sangat Kuat';
  }
}
