import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/models/kategori.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/providers/kategori_provider.dart';

class AmalanItem extends StatelessWidget {
  final Amalan amalan;
  final VoidCallback? onEdit;

  const AmalanItem({Key? key, required this.amalan, this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final kategoriProvider = Provider.of<KategoriProvider>(context);
    final amalanProvider = Provider.of<AmalanProvider>(context, listen: false);
    final Kategori? kategori = kategoriProvider.getKategoriById(
      amalan.kategori,
    );
    final Color kategoriColor =
        kategori != null
            ? Color(int.parse(kategori.warna.replaceFirst('#', '0xFF')))
            : Theme.of(context).colorScheme.primary;

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onEdit?.call(),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _confirmDelete(context, amalanProvider),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Hapus',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: () => _toggleAmalanStatus(context, amalanProvider),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircularPercentIndicator(
                  radius: 25.0,
                  lineWidth: 5.0,
                  percent: amalan.progressPercentage,
                  center: Text(
                    '${amalan.jumlahSelesai}/${amalan.targetJumlah}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: kategoriColor,
                  backgroundColor: kategoriColor.withOpacity(0.2),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              amalan.nama,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration:
                                    amalan.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kategoriColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              kategori?.nama ?? 'Lainnya',
                              style: TextStyle(
                                fontSize: 12,
                                color: kategoriColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (amalan.deskripsi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          amalan.deskripsi,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            decoration:
                                amalan.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleAmalanStatus(BuildContext context, AmalanProvider provider) {
    if (amalan.isCompleted) {
      _confirmReset(context, provider);
    } else {
      provider.toggleAmalanStatus(amalan);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            amalan.isCompleted
                ? 'Alhamdulillah! ${amalan.nama} telah selesai'
                : 'Progress ${amalan.nama} diperbarui',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmReset(BuildContext context, AmalanProvider provider) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Reset Progress'),
            content: Text('Apakah Anda ingin mereset progress ${amalan.nama}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  provider.resetAmalanProgress(amalan);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Progress ${amalan.nama} telah direset'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _confirmDelete(BuildContext context, AmalanProvider provider) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hapus Amalan'),
            content: Text('Apakah Anda yakin ingin menghapus ${amalan.nama}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  provider.deleteAmalan(amalan.id);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${amalan.nama} telah dihapus'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
