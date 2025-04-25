// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Yaumian App';

  @override
  String get home => 'Home';

  @override
  String get statistics => 'Statistics';

  @override
  String get group => 'Group';

  @override
  String get quran => 'Quran';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get download => 'Download';

  @override
  String get delete => 'Delete';

  @override
  String get bookmark => 'Bookmark';

  @override
  String get share => 'Share';

  @override
  String get error => 'Error';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get success => 'Success';

  @override
  String get ayahDownloaded => 'Ayah downloaded successfully';

  @override
  String get ayahDeleted => 'Ayah deleted successfully';

  @override
  String get ayahBookmarked => 'Ayah bookmarked';

  @override
  String get shareFeatureComing => 'Share feature coming soon';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get meccan => 'Meccan';

  @override
  String get medinan => 'Medinan';

  @override
  String get verses => 'Verses';

  @override
  String get arabicText => 'Arabic Text';

  @override
  String get translation => 'Translation';

  @override
  String get indonesianTranslation => 'Indonesian Translation';

  @override
  String get downloadAyah => 'Download Ayah';

  @override
  String get deleteAyah => 'Delete Ayah';

  @override
  String errorDownloading(Object error) {
    return 'Error downloading ayah: $error';
  }

  @override
  String errorDeleting(Object error) {
    return 'Error deleting ayah: $error';
  }

  @override
  String errorLoading(Object error) {
    return 'Error loading data: $error';
  }
}
