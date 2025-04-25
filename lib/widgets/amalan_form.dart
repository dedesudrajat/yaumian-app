import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/providers/kategori_provider.dart';

class AmalanForm extends StatefulWidget {
  final Amalan? amalan;
  final Function(
    String nama,
    String deskripsi,
    String kategoriId,
    int targetJumlah,
  )
  onSave;

  const AmalanForm({Key? key, this.amalan, required this.onSave})
    : super(key: key);

  @override
  State<AmalanForm> createState() => _AmalanFormState();
}

class _AmalanFormState extends State<AmalanForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedKategoriId = '';
  int _targetJumlah = 1;

  @override
  void initState() {
    super.initState();
    if (widget.amalan != null) {
      _namaController.text = widget.amalan!.nama;
      _deskripsiController.text = widget.amalan!.deskripsi;
      _selectedKategoriId = widget.amalan!.kategori;
      _targetJumlah = widget.amalan!.targetJumlah;
    } else {
      // Set default kategori jika ada
      Future.delayed(Duration.zero, () {
        final kategoriProvider = Provider.of<KategoriProvider>(
          context,
          listen: false,
        );
        if (kategoriProvider.kategoriList.isNotEmpty &&
            _selectedKategoriId.isEmpty) {
          setState(() {
            _selectedKategoriId = kategoriProvider.kategoriList.first.id;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);
    final kategoriList = kategoriProvider.kategoriList;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _namaController,
            decoration: const InputDecoration(
              labelText: 'Nama Amalan',
              hintText: 'Masukkan nama amalan',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nama amalan tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _deskripsiController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (Opsional)',
              hintText: 'Masukkan deskripsi amalan',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Kategori',
              hintText: 'Pilih kategori amalan',
            ),
            value:
                _selectedKategoriId.isNotEmpty &&
                        kategoriList.any((k) => k.id == _selectedKategoriId)
                    ? _selectedKategoriId
                    : (kategoriList.isNotEmpty ? kategoriList.first.id : null),
            items:
                kategoriList.map((Kategori kategori) {
                  return DropdownMenuItem<String>(
                    value: kategori.id,
                    child: Text(kategori.nama),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedKategoriId = newValue;
                });
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Pilih kategori amalan';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Target Jumlah:'),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _targetJumlah.toDouble(),
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: _targetJumlah.toString(),
                  onChanged: (double value) {
                    setState(() {
                      _targetJumlah = value.round();
                    });
                  },
                ),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  _targetJumlah.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveForm,
              child: Text(
                widget.amalan == null ? 'Tambah Amalan' : 'Simpan Perubahan',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        _namaController.text,
        _deskripsiController.text,
        _selectedKategoriId,
        _targetJumlah,
      );
    }
  }
}
