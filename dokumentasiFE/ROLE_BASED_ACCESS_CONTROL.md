# Role-Based Access Control (RBAC) - Frontend Implementation

## 📋 Overview

Implementasi kontrol akses berbasis role untuk fitur Agenda dan My Gerindra (Announcement). User dengan role "simpatisan" akan mendapat popup informasi bahwa fitur ini hanya tersedia untuk Kader dan Admin.

## 🎯 Fitur yang Dibatasi

### 1. **Agenda** (Menu ke-4)
- **Akses Diberikan**: Admin, Kader
- **Akses Ditolak**: Simpatisan
- **Status Backend**: ✅ Ready

### 2. **My Gerindra / Announcement** (Menu ke-1)
- **Akses Diberikan**: Admin, Kader
- **Akses Ditolak**: Simpatisan
- **Status Backend**: ✅ Ready

### 3. **Voting** (Menu ke-5)
- **Akses Diberikan**: Admin, Kader
- **Akses Ditolak**: Simpatisan
- **Status Backend**: ⚠️ In Development (Menunggu dokumentasi dari backend)

## 📂 Files yang Dimodifikasi

### 1. **Model User Role** (`lib/models/user_role.dart`)
```dart
class UserRole {
  final int id;
  final String uuid;
  final int userId;
  final String role;
  
  // fromJson, toJson methods
}
```

### 2. **Updated User Profile Model** (`lib/models/user_profile.dart`)
```dart
class UserProfile {
  // ...existing fields...
  final List<UserRole> roles;
  
  // Constructor updated to include roles
  // fromJson updated to parse roles array
  // copyWith updated to include roles parameter
}
```

### 3. **Beranda Page dengan RBAC** (`lib/pages/beranda/beranda_page.dart`)
```dart
class _BerandaPageState extends State<BerandaPage> {
  UserProfile? _userProfile;
  
  // Method untuk cek akses
  bool _hasAccessToFeature(String featureName) {
    if (_userProfile == null || _userProfile!.roles.isEmpty) {
      return false;
    }
    
    // Untuk Agenda, My Gerindra, dan Voting
    if (featureName == 'Agenda' || 
        featureName == 'My Gerindra' || 
        featureName == 'Voting') {
      final userRole = _userProfile!.roles.first.role.toLowerCase();
      return userRole == 'kader' || userRole == 'admin';
    }
    
    return true;
  }
  
  // Method untuk tampilkan popup akses ditolak
  void _showAccessDeniedDialog(String featureName) {
    // Shows dialog with lock icon and explanation
  }
  
  // Method untuk tampilkan popup fitur dalam pengembangan
  void _showInDevelopmentDialog(String featureName) {
    // Shows dialog with construction icon
    // Displays access status (ALLOWED/DENIED)
    // Shows user role
    // Different message for allowed vs denied users
  }
}
```

## 🎨 UI/UX Flow

### Flow untuk User dengan Role Simpatisan:

1. **User menekan menu Agenda atau My Gerindra**
2. **Sistem mengecek role user dari profile**
3. **Dialog muncul dengan informasi:**
   - Icon lock merah
   - Judul: "Akses Terbatas"
   - Pesan: "Fitur [nama fitur] hanya tersedia untuk Kader dan Admin"
   - Badge: "Role Anda: SIMPATISAN"
   - Instruksi: "Silakan hubungi admin untuk upgrade role"
   - Button: "Mengerti"

4. **User menekan menu Voting**
5. **Dialog "Dalam Pengembangan" muncul dengan:**
   - Icon construction orange
   - Judul: "Dalam Pengembangan"
   - Badge: "Status Akses: DITOLAK" (merah)
   - Badge: "Role Anda: SIMPATISAN"
   - Pesan: "Fitur ini hanya tersedia untuk Kader dan Admin. Hubungi admin untuk upgrade role Anda."
   - Button: "Mengerti"

### Flow untuk User dengan Role Kader/Admin:

1. **User menekan menu Agenda atau My Gerindra**
2. **Sistem mengecek role user dari profile**
3. **Navigasi langsung ke halaman yang dituju**

4. **User menekan menu Voting**
5. **Dialog "Dalam Pengembangan" muncul dengan:**
   - Icon construction orange
   - Judul: "Dalam Pengembangan"
   - Badge: "Status Akses: DIIZINKAN" (hijau)
   - Badge: "Role Anda: KADER/ADMIN"
   - Pesan: "Backend sedang dalam pengembangan. Fitur ini akan segera tersedia untuk Anda!"
   - Button: "Mengerti"

## 🔒 Access Control Logic

```dart
// Check access sebelum navigasi
if (item['label'] == 'Agenda') {
  if (_hasAccessToFeature('Agenda')) {
    // Navigasi ke AgendaPage
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AgendaPage()),
    );
  } else {
    // Tampilkan popup akses ditolak
    _showAccessDeniedDialog('Agenda');
  }
}
```

## 📊 Role Hierarchy

