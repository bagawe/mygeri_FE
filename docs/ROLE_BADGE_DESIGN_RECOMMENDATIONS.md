# Role Badge Display - Saran Desain & Implementasi

**Date:** April 16, 2026  
**Status:** ✅ Recommended Design  

---

## 🎯 Rekomendasi Tampilan Role

### ❌ TIDAK - Popup Verifikasi (sekarang)
Setiap kali user login/masuk → popup "Selamat akun anda telah diverifikasi"
- **Problem:** Mengganggu UX, repetitif
- **Solution:** Ganti dengan badge visual di beranda

---

## ✅ YA - 5 Opsi Tampilan Cantik

### **Opsi 1: Role Badge di Header (RECOMMENDED) ⭐**
```
┌─────────────────────────────────┐
│  👤 Nama User      [🟦 KADER]   │  ← Badge di top-right
│  @username                      │
└─────────────────────────────────┘
```

**Keuntungan:**
- ✅ Paling visible
- ✅ Selalu terlihat di beranda
- ✅ Elegant & minimalist
- ✅ Tidak mengganggu content

**Implementasi:**
```dart
// Di header section
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: _userRole == 'kader' ? Colors.blue : Colors.grey,
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        _userRole == 'kader' ? Icons.verified : Icons.person,
        color: Colors.white,
        size: 14,
      ),
      SizedBox(width: 4),
      Text(
        _userRole.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ],
  ),
)
```

---

### **Opsi 2: Role Tag di Card Profile**
```
┌─────────────────────────────────┐
│  Profile Summary Card           │
│                                 │
│  👤 Nama User                   │
│  📍 Daerah Kabupaten            │
│                                 │
│  Status: 🟦 KADER ✓             │
│                                 │
└─────────────────────────────────┘
```

**Keuntungan:**
- ✅ Integrated dalam profile card
- ✅ Clear visual hierarchy
- ✅ Info terpusat

**Implementasi:**
```dart
// Di profile card section
Row(
  children: [
    Text('Status: ', style: TextStyle(fontWeight: FontWeight.w500)),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _userRole == 'kader' ? Colors.blue[50] : Colors.grey[100],
        border: Border.all(
          color: _userRole == 'kader' ? Colors.blue : Colors.grey,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _userRole == 'kader' ? Icons.verified : Icons.person,
            color: _userRole == 'kader' ? Colors.blue : Colors.grey,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            _userRole == 'kader' ? 'KADER ✓' : 'SIMPATISAN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _userRole == 'kader' ? Colors.blue : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ],
)
```

---

### **Opsi 3: Role Indicator dengan Warna Background**
```
┌─────────────────────────────────┐
│ 🟦 KADER                        │ ← Warna indicator atas
│                                 │
│  👤 Nama User                   │
│  Welcome back!                  │
│                                 │
└─────────────────────────────────┘
```

**Keuntungan:**
- ✅ Warna indicator mendalam (visual weight)
- ✅ Instantly recognizable
- ✅ Modern look

**Warna Scheme:**
```dart
// Kader: Blue (verified, elevated status)
const kaderColor = Color(0xFF2196F3);

// Simpatisan: Grey/Neutral (standard user)
const simpatisanColor = Color(0xFF9E9E9E);
```

---

### **Opsi 4: Vertical Role Strip (Side Accent)**
```
┌──────────────────────────────────┐
│🟦│  Nama User                    │
│🟦│  @username                    │
│🟦│                               │
└──────────────────────────────────┘
     ↑
  Left stripe indicator (2-3px)
```

**Keuntungan:**
- ✅ Subtle tapi clear
- ✅ Design modern (side accent)
- ✅ Tidak mengganggu content

---

### **Opsi 5: Floating Role Badge (Bottom-Right)**
```
┌─────────────────────────────────┐
│  👤 Nama User                   │
│  @username                      │
│  Welcome back!                  │
│                      ┌────────┐ │
│                      │🟦 KADER│ │ ← Floating badge
│                      └────────┘ │
└─────────────────────────────────┘
```

**Keuntungan:**
- ✅ Trendy design
- ✅ Clean & unobtrusive
- ✅ Easy to implement

---

## 🏆 MY RECOMMENDATION: **Opsi 1 (Header Badge) + Opsi 2 (Card Status)**

**Best Practice Combination:**
1. **Small badge di header** - Quick glance
2. **Detailed status di profile card** - More info

```
┌─────────────────────────────────┐
│  👤 Nama User    [🟦 KADER]     │  ← Quick indicator
├─────────────────────────────────┤
│  Profile Summary Card           │
│  @username                      │
│  Daerah: Kabupaten X            │
│                                 │
│  Status: 🟦 KADER ✓             │  ← Detailed info
│  Terverifikasi sejak: 15 Apr    │
│                                 │
└─────────────────────────────────┘
```

---

## 🎨 Color Psychology

| Role | Color | Icon | Meaning |
|------|-------|------|---------|
| **KADER** | Blue (#2196F3) | ✓ verified | Elevated status, verified, trusted |
| **SIMPATISAN** | Grey (#9E9E9E) | 👤 person | Regular user, standard access |

---

## 📱 Responsive Behavior

### Desktop/Large Screen:
```
Full badge visible: [🟦 KADER]
```

### Mobile/Small Screen:
```
Badge text hidden: [🟦] or just color indicator
```

---

## 🔄 When to Remove Popup Dialog

**Current:** `_showRoleUpgradeDialog()` shows popup when role changes

**New:** 
1. Keep dialog for **first time upgrade** (celebration moment)
2. Don't show on subsequent logins (already verified)
3. Just show badge consistently

**Implementation:**
```dart
// Only show popup once per verification
bool _alreadyShowedUpgradeDialog = false;

void _showRoleUpgradeDialog() {
  // Check if already showed today/this session
  if (_alreadyShowedUpgradeDialog) {
    return; // Don't show again
  }
  
  // Show once
  _alreadyShowedUpgradeDialog = true;
  showDialog(...);
}
```

---

## 📋 Implementation Steps

1. **Remove:** Popup dialog pada setiap login
   - Keep popup hanya untuk `roleChanged && oldRole == 'simpatisan' && newRole == 'kader'`
   - Show once per session/day

2. **Add:** Role badge di header
   - Selalu visible
   - Update otomatis saat role berubah

3. **Add:** Role status di profile card
   - Detailed info
   - Verification date

4. **Style:** Warna konsisten
   - Kader: Blue
   - Simpatisan: Grey

---

## ✨ User Experience Flow

### Before (Current):
```
Login → Popup "Selamat!" → OK → Beranda
                ↓
           Masuk lagi → Popup lagi (annoying!)
```

### After (Recommended):
```
Login → [First time upgrade] Popup "Selamat!" → OK → Beranda
                                    ↑
                            [Show once only]

Login again → Beranda dengan badge [🟦 KADER]
                ↓
              Tidak ada popup lagi (clean!)
```

---

## 🎯 Final Decision

**Pilihan Terbaik: Opsi 1 + Opsi 2**

**Why?**
- ✅ Clean & professional
- ✅ Always visible (role clarity)
- ✅ No annoying popups
- ✅ Modern design trend
- ✅ Easy to scan
- ✅ Responsive

**Action Items:**
1. Add role badge to header (persistent)
2. Add role status to profile card (detailed)
3. Keep upgrade popup only on first verification
4. Remove repetitive popups on login

---

**Status:** Ready for Implementation ✅  
**Recommendation Level:** 9/10 🌟  
