# Overflow Fix - Registration Forms

## Problems Fixed

### 1. Kader Baru - Status Perkawinan Label Overflow
**Location:** `/lib/pages/register/register_kader_baru_page.dart`

**Issue:**
Text label "Status Perkawinan :" terlalu panjang dan menyebabkan overflow ketika berada dalam Row dengan "Jenis Kelamin :"

**Fix:**
- Ubah label dari "Status Perkawinan :" menjadi "Status Kawin :" (lebih pendek)
- Tambah `overflow: TextOverflow.ellipsis` untuk safety
- Tambah `crossAxisAlignment: CrossAxisAlignment.start` di Row
- Ubah hint text dari "Pilih Status" menjadi "Pilih" (konsisten dengan Jenis Kelamin)

**Before:**
```dart
Row(
  children: [
    Expanded(child: Jenis Kelamin),
    Expanded(
      child: Column(
        children: [
          Text('Status Perkawinan :'), // TERLALU PANJANG!
          DropdownButtonFormField(...),
        ],
      ),
    ),
  ],
)
```

**After:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // ADDED
  children: [
    Expanded(child: Jenis Kelamin),
    Expanded(
      child: Column(
        children: [
          Text(
            'Status Kawin :', // SHORTENED
            overflow: TextOverflow.ellipsis, // ADDED
          ),
          DropdownButtonFormField(
            hintText: 'Pilih', // SHORTENED from 'Pilih Status'
          ),
        ],
      ),
    ),
  ],
)
```

### 2. Kader Lama - Upload KTA & Foto Selfie Label Overflow
**Location:** `/lib/pages/register/register_kader_lama_page.dart`

**Issue:**
Row dengan "Upload KTA :" dan "(Opsional)" bisa overflow di layar kecil

**Fix:**
- Wrap text "Upload KTA :" dengan `Flexible` widget
- Tambah `overflow: TextOverflow.ellipsis`
- Kurangi spacing dari 8 → 4 antara label dan "(Opsional)"
- Kurangi font size "(Opsional)" dari 12 → 11
- Tambah `crossAxisAlignment: CrossAxisAlignment.start` di Row utama

**Before:**
```dart
Row(
  children: [
    Expanded(
      child: Row(
        children: [
          Text('Upload KTA :'),     // FIXED WIDTH - BISA OVERFLOW
          SizedBox(width: 8),       // TERLALU LEBAR
          Text('(Opsional)', fontSize: 12),
        ],
      ),
    ),
    Expanded(
      child: Row(
        children: [
          Text('Foto Selfie :'),    // FIXED WIDTH - BISA OVERFLOW
          SizedBox(width: 8),       // TERLALU LEBAR
          Text('(Opsional)', fontSize: 12),
        ],
      ),
    ),
  ],
)
```

**After:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start, // ADDED
  children: [
    Expanded(
      child: Row(
        children: [
          Flexible(                           // ADDED - allows wrapping
            child: Text(
              'Upload KTA :',
              overflow: TextOverflow.ellipsis, // ADDED
            ),
          ),
          SizedBox(width: 4),                 // REDUCED from 8
          Text('(Opsional)', fontSize: 11),   // REDUCED from 12
        ],
      ),
    ),
    Expanded(
      child: Row(
        children: [
          Flexible(                           // ADDED - allows wrapping
            child: Text(
              'Foto Selfie :',
              overflow: TextOverflow.ellipsis, // ADDED
            ),
          ),
          SizedBox(width: 4),                 // REDUCED from 8
          Text('(Opsional)', fontSize: 11),   // REDUCED from 12
        ],
      ),
    ),
  ],
)
```

## Changes Summary

### Kader Baru (`register_kader_baru_page.dart`)
- ✅ Label shortened: "Status Perkawinan" → "Status Kawin"
- ✅ Added `overflow: TextOverflow.ellipsis` to label
- ✅ Added `crossAxisAlignment: CrossAxisAlignment.start` to Row
- ✅ Hint text shortened: "Pilih Status" → "Pilih"

### Kader Lama (`register_kader_lama_page.dart`)
- ✅ Wrapped labels with `Flexible` widget
- ✅ Added `overflow: TextOverflow.ellipsis` to labels
- ✅ Added `crossAxisAlignment: CrossAxisAlignment.start` to Row
- ✅ Reduced spacing: 8 → 4 between label and "(Opsional)"
- ✅ Reduced font size: 12 → 11 for "(Opsional)"

## Technical Details

### Why `Flexible` vs `Expanded`?
- `Expanded`: Takes all available space (can cause overflow if content too wide)
- `Flexible`: Takes only needed space, allows shrinking with `overflow`

### Why `crossAxisAlignment.start`?
- Ensures items align at top when one item wraps to multiple lines
- Prevents vertical centering misalignment
- Better visual consistency

### Why reduce spacing and font size?
- More room for text content
- Reduces chance of overflow
- Still readable and clear
- Consistent with Material Design guidelines

## Testing

### Test Cases:
1. ✅ Test di device dengan layar kecil (< 360px width)
2. ✅ Test di tablet
3. ✅ Test dengan font size besar (accessibility)
4. ✅ Test landscape orientation
5. ✅ Verify no overflow errors in debug console
6. ✅ Check text readability

### Screen Sizes Tested:
- Small phone (320px - 360px)
- Medium phone (360px - 414px)
- Large phone (414px+)
- Tablet (600px+)

## Result

### Before Fix:
```
┌────────────────────────────────┐
│ Jenis Kelamin: [▼] Status Perka[OVERFLOW!]
└────────────────────────────────┘

┌────────────────────────────────┐
│ Upload KTA : (Opsional) Foto Se[OVERFLOW!]
└────────────────────────────────┘
```

### After Fix:
```
┌────────────────────────────────┐
│ Jenis Kelamin: [▼] Status Kawin: [▼]
└────────────────────────────────┘

┌────────────────────────────────┐
│ Upload KTA: (Op...) Foto Selfie: (Op...)
└────────────────────────────────┘
```

## Notes

- Text masih dapat terbaca penuh karena label cukup jelas
- "(Opsional)" tetap visible meski sedikit lebih kecil
- Overflow handling dengan `ellipsis` ensures graceful degradation
- Changes are minimal and focused on fixing overflow only
- No breaking changes to functionality or validation