```
┌─────────────────────────────────────┐
│         ROLE HIERARCHY              │
├─────────────────────────────────────┤
│                                     │
│  ADMIN (Highest)                    │
│    ├─ Full Access                   │
│    ├─ Can access Agenda             │
│    ├─ Can access Announcement       │
│    └─ Can access all other features │
│                                     │
│  KADER (Medium)                     │
│    ├─ Can access Agenda             │
│    ├─ Can access Announcement       │
│    └─ Can access basic features     │
│                                     │
│  SIMPATISAN (Basic)                 │
│    ├─ Cannot access Agenda          │
│    ├─ Cannot access Announcement    │
│    └─ Can access basic features     │
│                                     │
└─────────────────────────────────────┘
```

## 🎯 Dialog Components

### 1. Access Denied Dialog (untuk Agenda & My Gerindra)
```dart
AlertDialog(
  title: Row(
    children: [
      Icon(Icons.lock_outline, color: Colors.red[700]),
      Text('Akses Terbatas'),
    ],
  ),
  content: Column(
    children: [
      // Feature name explanation
      // User role badge (grey)
      // Instructions to contact admin
    ],
  ),
  actions: [
    TextButton(child: Text('Mengerti')),
  ],
)
```

### 2. In Development Dialog (untuk Voting)
```dart
AlertDialog(
  title: Row(
    children: [
      Icon(Icons.construction, color: Colors.orange[700]),
      Text('Dalam Pengembangan'),
    ],
  ),
  content: Column(
    children: [
      // Feature name explanation
      // Access status badge (green=ALLOWED / red=DENIED)
      // User role badge
      // Different message based on access status
    ],
  ),
  actions: [
    TextButton(child: Text('Mengerti')),
  ],
)
```

## 🔄 Data Flow

```
User Tap Menu
     ↓
Load User Profile (with roles)
     ↓
Check _hasAccessToFeature(featureName)
     ↓
┌─────────────┐
│ Has Access? │
└─────┬───────┘
      │
   Yes│    No
      ↓      ↓
  Navigate  Show Dialog
  to Page   (Access Denied)
      ↓
    Done
```

## 🧪 Testing Scenarios

### Scenario 1: Simpatisan Click Agenda
- **Given**: User logged in as simpatisan
- **When**: User clicks Agenda menu
- **Then**: Access denied dialog appears
- **And**: User stays on Beranda page

### Scenario 2: Kader Click Agenda
- **Given**: User logged in as kader
- **When**: User clicks Agenda menu
- **Then**: Navigate to Agenda page with calendar
- **And**: Load agenda data successfully

### Scenario 3: Admin Click My Gerindra
- **Given**: User logged in as admin
- **When**: User clicks My Gerindra menu
- **Then**: Navigate to Announcement page
- **And**: Load announcements successfully

### Scenario 4: Simpatisan Click My Gerindra
- **Given**: User logged in as simpatisan
- **When**: User clicks My Gerindra menu
- **Then**: Access denied dialog appears
- **And**: User stays on Beranda page

### Scenario 5: Simpatisan Click Voting
- **Given**: User logged in as simpatisan
- **When**: User clicks Voting menu
- **Then**: "Dalam Pengembangan" dialog appears
- **And**: Shows "Status Akses: DITOLAK" (red badge)
- **And**: Message says "hanya tersedia untuk Kader dan Admin"
- **And**: User stays on Beranda page

### Scenario 6: Kader Click Voting
- **Given**: User logged in as kader
- **When**: User clicks Voting menu
- **Then**: "Dalam Pengembangan" dialog appears
- **And**: Shows "Status Akses: DIIZINKAN" (green badge)
- **And**: Message says "Backend sedang dalam pengembangan"
- **And**: User stays on Beranda page (waiting for backend)

### Scenario 7: Admin Click Voting
- **Given**: User logged in as admin
- **When**: User clicks Voting menu
- **Then**: "Dalam Pengembangan" dialog appears
- **And**: Shows "Status Akses: DIIZINKAN" (green badge)
- **And**: Message says "Backend sedang dalam pengembangan"
- **And**: User stays on Beranda page (waiting for backend)

## 📝 Backend Coordination

### ⚠️ Important Notes:

1. **Frontend melakukan double-check:**
   - Check role sebelum navigasi (UI level)
   - Backend tetap harus validasi (API level)

2. **Backend masih mengembalikan 403 Forbidden:**
   - Ini adalah security layer kedua
   - Jika somehow user bypass frontend check
   - Backend akan tetap block request

3. **Role data source:**
   - Role didapat dari `/api/profile` endpoint
   - Backend mengirim array roles dalam response
   - Frontend parse dan store dalam UserProfile model

## 🚀 Future Enhancements

1. **Dynamic Role Configuration:**
   - Load role permissions from backend config
   - No need to hardcode role names

2. **Feature Flags:**
   - Enable/disable features per environment
   - A/B testing for new features

3. **Permission Levels:**
   - More granular permissions (READ, WRITE, DELETE)
   - Per-feature permission matrix

4. **Role Badge in UI:**
   - Show user role in profile page
   - Role badge in beranda header

## 📞 Contact

Jika ada pertanyaan tentang implementasi RBAC:
- Check dokumentasi ini
- Review code di `lib/pages/beranda/beranda_page.dart`
- Test dengan user berbeda role

---

**Last Updated**: February 11, 2026  
**Version**: 1.0  
**Status**: ✅ Implemented & Tested
