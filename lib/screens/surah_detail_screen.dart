import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/models/quran.dart';
import 'package:yaumian_app/models/ayah.dart';
import 'package:yaumian_app/providers/quran_provider.dart';
import 'package:yaumian_app/services/ayah_service.dart';
import 'package:yaumian_app/data/surah_translations.dart';
import 'package:yaumian_app/data/surah_names.dart';
import 'package:yaumian_app/data/quran_pages.dart';
import 'package:yaumian_app/utils/tajweed_rules.dart';
import 'package:yaumian_app/widgets/ayah_menu_popup.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

enum FontSize { small, normal, large }

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int initialPage;
  final int? initialAyah;

  const SurahDetailScreen({
    Key? key,
    required this.surah,
    this.initialPage = 1,
    this.initialAyah,
  }) : super(key: key);

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final AyahService _ayahService = AyahService();
  bool _isPerPageMode = false;
  late PageController _pageController;
  int _currentPage = 0;
  SurahDetail? _nextSurah;
  SurahDetail? _previousSurah;
  FontSize _fontSize = FontSize.normal;
  int? _currentPlayingAyah;
  AudioPlayer? _currentAudioPlayer;
  bool _isAutoPlayEnabled = true;
  bool _isPlaying = false;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahKeys = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _searchType = 'all'; // Default search type
  bool _isNavigatingToAyah = true; // For navigation dialog
  int? _highlightedAyah;

  double get _arabicFontSize {
    switch (_fontSize) {
      case FontSize.small:
        return 20;
      case FontSize.normal:
        return 24;
      case FontSize.large:
        return 28;
    }
  }

  double get _translationFontSize {
    switch (_fontSize) {
      case FontSize.small:
        return 16;
      case FontSize.normal:
        return 18;
      case FontSize.large:
        return 22;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _currentPage = widget.initialPage - 1;
    _setupAudioPlayer();
    _searchController.addListener(_onSearchChanged);

    // Schedule scroll to initial ayah after build
    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToInitialAyah();
      });
    }
  }

  void _setupAudioPlayer() {
    _currentAudioPlayer = AudioPlayer();
    _currentAudioPlayer!.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isLoading =
              state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });

        // Handle completion
        if (state.processingState == ProcessingState.completed) {
          if (_isAutoPlayEnabled) {
            _playNextAyah();
          } else {
            setState(() {
              _isPlaying = false;
              _currentPlayingAyah = null;
              _isLoading = false;
            });
          }
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCurrentAndAdjacentSurahs();
  }

  Future<void> _loadCurrentAndAdjacentSurahs() async {
    try {
      final quranProvider = Provider.of<QuranProvider>(context, listen: false);

      // Load current surah
      await quranProvider.fetchSurahDetail(widget.surah.number);

      // Only load adjacent surahs if we're still mounted
      if (!mounted) return;

      // Load next surah if available
      if (widget.surah.number < 114) {
        try {
          await quranProvider.fetchSurahDetail(widget.surah.number + 1);
          final nextSurahDetail = quranProvider.currentSurah;
          if (nextSurahDetail != null) {
            setState(() {
              _nextSurah = nextSurahDetail;
            });
          }
          // Restore current surah
          await quranProvider.fetchSurahDetail(widget.surah.number);
        } catch (e) {
          print('Error loading next surah: $e');
        }
      }

      // Load previous surah if available
      if (widget.surah.number > 1) {
        try {
          await quranProvider.fetchSurahDetail(widget.surah.number - 1);
          final previousSurahDetail = quranProvider.currentSurah;
          if (previousSurahDetail != null) {
            setState(() {
              _previousSurah = previousSurahDetail;
            });
          }
          // Restore current surah
          await quranProvider.fetchSurahDetail(widget.surah.number);
        } catch (e) {
          print('Error loading previous surah: $e');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading surah: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToSurah(Surah surah) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SurahDetailScreen(surah: surah)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.surah.englishName}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              '${widget.surah.englishName} - ${widget.surah.englishNameTranslation}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.navigation),
            onPressed: _showNavigationDialog,
          ),
          IconButton(
            icon: const Icon(Icons.format_size),
            onPressed: () {
              setState(() {
                switch (_fontSize) {
                  case FontSize.small:
                    _fontSize = FontSize.normal;
                    break;
                  case FontSize.normal:
                    _fontSize = FontSize.large;
                    break;
                  case FontSize.large:
                    _fontSize = FontSize.small;
                    break;
                }
              });
            },
          ),
          IconButton(
            icon: Icon(_isPerPageMode ? Icons.view_list : Icons.auto_stories),
            onPressed: () {
              setState(() {
                _isPerPageMode = !_isPerPageMode;
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

          final surahDetail = quranProvider.currentSurah;
          if (surahDetail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat surah'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCurrentAndAdjacentSurahs,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return _isPerPageMode
              ? _buildPageView(surahDetail)
              : _buildAyahListView(surahDetail);
        },
      ),
    );
  }

  Widget _buildPageView(SurahDetail surahDetail) {
    final totalPages = QuranPages.getTotalPages(widget.surah.number);
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () async {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else if (widget.surah.number > 1 &&
                          _previousSurah != null) {
                        final prevTotalPages = QuranPages.getTotalPages(
                          widget.surah.number - 1,
                        );
                        _navigateToSurah(
                          Surah(
                            number: widget.surah.number - 1,
                            name: _getSurahName(widget.surah.number - 1),
                            englishName: _previousSurah!.englishName,
                            englishNameTranslation:
                                _previousSurah!.englishNameTranslation,
                            numberOfAyahs: _previousSurah!.ayahs.length,
                            revelationType: _previousSurah!.revelationType,
                          ),
                        );
                        await Future.delayed(const Duration(milliseconds: 350));
                        setState(() {
                          _pageController = PageController(
                            initialPage: prevTotalPages - 1,
                          );
                          _currentPage = prevTotalPages - 1;
                        });
                      }
                    },
                  ),
                  Text(
                    'Halaman ${_currentPage + 1}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () async {
                      if (_currentPage < totalPages - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else if (widget.surah.number < 114 &&
                          _nextSurah != null) {
                        _navigateToSurah(
                          Surah(
                            number: widget.surah.number + 1,
                            name: _getSurahName(widget.surah.number + 1),
                            englishName: _nextSurah!.englishName,
                            englishNameTranslation:
                                _nextSurah!.englishNameTranslation,
                            numberOfAyahs: _nextSurah!.ayahs.length,
                            revelationType: _nextSurah!.revelationType,
                          ),
                        );
                        await Future.delayed(const Duration(milliseconds: 350));
                        setState(() {
                          _pageController = PageController(initialPage: 0);
                          _currentPage = 0;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: totalPages,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: _buildQuranText(
                            _getPageContent(surahDetail, index),
                            surahDetail: surahDetail,
                            ayat: index,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: MediaQuery.of(context).size.width / 3.6,
          child: Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle : Icons.play_circle,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () async {
                    if (_isPlaying) {
                      await _currentAudioPlayer?.pause();
                      setState(() {
                        _isPlaying = false;
                      });
                    } else {
                      final pageContent = _getPageContent(
                        surahDetail,
                        _currentPage,
                      );
                      final ayah = surahDetail.ayahs.firstWhere(
                        (a) => pageContent.contains(a.text),
                        orElse: () => surahDetail.ayahs.first,
                      );
                      await _playAyah(ayah);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuranText(String text, {int? ayat, SurahDetail? surahDetail}) {
    if (text.isEmpty) return const SizedBox.shrink();
    final startPage = QuranPages.getPageNumber(widget.surah.number, ayat ?? 0);
    final ayahRange = QuranPages.getAyahRangeForPage(
      widget.surah.number,
      startPage,
    );

    final tokens = Tajweed.applySimpleTajweed(text);

    return RichText(
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'AmiriQuran',
          fontSize: _arabicFontSize,
          height: 2.5,
          color: Colors.black,
        ),
        children: [
          if (_isPerPageMode)
            if (ayahRange != null)
              for (int i = ayahRange['start']! - 1; i < ayahRange['end']!; i++)
                if (surahDetail != null)
                  if (i < surahDetail.ayahs.length)
                    TextSpan(
                      text:
                          '${surahDetail.ayahs[i].text} ۝${_formatAyahNumber(surahDetail.ayahs[i].number)} ',
                      style: TextStyle(
                        color:
                            _currentPlayingAyah != null &&
                                    _currentPlayingAyah ==
                                        surahDetail.ayahs[i].number
                                ? Colors.blueAccent
                                : Colors.black,
                      ),
                    ),
          if (!_isPerPageMode)
            ...tokens.map(
              (token) => TextSpan(
                text: token.text,
                style: TextStyle(
                  color:
                      _currentPlayingAyah != null && _currentPlayingAyah == ayat
                          ? Colors.blueAccent
                          : token.rule.type != TajweedType.none
                          ? token.rule.color
                          : Colors.black,
                  fontFamily: 'AmiriQuran',
                  fontSize: _arabicFontSize,
                  fontWeight:
                      _currentPlayingAyah != null && _currentPlayingAyah == ayat
                          ? FontWeight.bold
                          : token.rule.type != TajweedType.none
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          if (_isPerPageMode) ...[
            const TextSpan(text: ' '),
            TextSpan(
              text: '۝${_formatAyahNumber(_currentPage + 1)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: _arabicFontSize * 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getPageContent(SurahDetail surahDetail, int pageIndex) {
    final startPage = QuranPages.getPageNumber(widget.surah.number, pageIndex);
    final ayahRange = QuranPages.getAyahRangeForPage(
      widget.surah.number,
      startPage,
    );

    if (ayahRange == null) {
      return '';
    }

    StringBuffer content = StringBuffer();

    for (int i = ayahRange['start']! - 1; i < ayahRange['end']!; i++) {
      if (i < surahDetail.ayahs.length) {
        final ayah = surahDetail.ayahs[i];
        // Format teks dengan nomor ayat
        content.write('${ayah.text} ۝${_formatAyahNumber(ayah.number)} ');
      }
    }
    return content.toString();
  }

  String _formatAyahNumber(int number) {
    const Map<String, String> arabicNumerals = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    return number
        .toString()
        .split('')
        .map((digit) => arabicNumerals[digit] ?? digit)
        .join();
  }

  @override
  void dispose() {
    _currentAudioPlayer?.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToInitialAyah() async {
    if (!mounted || widget.initialAyah == null) return;

    // Wait for the widget tree to be built and surah data to be loaded
    await Future.delayed(const Duration(milliseconds: 800)); // Increased delay

    if (!mounted) return;

    final quranProvider = Provider.of<QuranProvider>(context, listen: false);
    if (quranProvider.isLoading || quranProvider.currentSurah == null) {
      // If still loading, try again
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Increased delay
      if (mounted) {
        _scrollToInitialAyah();
      }
      return;
    }

    // Ensure the ayah number is valid
    if (widget.initialAyah! <= quranProvider.currentSurah!.ayahs.length) {
      // Pastikan ListView sudah dibangun sebelum mencoba fokus ke ayat
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        _focusAyah(widget.initialAyah!);
      }
    }
  }

  // Fungsi untuk mendapatkan nama Arab surah dari nomor surah
  String _getSurahName(int surahNumber) {
    // Menggunakan SurahNames dari data/surah_names.dart
    return SurahNames.getIndonesianName(surahNumber);
  }

  void _focusAyah(int ayahNumber) async {
    if (!mounted) return;

    // Set highlighted ayah
    setState(() {
      _highlightedAyah = ayahNumber;
      _isLoading = true; // Show loading state while scrolling
    });

    // Give time for the ListView to build completely
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Pastikan ayah key sudah dibuat
    if (_ayahKeys[ayahNumber] == null) {
      _ayahKeys[ayahNumber] = GlobalKey();
      // Tunggu satu frame untuk memastikan key terdaftar
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Multiple attempts to find the ayah's context
    GlobalKey? ayahKey = _ayahKeys[ayahNumber];
    BuildContext? ayahContext;
    int attempts = 0;

    while (attempts < 5 && mounted) {
      // Increase attempts to 5
      ayahContext = ayahKey?.currentContext;
      if (ayahContext != null) break;

      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
    }

    if (!mounted) return;

    if (ayahContext == null) {
      setState(() {
        _isLoading = false;
        _highlightedAyah = null;
      });
      // Tidak menampilkan toast error karena ayat mungkin masih dalam proses loading
      return;
    }

    // Get the RenderBox and calculate position
    final RenderBox box = ayahContext.findRenderObject() as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    // Calculate the offset to scroll to (position ayah 1/3 from the top of the screen)
    final screenHeight = MediaQuery.of(context).size.height;
    final targetOffset =
        _scrollController.offset + position.dy - (screenHeight * 0.33);

    try {
      // Animate to the position
      await _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );

      // Flash effect
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Efek highlight yang bertahan selama 3 detik kemudian memudar
      // Tetap highlight selama 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      // Kemudian mulai animasi fade out selama 1.5 detik
      // Kita tidak langsung menghilangkan highlight, tapi membiarkan
      // widget AnimatedContainer yang menangani transisi warna secara halus
      setState(() {
        // Tetap set _highlightedAyah tapi akan memudar melalui AnimatedContainer
        _highlightedAyah = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _highlightedAyah = null;
      });
    }
  }

  Future<void> _playNextAyah() async {
    final currentSurah =
        Provider.of<QuranProvider>(context, listen: false).currentSurah;
    if (currentSurah == null || _currentPlayingAyah == null) return;

    final currentIndex = currentSurah.ayahs.indexWhere(
      (a) => a.number == _currentPlayingAyah,
    );

    // Check if we can play next ayah
    if (currentIndex == -1 || currentIndex >= currentSurah.ayahs.length - 1) {
      setState(() {
        _isPlaying = false;
        _currentPlayingAyah = null;
        _isLoading = false;
      });
      return;
    }

    try {
      // Get next ayah
      final nextAyah = currentSurah.ayahs[currentIndex + 1];

      // Set loading state
      setState(() {
        _isLoading = true;
        _currentPlayingAyah = nextAyah.number;
      });

      // Focus on the next ayah
      _focusAyah(nextAyah.number);

      // Get and set new URL
      final url = await _ayahService.getAudioUrl(nextAyah);
      await _currentAudioPlayer!.setUrl(url);

      // Start playing
      await _currentAudioPlayer!.play();

      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error playing next ayah: $e');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _currentPlayingAyah = null;
      });
    }
  }

  Future<void> _playAyah(Ayah ayah) async {
    try {
      // Set loading state first
      setState(() {
        _isLoading = true;
        _currentPlayingAyah = ayah.number;
      });

      // Focus on the selected ayah
      _focusAyah(ayah.number);

      // Stop current audio if playing
      await _currentAudioPlayer?.stop();

      // Get and set new URL
      final url = await _ayahService.getAudioUrl(ayah);
      await _currentAudioPlayer!.setUrl(url);

      // Start playing
      await _currentAudioPlayer!.play();

      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error playing audio: $e');
      setState(() {
        _isLoading = false;
        _isPlaying = false;
        _currentPlayingAyah = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memutar audio ayat ${ayah.number}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePlay(Ayah ayah) async {
    if (_isLoading) return; // Prevent multiple clicks while loading

    if (_currentPlayingAyah == ayah.number && _isPlaying) {
      // Pause current ayah
      await _currentAudioPlayer?.pause();
      setState(() {
        _isPlaying = false;
      });
    } else if (_currentPlayingAyah == ayah.number && !_isPlaying) {
      // Resume current ayah
      setState(() {
        _isLoading = true;
      });
      await _currentAudioPlayer?.play();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } else {
      // Play new ayah
      await _playAyah(ayah);
    }
  }

  void _showAyahMenu(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => AyahMenuPopup(
            ayah: ayah,
            ayahService: _ayahService,
            onPlayAudio: () async {
              Navigator.pop(context);
              await _togglePlay(ayah);
            },
            onShare: () {
              Navigator.pop(context);
              Share.share(
                '${ayah.text}\n\n${ayah.translation}\n\nSurah ${widget.surah.name} ayat ${ayah.number}',
              );
            },
            onCopy: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: ayah.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayat telah disalin')),
              );
            },
            onBookmark: () {
              Navigator.pop(context);
              // TODO: Implement bookmark functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ayat ditambahkan ke bookmark')),
              );
            },
            onLastRead: () {
              Navigator.pop(context);
              // TODO: Implement last read functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ditandai sebagai terakhir dibaca'),
                ),
              );
            },
          ),
    );
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() {
        _searchQuery = _searchController.text;
        // Reset highlighted ayah saat pencarian berubah
        _highlightedAyah = null;
      });
    }
  }

  Widget _buildAyahListView(SurahDetail surahDetail) {
    // Filter ayat berdasarkan pencarian jika ada
    List<Ayah> filteredAyahs = surahDetail.ayahs;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredAyahs =
          surahDetail.ayahs.where((ayah) {
            final text = ayah.text.toLowerCase();
            final translation = (ayah.translation ?? '').toLowerCase();
            final number = ayah.number.toString();

            return text.contains(query) ||
                translation.contains(query) ||
                number == query;
          }).toList();
    }

    return Stack(
      children: [
        Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari ayat...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),

            // Auto-play toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _showNavigationDialog,
                    icon: const Icon(Icons.navigation),
                    label: const Text('Pergi ke Ayat'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Auto-play',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      Switch(
                        value: _isAutoPlayEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isAutoPlayEnabled = value;
                            if (!value && _isPlaying) {
                              _currentAudioPlayer?.pause();
                              _isPlaying = false;
                            }
                          });
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Ayah list
            Expanded(
              child:
                  filteredAyahs.isEmpty && _searchQuery.isNotEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 48,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Tidak ada ayat yang cocok dengan "$_searchQuery"',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              child: const Text('Hapus Pencarian'),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredAyahs.length,
                        itemBuilder: (context, index) {
                          final ayah = filteredAyahs[index];
                          final bool isCurrentAyah =
                              _currentPlayingAyah == ayah.number;
                          final bool isHighlighted =
                              _highlightedAyah == ayah.number;

                          // Pastikan key untuk ayat ini selalu dibuat baru jika belum ada
                          if (_ayahKeys[ayah.number] == null) {
                            _ayahKeys[ayah.number] = GlobalKey();
                          }

                          return Card(
                            key: _ayahKeys[ayah.number],
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            color:
                                null, // Warna card dibuat transparan untuk AnimatedContainer
                            elevation:
                                isHighlighted
                                    ? 4
                                    : 1, // Elevasi lebih tinggi saat highlight
                            child: AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 1500,
                              ), // Durasi animasi lebih lama
                              decoration: BoxDecoration(
                                color:
                                    isHighlighted
                                        ? Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.2)
                                        : isCurrentAyah
                                        ? Colors.amber.withOpacity(0.1)
                                        : Colors.white,
                                border:
                                    isHighlighted
                                        ? Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 2,
                                        )
                                        : null,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow:
                                    isHighlighted
                                        ? [
                                          BoxShadow(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                        : null,
                              ),
                              child: InkWell(
                                onTap: () => _showAyahMenu(context, ayah),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              ayah.number.toString(),
                                              style: TextStyle(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon:
                                                    _isLoading && isCurrentAyah
                                                        ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.black),
                                                          ),
                                                        )
                                                        : Icon(
                                                          (isCurrentAyah &&
                                                                  _isPlaying)
                                                              ? Icons
                                                                  .pause_circle_outline
                                                              : Icons
                                                                  .play_circle_outline,
                                                          color: Colors.black,
                                                          size: 28,
                                                        ),
                                                onPressed:
                                                    _isLoading && !isCurrentAyah
                                                        ? null
                                                        : () =>
                                                            _togglePlay(ayah),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                ),
                                                onPressed:
                                                    () => _showAyahMenu(
                                                      context,
                                                      ayah,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _buildQuranText(ayah.text),
                                      const SizedBox(height: 16),
                                      Text(
                                        ayah.translation ?? '',
                                        style: TextStyle(
                                          fontSize: _translationFontSize,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showNavigationDialog() {
    int selectedSurah = widget.surah.number;
    int selectedAyah = 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pergi ke',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                () =>
                                    setState(() => _isNavigatingToAyah = true),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  _isNavigatingToAyah
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(8),
                                ),
                              ),
                            ),
                            child: Text(
                              'Ayat',
                              style: TextStyle(
                                color:
                                    _isNavigatingToAyah
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed:
                                () =>
                                    setState(() => _isNavigatingToAyah = false),
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  !_isNavigatingToAyah
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[300],
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(8),
                                ),
                              ),
                            ),
                            child: Text(
                              'Halaman',
                              style: TextStyle(
                                color:
                                    !_isNavigatingToAyah
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isNavigatingToAyah) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Surat',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedSurah,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: List.generate(114, (index) {
                                    final number = index + 1;
                                    return DropdownMenuItem(
                                      value: number,
                                      child: Text(
                                        '$number. ${_getSurahName(number)}',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedSurah = value;
                                        selectedAyah =
                                            1; // Reset ayah when surah changes
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ayat',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                DropdownButtonFormField<int>(
                                  value: selectedAyah,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: List.generate(
                                    _getAyahCount(selectedSurah),
                                    (index) => DropdownMenuItem(
                                      value: index + 1,
                                      child: Text('${index + 1}'),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedAyah = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Nomor Halaman',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'BATAL',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (_isNavigatingToAyah) {
                              // Pastikan state pencarian direset
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                              _navigateToAyah(selectedSurah, selectedAyah);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  int _getAyahCount(int surahNumber) {
    final Map<int, int> ayahCounts = {
      1: 7, // Al-Fatihah
      2: 286, // Al-Baqarah
      3: 200, // Ali 'Imran
      4: 176, // An-Nisa'
      5: 120, // Al-Ma'idah
      6: 165, // Al-An'am
      7: 206, // Al-A'raf
      8: 75, // Al-Anfal
      9: 129, // At-Taubah
      10: 109, // Yunus
      11: 123, // Hud
      12: 111, // Yusuf
      13: 43, // Ar-Ra'd
      14: 52, // Ibrahim
      15: 99, // Al-Hijr
      16: 128, // An-Nahl
      17: 111, // Al-Isra'
      18: 110, // Al-Kahf
      19: 98, // Maryam
      20: 135, // Ta Ha
      21: 112, // Al-Anbiya'
      22: 78, // Al-Hajj
      23: 118, // Al-Mu'minun
      24: 64, // An-Nur
      25: 77, // Al-Furqan
      26: 227, // Asy-Syu'ara'
      27: 93, // An-Naml
      28: 88, // Al-Qasas
      29: 69, // Al-'Ankabut
      30: 60, // Ar-Rum
      31: 34, // Luqman
      32: 30, // As-Sajdah
      33: 73, // Al-Ahzab
      34: 54, // Saba'
      35: 45, // Fatir
      36: 83, // Ya Sin
      37: 182, // As-Saffat
      38: 88, // Sad
      39: 75, // Az-Zumar
      40: 85, // Ghafir
      41: 54, // Fussilat
      42: 53, // Asy-Syura
      43: 89, // Az-Zukhruf
      44: 59, // Ad-Dukhan
      45: 37, // Al-Jasiyah
      46: 35, // Al-Ahqaf
      47: 38, // Muhammad
      48: 29, // Al-Fath
      49: 18, // Al-Hujurat
      50: 45, // Qaf
      51: 60, // Az-Zariyat
      52: 49, // At-Tur
      53: 62, // An-Najm
      54: 55, // Al-Qamar
      55: 78, // Ar-Rahman
      56: 96, // Al-Waqi'ah
      57: 29, // Al-Hadid
      58: 22, // Al-Mujadilah
      59: 24, // Al-Hasyr
      60: 13, // Al-Mumtahanah
      61: 14, // As-Saff
      62: 11, // Al-Jumu'ah
      63: 11, // Al-Munafiqun
      64: 18, // At-Taghabun
      65: 12, // At-Talaq
      66: 12, // At-Tahrim
      67: 30, // Al-Mulk
      68: 52, // Al-Qalam
      69: 52, // Al-Haqqah
      70: 44, // Al-Ma'arij
      71: 28, // Nuh
      72: 28, // Al-Jinn
      73: 20, // Al-Muzzammil
      74: 56, // Al-Muddassir
      75: 40, // Al-Qiyamah
      76: 31, // Al-Insan
      77: 50, // Al-Mursalat
      78: 40, // An-Naba'
      79: 46, // An-Nazi'at
      80: 42, // 'Abasa
      81: 29, // At-Takwir
      82: 19, // Al-Infitar
      83: 36, // Al-Mutaffifin
      84: 25, // Al-Insyiqaq
      85: 22, // Al-Buruj
      86: 17, // At-Tariq
      87: 19, // Al-A'la
      88: 26, // Al-Ghasyiyah
      89: 30, // Al-Fajr
      90: 20, // Al-Balad
      91: 15, // Asy-Syams
      92: 21, // Al-Lail
      93: 11, // Ad-Duha
      94: 8, // Asy-Syarh
      95: 8, // At-Tin
      96: 19, // Al-'Alaq
      97: 5, // Al-Qadr
      98: 8, // Al-Bayyinah
      99: 8, // Az-Zalzalah
      100: 11, // Al-'Adiyat
      101: 11, // Al-Qari'ah
      102: 8, // At-Takasur
      103: 3, // Al-'Asr
      104: 9, // Al-Humazah
      105: 5, // Al-Fil
      106: 4, // Quraisy
      107: 7, // Al-Ma'un
      108: 3, // Al-Kausar
      109: 6, // Al-Kafirun
      110: 3, // An-Nasr
      111: 5, // Al-Masad
      112: 4, // Al-Ikhlas
      113: 5, // Al-Falaq
      114: 6, // An-Nas
    };
    return ayahCounts[surahNumber] ?? 1;
  }

  void _navigateToAyah(int surahNumber, int ayahNumber) async {
    // Dialog sudah ditutup oleh tombol OK di _showNavigationDialog
    // Jadi tidak perlu menutup dialog lagi di sini

    if (surahNumber == widget.surah.number) {
      // If same surah, wait for dialog to close then focus the ayah
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;

      // Show loading indicator
      setState(() {
        _isLoading = true;
        _searchQuery = ''; // Reset pencarian untuk menghindari blank screen
        _highlightedAyah = null; // Reset highlight sebelum fokus ke ayat baru
      });

      // Fokus ke ayat yang dipilih
      _focusAyah(ayahNumber);
    } else {
      // Navigate to different surah
      final surahInfo = _getSurahInfo(surahNumber);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => SurahDetailScreen(
                surah: Surah(
                  number: surahNumber,
                  name: surahInfo['arabic'] ?? '',
                  englishName: surahInfo['name'] ?? '',
                  englishNameTranslation: surahInfo['translation'] ?? '',
                  numberOfAyahs: _getAyahCount(surahNumber),
                  revelationType: '',
                ),
                initialAyah: ayahNumber,
              ),
        ),
      );
    }
  }

  Map<String, String> _getSurahInfo(int number) {
    final Map<int, Map<String, String>> surahInfo = {
      1: {
        'arabic': 'الفاتحة',
        'name': 'Al-Fatihah',
        'translation': 'Pembukaan',
      },
      2: {
        'arabic': 'البقرة',
        'name': 'Al-Baqarah',
        'translation': 'Sapi Betina',
      },
      3: {
        'arabic': 'آل عمران',
        'name': 'Ali \'Imran',
        'translation': 'Keluarga Imran',
      },
      4: {'arabic': 'النساء', 'name': 'An-Nisa\'', 'translation': 'Wanita'},
      5: {
        'arabic': 'المائدة',
        'name': 'Al-Ma\'idah',
        'translation': 'Hidangan',
      },
      6: {
        'arabic': 'الأنعام',
        'name': 'Al-An\'am',
        'translation': 'Binatang Ternak',
      },
      7: {
        'arabic': 'الأعراف',
        'name': 'Al-A\'raf',
        'translation': 'Tempat Tertinggi',
      },
      8: {
        'arabic': 'الأنفال',
        'name': 'Al-Anfal',
        'translation': 'Harta Rampasan Perang',
      },
      9: {
        'arabic': 'التوبة',
        'name': 'At-Taubah',
        'translation': 'Pengampunan',
      },
      10: {'arabic': 'يونس', 'name': 'Yunus', 'translation': 'Nabi Yunus'},
      11: {'arabic': 'هود', 'name': 'Hud', 'translation': 'Nabi Hud'},
      12: {'arabic': 'يوسف', 'name': 'Yusuf', 'translation': 'Nabi Yusuf'},
      13: {'arabic': 'الرعد', 'name': 'Ar-Ra\'d', 'translation': 'Guruh'},
      14: {
        'arabic': 'إبراهيم',
        'name': 'Ibrahim',
        'translation': 'Nabi Ibrahim',
      },
      15: {'arabic': 'الحجر', 'name': 'Al-Hijr', 'translation': 'Bukit Pasir'},
      16: {'arabic': 'النحل', 'name': 'An-Nahl', 'translation': 'Lebah'},
      17: {
        'arabic': 'الإسراء',
        'name': 'Al-Isra\'',
        'translation': 'Perjalanan Malam',
      },
      18: {'arabic': 'الكهف', 'name': 'Al-Kahf', 'translation': 'Gua'},
      19: {'arabic': 'مريم', 'name': 'Maryam', 'translation': 'Maryam'},
      20: {'arabic': 'طه', 'name': 'Ta Ha', 'translation': 'Ta Ha'},
      // Surah lainnya dapat ditambahkan sesuai kebutuhan
    };

    return surahInfo[number] ??
        {'arabic': '', 'name': 'Surah $number', 'translation': 'Surah $number'};
  }
}
