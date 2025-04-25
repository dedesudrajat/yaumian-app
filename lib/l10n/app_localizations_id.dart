// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Yaumian App';

  @override
  String get home => 'Beranda';

  @override
  String get statistics => 'Statistik';

  @override
  String get group => 'Grup';

  @override
  String get quran => 'Al-Quran';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Pengaturan';

  @override
  String get language => 'Bahasa';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Mode Gelap';

  @override
  String get lightMode => 'Mode Terang';

  @override
  String get systemDefault => 'Sistem Default';

  @override
  String get download => 'Unduh';

  @override
  String get delete => 'Hapus';

  @override
  String get bookmark => 'Tandai';

  @override
  String get share => 'Bagikan';

  @override
  String get error => 'Terjadi Kesalahan';

  @override
  String get tryAgain => 'Coba Lagi';

  @override
  String get success => 'Berhasil';

  @override
  String get ayahDownloaded => 'Ayat berhasil diunduh';

  @override
  String get ayahDeleted => 'Ayat berhasil dihapus';

  @override
  String get ayahBookmarked => 'Ayat ditandai';

  @override
  String get shareFeatureComing => 'Fitur berbagi akan segera hadir';

  @override
  String get loading => 'Memuat...';

  @override
  String get noData => 'Tidak ada data yang tersedia';

  @override
  String get meccan => 'Makkiyah';

  @override
  String get medinan => 'Madaniyah';

  @override
  String get verses => 'Ayat';

  @override
  String get arabicText => 'Teks Arab';

  @override
  String get translation => 'Terjemahan';

  @override
  String get indonesianTranslation => 'Terjemahan Indonesia';

  @override
  String get downloadAyah => 'Unduh Ayat';

  @override
  String get deleteAyah => 'Hapus Ayat';

  @override
  String errorDownloading(Object error) {
    return 'Error mengunduh ayat: $error';
  }

  @override
  String errorDeleting(Object error) {
    return 'Error menghapus ayat: $error';
  }

  @override
  String errorLoading(Object error) {
    return 'Error memuat data: $error';
  }
}
