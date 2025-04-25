import 'package:hive/hive.dart';
import 'package:yaumian_app/models/statistics_data.dart';
import 'package:yaumian_app/services/database_service.dart';

class StatisticsService {
  static const String statisticsBoxName = 'statistics_box';

  static Future<void> initializeStatistics() async {
    await Hive.openBox(statisticsBoxName);
  }

  // Mendapatkan data penyelesaian harian
  static List<DailyCompletionData> getDailyCompletionData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<DailyCompletionData> result = [];

    // Iterasi setiap hari dalam rentang tanggal
    for (
      DateTime date = startDate;
      date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
      date = date.add(const Duration(days: 1))
    ) {
      final amalans = DatabaseService.getAmalanByDate(date);

      if (amalans.isNotEmpty) {
        // Hitung tingkat penyelesaian
        int completed = 0;
        int total = 0;

        for (var amalan in amalans) {
          total += amalan.targetJumlah;
          completed += amalan.jumlahSelesai;
        }

        double completionRate = total > 0 ? completed / total : 0.0;
        result.add(
          DailyCompletionData(date: date, completionRate: completionRate),
        );
      } else {
        // Jika tidak ada amalan pada hari tersebut, tambahkan dengan nilai 0
        result.add(DailyCompletionData(date: date, completionRate: 0.0));
      }
    }

    return result;
  }

  // Mendapatkan data penyelesaian mingguan
  static List<WeeklyCompletionData> getWeeklyCompletionData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<WeeklyCompletionData> result = [];

    // Tentukan awal minggu (Senin) dari tanggal mulai
    DateTime weekStart = startDate.subtract(
      Duration(days: startDate.weekday - 1),
    );

    while (weekStart.isBefore(endDate)) {
      // Tentukan akhir minggu (Minggu)
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      // Jika akhir minggu melebihi tanggal akhir, gunakan tanggal akhir
      if (weekEnd.isAfter(endDate)) {
        weekEnd = endDate;
      }

      // Dapatkan data harian untuk minggu ini
      final dailyData = getDailyCompletionData(weekStart, weekEnd);

      // Hitung rata-rata tingkat penyelesaian untuk minggu ini
      double totalRate = 0.0;
      for (var data in dailyData) {
        totalRate += data.completionRate;
      }

      double weeklyRate =
          dailyData.isNotEmpty ? totalRate / dailyData.length : 0.0;

      // Tentukan nomor minggu dalam tahun
      int weekNumber = _getWeekNumber(weekStart);

      result.add(
        WeeklyCompletionData(
          weekNumber: weekNumber,
          startDate: weekStart,
          endDate: weekEnd,
          completionRate: weeklyRate,
        ),
      );

      // Pindah ke minggu berikutnya
      weekStart = weekStart.add(const Duration(days: 7));
    }

    return result;
  }

  // Mendapatkan data penyelesaian bulanan
  static List<MonthlyCompletionData> getMonthlyCompletionData(
    DateTime startDate,
    DateTime endDate,
  ) {
    final List<MonthlyCompletionData> result = [];

    // Tentukan awal bulan dari tanggal mulai
    DateTime monthStart = DateTime(startDate.year, startDate.month, 1);

    while (monthStart.isBefore(endDate) ||
        monthStart.month == endDate.month && monthStart.year == endDate.year) {
      // Tentukan akhir bulan
      DateTime monthEnd = DateTime(monthStart.year, monthStart.month + 1, 0);

      // Jika akhir bulan melebihi tanggal akhir, gunakan tanggal akhir
      if (monthEnd.isAfter(endDate)) {
        monthEnd = endDate;
      }

      // Dapatkan data harian untuk bulan ini
      final dailyData = getDailyCompletionData(monthStart, monthEnd);

      // Hitung rata-rata tingkat penyelesaian untuk bulan ini
      double totalRate = 0.0;
      for (var data in dailyData) {
        totalRate += data.completionRate;
      }

      double monthlyRate =
          dailyData.isNotEmpty ? totalRate / dailyData.length : 0.0;

      result.add(
        MonthlyCompletionData(
          month: monthStart.month,
          year: monthStart.year,
          completionRate: monthlyRate,
        ),
      );

      // Pindah ke bulan berikutnya
      monthStart = DateTime(monthStart.year, monthStart.month + 1, 1);
    }

    return result;
  }

  // Mendapatkan data penyelesaian berdasarkan kategori
  static List<CategoryData> getCategoryCompletionData() {
    final List<CategoryData> result = [];
    final categories = DatabaseService.getAllKategori();

    for (var category in categories) {
      final amalans = DatabaseService.getAmalanByKategori(category.id);

      if (amalans.isNotEmpty) {
        int completed = 0;
        int total = 0;

        for (var amalan in amalans) {
          total += amalan.targetJumlah;
          completed += amalan.jumlahSelesai;
        }

        double completionRate = total > 0 ? completed / total : 0.0;

        result.add(
          CategoryData(
            categoryId: category.id,
            categoryName: category.nama,
            completionRate: completionRate,
          ),
        );
      } else {
        result.add(
          CategoryData(
            categoryId: category.id,
            categoryName: category.nama,
            completionRate: 0.0,
          ),
        );
      }
    }

    return result;
  }

  // Mendapatkan statistik ringkasan
  static Future<Map<String, dynamic>> getSummaryStatistics() async {
    final allAmalans = DatabaseService.getAllAmalan();
    final categories = DatabaseService.getAllKategori();

    int totalAmalans = allAmalans.length;
    int completedAmalans =
        allAmalans.where((amalan) => amalan.isCompleted).length;
    double completionRate =
        totalAmalans > 0 ? completedAmalans / totalAmalans : 0.0;

    // Hitung kategori dengan tingkat penyelesaian tertinggi
    String topCategoryId = '';
    String topCategoryName = '';
    double topCategoryRate = 0.0;

    for (var category in categories) {
      final categoryAmalans = DatabaseService.getAmalanByKategori(category.id);

      if (categoryAmalans.isNotEmpty) {
        int completed = 0;
        int total = 0;

        for (var amalan in categoryAmalans) {
          total += amalan.targetJumlah;
          completed += amalan.jumlahSelesai;
        }

        double rate = total > 0 ? completed / total : 0.0;

        if (rate > topCategoryRate) {
          topCategoryRate = rate;
          topCategoryId = category.id;
          topCategoryName = category.nama;
        }
      }
    }

    return {
      'totalAmalans': totalAmalans,
      'completedAmalans': completedAmalans,
      'completionRate': completionRate,
      'topCategoryId': topCategoryId,
      'topCategoryName': topCategoryName,
      'topCategoryRate': topCategoryRate,
    };
  }

  // Helper method untuk mendapatkan nomor minggu dalam tahun
  static int _getWeekNumber(DateTime date) {
    int dayOfYear =
        int.parse(
          date.difference(DateTime(date.year, 1, 1)).inDays.toString(),
        ) +
        1;
    int weekOfYear = ((dayOfYear - date.weekday + 10) / 7).floor();

    if (weekOfYear < 1) {
      weekOfYear = _getWeeksInYear(date.year - 1);
    } else if (weekOfYear > _getWeeksInYear(date.year)) {
      weekOfYear = 1;
    }

    return weekOfYear;
  }

  // Helper method untuk mendapatkan jumlah minggu dalam tahun
  static int _getWeeksInYear(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 =
        int.parse(dec28.difference(DateTime(year, 1, 1)).inDays.toString()) + 1;
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }
}
