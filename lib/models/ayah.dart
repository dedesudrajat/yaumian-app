import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'ayah.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class Ayah extends HiveObject {
  @HiveField(0)
  @JsonKey(name: 'number')
  final int number;

  @HiveField(1)
  @JsonKey(name: 'text')
  final String text;

  @HiveField(2)
  @JsonKey(name: 'translation')
  final String? translation;

  @HiveField(3)
  @JsonKey(name: 'surah')
  final int surah;

  @HiveField(4)
  @JsonKey(name: 'audioUrl')
  final String? audioUrl;

  @HiveField(5)
  @JsonKey(name: 'isDownloaded')
  bool isDownloaded;

  @HiveField(6)
  @JsonKey(name: 'indonesianTranslation')
  final String? indonesianTranslation;

  @HiveField(7)
  @JsonKey(name: 'juz')
  final int juz;

  @HiveField(8)
  @JsonKey(name: 'page')
  final int page;

  Ayah({
    required this.number,
    required this.text,
    this.translation,
    required this.surah,
    this.audioUrl,
    this.isDownloaded = false,
    this.indonesianTranslation,
    required this.juz,
    required this.page,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
  Map<String, dynamic> toJson() => _$AyahToJson(this);

  factory Ayah.fromQuranAyah(dynamic ayah) {
    final surahNumber = ayah.surah;
    final ayahNumber = ayah.number;
    final audioUrl =
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$surahNumber$ayahNumber.mp3';

    return Ayah(
      number: ayah.number,
      text: ayah.text,
      translation: ayah.translation,
      indonesianTranslation:
          null, // Indonesian translation not available in the package
      audioUrl: audioUrl,
      isDownloaded: false,
      surah: ayah.surah,
      juz: ayah.juz,
      page: ayah.page,
    );
  }

  String get localAudioPath => 'audio_${surah}_$number.mp3';

  void updateDownloadStatus(bool downloaded) {
    isDownloaded = downloaded;
  }

  Ayah copyWith({
    int? number,
    String? text,
    String? translation,
    String? indonesianTranslation,
    String? audioUrl,
    bool? isDownloaded,
    String? localAudioPath,
    int? surah,
    int? juz,
    int? page,
  }) {
    return Ayah(
      number: number ?? this.number,
      text: text ?? this.text,
      translation: translation ?? this.translation,
      indonesianTranslation:
          indonesianTranslation ?? this.indonesianTranslation,
      audioUrl: audioUrl ?? this.audioUrl,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      surah: surah ?? this.surah,
      juz: juz ?? this.juz,
      page: page ?? this.page,
    );
  }
}
