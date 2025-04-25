import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:yaumian_app/models/achievement.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/statistics_data.dart';
import 'package:yaumian_app/services/database_service.dart';
import 'package:yaumian_app/services/gamification_service.dart';
import 'package:yaumian_app/services/statistics_service.dart';

class AmalanProvider with ChangeNotifier {
  List<Amalan> _amalanList = [];
  DateTime _selectedDate = DateTime.now();
  int _userPoints = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;
  List<Achievement> _achievements = [];
  List<DailyCompletionData> _dailyCompletionData = [];
  List<WeeklyCompletionData> _weeklyCompletionData = [];
  List<MonthlyCompletionData> _monthlyCompletionData = [];
  List<CategoryData> _categoryData = [];

  List<Amalan> get amalanList => _amalanList;
  DateTime get selectedDate => _selectedDate;
  int get userPoints => _userPoints;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  List<Achievement> get achievements => _achievements;
  List<DailyCompletionData> get dailyCompletionData => _dailyCompletionData;
  List<WeeklyCompletionData> get weeklyCompletionData => _weeklyCompletionData;
  List<MonthlyCompletionData> get monthlyCompletionData =>
      _monthlyCompletionData;
  List<CategoryData> get categoryData => _categoryData;

  AmalanProvider() {
    _loadAmalanForSelectedDate();
    _loadStatistics();
  }

  /// Menginisialisasi amalan default jika belum ada amalan untuk hari ini
  /// Amalan default akan dibuat untuk setiap hari baru
  Future<void> _initializeDefaultAmalanIfNeeded() async {
    // Cek apakah ada amalan untuk hari yang dipilih
    if (_amalanList.isEmpty) {
      // Tambahkan amalan default untuk hari yang dipilih
      final defaultAmalans = [
        Amalan(
          id: const Uuid().v4(),
          nama: 'Sholat 5 Waktu',
          deskripsi:
              'Sholat wajib 5 waktu (Subuh, Dzuhur, Ashar, Maghrib, Isya)',
          tanggal: _selectedDate,
          kategori: '1', // ID kategori Ibadah Wajib
          targetJumlah: 5,
          jumlahSelesai: 0, // Pastikan progress dimulai dari 0
        ),
        Amalan(
          id: const Uuid().v4(),
          nama: 'Membaca Al-Quran',
          deskripsi: 'Membaca Al-Quran minimal 1 halaman setiap hari',
          tanggal: _selectedDate,
          kategori: '4', // ID kategori Membaca
          targetJumlah: 1,
          jumlahSelesai: 0,
        ),
        Amalan(
          id: const Uuid().v4(),
          nama: 'Dzikir Pagi & Petang',
          deskripsi: 'Membaca dzikir pagi dan petang setiap hari',
          tanggal: _selectedDate,
          kategori: '3', // ID kategori Dzikir
          targetJumlah: 2,
          jumlahSelesai: 0,
        ),
        Amalan(
          id: const Uuid().v4(),
          nama: 'Sunnah Harian',
          deskripsi:
              'Amalan sunnah seperti sholat dhuha, tahajud, atau puasa sunnah',
          tanggal: _selectedDate,
          kategori: '2', // ID kategori Sunnah
          targetJumlah: 1,
          jumlahSelesai: 0,
        ),
      ];

      // Simpan semua amalan default ke database
      for (var amalan in defaultAmalans) {
        await DatabaseService.addAmalan(amalan);
      }

      // Muat ulang daftar amalan setelah menambahkan semua amalan default
      _amalanList = DatabaseService.getAmalanByDate(_selectedDate);
      notifyListeners();
    } else {
      // Jika sudah ada amalan, tetap perlu memanggil notifyListeners()
      // untuk memperbarui UI setelah memuat data
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _loadAmalanForSelectedDate();
    // notifyListeners() dipanggil di dalam _loadAmalanForSelectedDate()
  }

  void _loadAmalanForSelectedDate() {
    _amalanList = DatabaseService.getAmalanByDate(_selectedDate);
    _initializeDefaultAmalanIfNeeded(); // Ini akan menambahkan amalan default jika diperlukan
    // Load user stats dan achievements
    _loadUserStats();
    _loadAchievements();
    // Update streak jika tanggal berubah
    _updateStreakIfNeeded();
    // notifyListeners() dipanggil di dalam _initializeDefaultAmalanIfNeeded() jika ada perubahan
  }

  Future<void> _loadUserStats() async {
    try {
      final userStats = await GamificationService.getUserStats();
      _userPoints = userStats.totalPoints;
      _currentStreak = userStats.currentStreak;
      _longestStreak = userStats.longestStreak;
      notifyListeners();
    } catch (e) {
      print('Error loading user stats: $e');
    }
  }

  Future<void> _loadAchievements() async {
    try {
      _achievements = GamificationService.getUnlockedAchievements();
      notifyListeners();
    } catch (e) {
      print('Error loading achievements: $e');
    }
  }

  Future<void> _updateStreakIfNeeded() async {
    try {
      // Periksa apakah tanggal yang dipilih adalah hari ini
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );

      // Jika tanggal yang dipilih adalah hari ini, update streak
      if (selectedDay.isAtSameMomentAs(today)) {
        await GamificationService.updateStreakAndPoints(today);
        await _loadUserStats();
      }
    } catch (e) {
      print('Error updating streak: $e');
    }
  }

