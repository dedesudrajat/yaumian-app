import 'package:flutter/material.dart';
import 'package:yaumian_app/models/ayah.dart';
import 'package:yaumian_app/services/ayah_service.dart';

class AyahMenuPopup extends StatefulWidget {
  final Ayah ayah;
  final AyahService ayahService;
  final Function()? onPlayAudio;
  final Function()? onShare;
  final Function()? onCopy;
  final Function()? onBookmark;
  final Function()? onLastRead;

  const AyahMenuPopup({
    Key? key,
    required this.ayah,
    required this.ayahService,
    this.onPlayAudio,
    this.onShare,
    this.onCopy,
    this.onBookmark,
    this.onLastRead,
  }) : super(key: key);

  @override
  State<AyahMenuPopup> createState() => _AyahMenuPopupState();
}

class _AyahMenuPopupState extends State<AyahMenuPopup> {
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handlePlayAudio() async {
    if (widget.onPlayAudio == null) return;
    
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      widget.onPlayAudio!();
    } catch (e) {
      _showSnackBar('Gagal memutar audio');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBookmark() async {
    if (widget.onBookmark == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambahkan Bookmark'),
        content: const Text('Anda yakin ingin menambahkan ayat ini ke bookmark?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onBookmark!();
      _showSnackBar('Ayat berhasil ditambahkan ke bookmark');
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _handleLastRead() async {
    if (widget.onLastRead == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Terakhir Baca'),
        content: const Text('Anda yakin ingin menandai ayat ini sebagai terakhir dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      widget.onLastRead!();
      _showSnackBar('Ayat berhasil ditandai sebagai terakhir dibaca');
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${widget.ayah.surah}:${widget.ayah.number}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.play_circle_outline, color: Colors.white),
            title: const Text('Putar Murotal',
                style: TextStyle(color: Colors.white)),
            onTap: _isLoading ? null : _handlePlayAudio,
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined, color: Colors.white),
            title: const Text('Bagikan Ayat',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              widget.onShare?.call();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined, color: Colors.white),
            title: const Text('Salin Ayat',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              widget.onCopy?.call();
              _showSnackBar('Ayat berhasil disalin');
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_outline, color: Colors.white),
            title: const Text('Tambahkan ke Bookmark',
                style: TextStyle(color: Colors.white)),
            onTap: _handleBookmark,
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined, color: Colors.white),
            title: const Text('Tandai Terakhir Baca',
                style: TextStyle(color: Colors.white)),
            onTap: _handleLastRead,
          ),
        ],
      ),
    );
  }
} 