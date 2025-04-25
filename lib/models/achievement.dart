import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 2)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int points;

  @HiveField(4)
  DateTime earnedDate;

  @HiveField(5)
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.earnedDate,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'earnedDate': earnedDate.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      points: map['points'] as int,
      earnedDate: DateTime.parse(map['earnedDate'] as String),
      isUnlocked: map['isUnlocked'] as bool,
    );
  }
}

@HiveType(typeId: 3)
class UserStats extends HiveObject {
  @HiveField(0)
  int totalPoints;

  @HiveField(1)
  int completedAmalans;

  @HiveField(2)
  int currentStreak;

  @HiveField(3)
  int longestStreak;

  @HiveField(4)
  List<String> unlockedAchievements;

  UserStats({
    this.totalPoints = 0,
    this.completedAmalans = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<String>? unlockedAchievements,
  }) : unlockedAchievements = unlockedAchievements ?? [];

  void addPoints(int points) {
    totalPoints += points;
  }

  void incrementCompletedAmalans() {
    completedAmalans++;
  }

  void incrementStreak() {
    currentStreak++;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  void resetStreak() {
    currentStreak = 0;
  }

  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPoints': totalPoints,
      'completedAmalans': completedAmalans,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'unlockedAchievements': unlockedAchievements,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalPoints: map['totalPoints'] as int,
      completedAmalans: map['completedAmalans'] as int,
      currentStreak: map['currentStreak'] as int,
      longestStreak: map['longestStreak'] as int,
      unlockedAchievements: List<String>.from(map['unlockedAchievements'] as List),
    );
  }
}
