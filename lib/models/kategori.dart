import 'package:hive/hive.dart';

part 'kategori.g.dart';

@HiveType(typeId: 1)
class Kategori extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String deskripsi;

  @HiveField(3)
  String warna; // Hex color code

  @HiveField(4)
  String icon; // Icon name or path

  Kategori({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.warna,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'warna': warna,
      'icon': icon,
    };
  }

  factory Kategori.fromMap(Map<String, dynamic> map) {
    return Kategori(
      id: map['id'] as String,
      nama: map['nama'] as String,
      deskripsi: map['deskripsi'] as String,
      warna: map['warna'] as String,
      icon: map['icon'] as String,
    );
  }
}
