import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../providers/water_provider.dart';
import '../../widgets/wave_painter.dart';

class WaterTrackerCard extends ConsumerStatefulWidget {
  const WaterTrackerCard({super.key});

  @override
  ConsumerState<WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends ConsumerState<WaterTrackerCard> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    // Controller untuk animasi gelombang berjalan terus menerus (repeat)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIntake = ref.watch(waterIntakeProvider);
    final targetIntake = ref.watch(waterTargetProvider);
    
    // Batasi maksimum fill level di 1.0 (100%)
    final double fillLevel = (currentIntake / targetIntake).clamp(0.0, 1.0);
    final int percentage = (fillLevel * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: AppDecorations.card(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Latar Belakang (Wadah kosong)
            Positioned.fill(
              child: Container(
                color: AppColors.surface,
              ),
            ),
            
            // Animasi Gelombang Air
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return TweenAnimationBuilder<double>(
                    // Animasikan perubahan level air secara perlahan saat tombol ditekan
                    tween: Tween<double>(begin: fillLevel, end: fillLevel),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.elasticOut,
                    builder: (context, animatedFill, child) {
                      return CustomPaint(
                        painter: WavePainter(
                          fillLevel: animatedFill,
                          animationValue: _waveController.value,
                          color: const Color(0xFF3B82F6), // Biru air
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Konten UI (Teks dan Tombol)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '💧 Target Air Hari Ini',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(color: Colors.white70, blurRadius: 4)
                              ]
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currentIntake / $targetIntake ml',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(color: Colors.white70, blurRadius: 4)
                              ]
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          color: percentage >= 50 ? Colors.white : AppColors.primary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                          ]
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(waterIntakeProvider.notifier).addWater(250);
                          },
                          icon: const Icon(Icons.local_drink, size: 18),
                          label: const Text('+ 250 ml', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: const Color(0xFF3B82F6),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref.read(waterIntakeProvider.notifier).addWater(500);
                          },
                          icon: const Icon(Icons.water_drop, size: 18),
                          label: const Text('+ 500 ml', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            foregroundColor: const Color(0xFF1D4ED8),
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
