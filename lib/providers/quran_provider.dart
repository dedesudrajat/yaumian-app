import 'package:flutter/material.dart';
import 'package:yaumian_app/models/quran.dart';
import 'package:yaumian_app/services/quran_service.dart';

class QuranProvider extends ChangeNotifier {
  final QuranService _quranService = QuranService();

  List<Surah> _surahs = [];
  SurahDetail? _currentSurah;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Surah> get surahs => _surahs;
  SurahDetail? get currentSurah => _currentSurah;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Mengambil semua surah
  Future<void> fetchAllSurahs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surahs = await _quranService.getAllSurahs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mengambil detail surah berdasarkan nomor
  Future<void> fetchSurahDetail(int surahNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentSurah = await _quranService.getSurahDetail(surahNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Reset state
  void resetState() {
    _currentSurah = null;
    _error = null;
    notifyListeners();
  }
}
