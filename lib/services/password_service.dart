import 'api_service.dart';

class PasswordService {
  final ApiService _apiService;

  PasswordService(this._apiService);

  /// Change user password
  /// 
  /// Throws [Exception] if:
  /// - Old password is incorrect
  /// - New password doesn't meet requirements
  /// - Network error occurs
  /// 
  /// After successful password change, all refresh tokens are revoked.
  /// User must login again.
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 PasswordService: Changing password...');
      
      await _apiService.put('/api/users/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }, requiresAuth: true);
      
      print('✅ PasswordService: Password changed successfully');
      print('⚠️ Note: All refresh tokens revoked - user must login again');
    } catch (e) {
      print('❌ PasswordService: Error changing password - $e');
      
      // Parse and throw user-friendly error messages
      if (e is ApiException) {
        final message = e.message.toLowerCase();
        
        if (message.contains('incorrect') || message.contains('wrong')) {
          throw Exception('Password lama yang Anda masukkan salah');
        } else if (message.contains('validation')) {
          // Extract validation errors if available
          if (e.errors != null && e.errors!.isNotEmpty) {
            List<String> errorMessages = [];
            for (var error in e.errors!) {
              if (error is Map && error.containsKey('message')) {
                final msg = error['message'].toString();
                // Translate to Indonesian
                if (msg.contains('uppercase')) {
                  errorMessages.add('Password harus mengandung huruf besar (A-Z)');
                } else if (msg.contains('lowercase')) {
                  errorMessages.add('Password harus mengandung huruf kecil (a-z)');
                } else if (msg.contains('number')) {
                  errorMessages.add('Password harus mengandung angka (0-9)');
                } else if (msg.contains('8 characters')) {
                  errorMessages.add('Password minimal 8 karakter');
                } else {
                  errorMessages.add(msg);
                }
              }
            }
            if (errorMessages.isNotEmpty) {
              throw Exception(errorMessages.join('\n'));
            }
          }
          throw Exception('Password baru tidak memenuhi persyaratan keamanan');
        } else if (message.contains('same') || message.contains('different')) {
          throw Exception('Password baru harus berbeda dengan password lama');
        }
      }
      
      rethrow;
    }
  }
}
