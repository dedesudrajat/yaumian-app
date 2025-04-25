import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quran.dart';
import '../models/ayah.dart';
import '../data/surah_names.dart';
import '../data/surah_translations.dart';

class QuranService {
  static const String baseUrl = 'https://quran-api-id.vercel.app';

  // Mendapatkan daftar semua surah
  Future<List<Surah>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surahs'));
      if (response.statusCode != 200) {
        throw Exception('Failed to load surah list');
      }
      
      final List<dynamic> data = json.decode(response.body);
      return data.map((surah) => Surah(
        number: surah['number'],
        name: surah['name'],
        englishName: surah['englishName'] ?? surah['name'],
        englishNameTranslation: surah['translation'] ?? '',
        revelationType: surah['revelation'] == 'Makkiyah' ? 'Makkiyah' : 'Madaniyah',
        numberOfAyahs: surah['numberOfAyahs'],
      )).toList();
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Mendapatkan detail surah berdasarkan nomor surah
  Future<SurahDetail> getSurahDetail(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surahs/$surahNumber'));
      if (response.statusCode != 200) {
        throw Exception('Failed to load surah details');
      }

      final data = json.decode(response.body);
      final List<dynamic> ayahsData = data['ayahs'];
      
      List<Ayah> ayahs = ayahsData.map((ayah) {
        return Ayah(
          number: ayah['number']['inSurah'],
          text: ayah['arab'],
          translation: ayah['translation'],
          surah: surahNumber,
          juz: ayah['meta']['juz'],
          page: ayah['meta']['page'],
        );
      }).toList();

      return SurahDetail(
        number: data['number'],
        name: data['name'],
        englishName: data['englishName'] ?? data['name'],
        englishNameTranslation: data['translation'] ?? '',
        revelationType: data['revelation'] == 'Makkiyah' ? 'Makkiyah' : 'Madaniyah',
        ayahs: ayahs,
      );
    } catch (e) {
      print('Error in getSurahDetail: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getSurahList() async {
    final response = await http.get(Uri.parse('$baseUrl/surahs'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return {
        'surahs': data.map((surah) {
          return {
            'number': surah['number'],
            'name': surah['name'],
            'englishName': surah['englishName'] ?? surah['name'],
            'indonesianName': surah['translation'] ?? '',
            'revelationType': surah['revelation'] == 'Makkiyah' ? 'Makkiyah' : 'Madaniyah',
            'numberOfAyahs': surah['numberOfAyahs'],
          };
        }).toList(),
      };
    } else {
      throw Exception('Failed to load surah list');
    }
  }

  Future<Map<String, dynamic>> getSurahDetails(int surahNumber) async {
    final response = await http.get(Uri.parse('$baseUrl/surahs/$surahNumber'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'number': data['number'],
        'name': data['name'],
        'englishName': data['englishName'] ?? data['name'],
        'indonesianName': data['translation'] ?? '',
        'revelationType': data['revelation'] == 'Makkiyah' ? 'Makkiyah' : 'Madaniyah',
        'numberOfAyahs': data['numberOfAyahs'],
        'ayahs': data['ayahs'],
      };
    } else {
      throw Exception('Failed to load surah details');
    }
  }
}
