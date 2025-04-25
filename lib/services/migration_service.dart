import 'package:hive_flutter/hive_flutter.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/models/achievement.dart';
import 'package:yaumian_app/services/firebase_service.dart';
import 'package:yaumian_app/services/database_service.dart';

class MigrationService {
  // Metode untuk migrasi data dari Hive ke Firebase
  static Future<void> migrateDataToFirebase() async {
    await _migrateAmalans();
    await _migrateKategoris();
    await _migrateAchievements();
    await _migrateUserStats();
    await _migrateGroups();
  }

  // Migrasi data amalan
  static Future<void> _migrateAmalans() async {
    final Box<Amalan> amalanBox = Hive.box<Amalan>(
      DatabaseService.amalanBoxName,
    );

    for (var i = 0; i < amalanBox.length; i++) {
      final Amalan? amalan = amalanBox.getAt(i);
      if (amalan != null) {
        await FirebaseService.addAmalan(amalan);
      }
    }
  }

  // Migrasi data kategori
  static Future<void> _migrateKategoris() async {
    final Box<Kategori> kategoriBox = Hive.box<Kategori>(
      DatabaseService.kategoriBoxName,
    );

    for (var i = 0; i < kategoriBox.length; i++) {
      final Kategori? kategori = kategoriBox.getAt(i);
      if (kategori != null) {
        await FirebaseService.addKategori(kategori);
      }
    }
  }

  // Migrasi data achievement
  static Future<void> _migrateAchievements() async {
    final Box<Achievement> achievementBox = Hive.box<Achievement>(
      'achievements',
    );

    // Implementasi migrasi achievement ke Firebase
    // Kode akan ditambahkan sesuai dengan struktur data achievement di Firebase
  }

  // Migrasi data statistik pengguna
  static Future<void> _migrateUserStats() async {
    // Implementasi migrasi statistik pengguna ke Firebase
    // Kode akan ditambahkan sesuai dengan struktur data statistik di Firebase
  }

  // Migrasi data grup
  static Future<void> _migrateGroups() async {
    // Implementasi migrasi data grup ke Firebase
    // Kode akan ditambahkan sesuai dengan struktur data grup di Firebase
  }

  // Metode untuk memeriksa apakah migrasi sudah dilakukan
  static Future<bool> isMigrationCompleted() async {
    // Implementasi untuk memeriksa status migrasi
    // Misalnya, dengan menyimpan flag di SharedPreferences atau Firestore
    return false; // Default: migrasi belum dilakukan
  }
}
