import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../auth/login_screen.dart';
import '../workout/workout_list_screen.dart';
import '../workout/add_workout_screen.dart';
import '../workout/workout_detail_screen.dart';
import '../progress/progress_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/lottie_empty_state.dart';

/// Layar utama (Home) setelah user berhasil login.
///
/// Menampilkan:
/// - Salam berdasarkan nama user
/// - Kartu statistik (total workout & workout hari ini)
/// - Daftar workout terbaru dengan Hero animation
/// - BottomNavigationBar dengan IndexedStack
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Gunakan IndexedStack supaya state tab tetap terjaga
    final screens = [
      _buildHomeContent(),
      const WorkoutListScreen(),
      const ProgressScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Workout'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () => Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, animation, secondaryAnimation) => FadeTransition(
              opacity: animation,
              child: const AddWorkoutScreen(),
            ),
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Konten tab Home — salam, statistik, dan workout terbaru.
  Widget _buildHomeContent() {
    final user = ref.watch(authStateProvider).value;
    final workoutAsync = ref.watch(workoutStreamProvider);
    final todayAsync = ref.watch(todayWorkoutProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.displayName ?? 'Athlete'}! 👋',
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              'Semangat latihan hari ini!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          // Tombol logout
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            tooltip: 'Logout',
            onPressed: () async {
              final navigator = Navigator.of(context);
              await ref.read(authRepositoryProvider).signOut();
              navigator.pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // === Kartu Statistik ===
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    'Total Workout',
                    workoutAsync.when(
                      data: (w) => '${w.length}',
                      loading: () => '...',
                      error: (e, st) => '0',
                    ),
                    Icons.fitness_center,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    'Hari Ini',
                    todayAsync.when(
                      data: (w) => '${w.length}',
                      loading: () => '...',
                      error: (e, st) => '0',
                    ),
                    Icons.today,
                    AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // === Judul section ===
            const Text(
              'Workout Terakhir',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // === Daftar workout terbaru ===
            workoutAsync.when(
              data: (workouts) {
                if (workouts.isEmpty) {
                  return _buildEmptyState();
                }
                final recent = workouts.take(5).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (_, i) => _workoutCard(context, recent[i]),
                );
              },
              loading: () => const Column(
                children: [
                  ShimmerWorkoutCard(),
                  ShimmerWorkoutCard(),
                  ShimmerWorkoutCard(),
                ],
              ),
              error: (e, _) => Center(
                child: Text('Error: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget empty state saat belum ada workout.
  Widget _buildEmptyState() {
    return const LottieEmptyState(
      message: 'Belum ada workout',
      subtitle: 'Tap + untuk mulai latihan!',
    );
  }

  /// Kartu statistik (Total Workout, Hari Ini).
  Widget _statCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  /// Kartu workout individual dengan Hero animation.
  Widget _workoutCard(BuildContext context, Workout workout) {
    return GestureDetector(
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
    );
  }
}