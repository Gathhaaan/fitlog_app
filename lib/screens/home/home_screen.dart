import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/user_provider.dart';
import '../../data/workout_templates.dart';
import '../auth/login_screen.dart';
import '../workout/workout_list_screen.dart';
import '../workout/add_workout_screen.dart';
import '../workout/workout_detail_screen.dart';
import '../progress/progress_screen.dart';
import '../schedule/schedule_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/lottie_empty_state.dart';
import 'weekly_progress_card.dart';
import 'water_tracker_card.dart';

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

  /// Lacak tab mana yang sudah pernah dibuka agar tidak di-render sebelum dikunjungi.
  /// Ini mencegah ANR karena semua tab di-render sekaligus saat startup.
  final Set<int> _visitedTabs = {0};

  Widget _buildTab(int index) {
    return switch (index) {
      0 => _buildHomeContent(),
      1 => const WorkoutListScreen(),
      2 => const ProgressScreen(),
      3 => const ScheduleScreen(),
      4 => const ProfileScreen(),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: List.generate(5, (index) {
          // Jangan build tab yang belum pernah dikunjungi
          if (!_visitedTabs.contains(index)) return const SizedBox.shrink();
          return Offstage(
            offstage: _currentIndex != index,
            child: TickerMode(
              enabled: _currentIndex == index,
              child: _buildTab(index),
            ),
          );
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _visitedTabs.add(i); // Tandai tab ini sudah dikunjungi
            _currentIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Workout'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
    final profileAsync = ref.watch(userProfileProvider);
    
    final String? goal = profileAsync.value?['goal'];
    final recommendations = WorkoutTemplatesData.getProgramForDay(goal, DateTime.now().weekday);

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
            Text(
              goal != null ? 'Targetmu: $goal' : 'Semangat latihan hari ini!',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
            workoutAsync.when(
              data: (workouts) {
                final todayWorkouts = todayAsync.value ?? [];
                return WeeklyProgressCard(
                  workouts: workouts,
                  todayWorkouts: todayWorkouts,
                  onNavigateToProgress: () {
                    setState(() {
                      _visitedTabs.add(2); // 2 is Progress tab
                      _currentIndex = 2;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
            ),
            const SizedBox(height: 24),

            // === Water Tracker ===
            const WaterTrackerCard(),
            const SizedBox(height: 24),

            // === Rekomendasi Olahraga ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Program Latihan Hari Ini',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  return _buildRecommendationCard(recommendations[index]);
                },
              ),
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



  /// Kartu workout individual dengan Hero animation.
  Widget _workoutCard(BuildContext context, Workout workout) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutDetailScreen(workout: workout, heroTagPrefix: 'home-'),
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
              tag: 'home-workout-icon-${workout.id}',
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
                    tag: 'home-workout-name-${workout.id}',
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

  /// Kartu rekomendasi
  Widget _buildRecommendationCard(WorkoutTemplate template) {
    if (template.isRestDay) {
      return Container(
        width: MediaQuery.of(context).size.width - 32, // Full width minus padding
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(Icons.self_improvement, color: AppColors.accent, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.title,
                    style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                template.description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template.category,
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              template.title,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showProgramDetailSheet(template),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Mulai & Catat', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgramDetailSheet(WorkoutTemplate template) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 16,
            bottom: MediaQuery.of(ctx).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textHint,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      Workout.iconForCategory(template.category),
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.category,
                          style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _detailItem(Icons.repeat, 'Set', '${template.sets}'),
                  _detailItem(Icons.numbers, 'Reps', '${template.reps}'),
                  if (template.weight != null) 
                    _detailItem(Icons.monitor_weight, 'Beban', template.weight!),
                  _detailItem(Icons.timer, 'Durasi', '${template.durationMinutes} mnt'),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Instruksi Latihan',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _addRecommendedWorkout(template);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Selesai & Catat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
      ],
    );
  }

  void _addRecommendedWorkout(WorkoutTemplate template) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;
    
    final repo = ref.read(workoutRepositoryProvider);
    
    final workout = Workout(
      userId: user.uid,
      name: template.title,
      category: template.category,
      createdAt: DateTime.now(),
      sets: template.sets,
      reps: template.reps,
      weight: double.tryParse(template.weight ?? ''),
      notes: 'Selesai Program Harian: ${template.title}.\\nInstruksi: ${template.description}',
    );
    
    try {
      await repo.addWorkout(workout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${template.title} berhasil dicatat ke jurnal!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}