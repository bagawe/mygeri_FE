# 🔧 Testing Troubleshooting Guide

## Error yang Sudah Diperbaiki

### ✅ 1. Connection Refused (SOLVED)

**Error:**
```
Exception: Network error: ClientException with SocketException: 
Connection refused (OS Error: Connection refused, errno = 111), 
address = localhost, port = 38202, uri=http://localhost:3030/api/auth/register
```

**Root Cause:**
- iOS Simulator tidak bisa connect ke `localhost`
- `localhost` di simulator mengarah ke simulator itu sendiri, bukan ke host Mac

**Solution:**
- ✅ Ganti `localhost` dengan IP Mac: `10.191.38.178`
- ✅ Update `lib/services/api_service.dart`:
  ```dart
  static const String baseUrl = 'http://10.191.38.178:3030';
  ```

**File Changed:**
- `lib/services/api_service.dart` - Line 7

---

### ✅ 2. Validation Error - Better Error Display (SOLVED)

**Error:**
```
Pendaftaran gagal: Exception: Registration failed: validation error
```

**Improvements Made:**

#### A. Enhanced Error Handling in ApiService
**File:** `lib/services/api_service.dart`

**Changes:**
1. Added `errors` field to `ApiException`:
   ```dart
   class ApiException implements Exception {
     final int statusCode;
     final String message;
     final dynamic errors;  // NEW!
   }
   ```

2. Pass errors from backend response:
   ```dart
   throw ApiException(
     statusCode: response.statusCode,
     message: data['message'] ?? 'Unknown error',
     errors: data['errors'],  // NEW!
   );
   ```

3. Added debug logging:
   ```dart
   print('Response status: ${response.statusCode}');
   print('Response body: ${response.body}');
   ```

#### B. Enhanced Error Handling in AuthService
**File:** `lib/services/auth_service.dart`

**Changes:**
1. Handle `ApiException` separately
2. Format validation errors for better readability:
   ```dart
   on ApiException catch (e) {
     final errors = e.errors;
     if (errors != null && errors is List && errors.isNotEmpty) {
       final errorMessages = errors.map((e) => 
         '• ${e['msg'] ?? e['message'] ?? e}'
       ).join('\n');
       throw Exception('$message:\n$errorMessages');
     }
   }
   ```

#### C. Better Error Display in UI
**File:** `lib/pages/register/register_simpatisan_page.dart`

**Changes:**
1. Changed from SnackBar to AlertDialog for better visibility
2. Clean up error message:
   ```dart
   String errorMessage = e.toString();
   errorMessage = errorMessage.replaceFirst('Exception: Registration failed: ', '');
   errorMessage = errorMessage.replaceFirst('Exception: ', '');
   ```

3. Show in scrollable dialog:
   ```dart
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
   ```

4. Added debug logging:
   ```dart
   print('Registration data: ${request.toJson()}');
   ```

---

## 📋 How to Test After Fix

### 1. Hot Restart App
Press `R` (capital R) in Flutter terminal or:
```bash
flutter run
```

### 2. Try Register Again
- Navigate to Register Simpatisan
- Fill in the form
- Submit

### 3. Check Debug Output
In terminal, you'll see:
```
Registration data: {name: ..., email: ..., username: ..., password: ...}
Response status: 400
Response body: {"success": false, "message": "Validation error", "errors": [...]}
```

### 4. Check Error Dialog
- If validation fails, you'll see a dialog with detailed errors
- Each validation error will be on a new line with bullet point

---

## 🐛 Common Validation Errors & Solutions

### Backend Validation Rules:
```
name:     Required, min 2 characters
email:    Required, valid email format
username: Required, min 3 characters, alphanumeric + underscore
password: Required, min 8 characters
```

### Example Errors & Fixes:

#### ❌ "Email is required"
**Fix:** Make sure email field is not empty

#### ❌ "Email must be a valid email"
**Fix:** Use proper email format (example@domain.com)

#### ❌ "Username must be at least 3 characters long"
**Fix:** Username minimum 3 characters

#### ❌ "Password must be at least 8 characters long"
**Fix:** Password minimum 8 characters

#### ❌ "Email already exists"
**Fix:** Use different email address

#### ❌ "Username already exists"
**Fix:** Use different username

---

## 🔍 Debug Checklist

### Before Testing:
- [ ] Backend server running on port 3030
- [ ] Base URL in api_service.dart = `http://10.191.38.178:3030`
- [ ] Mac and simulator on same network (if using physical device)

### During Testing:
- [ ] Check Flutter terminal for debug logs
- [ ] Check backend terminal for incoming requests
- [ ] Read error dialog carefully

### If Still Having Issues:

1. **Check Backend Logs:**
   ```bash
   # In backend terminal, look for incoming POST requests
   POST /api/auth/register
   ```

2. **Check Network:**
   ```bash
   # Test if backend is accessible
   curl http://10.191.38.178:3030/api/health
   ```

3. **Verify Data Format:**
   - Check debug log: "Registration data: {...}"
   - Make sure all required fields are present
   - Make sure values meet validation rules

---

## 📊 Testing Progress

### ✅ Fixed:
- [x] Connection refused error (localhost → IP)
- [x] Better error display (SnackBar → Dialog)
- [x] Validation error details (bullet points)
- [x] Debug logging (request & response)

### 🧪 Ready to Test:
- [ ] Register Simpatisan - Full validation check
- [ ] Register Kader Lama - With photo upload
- [ ] Register Kader Baru - Complex form
- [ ] Login - After successful registration
- [ ] Auto-login - Close & reopen app
- [ ] Logout - Clear session
- [ ] Token auto-refresh - Wait for expiry

---

## 💡 Tips for Successful Testing

1. **Use Valid Test Data:**
   ```
   Name:     Test User
   Email:    test123@example.com
   Username: testuser123
   Password: Test1234
   ```

2. **Check Backend First:**
   - Make sure backend is running
   - Check backend can handle requests
   - Verify database is connected

3. **Read Error Messages:**
   - New error dialog shows detailed validation errors
   - Each error is clear and actionable
   - Fix errors one by one

4. **Hot Restart When Needed:**
   - After changing base URL
   - After updating error handling
   - Press `R` in Flutter terminal

---

**Last Updated:** December 24, 2025
**Status:** Ready for comprehensive testing! 🚀
