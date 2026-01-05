# 🔐 Change Password - Status & Integration Plan

## 📊 Current Status

**Date:** 24 Desember 2025

| Component | Status | Progress |
|-----------|--------|----------|
| Frontend UI | ✅ Complete | 100% |
| Frontend Logic | ⏸️ Pending | 10% (Dummy) |
| Backend API | ❌ Not Started | 0% |
| Documentation | ✅ Complete | 100% |
| Testing | ⏸️ Pending | 0% |

**Overall Status:** 🚧 **BLOCKED - Waiting for Backend**

---

## 📱 Frontend Implementation

### Current File
**Location:** `/lib/pages/pengaturan/ganti_password_page.dart`

**What's Working:**
- ✅ Complete UI dengan 3 input fields
- ✅ Client-side validation
- ✅ Loading state
- ✅ Error handling UI

**What's NOT Working:**
- ❌ Backend integration (dummy implementation)
- ❌ Actual password change
- ❌ Real error messages from API

### Current Implementation
```dart
void _submit() {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    // TODO: Implementasi ganti password
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Berhasil'),
          content: const Text('Password berhasil diganti.'),
          // ...
        ),
      );
    });
  }
}
```

**Note:** Saat ini hanya menampilkan fake success setelah 2 detik. Tidak ada perubahan password yang sebenarnya.

---

## 🔧 What Backend Needs to Provide

### Required Endpoint
```
PUT /api/users/change-password
Authorization: Bearer <access_token>

Request Body:
{
  "oldPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}

Response (200 OK):
{
  "success": true,
  "message": "Password changed successfully"
}

Response (400 Bad Request):
{
  "success": false,
  "message": "Old password is incorrect"
}
```

**Full specification:** See `/dokumentasiBE/BACKEND_REQUEST_CHANGE_PASSWORD.md`

---

## 🚀 Integration Plan (After Backend Ready)

### Step 1: Create PasswordService

Create new file: `/lib/services/password_service.dart`

```dart
import 'api_service.dart';

class PasswordService {
  final ApiService _apiService;

  PasswordService(this._apiService);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      print('🔐 PasswordService: Changing password...');
      
      await _apiService.put('/users/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      });
      
      print('✅ PasswordService: Password changed successfully');
    } catch (e) {
      print('❌ PasswordService: Error changing password - $e');
      
      // Parse error message
      if (e is ApiException) {
        if (e.message.contains('incorrect')) {
          throw Exception('Password lama salah');
        } else if (e.message.contains('validation')) {
          throw Exception('Password baru tidak valid');
        }
      }
      
      rethrow;
    }
  }
}
```

---

### Step 2: Update ganti_password_page.dart

**Changes needed:**

```dart
import '../../services/password_service.dart';
import '../../services/api_service.dart';

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final PasswordService _passwordService;  // ADD THIS
  
  // Controllers...
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordService = PasswordService(ApiService());  // ADD THIS
  }

  Future<void> _submit() async {  // CHANGE TO ASYNC
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      // REPLACE dummy implementation with real API call
      await _passwordService.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diganti!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Go back to settings page
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // ...rest of the code stays the same
}
```

---

### Step 3: Enhanced Validation

Add password strength validator (optional but recommended):

```dart
// In _GantiPasswordPageState

String? _validateNewPassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password baru wajib diisi';
  }
  
  if (value.length < 8) {
    return 'Password minimal 8 karakter';
  }
  
  // Check for lowercase
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password harus ada huruf kecil (a-z)';
  }
  
  // Check for uppercase
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password harus ada huruf besar (A-Z)';
  }
  
  // Check for number
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password harus ada angka (0-9)';
  }
  
  return null;
}

// Then use it in the form:
TextFormField(
  controller: _newPasswordController,
  obscureText: true,
  decoration: const InputDecoration(
    labelText: 'Password Baru',
    helperText: 'Min 8 karakter: a-z, A-Z, 0-9',
  ),
  validator: _validateNewPassword,  // Use custom validator
),
```

---

### Step 4: Add Password Strength Indicator (Optional)

Show visual feedback of password strength:

