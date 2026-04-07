# Form Layout Fix - Register Kader Baru

## Problem
1. **Right Overflowed Error**: NIK, Jenis Kelamin, dan Status Perkawinan dalam 1 Row dengan 3 Expanded menyebabkan overflow di layar kecil
2. **Asymmetric Password Fields**: Field "Buat Password" memiliki helperText yang membuat tingginya berbeda dengan "Ulangi Password"

## Solution

### 1. NIK Field Layout - Full Width
**Before:**
```dart
Row(
  children: [
    Expanded(child: NIK),      // 1/3 width
    Expanded(child: Gender),   // 1/3 width
    Expanded(child: Status),   // 1/3 width - OVERFLOW!
  ],
)
```

**After:**
```dart
// NIK - Full width (seperti Username)
Column(
  children: [
    TextFormField(
      hintText: 'NIK 16 digit (hanya angka)',
    ),
  ],
),

// Gender & Status - Row dengan 2 field
Row(
  children: [
    Expanded(child: Gender),   // 1/2 width
    Expanded(child: Status),   // 1/2 width - No overflow!
  ],
)
```

### 2. Password Fields Symmetry
**Before:**
```dart
Row(
  children: [
    Expanded(
      child: TextFormField(
        helperText: 'Contoh: Password123 (WAJIB: a-z, A-Z, 0-9)',
        // Membuat field lebih tinggi
      ),
    ),
    Expanded(
      child: TextFormField(
        // Tidak ada helperText
        // Field lebih pendek - TIDAK SIMETRIS!
      ),
    ),
  ],
)
```

**After:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // Added
  children: [
    Expanded(
      child: TextFormField(
        hintText: 'Min 8 karakter',
        // No helperText - tinggi sama
      ),
    ),
    Expanded(
      child: TextFormField(
        hintText: 'Ulangi password',
        // No helperText - tinggi sama - SIMETRIS!
      ),
    ),
  ],
),
// Helper text di luar Row, di bawah kedua field
Padding(
  padding: EdgeInsets.only(left: 12),
  child: Text(
    'Password harus min 8 karakter dengan kombinasi huruf besar, kecil, dan angka',
    style: TextStyle(fontSize: 12, color: grey, italic),
  ),
),
```

## Changes Detail

### File: `register_kader_baru_page.dart`

#### Change 1: NIK Layout (Lines ~327-420)
```dart
// REMOVED: Row with 3 Expanded (NIK, Gender, Status)

// ADDED: NIK Full Width
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text('NIK :', ...),
    TextFormField(
      controller: _nikController,
      keyboardType: TextInputType.number,
      maxLength: 16,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        hintText: 'NIK 16 digit (hanya angka)',
        counterText: '',
      ),
      validator: (value) {
        // Same validation as before
      },
    ),
  ],
),

// ADDED: Gender & Status in Row (only 2 fields)
Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>( // Jenis Kelamin
        decoration: InputDecoration(hintText: 'Pilih'),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: DropdownButtonFormField<String>( // Status Perkawinan
        decoration: InputDecoration(hintText: 'Pilih Status'),
      ),
    ),
  ],
),
```

#### Change 2: Password Fields (Lines ~605-638)
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // ADDED
  children: [
    Expanded(
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Min 8 karakter', // SIMPLIFIED
          // REMOVED: helperText
        ),
        validator: Validators.validatePassword,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: TextFormField(
        controller: _ulangiPasswordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Ulangi password',
        ),
        validator: (value) => Validators.validateConfirmPassword(...),
      ),
    ),
  ],
),
const SizedBox(height: 8), // ADDED
// ADDED: Helper text below both fields
Padding(
  padding: const EdgeInsets.only(left: 12),
  child: Text(
    'Password harus min 8 karakter dengan kombinasi huruf besar, kecil, dan angka',
    style: TextStyle(
      fontSize: 12,
      color: Colors.grey[600],
      fontStyle: FontStyle.italic,
    ),
  ),
),
```

## UI Improvements

### Layout Structure Now:
```
┌─────────────────────────────────────┐
│ Nama:              [Full Width]     │
│ Email:             [Full Width]     │
│ Username:          [Full Width]     │
│ NIK:               [Full Width]     │  ← FIX: Full width seperti Username
│ Jenis Kelamin: [1/2] | Status: [1/2]│  ← FIX: Only 2 fields, no overflow
│ Tempat Lahir:  [1/2] | Tgl: [1/2]   │
│ ...                                 │
│ Password:      [1/2] | Ulangi: [1/2]│  ← FIX: Same height
│ ℹ️ Password harus min 8 karakter...  │  ← NEW: Helper text below
│ ...                                 │
└─────────────────────────────────────┘
```

## Benefits

1. ✅ **No Overflow**: Gender & Status hanya 2 field dalam Row (50% each)
2. ✅ **Consistent Width**: NIK full width seperti Username, Email, Nama
3. ✅ **Symmetric Password**: Kedua field password sekarang sama tinggi
4. ✅ **Better UX**: Helper text untuk password tetap visible tapi tidak mengganggu layout
5. ✅ **Responsive**: Layout lebih baik di layar kecil
6. ✅ **Clean Code**: crossAxisAlignment.start untuk Row password

## Validation Status

All validations remain intact:
- ✅ NIK: 16 digit, angka only
- ✅ Gender: Required dropdown
- ✅ Status: Required dropdown
- ✅ Password: Min 8, mixed case, number
- ✅ Confirm Password: Must match

## Testing Checklist

### Layout Tests:
- [ ] Test di layar kecil (small phone)
- [ ] Test di tablet
- [ ] Test landscape orientation
- [ ] Verify no overflow errors
- [ ] Check password fields sama tinggi
- [ ] Check helper text visible

### Functional Tests:
- [ ] NIK input hanya angka
- [ ] NIK max 16 karakter
- [ ] Gender dropdown berfungsi
- [ ] Status dropdown berfungsi
- [ ] Password validation berfungsi
- [ ] Password match validation berfungsi

## Notes

- Helper text untuk password menggunakan `fontStyle: FontStyle.italic` untuk membedakan dari label
- `crossAxisAlignment: CrossAxisAlignment.start` pada Row password memastikan alignment yang tepat
- Dropdown hint text diperpendek: "Pilih" dan "Pilih Status" agar tidak terlalu panjang
- Layout sekarang konsisten dengan struktur: Full width fields → 2-column fields → Full width fields
