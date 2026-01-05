# 🚀 MyGeri - Flutter Application

Aplikasi mobile berbasis Flutter untuk sistem manajemen partai politik.

## 📚 Dokumentasi

Dokumentasi lengkap tersedia di folder terpisah:

### 📱 Frontend Documentation
**Lokasi:** [`/dokumentasiFE/INDEX.md`](./dokumentasiFE/INDEX.md)

**Konten:**
- ✅ Implementation guides (Login, Token Refresh, Auto-login)
- 🐛 Troubleshooting & fixes
- 🎨 UI/UX implementation
- 🗄️ Database schema

### 🔧 Backend Documentation
**Lokasi:** [`/dokumentasiBE/INDEX.md`](./dokumentasiBE/INDEX.md)

**Konten:**
- 📖 API documentation
- 🔗 Flutter integration guides
- 📊 Quick reference
- 🧪 Testing guides

---

## 🏃 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Dart (3.0+)
- iOS Simulator / Android Emulator / Physical Device

### Installation

1. **Clone repository:**
```bash
git clone <repository-url>
cd mygeri
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Update base URL:**
Edit `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3030';
```

4. **Run the app:**
```bash
flutter run
```

---

## 📁 Project Structure

```
mygeri/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── models/                   # Data models
│   ├── pages/                    # UI screens
│   ├── services/                 # API & Auth services
│   ├── utils/                    # Helpers & validators
│   └── widgets/                  # Reusable components
├── dokumentasiFE/                # Frontend documentation
├── dokumentasiBE/                # Backend documentation
└── README.md                     # This file
```

---

## 🔑 Core Features

✅ **Authentication System**
- Login / Register
- JWT token management
- Auto-refresh token
- Auto-login check

✅ **User Management**
- Profile view/edit
- Kader registration with photo upload
- Simpatisan registration

✅ **Session Management**
- Persistent login
- Secure token storage
- Proper logout with revocation

---

## 📖 Documentation Index

| Kategori | Link | Deskripsi |
|----------|------|-----------|
| 🚀 **Priority Features** | [PRIORITY_FEATURES_COMPLETE.md](./dokumentasiFE/PRIORITY_FEATURES_COMPLETE.md) | Token refresh, logout, auto-login |
| 🔐 **Login Integration** | [LOGIN_INTEGRATION.md](./dokumentasiFE/LOGIN_INTEGRATION.md) | Login flow & JWT handling |
| 🐛 **Null Type Fix** | [FIX_NULL_TYPE_ERROR.md](./dokumentasiFE/FIX_NULL_TYPE_ERROR.md) | Null safety implementation |
| ✅ **Validation** | [CLIENT_VALIDATION_IMPLEMENTATION.md](./dokumentasiFE/CLIENT_VALIDATION_IMPLEMENTATION.md) | Form validation rules |
| 🎨 **UI Layout** | [UI_LAYOUT_FOTO_OPTIONAL.md](./dokumentasiFE/UI_LAYOUT_FOTO_OPTIONAL.md) | Layout fixes & optional uploads |
| 🧪 **Testing** | [TESTING_TROUBLESHOOTING.md](./dokumentasiFE/TESTING_TROUBLESHOOTING.md) | Common issues & solutions |
| 🔗 **Full Index** | [dokumentasiFE/INDEX.md](./dokumentasiFE/INDEX.md) | Complete documentation list |

---

## 🧪 Testing

```bash
# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

**Note:** Gunakan kredensial yang sudah Anda daftarkan melalui form register (Kader Lama atau Simpatisan).

---

## 🛠️ Development

### Code Style
Ikuti Flutter best practices dan gunakan widget yang sesuai untuk pengembangan aplikasi mobile.

### Copilot Instructions
Custom instructions tersedia di `.github/copilot-instructions.md`

---

## 📊 Project Status

| Component | Status | Progress |
|-----------|--------|----------|
| Authentication | ✅ Complete | 100% |
| Registration | ✅ Complete | 100% |
| Token Management | ✅ Complete | 100% |
| Profile | 🚧 In Progress | 70% |
| Upload Service | 📋 Planned | 0% |

**Overall:** 85% Complete

---

## 🤝 Contributing

1. Check dokumentasi sebelum membuat perubahan
2. Follow Flutter best practices
3. Test di physical device sebelum commit
4. Update dokumentasi jika ada perubahan major

---

## 📞 Support

Untuk bantuan dan troubleshooting, check:
- [Frontend Docs](./dokumentasiFE/INDEX.md)
- [Backend Docs](./dokumentasiBE/INDEX.md)
- [Flutter Documentation](https://docs.flutter.dev/)

---

**Last Updated:** 24 Desember 2025  
**Status:** 🟢 Active Development
