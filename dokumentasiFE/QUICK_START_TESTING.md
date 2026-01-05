# 🚀 Quick Start - Testing Update Profile & Change Password

## ⚡ **QUICK SETUP (5 Minutes)**

### 1. Start Backend
```bash
cd /path/to/backend
npm start
```
✅ Wait for: `Server running on port 3030`

### 2. Start Flutter App
```bash
cd /Users/mac/development/mygeri
flutter run
```
Or press **F5** in VS Code

### 3. Login
**Test User:**
- Email: `ahmad@example.com`
- Password: `Password123!`

---

## 📝 **TESTING CHECKLIST**

### ✅ **Phase 1: Update Profile** (Priority 🔴)

Quick test flow:
1. [ ] Login → Tap "Profil"
2. [ ] Tap "Edit Profil"
3. [ ] Change name to: "Ahmad Yani Pratama"
4. [ ] Upload new photo
5. [ ] Tap "Simpan"
6. [ ] ✅ Success? Profile updated?
7. [ ] ✅ Photo visible?
8. [ ] Restart app → ✅ Data persists?

**Full testing:** See `/dokumentasiFE/TESTING_GUIDE.md` Test Cases 1-14

---

### ✅ **Phase 2: Change Password** (Priority 🔴)

Quick test flow:
1. [ ] Tap "Pengaturan" → "Ubah Password"
2. [ ] Input:
   - Old: `Password123!`
   - New: `NewPassword456!`
   - Confirm: `NewPassword456!`
3. [ ] Tap "Simpan"
4. [ ] ✅ Auto-logout?
5. [ ] ✅ Redirect to login?
6. [ ] Login with NEW password → ✅ Success?
7. [ ] Try OLD password → ✅ Rejected?

**Full testing:** See `/dokumentasiFE/TESTING_GUIDE.md` Test Cases 15-27

---

## 🐛 **Found a Bug?**

Document immediately in `/dokumentasiFE/TESTING_GUIDE.md` → Bug Report section

Include:
- Test case number
- Steps to reproduce
- Expected vs Actual result
- Screenshot/logs

---

## ⏳ **Next: Biometric Auth**

**After** Update Profile & Change Password **100% working**:
→ See `/dokumentasiFE/BIOMETRIC_AUTH_PLAN.md` for implementation

---

## 📊 **Testing Progress**

- [ ] Update Profile: 0/14 tests complete
- [ ] Change Password: 0/13 tests complete
- [ ] Biometric Auth: Not started (waiting)

**Target:** ≥95% pass rate before Phase 2

---

## 📚 **Documentation Index**

1. **TESTING_GUIDE.md** ← Start here for detailed testing
2. **BIOMETRIC_AUTH_PLAN.md** ← Read for next phase
3. **SECURITY_ANALYSIS.md** ← Security overview
4. **CHANGE_PASSWORD_COMPLETE.md** ← Change password implementation
5. **dokumentasiBE/** ← Backend API docs

---

**Last Updated:** 24 Desember 2025  
**Status:** 🟡 Ready for testing  
**Next Action:** Start testing with TESTING_GUIDE.md
