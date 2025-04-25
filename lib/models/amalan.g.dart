// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'amalan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AmalanAdapter extends TypeAdapter<Amalan> {
  @override
  final int typeId = 0;

  @override
  Amalan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Amalan(
      id: fields[0] as String,
      nama: fields[1] as String,
      deskripsi: fields[2] as String,
      selesai: fields[3] as bool,
      tanggal: fields[4] as DateTime,
      kategori: fields[5] as String,
      targetJumlah: fields[6] as int,
      jumlahSelesai: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Amalan obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.selesai)
      ..writeByte(4)
      ..write(obj.tanggal)
      ..writeByte(5)
      ..write(obj.kategori)
      ..writeByte(6)
      ..write(obj.targetJumlah)
      ..writeByte(7)
      ..write(obj.jumlahSelesai);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AmalanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
