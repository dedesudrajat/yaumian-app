import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/models/achievement.dart';
import 'package:yaumian_app/models/statistics_data.dart';
import 'package:yaumian_app/models/group.dart';
import 'package:yaumian_app/services/group_service.dart';
import 'package:hive/hive.dart';

class DatabaseService {
  static const String amalanBoxName = 'amalan_box';
  static const String kategoriBoxName = 'kategori_box';

  static Future<void> initializeHive() async {
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDirectory.path);

    // Register adapters
    Hive.registerAdapter(AmalanAdapter());
    Hive.registerAdapter(KategoriAdapter());
    Hive.registerAdapter(AchievementAdapter());
    Hive.registerAdapter(UserStatsAdapter());
    Hive.registerAdapter(CategoryDataAdapter());

    // Register Group-related adapters
    Hive.registerAdapter(GroupAdapter());
    Hive.registerAdapter(GroupAmalanAdapter());
    Hive.registerAdapter(GroupMemberProgressAdapter());
    Hive.registerAdapter(GroupInvitationAdapter());

    // Open boxes
    await Hive.openBox<Amalan>(amalanBoxName);
    await Hive.openBox<Kategori>(kategoriBoxName);
    await Hive.openBox<Achievement>('achievements');
    await Hive.openBox<UserStats>('user_stats');
    await Hive.openBox('statistics_box');

    // Initialize Group-related adapters and boxes
    await GroupService.initializeGroupBoxes();

    // Initialize default categories if empty
    await _initializeDefaultCategories();
  }

  static Future<void> _initializeDefaultCategories() async {
    final kategoriBox = Hive.box<Kategori>(kategoriBoxName);

    if (kategoriBox.isEmpty) {
      final defaultCategories = [
        Kategori(
          id: '1',
          nama: 'Ibadah Wajib',
          deskripsi: 'Amalan ibadah yang wajib dilakukan',
          warna: '#4CAF50', // Green
          icon: 'mosque',
        ),
        Kategori(
          id: '2',
          nama: 'Sunnah',
          deskripsi: 'Amalan sunnah harian',
          warna: '#2196F3', // Blue
          icon: 'star',
        ),
        Kategori(
          id: '3',
          nama: 'Dzikir',
          deskripsi: 'Amalan dzikir harian',
          warna: '#9C27B0', // Purple
          icon: 'favorite',
        ),
        Kategori(
          id: '4',
          nama: 'Membaca',
          deskripsi: 'Amalan membaca Al-Quran atau buku',
          warna: '#FF9800', // Orange
          icon: 'book',
        ),
        Kategori(
          id: '5',
          nama: 'Lainnya',
          deskripsi: 'Amalan lainnya',
          warna: '#607D8B', // Blue Grey
          icon: 'list',
        ),
      ];

      for (var kategori in defaultCategories) {
        await kategoriBox.put(kategori.id, kategori);
      }
    }
  }

  // CRUD operations for Amalan
  static Future<void> addAmalan(Amalan amalan) async {
    final box = Hive.box<Amalan>(amalanBoxName);
    await box.put(amalan.id, amalan);
  }

  static Future<void> updateAmalan(Amalan amalan) async {
    final box = Hive.box<Amalan>(amalanBoxName);
    await box.put(amalan.id, amalan);
  }

  static Future<void> deleteAmalan(String id) async {
    final box = Hive.box<Amalan>(amalanBoxName);
    await box.delete(id);
  }

  static List<Amalan> getAllAmalan() {
    final box = Hive.box<Amalan>(amalanBoxName);
    return box.values.toList();
  }

  static List<Amalan> getAmalanByDate(DateTime date) {
    final box = Hive.box<Amalan>(amalanBoxName);
    return box.values
        .where(
          (amalan) =>
              amalan.tanggal.year == date.year &&
              amalan.tanggal.month == date.month &&
              amalan.tanggal.day == date.day,
        )
        .toList();
  }

  static List<Amalan> getAmalanByKategori(String kategoriId) {
    final box = Hive.box<Amalan>(amalanBoxName);
    return box.values.where((amalan) => amalan.kategori == kategoriId).toList();
  }

  // CRUD operations for Kategori
  static List<Kategori> getAllKategori() {
    final box = Hive.box<Kategori>(kategoriBoxName);
    return box.values.toList();
  }

  static Kategori? getKategoriById(String id) {
    final box = Hive.box<Kategori>(kategoriBoxName);
    return box.get(id);
  }

  static Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }
}
