import 'package:flutter/foundation.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/services/database_service.dart';

class KategoriProvider with ChangeNotifier {
  List<Kategori> _kategoriList = [];

  List<Kategori> get kategoriList => _kategoriList;

  KategoriProvider() {
    _loadKategori();
  }

  void _loadKategori() {
    _kategoriList = DatabaseService.getAllKategori();
    notifyListeners();
  }

  Kategori? getKategoriById(String id) {
    return DatabaseService.getKategoriById(id);
  }
}
