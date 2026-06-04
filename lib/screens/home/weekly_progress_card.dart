import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';

class WeeklyProgressCard extends StatelessWidget {
  final List<Workout> workouts;
  final List<Workout> todayWorkouts;
  final VoidCallback? onNavigateToProgress;
  
  const WeeklyProgressCard({
    super.key,
    required this.workouts,
    required this.todayWorkouts,
    this.onNavigateToProgress,
  });

  @override
  Widget build(BuildContext context) {
    // Hitung statistik
    final now = DateTime.now();
    // Cari hari Senin minggu ini
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekMidnight = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    final thisWeekWorkouts = workouts.where((w) => w.createdAt.isAfter(startOfWeekMidnight)).toList();
    
    // Target mingguan = 5 sesi
    const targetWeeklySessions = 5;
    final currentSessions = thisWeekWorkouts.length;
    final progress = (currentSessions / targetWeeklySessions).clamp(0.0, 1.0);
    
    // Hitung total set selesai minggu ini
    int totalSetsThisWeek = 0;
    for (var w in thisWeekWorkouts) {
      totalSetsThisWeek += w.sets;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: AppDecorations.card(radius: 24),
      child: Column(
        children: [
          GestureDetector(
            onTap: onNavigateToProgress,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_fire_department, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Progress Minggu Ini',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textHint),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // === Semi-Circle Gauge ===
          SizedBox(
            height: 120, // Setengah dari lebar (karena setengah lingkaran)
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: 240,
                  height: 120,
                  child: CustomPaint(
                    painter: _GaugePainter(
                      progress: progress,
                      backgroundColor: AppColors.surfaceVariant,
                      progressColor: AppColors.cardOrange,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$currentSessions',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(
                            text: ' / $targetWeeklySessions',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sesi Latihan',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Container(
            height: 1,
            color: AppColors.surfaceVariant,
          ),
          const SizedBox(height: 16),
          
          // === Bottom Stats ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMiniStat('Total Sesi', '${workouts.length}'),
              _buildDivider(),
              _buildMiniStat('Hari Ini', '${todayWorkouts.length}'),
              _buildDivider(),
              _buildMiniStat('Total Set', '$totalSetsThisWeek'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.surfaceVariant,
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _GaugePainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pusat berada di tengah bawah
    final center = Offset(size.width / 2, size.height);
    // Radius disesuaikan dengan ketebalan garis agar tidak terpotong
    final strokeWidth = 24.0;
    final radius = size.width / 2 - (strokeWidth / 2);

    // Paint untuk background (abu-abu)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint untuk progress (orange)
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Gambar background arc (180 derajat / pi)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // mulai dari kiri (180 derajat)
      pi, // sapuan 180 derajat ke kanan
      false,
      bgPaint,
    );

    // Gambar progress arc
    // Sweep angle berdasarkan progress (0.0 sampai 1.0)
    final sweepAngle = pi * progress;
    if (sweepAngle > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.progressColor != progressColor;
  }
}
