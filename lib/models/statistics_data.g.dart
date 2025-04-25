// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryDataAdapter extends TypeAdapter<CategoryData> {
  @override
  final int typeId = 4;

  @override
  CategoryData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryData(
      categoryId: fields[0] as String,
      categoryName: fields[1] as String,
      completionRate: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.categoryId)
      ..writeByte(1)
      ..write(obj.categoryName)
      ..writeByte(2)
      ..write(obj.completionRate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class StatisticsDataAdapter extends TypeAdapter<StatisticsData> {
  @override
  final int typeId = 5;

  @override
  StatisticsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StatisticsData(
      totalPoints: fields[0] as int,
      completedAmalans: fields[1] as int,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      unlockedAchievements: (fields[4] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, StatisticsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalPoints)
      ..writeByte(1)
      ..write(obj.completedAmalans)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.unlockedAchievements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
