import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBoxName = 'theme_box';
  static const String _themeModeKey = 'theme_mode';

  late Box<dynamic> _themeBox;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemePreference() async {
    if (!Hive.isBoxOpen(_themeBoxName)) {
      _themeBox = await Hive.openBox(_themeBoxName);
    } else {
      _themeBox = Hive.box(_themeBoxName);
    }

    final savedThemeMode = _themeBox.get(_themeModeKey, defaultValue: 'system');
    _themeMode = _getThemeModeFromString(savedThemeMode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _themeBox.put(_themeModeKey, _getStringFromThemeMode(mode));
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  ThemeMode _getThemeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_themeBoxName)) {
      await Hive.openBox(_themeBoxName);
    }
  }
}
