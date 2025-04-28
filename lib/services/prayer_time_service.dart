import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';

class PrayerTimeService {
  // Singleton instance
  static final PrayerTimeService _instance = PrayerTimeService._internal();
  factory PrayerTimeService() => _instance;
  PrayerTimeService._internal();

  // Cache key untuk menyimpan data waktu sholat
  static const String _cacheKey = 'prayer_times_cache';
  static const String _locationCacheKey = 'user_location_cache';
  static const String _lastFetchDateKey = 'last_fetch_date';

  // Model untuk data waktu sholat
  PrayerSchedule? _currentSchedule;
  String? _currentLocation;
  String? _currentHijriDate;

  // Getter untuk data waktu sholat
  PrayerSchedule? get currentSchedule => _currentSchedule;
  String? get currentLocation => _currentLocation;
  String? get currentHijriDate => _currentHijriDate;

  // Inisialisasi service
  Future<void> initialize() async {
    await _loadCachedData();
    await updatePrayerTimes();
    await updateHijriDate();
  }

  // Memuat data dari cache
  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedLocation = prefs.getString(_locationCacheKey);

    if (cachedData != null) {
      _currentSchedule = PrayerSchedule.fromJson(json.decode(cachedData));
    }

    if (cachedLocation != null) {
      _currentLocation = cachedLocation;
    }
  }

  // Menyimpan data ke cache
  Future<void> _saveToCache(PrayerSchedule schedule, String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(schedule.toJson()));
    await prefs.setString(_locationCacheKey, location);
    await prefs.setString(_lastFetchDateKey, DateTime.now().toIso8601String());
  }

  // Mendapatkan lokasi pengguna
  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Memeriksa apakah layanan lokasi diaktifkan
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi dinonaktifkan');
    }

    // Memeriksa izin lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak secara permanen');
    }

    // Mendapatkan posisi saat ini
    return await Geolocator.getCurrentPosition();
  }

  // Mendapatkan nama lokasi dari koordinat
  Future<String> _getLocationName(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality}, ${place.country}';
      }
      return 'Lokasi tidak diketahui';
    } catch (e) {
      return 'Lokasi tidak diketahui';
    }
  }

  // Memperbarui waktu sholat
  Future<void> updatePrayerTimes() async {
    try {
      // Memeriksa apakah perlu memperbarui data (hanya sekali sehari)
      final prefs = await SharedPreferences.getInstance();
      final lastFetchDateStr = prefs.getString(_lastFetchDateKey);

      if (lastFetchDateStr != null) {
        final lastFetchDate = DateTime.parse(lastFetchDateStr);
        final now = DateTime.now();
        if (lastFetchDate.year == now.year &&
            lastFetchDate.month == now.month &&
            lastFetchDate.day == now.day) {
          // Data sudah diperbarui hari ini
          return;
        }
      }

      // Mendapatkan posisi pengguna
      final position = await _getCurrentPosition();
      final locationName = await _getLocationName(position);

      // Mendapatkan waktu sholat dari API
      final schedule = await _fetchPrayerTimes(
        position.latitude,
        position.longitude,
      );

      // Memperbarui data
      _currentSchedule = schedule;
      _currentLocation = locationName;

      // Menyimpan data ke cache
      await _saveToCache(schedule, locationName);
    } catch (e) {
      // Jika gagal, gunakan data default atau cache
      if (_currentSchedule == null) {
        _currentSchedule = PrayerSchedule(
          fajr: '04:50',
          sunrise: '06:31',
          dhuhr: '11:48',
          asr: '15:05',
          maghrib: '17:06',
          isha: '18:28',
          date: DateTime.now(),
        );
      }

      if (_currentLocation == null) {
        _currentLocation = 'Lokasi tidak tersedia';
      }
    }
  }

  // Memperbarui tanggal Hijriah
  Future<void> updateHijriDate() async {
    try {
      final hijri = HijriCalendar.now();
      _currentHijriDate =
          '${hijri.longMonthName} ${hijri.hDay}, ${hijri.hYear} H';
    } catch (e) {
      _currentHijriDate = 'Tanggal Hijriah tidak tersedia';
    }
  }

  // Mendapatkan waktu sholat dari API
  Future<PrayerSchedule> _fetchPrayerTimes(
    double latitude,
    double longitude,
  ) async {
    try {
      final today = DateTime.now();
      final formattedDate = DateFormat('dd-MM-yyyy').format(today);

      // API URL (contoh menggunakan API Aladhan)
      final url =
          'https://api.aladhan.com/v1/timings/$formattedDate?latitude=$latitude&longitude=$longitude&method=2';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return PrayerSchedule(
          fajr: timings['Fajr'],
          sunrise: timings['Sunrise'],
          dhuhr: timings['Dhuhr'],
          asr: timings['Asr'],
          maghrib: timings['Maghrib'],
          isha: timings['Isha'],
          date: today,
        );
      } else {
        throw Exception('Gagal memuat data waktu sholat');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Menghitung waktu menuju sholat berikutnya (dalam menit)
  int getMinutesToNextPrayer() {
    if (_currentSchedule == null) return 0;

    final now = DateTime.now();
    final currentTime =
        int.parse(DateFormat('HH').format(now)) * 60 +
        int.parse(DateFormat('mm').format(now));

    final prayerTimes = {
      'Subuh': _timeToMinutes(_currentSchedule!.fajr),
      'Syuruq': _timeToMinutes(_currentSchedule!.sunrise),
      'Dzuhur': _timeToMinutes(_currentSchedule!.dhuhr),
      'Ashar': _timeToMinutes(_currentSchedule!.asr),
      'Maghrib': _timeToMinutes(_currentSchedule!.maghrib),
      'Isya': _timeToMinutes(_currentSchedule!.isha),
    };

    String nextPrayer = 'Subuh';
    int minutesToNext = 24 * 60; // Default ke maksimum (24 jam)

    prayerTimes.forEach((prayer, time) {
      final diff = time - currentTime;
      if (diff > 0 && diff < minutesToNext) {
        minutesToNext = diff;
        nextPrayer = prayer;
      }
    });

    // Jika semua waktu sholat hari ini sudah lewat, hitung ke Subuh besok
    if (minutesToNext == 24 * 60) {
      final subuhTomorrow = prayerTimes['Subuh']! + (24 * 60);
      minutesToNext = subuhTomorrow - currentTime;
      nextPrayer = 'Subuh';
    }

    return minutesToNext;
  }

  // Mendapatkan nama sholat berikutnya
  String getNextPrayerName() {
    if (_currentSchedule == null) return 'Subuh';

    final now = DateTime.now();
    final currentTime =
        int.parse(DateFormat('HH').format(now)) * 60 +
        int.parse(DateFormat('mm').format(now));

    final prayerTimes = {
      'Subuh': _timeToMinutes(_currentSchedule!.fajr),
      'Syuruq': _timeToMinutes(_currentSchedule!.sunrise),
      'Dzuhur': _timeToMinutes(_currentSchedule!.dhuhr),
      'Ashar': _timeToMinutes(_currentSchedule!.asr),
      'Maghrib': _timeToMinutes(_currentSchedule!.maghrib),
      'Isya': _timeToMinutes(_currentSchedule!.isha),
    };

    String nextPrayer = 'Subuh';
    int minutesToNext = 24 * 60; // Default ke maksimum (24 jam)

    prayerTimes.forEach((prayer, time) {
      final diff = time - currentTime;
      if (diff > 0 && diff < minutesToNext) {
        minutesToNext = diff;
        nextPrayer = prayer;
      }
    });

    return nextPrayer;
  }

  // Konversi format waktu (HH:mm) ke menit
  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

// Model untuk data waktu sholat
class PrayerSchedule {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final DateTime date;

  PrayerSchedule({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerSchedule.fromJson(Map<String, dynamic> json) {
    return PrayerSchedule(
      fajr: json['fajr'],
      sunrise: json['sunrise'],
      dhuhr: json['dhuhr'],
      asr: json['asr'],
      maghrib: json['maghrib'],
      isha: json['isha'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'date': date.toIso8601String(),
    };
  }
}
