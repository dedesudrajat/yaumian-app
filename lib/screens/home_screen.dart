import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/providers/prayer_time_provider.dart';
import 'package:yaumian_app/screens/amalan_screen.dart';
import 'package:yaumian_app/screens/quran_screen.dart';
import 'package:yaumian_app/screens/statistics_screen.dart';
import 'package:yaumian_app/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final amalanProvider = Provider.of<AmalanProvider>(context);
    final progressPercentage =
        (amalanProvider.getProgressPercentage() * 100).toInt();
    final completedTasks =
        amalanProvider.amalanList.where((amalan) => amalan.isCompleted).length;
    final totalTasks = amalanProvider.amalanList.length;

    // Waktu saat ini
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    // Mendapatkan provider waktu sholat
    final prayerTimeProvider = Provider.of<PrayerTimeProvider>(context);
    final prayerTimes = prayerTimeProvider.prayerTimes;
    final userLocation =
        prayerTimeProvider.currentLocation ?? 'Lokasi tidak tersedia';
    final hijriDate =
        prayerTimeProvider.currentHijriDate ?? 'Tanggal Hijriah tidak tersedia';

    // Menghitung waktu menuju sholat berikutnya
    final nextPrayerMinutes = prayerTimeProvider.getMinutesToNextPrayer();

    return Scaffold(
      body: Stack(
        children: [
          // Background gambar
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_home.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Lapisan warna gelap pakai gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(
                    0xFF0D6E70,
                  ).withOpacity(0.7), // atas lebih terang biru kehijauan
                  Colors.black.withOpacity(0.8), // bawah makin gelap
                ],
              ),
            ),
          ),

          // Isi konten
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  _buildHeader(userLocation),
                  _buildCurrentTimeAndNextPrayer(
                    currentTime,
                    nextPrayerMinutes,
                    hijriDate,
                    prayerTimeProvider,
                  ),
                  _buildPrayerTimesRow(prayerTimes),
                  _buildMenuGrid(),
                  _buildTodayGoalCard(
                    progressPercentage,
                    completedTasks,
                    totalTasks,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String userLocation) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Lokasi pengguna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),

              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  userLocation,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          // Ikon pencarian dan notifikasi
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTimeAndNextPrayer(
    String currentTime,
    int nextPrayerMinutes,
    String hijriDate,
    PrayerTimeProvider prayerTimeProvider,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          // Tanggal Hijriah
          Text(
            hijriDate,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Waktu saat ini
          Text(
            currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // Informasi waktu menuju sholat berikutnya
          Text(
            '${prayerTimeProvider.getNextPrayerName()} hanya $nextPrayerMinutes menit lagi',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 16),
          // Garis pemisah
          Container(
            height: 1,
            width: MediaQuery.of(context).size.width * 0.9,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesRow(Map<String, String> prayerTimes) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:
            prayerTimes.entries.map((entry) {
              // Ikon untuk setiap waktu sholat
              IconData icon;
              switch (entry.key) {
                case 'Subuh':
                  icon = Icons.nightlight_round;
                  break;
                case 'Syuruq':
                  icon = Icons.wb_sunny_outlined;
                  break;
                case 'Dzuhur':
                  icon = Icons.wb_sunny;
                  break;
                case 'Ashar':
                  icon = Icons.cloud;
                  break;
                case 'Maghrib':
                  icon = Icons.brightness_4;
                  break;
                case 'Isya':
                  icon = Icons.nights_stay;
                  break;
                default:
                  icon = Icons.access_time;
              }

              return Column(
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Icon(icon, color: Colors.white, size: 20),
                  const SizedBox(height: 4),
                  Text(
                    entry.value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildMenuGrid() {
    // Daftar menu dengan ikon
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.history, 'label': 'Last Read'},
      {'icon': Icons.menu_book, 'label': 'Quran'},
      {'icon': Icons.favorite, 'label': 'Amalan'},
      {'icon': Icons.explore, 'label': 'Kiblat'},
      {'icon': Icons.access_time, 'label': 'Prayer Time'},
      {'icon': Icons.bar_chart, 'label': 'Statistik'},
      {'icon': Icons.volunteer_activism, 'label': 'Donation'},
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          bool isComingSoon = [
            'Last Read',
            'Kiblat',
            'Prayer Time',
            'Donation',
          ].contains(menuItems[index]['label']);

          return Stack(
            children: [
              InkWell(
                onTap: () {
                  if (isComingSoon) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${menuItems[index]['label']} coming soon!',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    return;
                  }

                  switch (menuItems[index]['label']) {
                    case 'Quran':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuranScreen()),
                      );
                      break;
                    case 'Amalan':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AmalanScreen(),
                        ),
                      );
                      break;
                    case 'Statistik':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatisticsScreen(),
                        ),
                      );
                      break;
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      menuItems[index]['icon'],
                      color: isComingSoon ? Colors.grey : Colors.amber[700],
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menuItems[index]['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isComingSoon ? Colors.grey : Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              if (isComingSoon)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(fontSize: 8, color: Colors.grey[700]),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayGoalCard(
    int progressPercentage,
    int completedTasks,
    int totalTasks,
  ) {
    final amalanProvider = Provider.of<AmalanProvider>(context);
    // Mendapatkan daftar amalan yang belum selesai
    final uncompletedAmalans =
        amalanProvider.amalanList
            .where((amalan) => !amalan.isCompleted)
            .toList();

    // Batasi jumlah amalan yang ditampilkan (maksimal 3)
    final displayedAmalans = uncompletedAmalans.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Amalan Hari ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$progressPercentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the daily activity checklist.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '$completedTasks of $totalTasks Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, color: neutral100),
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              color: primaryColor,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 16),

          // Daftar amalan yang belum selesai
          if (displayedAmalans.isNotEmpty) ...[
            const Text(
              'Amalan yang belum selesai:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...displayedAmalans.map(
              (amalan) => _buildAmalanCheckItem(amalan, amalanProvider),
            ),
            const SizedBox(height: 8),
          ],

          // Tombol menuju checklist
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AmalanScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go to Checklist',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan item amalan dengan checkbox
  Widget _buildAmalanCheckItem(Amalan amalan, AmalanProvider amalanProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Indikator progress
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.teal.shade700, width: 2),
              color: amalan.isCompleted ? Colors.teal.shade700 : Colors.white,
            ),
            child: InkWell(
              onTap: () {
                // Increment progress amalan
                amalan.incrementProgress();
                amalanProvider.updateAmalan(amalan);
                setState(() {});
              },
              child:
                  amalan.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
          ),
          // Nama amalan
          Expanded(
            child: Text(
              amalan.nama,
              style: TextStyle(
                fontSize: 14,
                decoration:
                    amalan.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Progress counter
          Text(
            '${amalan.jumlahSelesai}/${amalan.targetJumlah}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
