import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
part 'statistics_data.g.dart';

class DailyCompletionData {
  final DateTime date;
  final double completionRate;

  DailyCompletionData({required this.date, required this.completionRate});
}

class WeeklyCompletionData {
  final int weekNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double completionRate;

  WeeklyCompletionData({
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.completionRate,
  });
}

class MonthlyCompletionData {
  final int month;
  final int year;
  final double completionRate;

  MonthlyCompletionData({
    required this.month,
    required this.year,
    required this.completionRate,
  });
}

@HiveType(typeId: 4)
class CategoryData extends HiveObject {
  @HiveField(0)
  final String categoryId;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final double completionRate;

  CategoryData({
    required this.categoryId,
    required this.categoryName,
    required this.completionRate,
  });
}

@HiveType(typeId: 5)
class StatisticsData extends HiveObject {
  @HiveField(0)
  final int totalPoints;

  @HiveField(1)
  final int completedAmalans;

  @HiveField(2)
  final int currentStreak;

  @HiveField(3)
  final int longestStreak;

  @HiveField(4)
  final List<String> unlockedAchievements;

  StatisticsData({
    required this.totalPoints,
    required this.completedAmalans,
    required this.currentStreak,
    required this.longestStreak,
    required this.unlockedAchievements,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalPoints': totalPoints,
      'completedAmalans': completedAmalans,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  factory StatisticsData.fromMap(Map<String, dynamic> map) {
    return StatisticsData(
      totalPoints: map['totalPoints'] as int,
      completedAmalans: map['completedAmalans'] as int,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      unlockedAchievements: List<String>.from(map['unlockedAchievements'] as List),
    );
  }
}
