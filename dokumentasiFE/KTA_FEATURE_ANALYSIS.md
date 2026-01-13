# 🪪 ANALISIS FITUR: KTA (Kartu Tanda Anggota)

**Tanggal**: 9 Januari 2026  
**Fitur**: Digital Membership Card dengan QR Code + Download/Print

---

## 🎯 REQUIREMENT USER

### Fungsi Utama:
1. ✅ **Tampilkan KTA Digital** → User bisa lihat kartu anggota mereka
2. ✅ **Dua Sisi Kartu** → Depan (ID Card) dan Belakang (Detail Info)
3. ✅ **Download/Save** → User bisa download untuk print
4. ✅ **QR Code** → Berisi ID user untuk verifikasi

### Ukuran Kartu:
- **Standard ID Card Size**: 85.6mm x 54mm (3.375" x 2.125")
- **Aspect Ratio**: 1.586:1 (sama seperti kartu kredit/SIM)
- **Resolution untuk Print**: 300 DPI minimum
- **Pixel Size**: ~1011px x 638px (untuk 300 DPI)

---

## 🎨 DESIGN SPECIFICATION

### 📄 **SISI DEPAN (Front Card)**

```
┌─────────────────────────────────────┐
│                                     │
│           [LOGO GERINDRA]           │  ← Logo di atas (center)
│                                     │
│         ┌─────────────┐             │
│         │             │             │
│         │   [PHOTO]   │             │  ← Foto profil (center)
│         │             │             │
│         └─────────────┘             │
│                                     │
│    [QR CODE]      [NAMA LENGKAP]   │  ← QR Code (kiri) + Nama (kanan)
│                   [ID: 12345]       │  ← ID Number
│                                     │
└─────────────────────────────────────┘
```

**Element Details:**
- **Logo**: 60x60px (atau proportional)
- **Foto**: 120x150px (portrait, rounded corners)
- **QR Code**: 80x80px (encode: user ID)
- **Nama**: Font bold, 16px
- **ID**: Font regular, 12px
- **Background**: Gradient merah Gerindra atau solid color
- **Border**: Rounded corners 8px

---

### 📄 **SISI BELAKANG (Back Card)**

```
┌─────────────────────────────────────┐
│                                     │
│           [LOGO GERINDRA]           │  ← Logo sama dengan depan
│                                     │
│      KARTU TANDA ANGGOTA            │  ← Title (bold, center)
│                                     │
│  Nama           : John Doe          │
│  Tanggal Lahir  : 15 Januari 1990   │  ← Detail profil
│  Alamat         : Jl. Example No.1  │     (align left)
│                   Jakarta Selatan   │
│  Jenis Kelamin  : Laki-laki         │
│                                     │
│  Jakarta, 9 Januari 2026            │  ← Tanggal cetak
│                                     │
│  [TTD Ketua Umum]  [TTD Sekretaris] │  ← 2 Tanda tangan
│   Prabowo Subianto   Sufmi Dasco    │     (bisa signature image)
│   Ketua Umum         Sekretaris     │
│                                     │
└─────────────────────────────────────┘
```

**Element Details:**
- **Title**: Font bold, 18px, uppercase
- **Detail Profil**: Font 12px, line spacing 1.5
- **Tanggal Cetak**: Font italic, 10px
- **Signature**: Image 80x40px (transparent PNG)
- **Background**: Putih atau light gray

---

## 🔍 ANALISIS TEKNIS

### 1️⃣ **DATA YANG DIBUTUHKAN**

**Dari Profil User (sudah ada):**
```json
{
  "id": 12345,
  "name": "John Doe",
  "fotoProfil": "https://..../profile.jpg",
  "tanggal_lahir": "1990-01-15",
  "alamat_lengkap": "Jl. Example No. 1, RT 01/RW 02, Kebayoran Baru, Jakarta Selatan, DKI Jakarta",
  "jenis_kelamin": "Laki-laki",  // atau "Perempuan"
  "roles": [
    {"role": "simpatisan"}  // atau "kader", "admin"
  ]
}
```

