import 'package:hive/hive.dart';
import 'package:yaumian_app/models/achievement.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/services/database_service.dart';

class GamificationService {
  static const String userStatsBoxName = 'user_stats';
  static const String achievementsBoxName = 'achievements';

  // Poin yang diberikan untuk berbagai aktivitas
  static const int POINTS_COMPLETE_AMALAN = 10;
  static const int POINTS_STREAK_BONUS = 5;
  static const int POINTS_CATEGORY_COMPLETION = 15;

  // Level thresholds
  static List<int> levelThresholds = [
    0, // Level 1
    100, // Level 2
    250, // Level 3
    500, // Level 4
    1000, // Level 5
    2000, // Level 6
    3500, // Level 7
    5000, // Level 8
    7500, // Level 9
    10000, // Level 10
  ];

  static Future<void> initializeGamification() async {
    await Hive.openBox<UserStats>(userStatsBoxName);
    await Hive.openBox<Achievement>(achievementsBoxName);
    await _initializeDefaultAchievements();
  }

  static Future<void> _initializeDefaultAchievements() async {
    final achievementsBox = Hive.box<Achievement>(achievementsBoxName);

    if (achievementsBox.isEmpty) {
      final defaultAchievements = [
        Achievement(
          id: 'first_amalan',
          title: 'Langkah Pertama',
          description: 'Selesaikan amalan pertama Anda',
          points: 20,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'streak_3',
          title: 'Konsisten',
          description: 'Capai streak 3 hari berturut-turut',
          points: 30,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'streak_7',
          title: 'Semangat Tinggi',
          description: 'Capai streak 7 hari berturut-turut',
          points: 50,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'streak_30',
          title: 'Istiqomah',
          description: 'Capai streak 30 hari berturut-turut',
          points: 200,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'complete_10',
          title: 'Rajin Beramal',
          description: 'Selesaikan 10 amalan',
          points: 50,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'complete_50',
          title: 'Ahli Ibadah',
          description: 'Selesaikan 50 amalan',
          points: 100,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'complete_100',
          title: 'Teladan Amal',
          description: 'Selesaikan 100 amalan',
          points: 200,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
        Achievement(
          id: 'all_categories',
          title: 'Seimbang',
          description: 'Selesaikan amalan dari semua kategori',
          points: 75,
          earnedDate: DateTime.now(),
          isUnlocked: false,
        ),
      ];

      for (var achievement in defaultAchievements) {
        await achievementsBox.put(achievement.id, achievement);
      }
    }
  }

  static Future<UserStats> getUserStats() async {
    final box = await Hive.openBox<UserStats>(userStatsBoxName);
    if (box.isEmpty) {
      final userStats = UserStats();
      await box.add(userStats);
      return userStats;
    }
    return box.getAt(0)!;
  }

  static Future<void> saveUserStats(UserStats userStats) async {
    final box = await Hive.openBox<UserStats>(userStatsBoxName);
    if (box.isEmpty) {
      await box.add(userStats);
    } else {
      await box.putAt(0, userStats);
    }
  }

  static List<Achievement> getAllAchievements() {
    final box = Hive.box<Achievement>(achievementsBoxName);
    return box.values.toList();
  }

  static List<Achievement> getUnlockedAchievements() {
    final box = Hive.box<Achievement>(achievementsBoxName);
    return box.values.where((achievement) => achievement.isUnlocked).toList();
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final box = Hive.box<Achievement>(achievementsBoxName);
    final achievement = box.get(achievementId);
    if (achievement != null && !achievement.isUnlocked) {
      achievement.isUnlocked = true;
      achievement.earnedDate = DateTime.now();
      await achievement.save();

      // Update user stats
      final userStats = await getUserStats();
      userStats.addPoints(achievement.points);
      userStats.unlockAchievement(achievementId);
      await saveUserStats(userStats);
    }
  }

  static Future<void> checkAndUpdateAchievements(UserStats userStats) async {
    // Check for streak achievements
    if (userStats.currentStreak >= 3) {
      await unlockAchievement('streak_3');
    }
    if (userStats.currentStreak >= 7) {
      await unlockAchievement('streak_7');
    }
    if (userStats.currentStreak >= 30) {
      await unlockAchievement('streak_30');
    }

    // Check for completion count achievements
    if (userStats.completedAmalans >= 1) {
      await unlockAchievement('first_amalan');
    }
    if (userStats.completedAmalans >= 10) {
      await unlockAchievement('complete_10');
    }
    if (userStats.completedAmalans >= 50) {
      await unlockAchievement('complete_50');
    }
    if (userStats.completedAmalans >= 100) {
      await unlockAchievement('complete_100');
    }

    // Check for all categories achievement
    await _checkAllCategoriesAchievement();
  }

  static Future<void> _checkAllCategoriesAchievement() async {
    final categories = DatabaseService.getAllKategori();
    final completedCategories = <String>{};

    for (var category in categories) {
      final amalans = DatabaseService.getAmalanByKategori(category.id);
      if (amalans.any((amalan) => amalan.isCompleted)) {
        completedCategories.add(category.id);
      }
    }

    if (completedCategories.length == categories.length) {
      await unlockAchievement('all_categories');
    }
  }

  static int calculateLevel(int points) {
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (points >= levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }

  static int getPointsForNextLevel(int currentLevel) {
    if (currentLevel >= levelThresholds.length) {
      return levelThresholds.last;
    }
    return levelThresholds[currentLevel];
  }

  static double calculateLevelProgress(int points, int currentLevel) {
    if (currentLevel >= levelThresholds.length) {
      return 1.0;
    }

    int currentLevelPoints = levelThresholds[currentLevel - 1];
    int nextLevelPoints = levelThresholds[currentLevel];

    return (points - currentLevelPoints) /
        (nextLevelPoints - currentLevelPoints);
  }

  static Future<void> updateStreakAndPoints(DateTime date) async {
    final userStats = await getUserStats();
    final yesterday = DateTime(date.year, date.month, date.day - 1);
    final todayAmalans = DatabaseService.getAmalanByDate(date);
    final yesterdayAmalans = DatabaseService.getAmalanByDate(yesterday);

    // Check if today has any completed amalans
    bool hasCompletedToday = todayAmalans.any((amalan) => amalan.isCompleted);

    // Check if yesterday had any completed amalans
    bool hadCompletedYesterday = yesterdayAmalans.any(
      (amalan) => amalan.isCompleted,
    );

    // Jika hari ini ada amalan yang diselesaikan
    if (hasCompletedToday) {
      // Jika kemarin juga ada amalan yang diselesaikan atau streak masih 0 (baru mulai)
      if (hadCompletedYesterday || userStats.currentStreak == 0) {
        userStats.incrementStreak();
        userStats.addPoints(POINTS_STREAK_BONUS);
      }
      // Jika kemarin tidak ada amalan yang diselesaikan dan streak > 0, reset streak
      else if (!hadCompletedYesterday && userStats.currentStreak > 0) {
        userStats.resetStreak();
        // Mulai streak baru karena hari ini ada amalan yang diselesaikan
        userStats.incrementStreak();
      }
    } else if (!hasCompletedToday && userStats.currentStreak > 0) {
      // Jika hari ini tidak ada amalan yang diselesaikan dan streak > 0, reset streak
      userStats.resetStreak();
    }

    await saveUserStats(userStats);
    await checkAndUpdateAchievements(userStats);
  }

  static Future<void> awardPointsForCompletion(Amalan amalan) async {
    if (amalan.isCompleted) {
      final userStats = await getUserStats();
      userStats.addPoints(POINTS_COMPLETE_AMALAN);
      userStats.incrementCompletedAmalans();
      await saveUserStats(userStats);
      await checkAndUpdateAchievements(userStats);
    }
  }

  static Future<void> decreaseStreakAndPoints(DateTime date) async {
    final userStats = await getUserStats();
    final todayAmalans = DatabaseService.getAmalanByDate(date);

    // Periksa apakah masih ada amalan yang diselesaikan hari ini
    bool stillHasCompletedToday = todayAmalans.any(
      (amalan) => amalan.isCompleted,
    );

    // Jika tidak ada lagi amalan yang diselesaikan hari ini, kurangi streak
    if (!stillHasCompletedToday && userStats.currentStreak > 0) {
      // Kurangi streak sebanyak 1
      userStats.currentStreak = userStats.currentStreak - 1;
      // Pastikan streak tidak menjadi negatif
      if (userStats.currentStreak < 0) {
        userStats.currentStreak = 0;
      }
      await saveUserStats(userStats);
    }
  }
}
