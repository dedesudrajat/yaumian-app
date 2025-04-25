import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:yaumian_app/providers/firebase_provider.dart';
import 'package:yaumian_app/screens/main_screen.dart';
import 'package:yaumian_app/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login'; // Tambahkan routeName di sini

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo dan Judul
                _buildHeader(),
                const SizedBox(height: 48),

                // Tombol Login dengan Google
                _buildGoogleSignInButton(context),
                const SizedBox(height: 24),

                // Informasi tambahan
                _buildInfoText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo aplikasi
        Icon(
          Icons.book,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        // Judul aplikasi
        Text(
          'Amalan Yaumian',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        // Subtitle
        const Text(
          'Catat dan lacak amalan harian Anda',
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _handleGoogleSignIn(context),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child:
          _isLoading
              ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Google
                  SvgPicture.asset(
                    'assets/icons/google_logo.svg',
                    height: 24,
                    width: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Masuk dengan Google',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
    );
  }

  Widget _buildInfoText() {
    return const Column(
      children: [
        Text(
          'Dengan masuk, Anda menyetujui Syarat dan Ketentuan serta Kebijakan Privasi kami.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseProvider = Provider.of<FirebaseProvider>(
        context,
        listen: false,
      );
      final success = await firebaseProvider.signInWithGoogle();

      if (success && mounted) {
        // Navigasi ke halaman utama jika login berhasil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (mounted) {
        // Tampilkan pesan error jika login gagal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal masuk dengan Google. Silakan coba lagi.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