**Data Tambahan yang Perlu:**
- Logo Gerindra (asset image)
- Signature Ketua Umum (image)
- Signature Sekretaris (image)
- Tanggal cetak (generated saat download)

---

### 2️⃣ **TEKNOLOGI YANG DIBUTUHKAN**

#### **A. QR Code Generation**
**Package**: `qr_flutter: ^4.1.0`

```dart
QrImageView(
  data: user.id.toString(),  // Encode user ID
  version: QrVersions.auto,
  size: 80.0,
  backgroundColor: Colors.white,
)
```

#### **B. Card Rendering**
**Package**: `flutter/widgets` (built-in)

Gunakan `Container`, `Stack`, `Positioned` untuk layout card

#### **C. Download/Save Image**
**Package**: 
- `screenshot: ^2.1.0` - Capture widget as image
- `path_provider: ^2.1.2` - Get device directory
- `permission_handler: ^11.4.0` - Request storage permission
- `image_gallery_saver: ^2.0.3` - Save to gallery
- `share_plus: ^7.2.1` - Share functionality (optional)

```dart
// Capture widget as image
final image = await screenshotController.capture();

// Save to gallery
await ImageGallerySaver.saveImage(
  image!,
  quality: 100,
  name: "KTA_${user.name}_${DateTime.now().millisecondsSinceEpoch}",
);
```

#### **D. PDF Generation (Optional - untuk print quality)**
**Package**: `pdf: ^3.10.7` + `printing: ^5.11.1`

Untuk kualitas print lebih baik, generate PDF instead of image.

```dart
final pdf = pw.Document();
pdf.addPage(
  pw.Page(
    pageFormat: PdfPageFormat(85.6 * PdfPageFormat.mm, 54 * PdfPageFormat.mm),
    build: (context) => ktaFrontWidget(),
  ),
);

await Printing.layoutPdf(
  onLayout: (format) async => pdf.save(),
);
```

---

### 3️⃣ **BACKEND REQUIREMENTS**

#### **A. API Endpoint (Optional - jika ada data tambahan)**

**GET /api/user/kta-info**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 12345,
      "name": "John Doe",
      "fotoProfil": "https://...",
      "tanggal_lahir": "1990-01-15",
      "alamat_lengkap": "...",
      "jenis_kelamin": "Laki-laki",
      "member_since": "2024-01-01"  // Tambahan: sejak kapan jadi anggota
    },
    "assets": {
      "logo_url": "https://.../logo_gerindra.png",
      "signature_ketua": "https://.../ttd_ketua.png",
      "signature_sekretaris": "https://.../ttd_sekjen.png"
    }
  }
}
```

**Catatan**: Jika assets (logo, signature) static, bisa langsung bundle di Flutter assets.

---

### 4️⃣ **IMPLEMENTASI FLUTTER**

#### **A. Struktur File**

```
lib/
├── pages/
│   └── kta/
│       ├── kta_page.dart              # Main page (show cards)
│       └── kta_preview_page.dart      # Fullscreen preview
├── widgets/
│   └── kta/
│       ├── kta_card_front.dart        # Widget kartu depan
│       ├── kta_card_back.dart         # Widget kartu belakang
│       └── kta_flip_card.dart         # Animated flip card
├── services/
│   └── kta_service.dart               # Download/save logic
└── models/
    └── kta_models.dart                # KTA data model

assets/
├── images/
│   ├── logo_gerindra.png
│   ├── ttd_ketua_umum.png
│   └── ttd_sekretaris.png
```

---

#### **B. Model Data**

```dart
// lib/models/kta_models.dart

class KTAInfo {
  final int userId;
  final String name;
  final String? fotoProfil;
  final DateTime? tanggalLahir;
  final String? alamatLengkap;
  final String jenisKelamin;
  final String role;
  final DateTime cetakDate;

  KTAInfo({
    required this.userId,
    required this.name,
    this.fotoProfil,
    this.tanggalLahir,
    this.alamatLengkap,
    required this.jenisKelamin,
    required this.role,
    DateTime? cetakDate,
  }) : cetakDate = cetakDate ?? DateTime.now();

