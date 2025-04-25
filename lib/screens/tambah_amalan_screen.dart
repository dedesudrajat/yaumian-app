import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/widgets/amalan_form.dart';

class TambahAmalanScreen extends StatelessWidget {
  final Amalan? amalan;

  const TambahAmalanScreen({Key? key, this.amalan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amalanProvider = Provider.of<AmalanProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(amalan == null ? 'Tambah Amalan' : 'Edit Amalan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AmalanForm(
          amalan: amalan,
          onSave: (nama, deskripsi, kategoriId, targetJumlah) {
            if (amalan == null) {
              // Tambah amalan baru
              amalanProvider.addAmalan(
                nama: nama,
                deskripsi: deskripsi,
                kategoriId: kategoriId,
                targetJumlah: targetJumlah,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Amalan berhasil ditambahkan'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              // Update amalan yang sudah ada
              amalan!.nama = nama;
              amalan!.deskripsi = deskripsi;
              amalan!.kategori = kategoriId;
              amalan!.targetJumlah = targetJumlah;
              amalanProvider.updateAmalan(amalan!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Amalan berhasil diperbarui'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
