import 'package:json_annotation/json_annotation.dart';
import 'ayah.dart';

part 'quran.g.dart';

@JsonSerializable()
class Surah {
  final int number;
  final String name;
  final String? englishName;
  final String? englishNameTranslation;
  final String? revelationType;
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.name,
    this.englishName,
    this.englishNameTranslation,
    this.revelationType,
    required this.numberOfAyahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
  Map<String, dynamic> toJson() => _$SurahToJson(this);

  factory Surah.fromQuranSurah(dynamic surah) {
    return Surah(
      number: surah.number,
      name: surah.name,
      englishName: surah.englishName,
      englishNameTranslation: surah.englishNameTranslation,
      revelationType: surah.revelationType,
      numberOfAyahs: surah.numberOfAyahs,
    );
  }
}

@JsonSerializable()
class QuranResponse {
  final int code;
  final String status;
  final List<Surah> data;

  QuranResponse({required this.code, required this.status, required this.data});

  factory QuranResponse.fromJson(Map<String, dynamic> json) =>
      _$QuranResponseFromJson(json);
  Map<String, dynamic> toJson() => _$QuranResponseToJson(this);
}

@JsonSerializable()
class SurahDetailResponse {
  final int code;
  final String status;
  final SurahDetail data;

  SurahDetailResponse({
    required this.code,
    required this.status,
    required this.data,
  });

  factory SurahDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$SurahDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SurahDetailResponseToJson(this);
}

@JsonSerializable()
class SurahDetail {
  final int number;
  final String name;
  final String? englishName;
  final String? englishNameTranslation;
  final String? revelationType;
  final List<Ayah> ayahs;

  SurahDetail({
    required this.number,
    required this.name,
    this.englishName,
    this.englishNameTranslation,
    this.revelationType,
    required this.ayahs,
  });

  factory SurahDetail.fromJson(Map<String, dynamic> json) =>
      _$SurahDetailFromJson(json);
  Map<String, dynamic> toJson() => _$SurahDetailToJson(this);

  factory SurahDetail.fromQuranSurah(dynamic surah) {
    return SurahDetail(
      number: surah.number,
      name: surah.name,
      englishName: surah.englishName,
      englishNameTranslation: surah.englishNameTranslation,
      revelationType: surah.revelationType,
      ayahs: surah.ayahs.map<Ayah>((ayah) => Ayah.fromQuranAyah(ayah)).toList(),
    );
  }
}