  String get formattedId => 'ID: ${userId.toString().padLeft(6, '0')}';
  
  String get formattedTanggalLahir {
    if (tanggalLahir == null) return '-';
    return DateFormat('dd MMMM yyyy', 'id').format(tanggalLahir!);
  }
  
  String get formattedCetakDate {
    return 'Jakarta, ${DateFormat('dd MMMM yyyy', 'id').format(cetakDate)}';
  }

  String get qrCodeData => userId.toString();

  factory KTAInfo.fromUserData(Map<String, dynamic> userData) {
    return KTAInfo(
      userId: userData['id'],
      name: userData['name'],
      fotoProfil: userData['fotoProfil'],
      tanggalLahir: userData['tanggal_lahir'] != null 
        ? DateTime.parse(userData['tanggal_lahir']) 
        : null,
      alamatLengkap: userData['alamat_lengkap'],
      jenisKelamin: userData['jenis_kelamin'] ?? 'Laki-laki',
      role: (userData['roles'] as List?)?.first['role'] ?? 'simpatisan',
    );
  }
}
```

---

#### **C. Widget Kartu Depan**

```dart
// lib/widgets/kta/kta_card_front.dart

class KTACardFront extends StatelessWidget {
  final KTAInfo ktaInfo;
  final double cardWidth;
  final double cardHeight;

