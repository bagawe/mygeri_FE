/// Helper functions untuk generate username dan handle data
class RegisterHelper {
  /// Generate username dari email
  /// Contoh: john.doe@example.com → johndoe
  static String generateUsernameFromEmail(String email) {
    // Ambil bagian sebelum @
    final username = email.split('@')[0];
    
    // Remove dots, dashes, and special characters
    // Replace with underscore or remove
    final cleanUsername = username
        .replaceAll('.', '')
        .replaceAll('-', '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    
    // Ensure minimum 3 characters
    if (cleanUsername.length < 3) {
      return '${cleanUsername}_user';
    }
    
    // Ensure maximum 30 characters
    if (cleanUsername.length > 30) {
      return cleanUsername.substring(0, 30);
    }
    
    return cleanUsername.toLowerCase();
  }
  
  /// Generate username dari nama
  /// Contoh: John Doe → johndoe
  static String generateUsernameFromName(String name) {
    // Remove spaces and special characters
    final cleanName = name
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    
    // Ensure minimum 3 characters
    if (cleanName.length < 3) {
      return '${cleanName}_user';
    }
    
    // Ensure maximum 30 characters
    if (cleanName.length > 30) {
      return cleanName.substring(0, 30);
    }
    
    return cleanName;
  }
  
  /// Generate unique username dengan timestamp
  /// Contoh: johndoe1234567890
  static String generateUniqueUsername(String baseUsername) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final suffix = timestamp.substring(timestamp.length - 6); // Last 6 digits
    
    // Ensure total length <= 30
    if (baseUsername.length + suffix.length > 30) {
      final maxBaseLength = 30 - suffix.length;
      return '${baseUsername.substring(0, maxBaseLength)}$suffix';
    }
    
    return '$baseUsername$suffix';
  }
}
