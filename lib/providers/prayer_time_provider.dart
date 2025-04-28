import 'package:flutter/foundation.dart';
import 'package:yaumian_app/services/prayer_time_service.dart';

class PrayerTimeProvider extends ChangeNotifier {
  final PrayerTimeService _prayerTimeService = PrayerTimeService();
  bool _isLoading = true;

  // Getters
  PrayerSchedule? get currentSchedule => _prayerTimeService.currentSchedule;
  String? get currentLocation => _prayerTimeService.currentLocation;
  String? get currentHijriDate => _prayerTimeService.currentHijriDate;
  bool get isLoading => _isLoading;

  // Mendapatkan waktu sholat
  Map<String, String> get prayerTimes {
    if (_prayerTimeService.currentSchedule == null) {
      return {
        'Subuh': '--:--',
        'Syuruq': '--:--',
        'Dzuhur': '--:--',
        'Ashar': '--:--',
        'Maghrib': '--:--',
        'Isya': '--:--',
      };
    }

    return {
      'Subuh': _prayerTimeService.currentSchedule!.fajr,
      'Syuruq': _prayerTimeService.currentSchedule!.sunrise,
      'Dzuhur': _prayerTimeService.currentSchedule!.dhuhr,
      'Ashar': _prayerTimeService.currentSchedule!.asr,
      'Maghrib': _prayerTimeService.currentSchedule!.maghrib,
      'Isya': _prayerTimeService.currentSchedule!.isha,
    };
  }

  // Inisialisasi provider
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    await _prayerTimeService.initialize();

    _isLoading = false;
    notifyListeners();
  }

  // Memperbarui data waktu sholat
  Future<void> refreshPrayerTimes() async {
    _isLoading = true;
    notifyListeners();

    await _prayerTimeService.updatePrayerTimes();
    await _prayerTimeService.updateHijriDate();

    _isLoading = false;
    notifyListeners();
  }

  // Mendapatkan waktu menuju sholat berikutnya
  int getMinutesToNextPrayer() {
    return _prayerTimeService.getMinutesToNextPrayer();
  }

  // Mendapatkan nama sholat berikutnya
  String getNextPrayerName() {
    return _prayerTimeService.getNextPrayerName();
  }
}
