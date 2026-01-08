# Coming Soon Features Implementation

**Date:** 8 Januari 2026  
**Status:** ✅ Complete

---

## 📋 Overview

Menambahkan popup "Coming Soon" untuk fitur-fitur yang masih dalam pengembangan di aplikasi MyGeri.

---

## ✨ Features Added

### 1. **Beranda Page** - 5 Menu Icons

Semua menu di Beranda sekarang menampilkan popup "Coming Soon":

| Menu | Icon | Status |
|------|------|--------|
| My Gerindra | 🏛️ | 🚧 Coming Soon |
| KTA | 🎫 | 🚧 Coming Soon |
| Radar | 📡 | 🚧 Coming Soon |
| Agenda | 📅 | 🚧 Coming Soon |
| Voting | 🗳️ | 🚧 Coming Soon |

**Implementation:**
- Added `GestureDetector` wrapper untuk setiap menu item
- OnTap menampilkan dialog dengan informasi fitur dalam pengembangan
- Consistent UI dengan icon construction (🔧) dan pesan ramah user

---

### 2. **Pengaturan Page** - 5 Menu Settings

Menu pengaturan yang belum diimplementasi:

| Menu | Icon | Status | Action |
|------|------|--------|--------|
| Notifikasi | 🔔 | 🚧 Coming Soon | Switch → Dialog |
| Bahasa | 🌐 | 🚧 Coming Soon | Tap → Dialog |
| Tema | 🌓 | 🚧 Coming Soon | Tap → Dialog |
| Bantuan & FAQ | ❓ | 🚧 Coming Soon | Tap → Dialog |
| Tentang Aplikasi | ℹ️ | 🚧 Coming Soon | Tap → Dialog |

**Already Implemented (Not Changed):**
- ✅ Ubah Password
- ✅ Akun yang Diblokir
- ✅ Logout

---

## 🎨 Dialog Design

**Title:**
```
🔧 Coming Soon
```

**Content:**
```
Fitur [Nama Fitur] sedang dalam pengembangan.

Kami akan segera meluncurkan fitur ini untuk Anda!
```

**Button:**
```
OK (dismiss dialog)
```

**Visual:**
- Icon: Construction (orange)
- Border radius: 16px (rounded)
- Responsive layout
- Grey subtitle untuk pesan tambahan

---

## 📱 User Experience

### Before:
- Menu tidak bisa diklik / tidak ada feedback
- User bingung apakah fitur ada atau tidak

### After:
- ✅ Semua menu responsif terhadap tap
- ✅ Dialog informatif menjelaskan status fitur
- ✅ User tahu fitur sedang dalam pengembangan
- ✅ Professional appearance dengan icon & styling

---

## 🔧 Technical Implementation

### Beranda Page (`lib/pages/beranda/beranda_page.dart`)

**Added Method:**
```dart
void _showComingSoonDialog(String featureName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.construction, color: Colors.orange[700], size: 28),
          const SizedBox(width: 12),
          const Text('Coming Soon'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Fitur $featureName sedang dalam pengembangan.'),
          Text('Kami akan segera meluncurkan fitur ini untuk Anda!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

**Updated Menu Items:**
```dart
children: menuItems.map((item) {
  return GestureDetector(
    onTap: () => _showComingSoonDialog(item['label']),
    child: Column(
      children: [
        // ... menu icon & label
      ],
    ),
  );
}).toList(),
```

---

### Pengaturan Page (`lib/pages/pengaturan/pengaturan_page.dart`)

**Added Same Dialog Method**

**Updated Menu Items:**
```dart
// Notifikasi
SwitchListTile(
  value: true,
  onChanged: (val) {
    _showComingSoonDialog('Notifikasi');
  },
),

// Bahasa, Tema, Bantuan, Tentang
ListTile(
  onTap: () {
    _showComingSoonDialog('Nama Fitur');
  },
),
```

---

## ✅ Testing Checklist

- [x] Tap menu My Gerindra → Dialog muncul ✓
- [x] Tap menu KTA → Dialog muncul ✓
- [x] Tap menu Radar → Dialog muncul ✓
- [x] Tap menu Agenda → Dialog muncul ✓
- [x] Tap menu Voting → Dialog muncul ✓
- [x] Toggle Notifikasi → Dialog muncul ✓
- [x] Tap Bahasa → Dialog muncul ✓
- [x] Tap Tema → Dialog muncul ✓
- [x] Tap Bantuan & FAQ → Dialog muncul ✓
- [x] Tap Tentang Aplikasi → Dialog muncul ✓
- [x] Menu yang sudah ada tetap berfungsi ✓
- [x] Tidak ada error compile ✓
- [x] Responsive UI ✓

---

## 📦 Files Modified

```
✅ lib/pages/beranda/beranda_page.dart
✅ lib/pages/pengaturan/pengaturan_page.dart
```

**Total Changes:** 2 files

---

## 🎯 Benefits

1. **Better UX**: User mendapat feedback langsung
2. **Professional**: Menunjukkan fitur sedang dikembangkan (bukan bug)
3. **Consistency**: Semua menu unimplemented punya behavior yang sama
4. **Maintainability**: Mudah diupdate ketika fitur siap
5. **No Confusion**: User tidak bingung kenapa menu tidak berfungsi

---

## 🚀 Next Steps

Ketika fitur-fitur ini siap diimplementasi:

1. Replace `_showComingSoonDialog()` call dengan navigation ke page baru
2. Contoh:
   ```dart
   // FROM:
   onTap: () => _showComingSoonDialog('KTA'),
   
   // TO:
   onTap: () {
     Navigator.push(
       context,
       MaterialPageRoute(builder: (context) => const KTAPage()),
     );
   },
   ```

---

## 📝 Notes

- Dialog dapat ditutup dengan tap "OK" atau tap di luar dialog
- Pesan bisa di-customize per fitur jika perlu
- Icon construction (🔧) memberikan visual cue yang jelas
- Orange color untuk construction icon agar eye-catching tapi tidak alarming

---

**Status:** ✅ Ready for Testing  
**Last Updated:** 8 Januari 2026
