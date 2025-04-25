import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:yaumian_app/services/firebase_service.dart';
import 'package:yaumian_app/services/migration_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class FirebaseProvider with ChangeNotifier {
  AuthStatus _authStatus = AuthStatus.initial;
  User? _user;
  bool _isSyncing = false;
  bool _isMigrated = false;

  AuthStatus get authStatus => _authStatus;
  User? get user => _user;
  bool get isSyncing => _isSyncing;
  bool get isMigrated => _isMigrated;

  FirebaseProvider() {
    // Inisialisasi dengan memeriksa status autentikasi saat ini
    _initializeAuth();
    // Memeriksa status migrasi
    _checkMigrationStatus();
  }

  Future<void> _initializeAuth() async {
    _user = FirebaseService.getCurrentUser();
    _authStatus =
        _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _checkMigrationStatus() async {
    _isMigrated = await MigrationService.isMigrationCompleted();
    notifyListeners();
  }

  // Metode untuk login dengan email dan password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseService.signInWithEmailAndPassword(
        email,
        password,
      );
      if (userCredential != null) {
        _user = userCredential.user;
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  // Metode untuk registrasi dengan email dan password
  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential =
          await FirebaseService.createUserWithEmailAndPassword(email, password);
      if (userCredential != null) {
        _user = userCredential.user;
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Metode untuk login anonim
  Future<bool> signInAnonymously() async {
    try {
      final userCredential = await FirebaseService.signInAnonymously();
      if (userCredential != null) {
        _user = userCredential.user;
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return false;
    }
  }

  // Metode untuk login dengan Google
  Future<bool> signInWithGoogle() async {
    try {
      final userCredential = await FirebaseService.signInWithGoogle();
      if (userCredential != null) {
        _user = userCredential.user;
        _authStatus = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error signing in with Google: $e');
      return false;
    }
  }

  // Metode untuk logout
  Future<void> signOut() async {
    await FirebaseService.signOut();
    _user = null;
    _authStatus = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // Metode untuk migrasi data dari Hive ke Firebase
  Future<void> migrateDataToFirebase() async {
    if (_isMigrated) return; // Jangan migrasi jika sudah dilakukan

    _isSyncing = true;
    notifyListeners();

    try {
      await MigrationService.migrateDataToFirebase();
      _isMigrated = true;
    } catch (e) {
      print('Error migrating data: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Metode untuk sinkronisasi data antara lokal dan Firebase
  Future<void> syncData() async {
    _isSyncing = true;
    notifyListeners();

    try {
      // Implementasi sinkronisasi data
      // Kode akan ditambahkan sesuai kebutuhan
    } catch (e) {
      print('Error syncing data: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
