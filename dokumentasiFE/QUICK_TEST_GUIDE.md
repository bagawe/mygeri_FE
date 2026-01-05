# 🚀 QUICK START - Testing Mention Notification

## ⚡ TESTING DALAM 5 MENIT

### Prerequisites:
- ✅ Backend running di branch `heri01`
- ✅ Frontend sudah di-build
- ✅ 2 akun test (userA & userB)

---

## 📱 TEST STEPS

### 1️⃣ **Buat Postingan dengan Mention** (30 detik)
```
User: userA
Action: Create Post
Content: "Hello @userB, lihat ini!"
Submit: ✅
```

### 2️⃣ **Cek Riwayat** (30 detik)
```
User: userB
Action: Buka halaman Riwayat (tab ke-5)
Expected: 
  ✅ Icon @ warna orange
  ✅ Text: "Anda di-tag dalam postingan"
  ✅ Hint: "Ketuk untuk melihat postingan" (biru)
  ✅ Chevron right (→)
```

### 3️⃣ **Tap Notifikasi** (30 detik)
```
User: userB
Action: Tap pada notifikasi mention
Expected:
  ✅ Loading muncul
  ✅ Navigate ke PostDetailPage
  ✅ Tampil post dari userA dengan mention @userB
```

### 4️⃣ **Test Error Handling** (1 menit)
```
Setup: Hapus post dari userA
User: userB
Action: Tap notifikasi yang sama
Expected:
  ✅ Loading muncul
  ✅ SnackBar error: "Gagal memuat postingan..."
  ✅ App tidak crash
  ✅ Tetap di halaman Riwayat
```

### 5️⃣ **Test Non-Clickable History** (30 detik)
```
User: userB
Action: Cek history type "login"
Expected:
  ✅ Tidak ada chevron right
  ✅ Tidak ada hint text biru
  ✅ Tap tidak ada efek (onTap = null)
```

---

## ✅ SUCCESS CRITERIA

Semua test PASS jika:
- [x] Mention notification muncul
- [x] Visual indicators benar (icon, chevron, hint)
- [x] Navigation ke post detail berhasil
- [x] Error handling tidak crash
- [x] Non-clickable history benar

---

## 🐛 TROUBLESHOOTING

### Issue: Notifikasi tidak muncul
**Check:**
```dart
// Console log backend saat create post:
✅ "Mention detected: @userB"
✅ "History created for user ID: 123"

// Console log frontend saat get history:
✅ "📜 HistoryService: Getting history..."
✅ "✅ HistoryService: 5 history items retrieved"
```

### Issue: Tap tidak berfungsi
**Check:**
```dart
// Debug di RiwayatPage:
print('Is clickable: ${h.isClickable}'); // harus true
print('Post ID: ${h.postId}'); // harus ada angka, bukan null
print('Type: ${h.type}'); // harus 'mention'
```

### Issue: Post tidak ditemukan
**Check:**
```dart
// Console log:
❌ "PostService: Error getting post detail - 404"

// Solution: Normal behavior, post mungkin sudah dihapus
// Error handling harus menampilkan SnackBar
```

---

## 📊 EXPECTED CONSOLE OUTPUT

### Saat User B buka Riwayat:
```
🔵 LoginPage: didChangeDependencies called
📜 HistoryService: Getting history (page: 1, limit: 50)...
✅ HistoryService: 5 history items retrieved
```

### Saat User B tap notifikasi mention:
```
🔍 PostService: Getting post detail for ID: 123
✅ PostService: Post detail retrieved
Navigating to PostDetailPage...
```

### Saat post tidak ditemukan:
```
🔍 PostService: Getting post detail for ID: 123
❌ PostService: Error getting post detail - 404
SnackBar shown: Gagal memuat postingan...
```

---

## 🎯 QUICK COMMANDS

### Run Flutter:
```bash
flutter run
```

### Check Backend:
```bash
curl http://103.127.138.40:3030/api/history \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Debug Mode:
```bash
flutter run -v  # verbose logging
```

### Hot Reload:
```
Press 'r' in terminal untuk reload
Press 'R' untuk full restart
```

---

## 📞 QUICK HELP

**Console tidak ada log?**
→ Restart app dengan 'R'

**Backend error?**
→ Check server status: `curl http://103.127.138.40:3030/health`

**Frontend error?**
→ Check `flutter doctor`

---

**Happy Testing! 🎉**

**Time to Test:** ~5 minutes  
**Expected Result:** ✅ ALL PASS
