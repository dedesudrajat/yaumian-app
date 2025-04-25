import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/providers/amalan_provider.dart';
import 'package:yaumian_app/providers/notification_provider.dart';
import 'package:yaumian_app/providers/theme_provider.dart';
import 'package:yaumian_app/providers/firebase_provider.dart'; // Import FirebaseProvider
import 'package:yaumian_app/screens/login_screen.dart'; // Import LoginScreen

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final amalanProvider = Provider.of<AmalanProvider>(context);
    final totalPoints = amalanProvider.getUserPoints();
    final userLevel = amalanProvider.getUserLevel();
    final nextLevelPoints = amalanProvider.getPointsForNextLevel();
    final progressToNextLevel = amalanProvider.getLevelProgress();
    final currentStreak = amalanProvider.currentStreak;
    final longestStreak = amalanProvider.longestStreak;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [_buildThemeToggle(context)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(context, userLevel, totalPoints),
            const SizedBox(height: 24),
            _buildLevelProgressCard(
              context,
              userLevel,
              totalPoints,
              nextLevelPoints,
              progressToNextLevel,
            ),
            const SizedBox(height: 24),
            _buildStreakCard(context, currentStreak, longestStreak),
            const SizedBox(height: 24),
            _buildAchievementsSection(context, amalanProvider),
            const SizedBox(height: 24),
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    int userLevel,
    int totalPoints,
  ) {
    // Dapatkan data pengguna dari FirebaseProvider
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    final user = firebaseProvider.user;

    return Column(
      children: [
        // Tampilkan foto profil dari Google jika ada
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage:
              user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
          child:
              user?.photoURL == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
        ),
        const SizedBox(height: 16),
        // Tampilkan nama pengguna dari Google
        Text(
          user?.displayName ?? 'Pengguna Yaumian',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        // Tampilkan email pengguna jika ada
        if (user?.email != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              user!.email!,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Level $userLevel',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$totalPoints Poin',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLevelProgressCard(
    BuildContext context,
    int userLevel,
    int totalPoints,
    int nextLevelPoints,
    double progressToNextLevel,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level $userLevel',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Level ${userLevel + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressToNextLevel,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '$totalPoints / $nextLevelPoints Poin',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Terus selesaikan amalan harian untuk mendapatkan poin dan naik level!',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakCard(
    BuildContext context,
    int currentStreak,
    int longestStreak,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Streak Amalan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStreakInfo(
                  context,
                  'Streak Saat Ini',
                  '$currentStreak hari',
                  Icons.calendar_today,
                ),
                _buildStreakInfo(
                  context,
                  'Streak Terlama',
                  '$longestStreak hari',
                  Icons.emoji_events,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInfo(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return IconButton(
      icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        themeProvider.toggleTheme();
      },
      tooltip: themeProvider.isDarkMode ? 'Mode Terang' : 'Mode Gelap',
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pengaturan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifikasi'),
              subtitle: Text(
                Provider.of<NotificationProvider>(context).isNotificationEnabled
                    ? 'Aktif'
                    : 'Nonaktif',
              ),
              trailing: Switch(
                value:
                    Provider.of<NotificationProvider>(
                      context,
                    ).isNotificationEnabled,
                onChanged: (value) {
                  Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  ).toggleNotification();
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Mode Tampilan'),
              subtitle: Text(
                themeProvider.isDarkMode ? 'Mode Gelap' : 'Mode Terang',
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Bahasa'),
              subtitle: const Text('Indonesia'),
              onTap: () {
                // Implementasi pengaturan bahasa
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                // Tampilkan informasi tentang aplikasi
              },
            ),
            const Divider(),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.logout, color: Colors.red[700]),
      title: Text('Logout', style: TextStyle(color: Colors.red[700])),
      onTap: () async {
        try {
          await Provider.of<FirebaseProvider>(context, listen: false).signOut();
          // Navigasi ke LoginScreen dan hapus semua rute sebelumnya
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName, // Gunakan routeName jika ada, atau '/login'
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          // Tampilkan pesan error jika logout gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    AmalanProvider amalanProvider,
  ) {
    final achievements = amalanProvider.achievements;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pencapaian',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            achievements.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Belum ada pencapaian yang terbuka. Teruslah beramal untuk membuka pencapaian!',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        child: Icon(
                          Icons.emoji_events,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                      trailing: Text(
                        '+${achievement.points}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
