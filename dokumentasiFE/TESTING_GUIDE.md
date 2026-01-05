# 🧪 Testing Guide - Update Profile & Change Password

## 📋 **Testing Priority**

### ✅ **Phase 1: CURRENT FOCUS** (Must Test Now)
1. 🔴 **Update Profile** - Test all 18+ fields with photo upload
2. 🔴 **Change Password** - Test validation, API integration, auto-logout

### ⏳ **Phase 2: NEXT** (After Phase 1 Complete)
3. 🟡 **Biometric Authentication** - Implement & test

---

## 🎯 **PHASE 1: Update Profile Testing**

### **Preparation**

#### 1. Start Backend Server
```bash
# Terminal 1 - Backend
cd /path/to/backend
npm start

# Should see: Server running on port 3030
```

#### 2. Start Flutter App
```bash
# Terminal 2 - Flutter
cd /Users/mac/development/mygeri
flutter run

# Or press F5 in VS Code
```

#### 3. Login with Test Users
**Test User 1 - Ahmad Yani:**
- Email: `ahmad@example.com`
- Password: `Password123!`

**Test User 2 - Rina Wati:**
- Email: `rina@example.com`
- Password: `Password123!`

---

### **Test Scenarios - Update Profile**

#### ✅ **Test Case 1: View Current Profile**
**Steps:**
1. Login dengan ahmad@example.com
2. Tap "Profil" di bottom navigation
3. Verify data ditampilkan

**Expected Result:**
- ✅ Nama: Ahmad Yani
- ✅ NIK visible
- ✅ Email: ahmad@example.com
- ✅ Phone: +6281234567890
- ✅ Profile photo (if uploaded before)
- ✅ All fields populated correctly

**Status:** [ ] PASS / [ ] FAIL

**Notes:**
```
______________________________________
______________________________________
```

---

#### ✅ **Test Case 2: Edit Basic Info**
**Steps:**
1. Dari Profile page, tap "Edit Profil"
2. Update fields:
   - Nama Lengkap: "Ahmad Yani Pratama"
   - Tempat Lahir: "Surabaya"
   - Tanggal Lahir: 15 Agustus 1990
3. Tap "Simpan"

**Expected Result:**
- ✅ Loading indicator shows
- ✅ Success message: "Profil berhasil diperbarui"
- ✅ Navigate back to profile page
- ✅ Updated data visible immediately
- ✅ Data persists after app restart

**Status:** [ ] PASS / [ ] FAIL

**Actual Result:**
```
______________________________________
______________________________________
```

---

#### ✅ **Test Case 3: Upload Profile Photo**
**Steps:**
1. Edit Profil
2. Tap profile photo circle
3. Choose "Kamera" atau "Galeri"
4. Select/take photo
5. Tap "Simpan"

**Expected Result:**
- ✅ Photo picker opens
- ✅ Selected photo shows in preview
- ✅ Photo uploads successfully
- ✅ New photo visible immediately
- ✅ Old photo deleted (backend)
- ✅ Photo persists after refresh

**Status:** [ ] PASS / [ ] FAIL

**Photo Info:**
- Size: ______ KB
- Format: ______ (jpg/png)
- Upload time: ______ seconds

---

#### ✅ **Test Case 4: Update Contact Info**
**Steps:**
1. Edit Profil
2. Update:
   - Phone: "+6281234567899" (change last digit)
   - Email: "ahmad.yani@example.com"
3. Tap "Simpan"

**Expected Result:**
- ✅ Success message
- ✅ Updated contact visible
- ✅ Can still login with new email

**Status:** [ ] PASS / [ ] FAIL

**Notes:**
```
______________________________________
______________________________________
```

---

#### ✅ **Test Case 5: Update Address**
**Steps:**
1. Edit Profil
2. Update:
   - Alamat: "Jl. Raya Darmo No. 123"
   - Kelurahan: "Darmo"
   - Kecamatan: "Wonokromo"
   - Kabupaten: "Surabaya"
   - Provinsi: "Jawa Timur"
   - Kode Pos: "60241"
3. Tap "Simpan"

**Expected Result:**
- ✅ All address fields saved
- ✅ Display correctly in profile
- ✅ No data loss

**Status:** [ ] PASS / [ ] FAIL

---

#### ✅ **Test Case 6: Update All Fields (Maximum Update)**
**Steps:**
1. Edit Profil
2. Update SEMUA fields yang bisa diubah:
   - Basic info
   - Contact info
   - Address
   - Photo
3. Tap "Simpan"

**Expected Result:**
- ✅ All updates saved successfully
- ✅ No field skipped
- ✅ No data corruption
- ✅ Performance acceptable (< 3 seconds)

