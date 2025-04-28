import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/providers/prayer_time_provider.dart';
import 'package:yaumian_app/screens/amalan_screen.dart';
import 'package:yaumian_app/screens/home_screen.dart';
import 'package:yaumian_app/screens/statistics_screen.dart';
import 'package:yaumian_app/screens/profile_screen.dart';
import 'package:yaumian_app/screens/group_screen.dart';
import 'package:yaumian_app/screens/quran_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    ChangeNotifierProvider(
      create: (_) => PrayerTimeProvider(),
      child: HomeScreen(),
    ),
    const GroupScreen(),
    const QuranScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),

          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Grup'),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Al-Quran',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}
