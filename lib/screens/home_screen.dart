import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:yaumian_app/models/amalan.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/screens/tambah_amalan_screen.dart';
import 'package:yaumian_app/widgets/amalan_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    final amalanProvider = Provider.of<AmalanProvider>(context);
    final selectedDate = amalanProvider.selectedDate;
    final amalanList = amalanProvider.amalanList;

    // Mendapatkan semua amalan untuk ditampilkan sebagai marker di kalender
    final allAmalans = amalanProvider.getAllAmalans();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Amalan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              setState(() {
                _calendarFormat =
                    _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.week
                        : CalendarFormat.month;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: selectedDate,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(selectedDate, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              amalanProvider.setSelectedDate(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                return _buildCompletionMarker(date, allAmalans);
              },
            ),
          ),
          _buildGamificationFooter(amalanProvider),
          Expanded(
            child:
                amalanList.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      itemCount: amalanList.length,
                      itemBuilder: (context, index) {
                        final amalan = amalanList[index];
                        return AmalanItem(
                          amalan: amalan,
                          onEdit: () => _editAmalan(context, amalan),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahAmalanScreen()),
          );

          if (result == true) {
            // Refresh data jika ada perubahan
            amalanProvider.refreshAmalanList();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Amalan Default Tersedia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Amalan default seperti Sholat 5 Waktu, Membaca Al-Quran, dan Dzikir Pagi & Petang telah ditambahkan secara otomatis',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addAmalan(context),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Amalan Lainnya'),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan poin dan level pengguna
  Widget? _buildCompletionMarker(DateTime date, List<Amalan> allAmalans) {
    // Cek apakah tanggal adalah di masa depan (setelah hari ini)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    // Jika tanggal di masa depan, tidak perlu menampilkan marker
    if (checkDate.isAfter(today)) {
      return null;
    }

    // Gunakan AmalanProvider untuk mendapatkan status penyelesaian
    final amalanProvider = Provider.of<AmalanProvider>(context, listen: false);
    final completionStatus = amalanProvider.getDailyCompletionStatus(date);

    // Filter amalan untuk tanggal yang dipilih
    final hasAmalans = allAmalans.any(
      (amalan) => isSameDay(amalan.tanggal, date),
    );

    // Jika tidak ada amalan untuk tanggal tersebut, tidak perlu menampilkan marker
    if (!hasAmalans) {
      return null;
    }

    // Tentukan status penyelesaian
    Widget marker;
    if (completionStatus == 2) {
      // Semua amalan selesai - tampilkan centang (✓)
      marker = Container(
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        width: 18,
        height: 18,
        child: const Center(
          child: Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (completionStatus == 0) {
      // Tidak ada amalan yang selesai - tampilkan silang (✗)
      marker = Container(
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        width: 18,
        height: 18,
        child: const Center(
          child: Text(
            '✗',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else {
      // Sebagian amalan selesai - tampilkan ikon progress (⟳)
      marker = Container(
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        width: 18,
        height: 18,
        child: const Center(
          child: Text(
            '⟳',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Positioned(bottom: 1, child: marker);
  }

  Widget _buildGamificationFooter(AmalanProvider amalanProvider) {
    final points = amalanProvider.userPoints;
    final level = amalanProvider.getUserLevel();
    final streak = amalanProvider.currentStreak;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '$points Poin',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                'Level $level',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                '$streak Hari',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAmalan(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const TambahAmalanScreen()));
  }

  void _editAmalan(BuildContext context, Amalan amalan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TambahAmalanScreen(amalan: amalan),
      ),
    );
  }
}