**Status:** [ ] PASS / [ ] FAIL

**Performance:**
- Upload time: ______ seconds
- Total fields updated: ______

---

#### ❌ **Test Case 7: Validation - Invalid NIK**
**Steps:**
1. Edit Profil
2. Change NIK to: "123" (too short)
3. Tap "Simpan"

**Expected Result:**
- ✅ Client validation error: "NIK harus 16 digit"
- ✅ Cannot submit
- ✅ Error message clear

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 8: Validation - Invalid Email**
**Steps:**
1. Edit Profil
2. Change email to: "invalid-email"
3. Tap "Simpan"

**Expected Result:**
- ✅ Client validation error: "Format email tidak valid"
- ✅ Cannot submit

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 9: Validation - Invalid Phone**
**Steps:**
1. Edit Profil
2. Change phone to: "123" (too short)
3. Tap "Simpan"

**Expected Result:**
- ✅ Client validation error: "Nomor HP minimal 10 digit"
- ✅ Cannot submit

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 10: Network Error**
**Steps:**
1. Edit Profil
2. Update any field
3. **Turn OFF backend server**
4. Tap "Simpan"

**Expected Result:**
- ✅ Error message: "Gagal terhubung ke server"
- ✅ Data not lost (still in form)
- ✅ Can retry after server back online

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 11: Duplicate Email (Backend Validation)**
**Steps:**
1. Login as Ahmad
2. Edit Profil
3. Change email to: "rina@example.com" (Rina's email)
4. Tap "Simpan"

**Expected Result:**
- ✅ Backend error: "Email sudah digunakan"
- ✅ Error message displayed
- ✅ Form still editable

**Status:** [ ] PASS / [ ] FAIL

---

#### ⚡ **Test Case 12: Performance - Large Photo**
**Steps:**
1. Edit Profil
2. Upload photo > 5 MB
3. Tap "Simpan"

**Expected Result:**
- ✅ Photo compressed automatically
- ✅ Upload completes (< 10 seconds)
- ✅ No app freeze

**Status:** [ ] PASS / [ ] FAIL

**Photo Size:**
- Original: ______ MB
- After compress: ______ MB (if compressed)
- Upload time: ______ seconds

---

#### 🔄 **Test Case 13: Concurrent Edits (Ahmad & Rina)**
**Steps:**
1. **Device 1:** Login as Ahmad, edit profile
2. **Device 2:** Login as Ahmad on another device, edit same profile
3. **Device 1:** Tap "Simpan"
4. **Device 2:** Tap "Simpan"

**Expected Result:**
- ✅ Last save wins (normal behavior)
- ✅ No crash
- ✅ Data consistent

**Status:** [ ] PASS / [ ] FAIL

**Notes:**
```
______________________________________
______________________________________
```

---

#### 🔒 **Test Case 14: Security - Ahmad Cannot Edit Rina's Profile**
**Steps:**
1. Login as Ahmad
2. Navigate to Profile
3. **Manually inspect:** Check if there's any way to edit Rina's profile

**Expected Result:**
- ✅ Ahmad only sees his own profile
- ✅ No way to access Rina's profile
- ✅ Backend validates user from JWT token

**Status:** [ ] PASS / [ ] FAIL

**Security Check:**
- Can Ahmad see user_id in request? ______
- Can Ahmad modify request to change other user? ______

---

## 🔐 **PHASE 1: Change Password Testing**

### **Test Scenarios - Change Password**

#### ✅ **Test Case 15: View Change Password Page**
**Steps:**
1. Login as Ahmad
2. Tap "Pengaturan" (bottom nav)
3. Tap "Ubah Password"

**Expected Result:**
- ✅ Page title: "Ganti Password"
- ✅ Info banner visible: "Setelah password diganti, Anda akan logout otomatis..."
- ✅ 3 input fields visible:
  - Password Lama
  - Password Baru
  - Konfirmasi Password Baru
- ✅ All fields have show/hide toggle

**Status:** [ ] PASS / [ ] FAIL

---

#### ✅ **Test Case 16: Change Password Successfully**
**Steps:**
1. Ubah Password page
2. Input:
   - Password Lama: `Password123!`
   - Password Baru: `NewPassword456!`
   - Konfirmasi: `NewPassword456!`
3. Tap "Simpan"

**Expected Result:**
- ✅ Loading indicator shows
- ✅ Success message: "Password berhasil diganti! Silakan login kembali."
- ✅ Auto-logout (local tokens cleared)
- ✅ Redirect to Login page
- ✅ Can login with NEW password
- ✅ OLD password tidak bisa digunakan

**Status:** [ ] PASS / [ ] FAIL

**Verify:**
- Can login with new password? [ ] YES / [ ] NO
- Old password rejected? [ ] YES / [ ] NO

---

#### ❌ **Test Case 17: Wrong Old Password**
**Steps:**
1. Ubah Password page
2. Input:
   - Password Lama: `WrongPassword123!` (WRONG)
   - Password Baru: `NewPassword789!`
   - Konfirmasi: `NewPassword789!`
3. Tap "Simpan"

**Expected Result:**
- ✅ Error message: "Password lama yang Anda masukkan salah"
- ✅ Password TIDAK berubah
- ✅ Can still login with old password

**Status:** [ ] PASS / [ ] FAIL

**Verify:**
- Old password still works? [ ] YES / [ ] NO

---

#### ❌ **Test Case 18: Weak Password - Too Short**
**Steps:**
1. Ubah Password page
2. Input:
   - Password Lama: `Password123!`
   - Password Baru: `Pass1!` (only 6 chars)
   - Konfirmasi: `Pass1!`
3. Tap "Simpan"

**Expected Result:**
- ✅ Client validation error: "Password minimal 8 karakter"
- ✅ Cannot submit
- ✅ Button disabled or error shown

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 19: Weak Password - No Uppercase**
**Steps:**
1. Input new password: `password123!` (no uppercase)
2. Tap "Simpan"

**Expected Result:**
- ✅ Error: "Password harus ada huruf besar (A-Z)"

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 20: Weak Password - No Lowercase**
**Steps:**
1. Input new password: `PASSWORD123!` (no lowercase)
2. Tap "Simpan"

**Expected Result:**
- ✅ Error: "Password harus ada huruf kecil (a-z)"

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 21: Weak Password - No Number**
**Steps:**
1. Input new password: `PasswordABC!` (no number)
2. Tap "Simpan"

**Expected Result:**
- ✅ Error: "Password harus ada angka (0-9)"

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 22: Passwords Don't Match**
**Steps:**
1. Input:
   - Password Lama: `Password123!`
   - Password Baru: `NewPassword456!`
   - Konfirmasi: `Different789!` (DIFFERENT)
2. Tap "Simpan"

**Expected Result:**
- ✅ Error: "Password baru dan konfirmasi tidak cocok"
- ✅ Cannot submit

**Status:** [ ] PASS / [ ] FAIL

---

#### ❌ **Test Case 23: Same as Old Password**
**Steps:**
1. Input:
   - Password Lama: `Password123!`
   - Password Baru: `Password123!` (SAME)
   - Konfirmasi: `Password123!`
2. Tap "Simpan"

**Expected Result:**
- ✅ Backend error: "Password baru harus berbeda dengan password lama"
- ✅ Password not changed

**Status:** [ ] PASS / [ ] FAIL

---

#### ⚡ **Test Case 24: Show/Hide Password Toggle**
**Steps:**
1. Input any password in all 3 fields
2. Tap eye icon for each field

**Expected Result:**
- ✅ Password Lama toggle works
- ✅ Password Baru toggle works
- ✅ Konfirmasi toggle works
- ✅ Default state: obscured (hidden)
- ✅ After tap: visible

**Status:** [ ] PASS / [ ] FAIL

---

#### 🔒 **Test Case 25: Token Revocation - Multi-Device Logout**
**Steps:**
1. **Device 1 (iPhone):** Login as Ahmad
2. **Device 2 (iPad/Android):** Login as Ahmad
3. Both devices stay logged in
4. **Device 1:** Change password
5. Check **Device 2**

**Expected Result:**
- ✅ Device 1: Logout otomatis after password change
- ✅ Device 2: Next API call returns 401 (token expired)
- ✅ Device 2: Auto-redirect to login
- ✅ Must login with NEW password on both devices

**Status:** [ ] PASS / [ ] FAIL

**Notes:**
```
______________________________________
______________________________________
```

---

#### ❌ **Test Case 26: Network Error During Password Change**
**Steps:**
1. Input valid passwords
2. **Turn OFF backend**
3. Tap "Simpan"

**Expected Result:**
- ✅ Error message: "Gagal terhubung ke server" or similar
- ✅ Form data not lost
- ✅ Can retry after backend online

**Status:** [ ] PASS / [ ] FAIL

---

#### ⚡ **Test Case 27: Rapid Click Prevention**
**Steps:**
1. Input valid passwords
2. Tap "Simpan" button 5 times rapidly

**Expected Result:**
- ✅ Button disabled after first tap
- ✅ Loading indicator shows
- ✅ Only ONE API call made
- ✅ No duplicate requests

**Status:** [ ] PASS / [ ] FAIL

---

## 📊 **Test Results Summary**

### **Update Profile Test Results**

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC1: View Profile | ⬜ | |
| TC2: Edit Basic Info | ⬜ | |
| TC3: Upload Photo | ⬜ | |
| TC4: Update Contact | ⬜ | |
| TC5: Update Address | ⬜ | |
| TC6: Update All Fields | ⬜ | |
| TC7: Invalid NIK | ⬜ | |
| TC8: Invalid Email | ⬜ | |
| TC9: Invalid Phone | ⬜ | |
| TC10: Network Error | ⬜ | |
| TC11: Duplicate Email | ⬜ | |
| TC12: Large Photo | ⬜ | |
| TC13: Concurrent Edits | ⬜ | |
| TC14: Security Check | ⬜ | |

**Total:** 0/14 PASS

---

### **Change Password Test Results**

| Test Case | Status | Notes |
|-----------|--------|-------|
| TC15: View Page | ⬜ | |
| TC16: Change Success | ⬜ | |
| TC17: Wrong Old Password | ⬜ | |
| TC18: Too Short | ⬜ | |
| TC19: No Uppercase | ⬜ | |
| TC20: No Lowercase | ⬜ | |
| TC21: No Number | ⬜ | |
| TC22: Don't Match | ⬜ | |
| TC23: Same as Old | ⬜ | |
| TC24: Toggle Password | ⬜ | |
| TC25: Token Revocation | ⬜ | |
| TC26: Network Error | ⬜ | |
| TC27: Rapid Click | ⬜ | |

**Total:** 0/13 PASS

---

## 🐛 **Bug Report Template**

If you find a bug, document it here:

### Bug #1
**Test Case:** ______  
**Severity:** 🔴 Critical / 🟡 High / 🟢 Medium / ⚪ Low  
**Description:**
```
______________________________________
______________________________________
```

**Steps to Reproduce:**
1. ______
2. ______
3. ______

**Expected Result:**
```
______________________________________
```

**Actual Result:**
```
______________________________________
```

**Screenshots/Logs:**
```
______________________________________
```

**Status:** ⬜ Open / ⬜ In Progress / ⬜ Fixed / ⬜ Closed

---

### Bug #2
_(Copy template above)_

---

## ✅ **Testing Checklist**

### Before Starting Testing:
- [ ] Backend server running
- [ ] Flutter app compiled successfully
- [ ] Test users available (Ahmad & Rina)
- [ ] Internet connection stable
- [ ] Test devices ready (iOS Simulator/Physical device)

### During Testing:
- [ ] Document all test results
- [ ] Take screenshots of errors
- [ ] Save backend logs if error occurs
- [ ] Test on multiple screen sizes (if possible)
- [ ] Test on both iOS and Android (if possible)

### After Testing:
- [ ] Calculate pass rate: ____%
- [ ] List critical bugs (Priority 🔴)
- [ ] Report bugs to developer
- [ ] Re-test after bug fixes
- [ ] Sign-off when all tests pass

---

## 📱 **Test Environment**

**Tester:** ______________________  
**Date:** 24 Desember 2025  
**Duration:** ______ hours

**Backend:**
- URL: http://10.191.38.178:3030
- Status: ⬜ Running / ⬜ Stopped
- Version: ______

**Flutter App:**
- Version: ______
- Build: ______
- Device: ______ (iPhone 15 Pro / Android Pixel 8, etc.)
- OS Version: ______

**Network:**
- Type: ⬜ WiFi / ⬜ Mobile Data
- Speed: ______ Mbps

---

## 🎯 **Success Criteria**

### Phase 1 Complete When:
- ✅ All Update Profile tests: **≥95% PASS** (13/14)
- ✅ All Change Password tests: **≥95% PASS** (12/13)
- ✅ No critical bugs (🔴)
- ✅ No high-severity bugs (🟡) blocking production
- ✅ Performance acceptable (all operations < 5 seconds)

### Then Ready for:
- ✅ Phase 2: Biometric Authentication implementation
- ✅ Production deployment (if all pass)

---

## 📞 **Support**

If you encounter issues during testing:

1. **Check backend logs:**
   ```bash
   cd backend
   tail -f logs/app.log
   ```

2. **Check Flutter logs:**
   ```bash
   flutter logs
   ```

3. **Enable debug mode:**
   - Set `print()` statements visible in console
   - Check API service debug logs

4. **Contact developer** with:
   - Test case number
   - Screenshots
   - Backend logs
   - Flutter logs
   - Device info

---

**Testing Status:** 🟡 **IN PROGRESS**  
**Last Updated:** 24 Desember 2025  
**Next Review:** After Phase 1 testing complete