  // Metode ini dipanggil saat pengguna menyelesaikan amalan
  Future<void> _updateStreakAfterCompletion() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await GamificationService.updateStreakAndPoints(today);
      await _loadUserStats();
    } catch (e) {
      print('Error updating streak after completion: $e');
    }
  }

  // Metode ini dipanggil saat pengguna membatalkan amalan yang sudah selesai
  Future<void> _decreaseStreakAfterCancellation() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      await GamificationService.decreaseStreakAndPoints(today);
      await _loadUserStats();
    } catch (e) {
      print('Error decreasing streak after cancellation: $e');
    }
  }

  Future<void> _loadStatistics() async {
    try {
      // Tentukan rentang waktu untuk statistik (30 hari terakhir)
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month, now.day);
      final startDate = endDate.subtract(const Duration(days: 30));

      // Muat data statistik
      _dailyCompletionData = StatisticsService.getDailyCompletionData(
        startDate,
        endDate,
      );
      _weeklyCompletionData = StatisticsService.getWeeklyCompletionData(
        startDate,
        endDate,
      );
      _monthlyCompletionData = StatisticsService.getMonthlyCompletionData(
        startDate,
        endDate,
      );
      _categoryData = StatisticsService.getCategoryCompletionData();

      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  Future<void> addAmalan({
    required String nama,
    required String deskripsi,
    required String kategoriId,
    int targetJumlah = 1,
  }) async {
    final newAmalan = Amalan(
      id: const Uuid().v4(),
      nama: nama,
      deskripsi: deskripsi,
      tanggal: _selectedDate,
      kategori: kategoriId,
      targetJumlah: targetJumlah,
    );

    await DatabaseService.addAmalan(newAmalan);
    _loadAmalanForSelectedDate();
  }

  Future<void> updateAmalan(Amalan amalan) async {
    await DatabaseService.updateAmalan(amalan);
    _loadAmalanForSelectedDate();
  }

  Future<void> deleteAmalan(String id) async {
    await DatabaseService.deleteAmalan(id);
    _loadAmalanForSelectedDate();
  }

  Future<void> toggleAmalanCompletion(String id) async {
    final index = _amalanList.indexWhere((amalan) => amalan.id == id);
    if (index != -1) {
      final amalan = _amalanList[index];
      final wasCompleted = amalan.isCompleted;
      amalan.selesai = !amalan.selesai;

      // Update amalan di database
      await DatabaseService.updateAmalan(amalan);

      // Berikan poin jika amalan diselesaikan dan belum selesai sebelumnya
      if (amalan.isCompleted && !wasCompleted) {
        await GamificationService.awardPointsForCompletion(amalan);
        // Update streak setelah menyelesaikan amalan
        await _updateStreakAfterCompletion();
        await _loadUserStats();
        await _loadAchievements();
      }
      // Kurangi streak jika amalan dibatalkan (dari selesai menjadi belum selesai)
      else if (!amalan.isCompleted && wasCompleted) {
        await _decreaseStreakAfterCancellation();
        await _loadUserStats();
        await _loadAchievements();
      }

      notifyListeners();
    }
  }

  Future<void> toggleAmalanStatus(Amalan amalan) async {
    amalan.incrementProgress();
    await DatabaseService.updateAmalan(amalan);

    // Tambahkan poin saat menyelesaikan amalan
    if (amalan.isCompleted) {
      await GamificationService.awardPointsForCompletion(amalan);
      await _loadUserStats();
      await _loadAchievements();
    }

    _loadAmalanForSelectedDate();
  }

  Future<void> incrementAmalanProgress(String id) async {
    final index = _amalanList.indexWhere((amalan) => amalan.id == id);
    if (index != -1) {
      final amalan = _amalanList[index];
      final wasCompleted = amalan.isCompleted;

      // Cek apakah sudah mencapai target
      if (amalan.jumlahSelesai < amalan.targetJumlah) {
        amalan.incrementProgress();
        await DatabaseService.updateAmalan(amalan);

        // Jika mencapai target setelah increment dan belum selesai sebelumnya, berikan poin
        if (amalan.isCompleted && !wasCompleted) {
          await GamificationService.awardPointsForCompletion(amalan);
          await _loadUserStats();
          await _loadAchievements();
        }

        notifyListeners();
      }
    }
  }

  Future<void> resetAmalanProgress(Amalan amalan) async {
    amalan.resetProgress();
    await DatabaseService.updateAmalan(amalan);
    _loadAmalanForSelectedDate();
  }

  /// Memuat ulang daftar amalan untuk tanggal yang dipilih
  Future<void> refreshAmalanList() async {
    _loadAmalanForSelectedDate();
  }

  // Metode untuk gamifikasi
  int getUserPoints() {
    return _userPoints;
  }

  int getUserLevel() {
    return GamificationService.calculateLevel(_userPoints);
  }

  int getPointsForNextLevel() {
    final currentLevel = getUserLevel();
    return GamificationService.getPointsForNextLevel(currentLevel);
  }

  double getLevelProgress() {
    final currentLevel = getUserLevel();
    return GamificationService.calculateLevelProgress(
      _userPoints,
      currentLevel,
    );
  }

  double getWeeklyCompletionRate() {
    if (_weeklyCompletionData.isEmpty) return 0.0;
    double sum = 0.0;
    for (var data in _weeklyCompletionData) {
      sum += data.completionRate;
    }
    return sum / _weeklyCompletionData.length;
  }

  double getMonthlyCompletionRate() {
    if (_monthlyCompletionData.isEmpty) return 0.0;
    double sum = 0.0;
    for (var data in _monthlyCompletionData) {
      sum += data.completionRate;
    }
    return sum / _monthlyCompletionData.length;
  }

  List<Achievement> getUserAchievements() {
    // Implementasi sederhana untuk demo
    return [
      Achievement(
        id: '1',
        title: 'Pemula',
        description: 'Selesaikan 10 amalan',
        points: 50,
        earnedDate: DateTime.now(),
        isUnlocked: true,
      ),
      Achievement(
        id: '2',
        title: 'Konsisten',
        description: 'Selesaikan amalan 7 hari berturut-turut',
        points: 100,
        earnedDate: DateTime.now().subtract(const Duration(days: 2)),
        isUnlocked: true,
      ),
    ];
  }

  List<Amalan> getAmalanByKategori(String kategoriId) {
    return _amalanList
        .where((amalan) => amalan.kategori == kategoriId)
        .toList();
  }

  double getProgressPercentage() {
    if (_amalanList.isEmpty) return 0.0;

    int totalCompleted =
        _amalanList.where((amalan) => amalan.isCompleted).length;
    return totalCompleted / _amalanList.length;
  }

  /// Mendapatkan status penyelesaian amalan untuk tanggal tertentu
  /// Return: 0 = tidak ada yang selesai, 1 = sebagian selesai, 2 = semua selesai
  int getDailyCompletionStatus(DateTime date) {
    final dailyAmalans = DatabaseService.getAmalanByDate(date);

    if (dailyAmalans.isEmpty) return 0;

    final completedCount =
        dailyAmalans.where((amalan) => amalan.isCompleted).length;

    if (completedCount == 0) return 0; // Tidak ada yang selesai
    if (completedCount == dailyAmalans.length) return 2; // Semua selesai
    return 1; // Sebagian selesai
  }

  /// Mendapatkan semua amalan dari database untuk ditampilkan di kalender
  List<Amalan> getAllAmalans() {
    return DatabaseService.getAllAmalan();
  }

  // Metode untuk statistik
  List<DailyCompletionData> getWeeklyCompletionData() {
    // Implementasi untuk mendapatkan data 7 hari terakhir
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = DateTime(now.year, now.month, now.day - 6 + index);
      // Simulasi data untuk demo
      final completionRate = (index * 10.0) + 30.0;
      return DailyCompletionData(date: date, completionRate: completionRate);
    });
  }

  // Metode getWeeklyCompletionRate() sudah diimplementasikan di atas

  List<CategoryData> getWeeklyCategoryData() {
    // Data kategori untuk demo
    return [
      CategoryData(
        categoryId: '1',
        categoryName: 'Ibadah Wajib',
        completionRate: 85.0,
      ),
      CategoryData(
        categoryId: '2',
        categoryName: 'Ibadah Sunnah',
        completionRate: 65.0,
      ),
      CategoryData(
        categoryId: '3',
        categoryName: 'Dzikir',
        completionRate: 75.0,
      ),
      CategoryData(
        categoryId: '4',
        categoryName: 'Membaca',
        completionRate: 50.0,
      ),
      CategoryData(
        categoryId: '5',
        categoryName: 'Sedekah',
        completionRate: 30.0,
      ),
    ];
  }

  List<WeeklyCompletionData> getMonthlyCompletionData() {
    // Data 4 minggu terakhir untuk demo
    final now = DateTime.now();
    return List.generate(4, (index) {
      final weekNumber = index + 1;
      final startDate = DateTime(now.year, now.month, 1 + (index * 7));
      final endDate = DateTime(now.year, now.month, 7 + (index * 7));
      final completionRate = 40.0 + (index * 15.0);
      return WeeklyCompletionData(
        weekNumber: weekNumber,
        startDate: startDate,
        endDate: endDate,
        completionRate: completionRate,
      );
    });
  }

  // Metode getMonthlyCompletionRate() sudah diimplementasikan di atas

  List<CategoryData> getMonthlyCategoryData() {
    // Data kategori bulanan untuk demo
    return [
      CategoryData(
        categoryId: '1',
        categoryName: 'Ibadah Wajib',
        completionRate: 80.0,
      ),
      CategoryData(
        categoryId: '2',
        categoryName: 'Ibadah Sunnah',
        completionRate: 60.0,
      ),
      CategoryData(
        categoryId: '3',
        categoryName: 'Dzikir',
        completionRate: 70.0,
      ),
      CategoryData(
        categoryId: '4',
        categoryName: 'Membaca',
        completionRate: 55.0,
      ),
      CategoryData(
        categoryId: '5',
        categoryName: 'Sedekah',
        completionRate: 35.0,
      ),
    ];
  }
}
