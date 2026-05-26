import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';
import 'workout_detail_screen.dart';
import 'add_workout_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/lottie_empty_state.dart';

/// Layar daftar semua workout milik user.
///
/// Fitur:
/// - Daftar workout dari Firestore (real-time)
/// - Swipe untuk hapus (Dismissible)
/// - Tap untuk lihat detail (dengan Hero animation)
/// - Filter berdasarkan kategori
/// - Animasi stagger saat list muncul
class WorkoutListScreen extends ConsumerStatefulWidget {
  const WorkoutListScreen({super.key});

  @override
  ConsumerState<WorkoutListScreen> createState() => _WorkoutListScreenState();
}

class _WorkoutListScreenState extends ConsumerState<WorkoutListScreen> {
  String? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(workoutStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Workout'),
        backgroundColor: AppColors.surface,
        actions: [
          // Tombol filter berdasarkan kategori
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            color: AppColors.surface,
            onSelected: (value) => setState(() => _selectedFilter = value),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: null,
                child: Text('Semua Kategori',
                    style: TextStyle(color: AppColors.textPrimary)),
              ),
              ...Workout.categories.map(
                (cat) => PopupMenuItem(
                  value: cat,
                  child: Text(
                    '${Workout.iconForCategory(cat)} $cat',
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workouts) {
          // Terapkan filter jika dipilih
          final filtered = _selectedFilter != null
              ? workouts
                  .where((w) => w.category == _selectedFilter)
                  .toList()
              : workouts;

          if (filtered.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              // Animasi stagger: setiap item muncul dengan delay
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 400 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 30 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _buildWorkoutCard(context, filtered[index]),
              );
            },
          );
        },
        loading: () => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(4, (_) => const ShimmerWorkoutCard()),
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Error: $e',
                  style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_workout_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddWorkoutScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Widget yang ditampilkan saat tidak ada workout.
  Widget _buildEmptyState() {
    return LottieEmptyState(
      message: _selectedFilter != null
          ? 'Belum ada workout "$_selectedFilter"'
          : 'Belum ada workout',
      subtitle: 'Tap + untuk menambah latihan baru!',
    );
  }

  /// Kartu workout dengan fitur swipe-to-delete dan tap-to-detail.
  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    return Dismissible(
      key: Key(workout.id ?? ''),
      direction: DismissDirection.endToStart,
      // Konfirmasi sebelum hapus
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Hapus Workout?',
                style: TextStyle(color: AppColors.textPrimary)),
            content: Text(
              'Apakah kamu yakin ingin menghapus "${workout.name}"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child:
                    const Text('Hapus', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      // Lakukan hapus dari Firestore
      onDismissed: (_) async {
        if (workout.id != null) {
          final messenger = ScaffoldMessenger.of(context);
          await ref.read(workoutRepositoryProvider).deleteWorkout(workout.id!);
          messenger.showSnackBar(
            SnackBar(
              content: Text('${workout.name} dihapus'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      // Background merah saat di-swipe
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailScreen(workout: workout),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.card(),
          child: Row(
            children: [
              // Ikon kategori dengan Hero animation
              Hero(
                tag: 'workout-icon-${workout.id}',
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    Workout.iconForCategory(workout.category),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info workout
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'workout-name-${workout.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          workout.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.category} • ${workout.sets} set × ${workout.reps} rep'
                      '${workout.weight != null ? ' • ${workout.weight} kg' : ''}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
