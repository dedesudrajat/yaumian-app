import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yaumian_app/l10n/app_localizations.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/providers/firebase_provider.dart';
import 'package:yaumian_app/providers/group_provider.dart';
import 'package:yaumian_app/providers/kategori_provider.dart';
import 'package:yaumian_app/providers/locale_provider.dart';
import 'package:yaumian_app/providers/notification_provider.dart';
import 'package:yaumian_app/providers/theme_provider.dart';
import 'package:yaumian_app/providers/quran_provider.dart';
import 'package:yaumian_app/screens/login_screen.dart';
import 'package:yaumian_app/screens/main_screen.dart';
import 'package:yaumian_app/services/database_service.dart';
import 'package:yaumian_app/services/notification_service.dart';
import 'package:yaumian_app/services/gamification_service.dart';
import 'package:yaumian_app/services/statistics_service.dart';
import 'package:yaumian_app/services/firebase_service.dart';
import 'package:yaumian_app/theme/app_theme.dart';
import 'package:yaumian_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService.initializeFirebase();

  // Inisialisasi database lokal
  await DatabaseService.initializeHive();

  // Inisialisasi gamifikasi dan statistik
  await GamificationService.initializeGamification();
  await StatisticsService.initializeStatistics();

  // Inisialisasi tema
  await ThemeProvider.initialize();

  // Inisialisasi notifikasi
  await NotificationService.initialize();
  await NotificationProvider.initialize();

  // Inisialisasi locale
  await LocaleProvider.initialize();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FirebaseProvider()),
        ChangeNotifierProvider(create: (_) => KategoriProvider()),
        ChangeNotifierProvider(create: (_) => AmalanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
      ],
      child: Consumer3<ThemeProvider, FirebaseProvider, LocaleProvider>(
        builder:
            (context, themeProvider, firebaseProvider, localeProvider, _) =>
                MaterialApp(
                  title: 'Amalan Yaumian',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  themeMode: themeProvider.themeMode,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('id', 'ID'), // Indonesian
                    Locale('en', 'US'), // English
                  ],
                  locale: localeProvider.locale,
                  home:
                      firebaseProvider.authStatus == AuthStatus.authenticated
                          ? const MainScreen()
                          : const LoginScreen(),
                  routes: {
                    LoginScreen.routeName: (context) => const LoginScreen(),
                  },
                  debugShowCheckedModeBanner: false,
                ),
      ),
    ),
  );
}
