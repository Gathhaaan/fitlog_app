import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';
import 'workout_detail_screen.dart';
import 'add_workout_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/lottie_empty_state.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  String _searchQuery = '';
  String _sortOrder = 'date_desc'; // 'date_desc', 'date_asc', 'weight_desc'

  @override
  void initState() {
    super.initState();
    // Load preferensi dari Hive
    final box = Hive.box('settings');
    _sortOrder = box.get('workout_sort_order', defaultValue: 'date_desc');
  }

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
            tooltip: 'Filter Kategori',
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
          // Tombol urutkan
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: AppColors.textPrimary),
            color: AppColors.surface,
            tooltip: 'Urutkan',
            onSelected: (value) {
              setState(() => _sortOrder = value);
              // Simpan preferensi pengguna dengan Hive
              Hive.box('settings').put('workout_sort_order', value);
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'date_desc',
                child: Text('Terbaru', style: TextStyle(color: AppColors.textPrimary)),
              ),
              PopupMenuItem(
                value: 'date_asc',
                child: Text('Terlama', style: TextStyle(color: AppColors.textPrimary)),
              ),
              PopupMenuItem(
                value: 'weight_desc',
                child: Text('Beban Terberat', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ],
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workouts) {
          // Terapkan filter kategori & pencarian nama
          var filtered = workouts.where((w) {
            final matchesFilter = _selectedFilter == null || w.category == _selectedFilter;
            final matchesSearch = w.name.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesFilter && matchesSearch;
          }).toList();

          // Terapkan urutan (sorting)
          filtered.sort((a, b) {
            if (_sortOrder == 'date_asc') {
              return a.createdAt.compareTo(b.createdAt);
            } else if (_sortOrder == 'weight_desc') {
              return (b.weight ?? 0).compareTo(a.weight ?? 0);
            }
            // default date_desc
            return b.createdAt.compareTo(a.createdAt);
          });

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  decoration: AppDecorations.inputDecoration('Cari Latihan...', Icons.search).copyWith(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          // Dummy delay untuk visual pull-to-refresh
                          // Data dari Firestore secara otomatis real-time via Stream
                          await Future.delayed(const Duration(milliseconds: 800));
                        },
                        color: AppColors.primary,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
                        ),
                      ),
              ),
            ],
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
            builder: (_) => WorkoutDetailScreen(workout: workout, heroTagPrefix: 'list-'),
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
                tag: 'list-workout-icon-${workout.id}',
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
                      tag: 'list-workout-name-${workout.id}',
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