  const KTACardFront({
    Key? key,
    required this.ktaInfo,
    this.cardWidth = 340, // 85.6mm = ~340px at screen DPI
    this.cardHeight = 214, // 54mm = ~214px
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE31E24), // Merah Gerindra
            Color(0xFF8B0000), // Merah gelap
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Logo
            Image.asset(
              'assets/images/logo_gerindra.png',
              height: 40,
              color: Colors.white,
            ),
            SizedBox(height: 12),

            // Photo
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: ktaInfo.fotoProfil != null
                    ? Image.network(
                        ktaInfo.fotoProfil!,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            
            Spacer(),

            // Bottom Section: QR Code + Name
            Row(
              children: [
                // QR Code
                Container(
                  width: 70,
                  height: 70,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: QrImageView(
                    data: ktaInfo.qrCodeData,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(width: 12),

                // Name & ID
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ktaInfo.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        ktaInfo.formattedId,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

#### **D. Widget Kartu Belakang**

```dart
// lib/widgets/kta/kta_card_back.dart

class KTACardBack extends StatelessWidget {
  final KTAInfo ktaInfo;
  final double cardWidth;
  final double cardHeight;

  const KTACardBack({
    Key? key,
    required this.ktaInfo,
    this.cardWidth = 340,
    this.cardHeight = 214,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE31E24), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo_gerindra.png',
              height: 30,
            ),
            SizedBox(height: 8),

            // Title
            Text(
              'KARTU TANDA ANGGOTA',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE31E24),
              ),
            ),
            SizedBox(height: 12),

            // Profile Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Nama', ktaInfo.name),
                  _buildDetailRow('Tanggal Lahir', ktaInfo.formattedTanggalLahir),
                  _buildDetailRow('Alamat', ktaInfo.alamatLengkap ?? '-'),
                  _buildDetailRow('Jenis Kelamin', ktaInfo.jenisKelamin),
                ],
              ),
            ),

            // Print Date
            Text(
              ktaInfo.formattedCetakDate,
              style: TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),

            // Signatures
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSignature(
                  'assets/images/ttd_ketua_umum.png',
                  'Prabowo Subianto',
                  'Ketua Umum',
                ),
                _buildSignature(
                  'assets/images/ttd_sekretaris.png',
                  'Sufmi Dasco',
                  'Sekretaris Jenderal',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            ': ',
            style: TextStyle(fontSize: 10),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignature(String assetPath, String name, String title) {
    return Column(
      children: [
        // Signature image
        Container(
          width: 80,
          height: 30,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(),
          ),
        ),
        SizedBox(height: 2),
        Text(
          name,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 7,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
```

---

#### **E. Main KTA Page**

```dart
// lib/pages/kta/kta_page.dart

class KTAPage extends StatefulWidget {
  const KTAPage({Key? key}) : super(key: key);

  @override
  State<KTAPage> createState() => _KTAPageState();
}

class _KTAPageState extends State<KTAPage> {
  bool _showFront = true;
  KTAInfo? _ktaInfo;
  bool _isLoading = true;

  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadKTAData();
  }

  Future<void> _loadKTAData() async {
    try {
      // Get user data from storage or API
      final storage = StorageService();
      final userDataString = await storage.getUserData();
      
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          _ktaInfo = KTAInfo.fromUserData(userData);
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading KTA data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadCard() async {
    try {
      // Request permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission required')),
        );
        return;
      }

      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Menyimpan kartu...')),
      );

      // Capture front card
      final frontImage = await _captureCard(front: true);
      
      // Save front
      await ImageGallerySaver.saveImage(
        frontImage!,
        quality: 100,
        name: "KTA_${_ktaInfo!.name}_Depan_${DateTime.now().millisecondsSinceEpoch}",
      );

      // Flip and capture back
      setState(() => _showFront = false);
      await Future.delayed(Duration(milliseconds: 500));
      
      final backImage = await _captureCard(front: false);
      
      // Save back
      await ImageGallerySaver.saveImage(
        backImage!,
        quality: 100,
        name: "KTA_${_ktaInfo!.name}_Belakang_${DateTime.now().millisecondsSinceEpoch}",
      );

      // Flip back
      setState(() => _showFront = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ KTA berhasil disimpan ke galeri!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<Uint8List?> _captureCard({required bool front}) async {
    return await _screenshotController.capture(
      pixelRatio: 3.0, // High resolution for print
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Kartu Tanda Anggota'),
          backgroundColor: Colors.red,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ktaInfo == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Kartu Tanda Anggota'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text('Data tidak tersedia'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kartu Tanda Anggota'),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadCard,
            tooltip: 'Download KTA',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Card Display
            GestureDetector(
              onTap: () {
                setState(() => _showFront = !_showFront);
              },
              child: Screenshot(
                controller: _screenshotController,
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: _showFront
                      ? KTACardFront(
                          key: ValueKey('front'),
                          ktaInfo: _ktaInfo!,
                        )
                      : KTACardBack(
                          key: ValueKey('back'),
                          ktaInfo: _ktaInfo!,
                        ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // Flip instruction
            Text(
              'Tap kartu untuk flip',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            SizedBox(height: 16),

            // Download Button
            ElevatedButton.icon(
              onPressed: _downloadCard,
              icon: Icon(Icons.download),
              label: Text('Download KTA untuk Print'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),

            SizedBox(height: 8),

            Text(
              'Kartu akan disimpan depan dan belakang',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 📦 DEPENDENCIES

Tambahkan ke `pubspec.yaml`:

```yaml
dependencies:
  # Existing dependencies...
  
  # KTA Feature
  qr_flutter: ^4.1.0                 # QR Code generation
  screenshot: ^2.1.0                  # Capture widget as image
  image_gallery_saver: ^2.0.3        # Save to gallery
  intl: ^0.19.0                       # Date formatting
  
dev_dependencies:
  # Existing dev dependencies...
```

---

## 🎨 ASSETS YANG DIBUTUHKAN

Tambahkan ke `pubspec.yaml`:

```yaml
flutter:
  assets:
    # Existing assets...
    
    # KTA Assets
    - assets/images/logo_gerindra.png
    - assets/images/ttd_ketua_umum.png
    - assets/images/ttd_sekretaris.png
```

**File yang perlu disiapkan:**
1. **logo_gerindra.png** - Logo Gerindra (transparent PNG, 200x200px)
2. **ttd_ketua_umum.png** - Signature Ketua Umum (transparent PNG, 200x80px)
3. **ttd_sekretaris.png** - Signature Sekjen (transparent PNG, 200x80px)

---

## 🔐 PERMISSIONS

Tambahkan ke `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Storage Permission for Saving Images -->
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

Untuk Android 13+, sudah handled by `image_gallery_saver` package.

---

## ✅ CHECKLIST IMPLEMENTASI

### Phase 1: Setup & Design
- [ ] Install dependencies (qr_flutter, screenshot, image_gallery_saver)
- [ ] Prepare assets (logo, signatures)
- [ ] Create KTA models
- [ ] Design KTA card front widget
- [ ] Design KTA card back widget

### Phase 2: Functionality
- [ ] Implement flip animation
- [ ] Add QR code generation
- [ ] Implement screenshot capture
- [ ] Add download functionality
- [ ] Handle storage permissions

### Phase 3: Integration
- [ ] Integrate with profile data
- [ ] Add navigation from profile page
- [ ] Test on multiple screen sizes
- [ ] Test print quality (300 DPI)

### Phase 4: Enhancement (Optional)
- [ ] Add share functionality
- [ ] Generate PDF for better print quality
- [ ] Add watermark/hologram effect
- [ ] Add expiry date (jika ada)

---

## 📱 USER FLOW

```
Profile Page
    ↓
[Tap "Lihat KTA" button]
    ↓
KTA Page (showing front card)
    ↓
[Tap card to flip] → Show back card
    ↓
[Tap "Download" button]
    ↓
Request storage permission
    ↓
Capture front & back as images
    ↓
Save to gallery
    ↓
Show success message
```

---

## 🎯 MOCKUP UI

### Main KTA Page:
```
┌─────────────────────────────────┐
│  ← Kartu Tanda Anggota    📥    │  ← AppBar with download
├─────────────────────────────────┤
│                                 │
│         (Empty space)           │
│                                 │
│    ┌─────────────────────┐     │
│    │                     │     │
│    │    [KTA CARD]       │     │  ← Card (flip animation)
│    │                     │     │
│    └─────────────────────┘     │
│                                 │
│   Tap kartu untuk flip          │  ← Instruction
│                                 │
│   [Download KTA untuk Print]    │  ← Download button
│                                 │
│   Kartu akan disimpan depan     │  ← Info text
│   dan belakang                  │
│                                 │
└─────────────────────────────────┘
```

---

## ⏱️ ESTIMASI WAKTU

- **Setup & Dependencies**: 30 menit
- **Design Card Front**: 2 jam
- **Design Card Back**: 2 jam
- **QR Code Integration**: 30 menit
- **Screenshot & Download**: 1.5 jam
- **Flip Animation**: 1 jam
- **Testing & Polish**: 1.5 jam

**TOTAL**: ~9 jam (1-2 hari kerja)

---

## 🤔 APAKAH PERLU BACKEND?

### ❌ **TIDAK MUTLAK** - Bisa Full Frontend

**Alasan:**
- Data profil sudah ada (dari API login/profile)
- Assets (logo, signature) bisa bundle di Flutter
- QR Code generated di frontend
- Download/save purely client-side

### ✅ **OPTIONAL: Backend Support untuk:**

1. **KTA Verification API** (future feature)
```
POST /api/kta/verify
{
  "qr_data": "12345"  // User ID dari QR code
}

Response:
{
  "valid": true,
  "user": { ... }  // User info if valid
}
```

2. **Dynamic Signatures** (jika signature berubah)
```
GET /api/kta/assets

Response:
{
  "logo_url": "https://...",
  "ketua_signature": "https://...",
  "sekjen_signature": "https://..."
}
```

---

## 🚀 NEXT STEPS

1. **Siapkan assets** (logo, signatures) - koordinasi dengan design team
2. **Install dependencies** - Flutter packages
3. **Implement card design** - Front & back widgets
4. **Add download functionality** - Screenshot + save
5. **Test print quality** - Print test di printer fisik
6. **Integration** - Tambah button di profile page

---

## 📝 NOTES

- **Print Quality**: Gunakan `pixelRatio: 3.0` untuk high-res (1011x638px = 300 DPI)
- **Card Size**: Standard ID card (85.6mm x 54mm)
- **QR Code**: Encode user ID only (simple & scannable)
- **Alamat**: Truncate jika terlalu panjang (max 2 lines)
- **Font**: Gunakan font yang readable untuk print

---

**Ready to implement!** 🚀
