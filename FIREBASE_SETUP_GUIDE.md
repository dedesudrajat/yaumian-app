# Panduan Menghubungkan Aplikasi Yaumian ke Firebase

Dokumen ini berisi panduan langkah demi langkah untuk menghubungkan aplikasi Yaumian ke Firebase.

## Tahapan Menghubungkan ke Firebase

### 1. Menambahkan Dependensi Firebase

Dependensi Firebase telah ditambahkan ke file `pubspec.yaml`:

```yaml
dependencies:
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
```

Jalankan perintah berikut untuk menginstal dependensi:

```bash
flutter pub get
```

### 2. Membuat Project Firebase

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Tambahkan project"
3. Masukkan nama project (misalnya "Yaumian App")
4. Ikuti langkah-langkah untuk membuat project baru

### 3. Menambahkan Aplikasi ke Project Firebase

#### Untuk Android:

1. Di Firebase Console, pilih project yang baru dibuat
2. Klik ikon Android untuk menambahkan aplikasi Android
3. Masukkan package name: `com.yaumian.yaumian_app`
4. Klik "Register app"
5. Download file `google-services.json`
6. Pindahkan file tersebut ke folder `android/app/`
7. Tambahkan plugin Google Services di `android/build.gradle`:

```gradle
buildscript {
  dependencies {
    // ...
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

8. Tambahkan plugin di `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Tambahkan ini
    id("dev.flutter.flutter-gradle-plugin")
}
```

#### Untuk iOS:

1. Di Firebase Console, klik ikon Apple untuk menambahkan aplikasi iOS
2. Masukkan Bundle ID: `com.yaumian.yaumianApp`
3. Klik "Register app"
4. Download file `GoogleService-Info.plist`
5. Buka Xcode, klik kanan pada folder Runner dan pilih "Add Files to 'Runner'"
6. Pilih file `GoogleService-Info.plist` yang telah didownload
7. Pastikan "Copy items if needed" dicentang dan klik "Add"

### 4. Konfigurasi Firebase Options

Update file `lib/firebase_options.dart` dengan nilai-nilai dari Firebase Console:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_ANDROID_API_KEY', // Ganti dengan nilai dari google-services.json
  appId: 'YOUR_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_IOS_API_KEY', // Ganti dengan nilai dari GoogleService-Info.plist
  appId: 'YOUR_IOS_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'YOUR_PROJECT_ID',
  storageBucket: 'YOUR_STORAGE_BUCKET',
  iosClientId: 'YOUR_IOS_CLIENT_ID',
  iosBundleId: 'com.yaumian.yaumianApp',
);
```

### 5. Mengaktifkan Layanan Firebase yang Dibutuhkan

1. Di Firebase Console, pilih project Anda
2. Aktifkan layanan yang dibutuhkan:
   - Authentication: Untuk manajemen pengguna
   - Firestore Database: Untuk penyimpanan data
   - Storage: Untuk penyimpanan file

#### Mengaktifkan Authentication:
1. Pilih "Authentication" di sidebar
2. Klik "Get started"
3. Aktifkan metode autentikasi yang diinginkan (Email/Password, Anonymous, dll)

#### Mengaktifkan Firestore:
1. Pilih "Firestore Database" di sidebar
2. Klik "Create database"
3. Pilih mode keamanan (disarankan "Start in test mode" untuk pengembangan)
4. Pilih lokasi server yang terdekat dengan pengguna Anda

#### Mengaktifkan Storage:
1. Pilih "Storage" di sidebar
2. Klik "Get started"
3. Pilih mode keamanan (disarankan "Start in test mode" untuk pengembangan)
4. Pilih lokasi server yang terdekat dengan pengguna Anda

### 6. Migrasi Data dari Hive ke Firebase

Aplikasi Yaumian saat ini menggunakan Hive sebagai database lokal. Untuk migrasi data ke Firebase:

1. Gunakan `FirebaseService.migrateHiveDataToFirebase()` untuk memindahkan data dari Hive ke Firebase
2. Implementasikan logika migrasi sesuai kebutuhan

### 7. Menggunakan Firebase dalam Aplikasi

Setelah konfigurasi selesai, Anda dapat menggunakan Firebase dalam aplikasi:

```dart
// Autentikasi pengguna
await FirebaseService.signInWithEmailAndPassword(email, password);

// Menyimpan data amalan
await FirebaseService.addAmalan(amalan);

// Mengambil data amalan berdasarkan tanggal
List<Amalan> amalans = await FirebaseService.getAmalanByDate(date);
```

## Keuntungan Menggunakan Firebase

1. **Sinkronisasi Data**: Data tersimpan di cloud dan dapat diakses dari berbagai perangkat
2. **Autentikasi**: Sistem autentikasi yang aman dan mudah diimplementasikan
3. **Realtime Database**: Pembaruan data secara realtime
4. **Skalabilitas**: Dapat menangani jumlah pengguna yang besar
5. **Analytics**: Analisis penggunaan aplikasi

## Catatan Penting

- Pastikan untuk menambahkan aturan keamanan yang sesuai di Firestore dan Storage setelah fase pengembangan
- Backup data secara berkala
- Perhatikan kuota penggunaan Firebase untuk menghindari biaya yang tidak diinginkan