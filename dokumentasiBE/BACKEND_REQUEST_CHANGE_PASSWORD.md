# 🔐 REQUEST: Change Password API Implementation

## 📋 Overview

Frontend sudah memiliki UI untuk change password (`/lib/pages/pengaturan/ganti_password_page.dart`), namun **backend belum memiliki endpoint** untuk fitur ini. Dokumen ini menjelaskan requirement yang dibutuhkan untuk implementasi backend.

---

## 🎯 Requirement Summary

**Status:** 🚧 Backend belum ada (Frontend sudah ready)

**Frontend File:** `/lib/pages/pengaturan/ganti_password_page.dart`

**Yang Dibutuhkan:**
1. API endpoint untuk change password
2. Validasi old password
3. Validasi new password sesuai password policy
4. (Optional) Revoke all sessions setelah password changed

---

## 📱 Frontend UI yang Sudah Ada

Form yang sudah ada di Flutter memiliki 3 field:

```dart
class GantiPasswordPage {
  // Field 1: Password Lama
  final TextEditingController _oldPasswordController;
  
  // Field 2: Password Baru
  final TextEditingController _newPasswordController;
  
  // Field 3: Konfirmasi Password Baru
  final TextEditingController _confirmPasswordController;
}
```

**Flow Frontend:**
1. User input 3 field di atas
2. Frontend validasi:
   - Old password tidak boleh kosong
   - New password minimal 8 karakter
   - Confirm password harus sama dengan new password
3. Frontend kirim request ke backend (old password + new password)
4. Backend validasi dan update password
5. Frontend tampilkan success/error message

---

## 🔧 API Specification yang Dibutuhkan

### Endpoint Details

```
PUT /api/users/change-password
```

**Authentication:** Required (Bearer Token)

**Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "oldPassword": "OldPassword123",
  "newPassword": "NewPassword456"
}
```

**Notes:**
- Frontend sudah validasi `confirmPassword`, jadi tidak perlu dikirim ke backend
- Backend hanya perlu terima `oldPassword` dan `newPassword`

---

### Success Response

**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

---

### Error Responses

#### 1. Old Password Salah
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "Old password is incorrect"
}
```

#### 2. New Password Tidak Valid
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "Password must be at least 8 characters and contain uppercase, lowercase, and numbers",
  "errors": [
    {
      "field": "newPassword",
      "message": "Password must contain at least one uppercase letter"
    }
  ]
}
```

#### 3. New Password Sama dengan Old Password
**Status Code:** `400 Bad Request`

```json
{
  "success": false,
  "message": "New password must be different from old password"
}
```

#### 4. Unauthorized (Token Invalid/Expired)
**Status Code:** `401 Unauthorized`

```json
{
  "success": false,
  "message": "Unauthorized"
}
```

---

## ✅ Validation Rules

### 1. Old Password Validation
- ✅ **Required:** Harus diisi
- ✅ **Match:** Harus cocok dengan password saat ini di database (gunakan bcrypt.compare)

### 2. New Password Validation
- ✅ **Required:** Harus diisi
- ✅ **Min Length:** Minimal 8 karakter
- ✅ **Lowercase:** Harus ada minimal 1 huruf kecil (a-z)
- ✅ **Uppercase:** Harus ada minimal 1 huruf besar (A-Z)
- ✅ **Number:** Harus ada minimal 1 angka (0-9)
- ✅ **Different:** Tidak boleh sama dengan old password

**Regex untuk validasi new password:**
```javascript
const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;
```

**Contoh Password Valid:**
- ✅ `Password123`
- ✅ `MyNewPass2024`
- ✅ `Secure1234`

**Contoh Password Invalid:**
- ❌ `password` - Tidak ada huruf besar & angka
- ❌ `PASSWORD123` - Tidak ada huruf kecil
- ❌ `Password` - Tidak ada angka
- ❌ `Pass12` - Kurang dari 8 karakter

---

## 🔐 Security Considerations

### 1. Password Hashing
```javascript
// Hash new password dengan bcrypt
const hashedPassword = await bcrypt.hash(newPassword, 10);

// Update di database
await db.users.update({
  where: { id: userId },
  data: { password: hashedPassword }
});
```

### 2. Old Password Verification
```javascript
// Verify old password
const user = await db.users.findUnique({ where: { id: userId } });
const isOldPasswordValid = await bcrypt.compare(oldPassword, user.password);

