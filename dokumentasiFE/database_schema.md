# Database Schema MyGeri (PostgreSQL)

## 1. Tabel anggota
```sql
CREATE TABLE anggota (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    nik VARCHAR(20) UNIQUE,
    tempat_lahir VARCHAR(50),
    tanggal_lahir DATE,
    jenis_kelamin VARCHAR(20),
    status_kawin VARCHAR(20),
    provinsi VARCHAR(50),
    kota VARCHAR(50),
    kecamatan VARCHAR(50),
    kelurahan VARCHAR(50),
    rt VARCHAR(10),
    rw VARCHAR(10),
    jalan VARCHAR(100),
    pekerjaan VARCHAR(50),
    pendidikan VARCHAR(50),
    underbow VARCHAR(100),
    kegiatan TEXT,
    foto_profil VARCHAR(200),
    foto_ktp VARCHAR(200),
    password_hash VARCHAR(200) NOT NULL,
    tanggal_daftar TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 2. Tabel login_log
```sql
CREATE TABLE login_log (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    username VARCHAR(50),
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    device_info VARCHAR(100)
);
```

## 3. Tabel pendaftaran
```sql
CREATE TABLE pendaftaran (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    username VARCHAR(50),
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20)
);
```

## 4. Tabel voting
```sql
CREATE TABLE voting (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    gambar VARCHAR(200),
    tanggal_mulai TIMESTAMP,
    tanggal_selesai TIMESTAMP,
    status VARCHAR(20)
);

CREATE TABLE voting_pilihan (
    id SERIAL PRIMARY KEY,
    id_voting INTEGER REFERENCES voting(id),
    pilihan VARCHAR(100) NOT NULL
);

CREATE TABLE voting_jawaban (
    id SERIAL PRIMARY KEY,
    id_voting INTEGER REFERENCES voting(id),
    id_pilihan INTEGER REFERENCES voting_pilihan(id),
    id_anggota INTEGER REFERENCES anggota(id),
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 5. Tabel agenda
```sql
CREATE TABLE agenda (
    id SERIAL PRIMARY KEY,
    judul VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    gambar VARCHAR(200),
    lokasi VARCHAR(100),
    tanggal_mulai TIMESTAMP,
    tanggal_selesai TIMESTAMP,
    dibuat_oleh INTEGER REFERENCES anggota(id),
    tanggal_buat TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 6. Tabel kegiatan
```sql
CREATE TABLE kegiatan (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    judul VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    gambar VARCHAR(200),
    tanggal TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 7. Tabel kegiatan_gambar
```sql
CREATE TABLE kegiatan_gambar (
    id SERIAL PRIMARY KEY,
    id_kegiatan INTEGER REFERENCES kegiatan(id),
    path_gambar VARCHAR(200) NOT NULL
);
```

## 8. Tabel komentar_kegiatan
```sql
CREATE TABLE komentar_kegiatan (
    id SERIAL PRIMARY KEY,
    id_kegiatan INTEGER REFERENCES kegiatan(id),
    id_anggota INTEGER REFERENCES anggota(id),
    isi TEXT NOT NULL,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 9. Tabel notifikasi
```sql
CREATE TABLE notifikasi (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    judul VARCHAR(100),
    isi TEXT,
    sudah_dibaca BOOLEAN DEFAULT FALSE,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 10. Tabel rekomendasi
```sql
CREATE TABLE rekomendasi (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    tipe VARCHAR(30),
    id_referensi INTEGER,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 11. Tabel lokasi_anggota
```sql
CREATE TABLE lokasi_anggota (
    id SERIAL PRIMARY KEY,
    id_anggota INTEGER REFERENCES anggota(id),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
