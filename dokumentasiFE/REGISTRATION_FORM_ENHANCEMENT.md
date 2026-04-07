# Form Registration Enhancement - Kader Lama & Kader Baru

## Overview
Perbaikan form pendaftaran untuk Kader Lama dan Kader Baru dengan validasi yang lebih ketat dan UX yang lebih baik.

## Changes Summary

### Register Kader Baru (`register_kader_baru_page.dart`)

#### ✅ Added/Fixed:

1. **Field Username**
   - Added username field dengan validasi
   - Min 3 karakter, hanya huruf, angka, underscore
   - Validator: `Validators.validateUsername`

2. **Jenis Kelamin - Dropdown**
   ```dart
   DropdownButtonFormField<String>(
     items: [
       DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
       DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
     ],
   )
   ```
   - Sebelumnya: TextField manual input
   - Sekarang: Dropdown dengan 2 pilihan
   - Validasi: Required

3. **Status Perkawinan - Dropdown**
   ```dart
   DropdownButtonFormField<String>(
     items: [
       'Kawin',
       'Belum Kawin',
       'Cerai Hidup',
       'Cerai Mati',
     ],
   )
   ```
   - Sebelumnya: TextField manual input
   - Sekarang: Dropdown dengan 4 pilihan
   - Validasi: Required

4. **Tanggal Lahir - DatePicker**
   ```dart
   TextFormField(
     readOnly: true,
     onTap: _selectDate,
     decoration: InputDecoration(
       suffixIcon: Icon(Icons.calendar_today),
     ),
   )
   ```
   - Sebelumnya: TextField manual ketik
   - Sekarang: DatePicker dengan calendar icon
   - Format: dd/MM/yyyy
   - Range: 1950 - now
   - Validasi: Required

5. **NIK - Validation**
   ```dart
   TextFormField(
     keyboardType: TextInputType.number,
     maxLength: 16,
     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
     validator: (value) {
       // Harus 16 digit
       // Hanya angka
     },
   )
   ```
   - Batas input: 16 digit
   - Input formatter: Hanya angka (digits only)
   - Keyboard: Numeric
   - Validasi: Exactly 16 digit, angka semua

6. **Email - Validation**
   ```dart
   TextFormField(
     keyboardType: TextInputType.emailAddress,
     validator: Validators.validateEmail,
   )
   ```
   - Keyboard: Email type
   - Validasi: Format email yang benar (@ dan domain)
   - Validator dari `Validators.validateEmail`

7. **Password - Enhanced Validation**
   ```dart
   TextFormField(
     obscureText: true,
     validator: Validators.validatePassword,
     decoration: InputDecoration(
       helperText: 'Min 8 karakter: huruf besar, kecil, angka',
     ),
   )
   ```
   - Min 8 karakter
   - Harus ada: huruf kecil (a-z)
   - Harus ada: huruf besar (A-Z)
   - Harus ada: angka (0-9)
   - Confirm password: Must match

8. **Nama - Validation**
   ```dart
   TextFormField(
     validator: Validators.validateName,
   )
   ```
   - Hanya huruf dan spasi
   - Tidak boleh angka atau karakter khusus

#### Changed Controllers:
- Removed: `_genderController`, `_statusController`
- Added State Variables:
  - `String? _selectedGender`
  - `String? _selectedStatusKawin`
  - `DateTime? _selectedDate`

#### Added Methods:
```dart
Future<void> _selectDate() async {
  // DatePicker dialog dengan tema red
  // Format output: dd/MM/yyyy
}
```

#### Enhanced Validation in `_handleRegister()`:
- Check `_selectedGender != null`
- Check `_selectedStatusKawin != null`
- Check `_selectedDate != null`
- All form fields validated before submit

### Register Kader Lama (`register_kader_lama_page.dart`)

#### ✅ Status:
Sudah lengkap dengan:
- ✅ Username field dengan validation
- ✅ Email validation dengan format check
- ✅ Password validation (min 8, uppercase, lowercase, number)
- ✅ Name validation (hanya huruf dan spasi)
- ✅ Confirm password matching

**No changes needed** - Sudah sesuai requirement!

## Validators Used

All validators from `/lib/utils/validators.dart`:

1. **validateName**: Hanya huruf dan spasi
2. **validateEmail**: Format email valid
3. **validateUsername**: Min 3 char, alphanumeric + underscore
4. **validatePassword**: Min 8 char, mixed case + number
5. **validateConfirmPassword**: Password matching

## UI/UX Improvements

### Before:
- Manual text input untuk jenis kelamin (typo: "Laki/Perempuan")
- Manual text input untuk status kawin (tidak konsisten)
- Manual ketik tanggal lahir (format bebas, error-prone)
- NIK bisa input huruf
- Email tidak ada validasi
- Password weak (hanya panjang)

### After:
- ✅ Dropdown jenis kelamin (2 pilihan fix)
- ✅ Dropdown status kawin (4 pilihan fix)
- ✅ DatePicker dengan calendar (format dd/MM/yyyy konsisten)
- ✅ NIK hanya angka, exact 16 digit
- ✅ Email wajib format email valid
- ✅ Password strong: min 8 + mixed case + number

## Testing Checklist

### Kader Baru:
- [ ] Test username validation (min 3 char)
- [ ] Test NIK validation (16 digit, angka only)
- [ ] Test jenis kelamin dropdown (Laki-laki/Perempuan)
- [ ] Test status kawin dropdown (4 pilihan)
- [ ] Test date picker (calendar icon, format dd/MM/yyyy)
- [ ] Test email validation (format @ domain)
- [ ] Test password validation (min 8, mixed case, number)
- [ ] Test password confirmation matching
- [ ] Test form submission dengan data lengkap
- [ ] Test error message untuk field kosong

### Kader Lama:
- [ ] Test username validation
- [ ] Test email validation
- [ ] Test password validation
- [ ] Test password confirmation
- [ ] Test nama validation (hanya huruf)

## Files Modified

1. `/lib/pages/register/register_kader_baru_page.dart`
   - Added imports: `flutter/services.dart`, `intl.dart`, `validators.dart`
   - Changed 3 TextFields → DropdownButtonFormField/DatePicker
   - Added `_selectDate()` method
   - Enhanced validation in all form fields
   - Updated `_handleRegister()` with additional checks

2. `/lib/pages/register/register_kader_lama_page.dart`
   - **No changes needed** (already compliant)

## Backend Expectations

Form akan mengirim data dengan format:
- `jenisKelamin`: "Laki-laki" atau "Perempuan"
- `statusKawin`: "Kawin", "Belum Kawin", "Cerai Hidup", atau "Cerai Mati"
- `tanggalLahir`: "dd/MM/yyyy" (String)
- `nik`: String 16 digit angka
- `email`: Valid email format
- `username`: Min 3 char, alphanumeric + underscore
- `password`: Min 8 char dengan mixed case dan angka

## Notes

- DatePicker menggunakan `intl` package yang sudah ada di pubspec.yaml
- Theme untuk DatePicker menggunakan red color sesuai branding Gerindra
- Input formatter untuk NIK menggunakan `FilteringTextInputFormatter.digitsOnly`
- Semua validation error akan ditampilkan di bawah field yang bersangkutan
- Dropdown akan show validation error jika user belum memilih (tap submit tanpa pilih)
