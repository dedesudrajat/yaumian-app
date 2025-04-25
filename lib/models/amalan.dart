import 'package:hive/hive.dart';

part 'amalan.g.dart';

@HiveType(typeId: 0)
class Amalan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String deskripsi;

  @HiveField(3)
  bool selesai;

  @HiveField(4)
  DateTime tanggal;

  @HiveField(5)
  String kategori;

  @HiveField(6)
  int targetJumlah;

  @HiveField(7)
  int jumlahSelesai;

  Amalan({
    required this.id,
    required this.nama,
    required this.deskripsi,
    this.selesai = false,
    required this.tanggal,
    required this.kategori,
    this.targetJumlah = 1,
    this.jumlahSelesai = 0,
  });

  double get progressPercentage {
    if (targetJumlah == 0) return 0.0;
    return jumlahSelesai / targetJumlah;
  }

  bool get isCompleted => jumlahSelesai >= targetJumlah;

  void incrementProgress() {
    if (jumlahSelesai < targetJumlah) {
      jumlahSelesai++;
      if (jumlahSelesai >= targetJumlah) {
        selesai = true;
      }
    }
  }

  void resetProgress() {
    jumlahSelesai = 0;
    selesai = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'selesai': selesai,
      'tanggal': tanggal.toIso8601String(),
      'kategori': kategori,
      'targetJumlah': targetJumlah,
      'jumlahSelesai': jumlahSelesai,
    };
  }

  factory Amalan.fromMap(Map<String, dynamic> map) {
    return Amalan(
      id: map['id'] as String,
      nama: map['nama'] as String,
      deskripsi: map['deskripsi'] as String,
      selesai: map['selesai'] as bool,
      tanggal: DateTime.parse(map['tanggal'] as String),
      kategori: map['kategori'] as String,
      targetJumlah: map['targetJumlah'] as int,
      jumlahSelesai: map['jumlahSelesai'] as int,
    );
  }
}