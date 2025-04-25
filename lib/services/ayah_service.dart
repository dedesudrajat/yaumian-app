import 'package:yaumian_app/models/ayah.dart';

class AyahService {
  // Singleton instance
  static final AyahService _instance = AyahService._internal();
  factory AyahService() => _instance;
  AyahService._internal();

  // Bookmark operations
  Future<void> bookmarkAyah(Ayah ayah) async {
    // TODO: Implement bookmark functionality
    // This will be implemented when we add persistence
  }

  Future<void> unbookmarkAyah(Ayah ayah) async {
    // TODO: Implement unbookmark functionality
  }

  Future<bool> isAyahBookmarked(Ayah ayah) async {
    // TODO: Implement bookmark check
    return false;
  }

  // Last read operations
  Future<void> setLastRead(Ayah ayah) async {
    // TODO: Implement last read functionality
  }

  Future<Ayah?> getLastRead() async {
    // TODO: Implement get last read
    return null;
  }

  // Audio operations
  Future<String> getAudioUrl(Ayah ayah) async {
    // Calculate the global ayah number
    // This API uses continuous ayah numbering from 1 to 6236
    final int globalAyahNumber = _calculateGlobalAyahNumber(ayah.surah, ayah.number);
    
    // Using Alquran.cloud API with Mishary Rashid Alafasy recitation
    return 'https://cdn.alquran.cloud/media/audio/ayah/ar.alafasy/$globalAyahNumber';
  }

  // Helper method to calculate global ayah number
  int _calculateGlobalAyahNumber(int surahNumber, int ayahNumber) {
    // Cumulative ayah counts for each surah
    const List<int> ayahCounts = [
      7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
      111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
      54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
      49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52,
      44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
      26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
      6, 3, 5, 4, 5, 6
    ];

    // Calculate global ayah number
    int globalAyah = ayahNumber;
    for (int i = 0; i < surahNumber - 1; i++) {
      globalAyah += ayahCounts[i];
    }
    
    return globalAyah;
  }
} 