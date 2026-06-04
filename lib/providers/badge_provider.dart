import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/badge_model.dart';
import 'workout_provider.dart';

class BadgeNotifier extends Notifier<List<AchievementBadge>> {
  Box get _box => Hive.box('settings');

  final List<AchievementBadge> _allBadges = const [
    AchievementBadge(id: 'first_blood', title: 'First Blood', description: 'Menyelesaikan 1 workout pertama.', icon: '🔥'),
    AchievementBadge(id: 'consistent_3', title: 'Konsisten 3x', description: 'Menyelesaikan 3 workout.', icon: '🥉'),
    AchievementBadge(id: 'master_5', title: 'Master 5x', description: 'Menyelesaikan 5 workout.', icon: '🥈'),
    AchievementBadge(id: 'legend_10', title: 'Legend 10x', description: 'Menyelesaikan 10 workout.', icon: '🥇'),
  ];

  @override
  List<AchievementBadge> build() {
    // Muat state unlock dari Hive
    return _allBadges.map((badge) {
      final isUnlocked = _box.get('badge_${badge.id}_unlocked', defaultValue: false) as bool;
      final unlockedAtStr = _box.get('badge_${badge.id}_date') as String?;
      return badge.copyWith(
        isUnlocked: isUnlocked,
        unlockedAt: unlockedAtStr != null ? DateTime.parse(unlockedAtStr) : null,
      );
    }).toList();
  }

  /// Mengevaluasi apakah ada badge baru yang terbuka berdasarkan jumlah workout
  /// Mengembalikan list badge yang baru saja terbuka (untuk trigger animasi confetti)
  List<AchievementBadge> evaluateWorkouts(int workoutCount) {
    List<AchievementBadge> newlyUnlocked = [];
    List<AchievementBadge> updatedState = [...state];

    for (int i = 0; i < updatedState.length; i++) {
      final badge = updatedState[i];
      if (badge.isUnlocked) continue;

      bool shouldUnlock = false;
      if (badge.id == 'first_blood' && workoutCount >= 1) shouldUnlock = true;
      if (badge.id == 'consistent_3' && workoutCount >= 3) shouldUnlock = true;
      if (badge.id == 'master_5' && workoutCount >= 5) shouldUnlock = true;
      if (badge.id == 'legend_10' && workoutCount >= 10) shouldUnlock = true;

      if (shouldUnlock) {
        final now = DateTime.now();
        final unlockedBadge = badge.copyWith(isUnlocked: true, unlockedAt: now);
        updatedState[i] = unlockedBadge;
        newlyUnlocked.add(unlockedBadge);

        // Simpan ke Hive
        _box.put('badge_${badge.id}_unlocked', true);
        _box.put('badge_${badge.id}_date', now.toIso8601String());
      }
    }

    if (newlyUnlocked.isNotEmpty) {
      state = updatedState;
    }
    
    return newlyUnlocked;
  }
}

final badgeProvider = NotifierProvider<BadgeNotifier, List<AchievementBadge>>(() {
  return BadgeNotifier();
});
