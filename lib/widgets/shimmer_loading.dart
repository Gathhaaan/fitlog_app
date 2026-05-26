import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../app/theme.dart';

/// Widget shimmer loading yang menampilkan efek "skeleton loading"
/// saat data masih dimuat dari Firestore.
///
/// Lebih profesional daripada CircularProgressIndicator biasa.
/// Digunakan di HomeScreen, WorkoutListScreen, dan ProgressScreen.
class ShimmerWorkoutCard extends StatelessWidget {
  const ShimmerWorkoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withValues(alpha: 0.5),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Placeholder ikon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder nama
                  Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Placeholder detail
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget shimmer loading untuk kartu statistik.
class ShimmerStatCard extends StatelessWidget {
  const ShimmerStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface.withValues(alpha: 0.5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 70,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget helper yang menampilkan beberapa shimmer cards.
class ShimmerLoadingList extends StatelessWidget {
  final int count;
  const ShimmerLoadingList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Shimmer stat cards
          const Row(
            children: [
              Expanded(child: ShimmerStatCard()),
              SizedBox(width: 12),
              Expanded(child: ShimmerStatCard()),
            ],
          ),
          const SizedBox(height: 24),
          // Shimmer workout cards
          ...List.generate(count, (_) => const ShimmerWorkoutCard()),
        ],
      ),
    );
  }
}