```dart
Widget _buildPasswordStrengthIndicator(String password) {
  int strength = 0;
  
  if (password.length >= 8) strength++;
  if (RegExp(r'[a-z]').hasMatch(password)) strength++;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
  if (RegExp(r'\d').hasMatch(password)) strength++;
  
  Color color = strength < 2 ? Colors.red : 
                strength < 3 ? Colors.orange : 
                Colors.green;
  
  String text = strength < 2 ? 'Lemah' : 
                strength < 3 ? 'Sedang' : 
                'Kuat';
  
  return Row(
    children: [
      Expanded(
        child: LinearProgressIndicator(
          value: strength / 4,
          backgroundColor: Colors.grey[300],
          color: color,
        ),
      ),
      const SizedBox(width: 8),
      Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    ],
  );
}
```

---

## 🧪 Testing Plan

### Manual Testing Checklist

After backend implementation, test these scenarios:

- [ ] **Success Case**
  - Input valid old password
  - Input valid new password (8+ chars, a-z, A-Z, 0-9)
  - Confirm password matches
  - Click Simpan
  - ✅ Success message appears
  - ✅ Navigate back to settings
  - ✅ Can login with new password

- [ ] **Wrong Old Password**
  - Input invalid old password
  - Input valid new password
  - Click Simpan
  - ✅ Error message: "Password lama salah"
  - ✅ Password tidak berubah

- [ ] **Weak New Password**
  - Input valid old password
  - Input weak password (e.g., "weak")
  - ✅ Client validation shows error before submit
  - OR if submit → ✅ Backend returns validation error

- [ ] **Passwords Don't Match**
  - Input valid old password
  - Input valid new password
  - Input different confirm password
  - ✅ Client validation shows error
  - ✅ Cannot submit

- [ ] **Network Error**
  - Turn off backend or network
  - Try to change password
  - ✅ Error message shows network error
  - ✅ UI returns to normal state

---

## 📋 Files to Create/Modify

### New Files:
1. ✅ `/dokumentasiBE/BACKEND_REQUEST_CHANGE_PASSWORD.md` (Created)
2. ✅ `/dokumentasiFE/CHANGE_PASSWORD_STATUS.md` (This file)
3. ⏸️ `/lib/services/password_service.dart` (After BE ready)

### Files to Modify:
1. ⏸️ `/lib/pages/pengaturan/ganti_password_page.dart` (After BE ready)

---

## 🔗 Related Documentation

- **Backend Request:** [BACKEND_REQUEST_CHANGE_PASSWORD.md](../dokumentasiBE/BACKEND_REQUEST_CHANGE_PASSWORD.md)
- **API Service:** [/lib/services/api_service.dart](../lib/services/api_service.dart)
- **Validators:** [/lib/utils/validators.dart](../lib/utils/validators.dart)

---

## ⏱️ Timeline Estimate

| Task | Owner | Duration | Status |
|------|-------|----------|--------|
| Backend Endpoint | BE Team | 1-1.5 hours | ⏸️ Pending |
| Backend Testing | BE Team | 0.5 hour | ⏸️ Pending |
| Backend Docs | BE Team | 0.5 hour | ⏸️ Pending |
| Frontend Service | FE Team | 20 minutes | ⏸️ Pending |
| Frontend Integration | FE Team | 30 minutes | ⏸️ Pending |
| Frontend Testing | FE Team | 30 minutes | ⏸️ Pending |
| **Total** | - | **3-4 hours** | - |

---

## 📞 Next Actions

### For Backend Team:
1. ✅ Review `/dokumentasiBE/BACKEND_REQUEST_CHANGE_PASSWORD.md`
2. ⏸️ Implement `PUT /api/users/change-password` endpoint
3. ⏸️ Test endpoint with Postman
4. ⏸️ Create API documentation (CHANGE_PASSWORD_API.md)
5. ⏸️ Notify Frontend Team when ready

### For Frontend Team:
1. ✅ UI sudah siap (no action needed)
2. ✅ Documentation complete
3. ⏸️ Wait for backend notification
4. ⏸️ Create PasswordService
5. ⏸️ Integrate API to ganti_password_page.dart
6. ⏸️ Test end-to-end

---

## 🎯 Success Metrics

### Definition of Done:
- [ ] Backend endpoint implemented & tested
- [ ] Frontend integration complete
- [ ] User dapat change password dari aplikasi
- [ ] Validation errors ditampilkan dengan jelas
- [ ] Success/error messages user-friendly
- [ ] Manual testing passed (all scenarios)
- [ ] Documentation complete (BE & FE)

---

**Status:** 🚧 **WAITING FOR BACKEND**  
**Blocker:** Backend endpoint belum ada  
**ETA:** TBD (after backend starts implementation)  
**Last Updated:** 24 Desember 2025
