import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/quran.dart';
import 'package:yaumian_app/providers/quran_provider.dart';
import 'package:yaumian_app/screens/surah_detail_screen.dart';
import 'package:yaumian_app/data/surah_translations.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({Key? key}) : super(key: key);

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Muat daftar surah saat layar pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).fetchAllSurahs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Surah> _filterSurahs(List<Surah> surahs) {
    if (_searchQuery.isEmpty) return surahs;
    
    return surahs.where((surah) {
      final name = surah.name.toLowerCase();
      final englishName = surah.englishName?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || 
             englishName.contains(query) ||
             surah.number.toString().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Cari surah...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Al-Quran'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          if (quranProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (quranProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Terjadi kesalahan:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(quranProvider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      quranProvider.fetchAllSurahs();
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final surahs = quranProvider.surahs;
          if (surahs.isEmpty) {
            return const Center(child: Text('Tidak ada surah yang tersedia'));
          }

          final filteredSurahs = _filterSurahs(surahs);
          if (filteredSurahs.isEmpty) {
            return const Center(child: Text('Tidak ada surah yang ditemukan'));
          }

          return ListView.builder(
            itemCount: filteredSurahs.length,
            itemBuilder: (context, index) {
              final surah = filteredSurahs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(surah.englishName ?? ''),
                  subtitle: Text(
                    '${SurahTranslations.getIndonesianTranslation(surah.number)} - ${surah.numberOfAyahs} Ayat',
                  ),
                  trailing: Text(
                    surah.revelationType == 'Meccan' ? 'Makkiyah' : 'Madaniyah',
                    style: TextStyle(
                      color:
                          surah.revelationType == 'Meccan'
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SurahDetailScreen(surah: surah),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
