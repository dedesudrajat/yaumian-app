// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahAdapter extends TypeAdapter<Ayah> {
  @override
  final int typeId = 5;

  @override
  Ayah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Ayah(
      number: fields[0] as int,
      text: fields[1] as String,
      translation: fields[2] as String?,
      surah: fields[3] as int,
      audioUrl: fields[4] as String?,
      isDownloaded: fields[5] as bool,
      indonesianTranslation: fields[6] as String?,
      juz: fields[7] as int,
      page: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Ayah obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.translation)
      ..writeByte(3)
      ..write(obj.surah)
      ..writeByte(4)
      ..write(obj.audioUrl)
      ..writeByte(5)
      ..write(obj.isDownloaded)
      ..writeByte(6)
      ..write(obj.indonesianTranslation)
      ..writeByte(7)
      ..write(obj.juz)
      ..writeByte(8)
      ..write(obj.page);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ayah _$AyahFromJson(Map<String, dynamic> json) => Ayah(
      number: (json['number'] as num).toInt(),
      text: json['text'] as String,
      translation: json['translation'] as String?,
      surah: (json['surah'] as num).toInt(),
      audioUrl: json['audioUrl'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      indonesianTranslation: json['indonesianTranslation'] as String?,
      juz: (json['juz'] as num).toInt(),
      page: (json['page'] as num).toInt(),
    );

Map<String, dynamic> _$AyahToJson(Ayah instance) => <String, dynamic>{
      'number': instance.number,
      'text': instance.text,
      'translation': instance.translation,
      'surah': instance.surah,
      'audioUrl': instance.audioUrl,
      'isDownloaded': instance.isDownloaded,
      'indonesianTranslation': instance.indonesianTranslation,
      'juz': instance.juz,
      'page': instance.page,
    };