if (!isOldPasswordValid) {
  throw new Error('Old password is incorrect');
}
```

### 3. Optional: Revoke All Sessions
Untuk keamanan ekstra, setelah password berhasil diubah, revoke semua refresh tokens:

```javascript
// Revoke all refresh tokens
await db.refreshTokens.updateMany({
  where: { userId: userId },
  data: { isRevoked: true }
});
```

**Note:** Jika implement ini, user harus login ulang setelah change password.

---

## 🗄️ Database Changes

Tidak ada perubahan database yang diperlukan. Gunakan field `password` yang sudah ada di tabel `users`.

```sql
-- Tidak ada migration baru diperlukan
-- Field password sudah ada di tabel users
```

---

## 🧪 Testing Scenarios

### Test Case 1: Success - Change Password
**Input:**
```json
{
  "oldPassword": "OldPass123",
  "newPassword": "NewPass456"
}
```

**Expected:**
- Status: 200 OK
- Password di database terupdate
- Message: "Password changed successfully"

---

### Test Case 2: Error - Wrong Old Password
**Input:**
```json
{
  "oldPassword": "WrongPassword123",
  "newPassword": "NewPass456"
}
```

**Expected:**
- Status: 400 Bad Request
- Message: "Old password is incorrect"
- Password tidak berubah

---

### Test Case 3: Error - Weak New Password
**Input:**
```json
{
  "oldPassword": "OldPass123",
  "newPassword": "weak"
}
```

**Expected:**
- Status: 400 Bad Request
- Message: Validation error
- Password tidak berubah

---

### Test Case 4: Error - Same Password
**Input:**
```json
{
  "oldPassword": "OldPass123",
  "newPassword": "OldPass123"
}
```

**Expected:**
- Status: 400 Bad Request
- Message: "New password must be different from old password"
- Password tidak berubah

---

### Test Case 5: Error - Unauthorized
**Input:**
```
Authorization: Bearer invalid_token
```

**Expected:**
- Status: 401 Unauthorized
- Message: "Unauthorized"

---

## 📝 Implementation Checklist

### Backend Tasks

- [ ] **Create Route**
  ```javascript
  router.put('/users/change-password', authenticate, changePasswordController);
  ```

- [ ] **Create Controller** (`/controllers/userController.js`)
  ```javascript
  export const changePassword = async (req, res) => {
    // 1. Get oldPassword, newPassword from req.body
    // 2. Get userId from req.user (dari JWT)
    // 3. Verify old password dengan bcrypt.compare
    // 4. Validate new password (regex)
    // 5. Check new password != old password
    // 6. Hash new password
    // 7. Update database
    // 8. (Optional) Revoke all refresh tokens
    // 9. Return success response
  };
  ```

- [ ] **Add Validation** (Zod/Joi schema)
  ```javascript
  const changePasswordSchema = z.object({
    oldPassword: z.string().min(1, "Old password is required"),
    newPassword: z.string()
      .min(8, "Password must be at least 8 characters")
      .regex(/[a-z]/, "Password must contain lowercase letter")
      .regex(/[A-Z]/, "Password must contain uppercase letter")
      .regex(/\d/, "Password must contain number")
  });
  ```

- [ ] **Add Tests** (Unit & Integration tests)
  - Test success case
  - Test wrong old password
  - Test weak new password
  - Test same password
  - Test unauthorized

- [ ] **Update API Documentation**
  - Add endpoint ke API docs
  - Add request/response examples
  - Add validation rules

---

## 📚 Documentation Files to Create

### 1. `CHANGE_PASSWORD_API.md`
Dokumentasi lengkap API untuk Flutter team (format seperti FLUTTER_EDIT_PROFILE_API.md)

**Content:**
- Endpoint details
- Request/response examples
- Flutter implementation code
- Error handling
- Testing guide

### 2. `TESTING_CHANGE_PASSWORD.md`
Manual testing guide dengan Postman/curl

**Content:**
- Step-by-step testing
- Test data examples
- Expected responses
- Troubleshooting

---

## 🚀 Flutter Implementation (Ready After BE Complete)

Setelah backend selesai, Flutter akan implementasi seperti ini:

```dart
// 1. Create service
class PasswordService {
  Future<void> changePassword(String oldPassword, String newPassword) async {
    final response = await apiService.put(
      '/users/change-password',
      {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
    // Handle response
  }
}

// 2. Update ganti_password_page.dart
Future<void> _submit() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true);
    
    try {
      final passwordService = PasswordService(ApiService());
      
      await passwordService.changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password berhasil diganti!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

---

## 📊 Priority & Timeline

**Priority:** 🟡 Medium

**Estimated Effort:** 2-3 hours

**Breakdown:**
- Backend endpoint implementation: 1-1.5 hours
- Testing: 0.5 hour
- Documentation: 0.5 hour
- Code review: 0.5 hour

**Dependencies:**
- ✅ User authentication (sudah ada)
- ✅ JWT middleware (sudah ada)
- ✅ User model (sudah ada)

**After Implementation:**
- Frontend integration: 30 minutes
- End-to-end testing: 30 minutes

---

## 🔗 Related Features

**Already Implemented:**
- ✅ Login/Register
- ✅ JWT Authentication
- ✅ Token Refresh
- ✅ Edit Profile

**To Be Implemented:**
- 🚧 Change Password (this feature)
- 📋 Forgot Password (future)
- 📋 Email Verification (future)

---

## 📞 Questions & Support

**Frontend Contact:** Flutter Team  
**Backend Contact:** Backend Team  
**Document Created:** 24 Desember 2025  
**Last Updated:** 24 Desember 2025

---

## 🎯 Summary

### What Frontend Has:
✅ Complete UI with 3 input fields  
✅ Client-side validation  
✅ Ready for API integration  

### What Backend Needs to Build:
❌ PUT `/api/users/change-password` endpoint  
❌ Old password verification  
❌ New password validation  
❌ Password hashing & update  
❌ API documentation  

### Success Criteria:
- [ ] User dapat mengubah password dari aplikasi
- [ ] Old password diverifikasi dengan benar
- [ ] New password mengikuti password policy
- [ ] Error messages yang jelas dan helpful
- [ ] Session handling (optional revoke)

---

**Status:** 🚧 **WAITING FOR BACKEND IMPLEMENTATION**

**Next Steps:**
1. Backend Team review dokumen ini
2. Backend Team implement endpoint
3. Backend Team create API documentation
4. Frontend Team integrate API
5. QA testing end-to-end
