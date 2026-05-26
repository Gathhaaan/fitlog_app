import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// Layar splash yang ditampilkan saat app pertama kali dibuka.
///
/// Animasi:
/// 1. FadeTransition — logo muncul secara perlahan
/// 2. ScaleTransition — logo membesar sedikit untuk efek "pop"
///
/// Setelah 2.5 detik, otomatis cek status login:
/// - Sudah login → ke HomeScreen
/// - Belum login → ke LoginScreen
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Animasi scale (membesar sedikit)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Jalankan animasi
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _scaleController.forward();
    });

    // Cek login setelah delay
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Gunakan auth provider (bukan akses langsung ke FirebaseAuth)
    final user = ref.read(authStateProvider).value;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: user != null ? const HomeScreen() : const LoginScreen(),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo app dengan gradien dan shadow
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Nama app
                const Text(
                  'FitLog',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                const Text(
                  'Catat Perjalanan Fitnessmu',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                // Loading indicator
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}