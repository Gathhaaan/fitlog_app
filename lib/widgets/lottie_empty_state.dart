import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../app/theme.dart';

/// Widget animasi Lottie untuk empty state.
///
/// Menampilkan animasi dumbbell yang bergerak saat:
/// - Belum ada data workout
/// - Tidak ada data progress
/// - Daftar kosong setelah filter
///
/// Menggunakan file Lottie lokal dari `assets/lottie/`.
class LottieEmptyState extends StatelessWidget {
  final String message;
  final String subtitle;

  const LottieEmptyState({
    super.key,
    required this.message,
    this.subtitle = 'Tap + untuk mulai latihan!',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animasi Lottie — dumbbell bounce
            SizedBox(
              height: 180,
              width: 180,
              child: Lottie.asset(
                'assets/lottie/empty_workout.json',
                fit: BoxFit.contain,
                repeat: true,
                // Fallback jika file rusak
                errorBuilder: (_, error, stackTrace) {
                  return _buildFallbackAnimation();
                },
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fallback animated icon jika Lottie gagal dimuat.
  static Widget _buildFallbackAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Opacity(
          opacity: 0.3 + (0.3 * value),
          child: Transform.translate(
            offset: Offset(0, -10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: const Icon(
        Icons.fitness_center,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}
