import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';

import '../../providers/workout_provider.dart';
import '../../providers/measurement_provider.dart';
import '../../models/body_measurement_model.dart';
import '../../widgets/lottie_empty_state.dart';
import 'add_measurement_screen.dart';
import 'package:intl/intl.dart';

/// Layar Progress — visualisasi data latihan pengguna.
///
/// Menampilkan:
/// - Grafik batang mingguan (jumlah workout per hari)
/// - Grafik donut per kategori latihan
/// - Ringkasan statistik total
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutAsync = ref.watch(workoutStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📊 Progress Latihan'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: workoutAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Dummy delay untuk visual pull-to-refresh
              await Future.delayed(const Duration(milliseconds: 800));
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Ringkasan Statistik ===
                  _buildSummaryCards(workouts),
                  const SizedBox(height: 24),

                  // === Grafik Mingguan ===
                  const Text(
                    'Aktivitas Mingguan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Jumlah workout per hari minggu ini',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildWeeklyChart(workouts),
                  const SizedBox(height: 24),

                  // === Grafik Kategori ===
                  const Text(
                    'Distribusi Kategori',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Persebaran jenis latihan kamu',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryChart(workouts),
                  const SizedBox(height: 32),

                  // === Jurnal Fisik ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jurnal Fisik',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Catatan berat badan & foto progres',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          // Gunakan Future.microtask agar animasi ripple selesai
                          // dan tidak memblokir main thread yang menyebabkan ANR
                          Future.microtask(() {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddMeasurementScreen(),
                                ),
                              );
                            }
                          });
                        },
                        icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildMeasurementJournal(ref),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
    );
  }

  /// Kartu ringkasan: Total, Minggu Ini, Rata-rata.
  Widget _buildSummaryCards(List<Workout> workouts) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    final thisWeek =
        workouts.where((w) => w.createdAt.isAfter(mondayStart)).length;

    // Total set x reps
    final totalVolume =
        workouts.fold<int>(0, (sum, w) => sum + (w.sets * w.reps));

    return Row(
      children: [
        _summaryTile('Total', '${workouts.length}', Icons.fitness_center,
            AppColors.primary),
        const SizedBox(width: 10),
        _summaryTile(
            'Minggu Ini', '$thisWeek', Icons.date_range, AppColors.accent),
        const SizedBox(width: 10),
        _summaryTile(
            'Volume', '$totalVolume', Icons.trending_up, const Color(0xFFFF9F43)),
      ],
    );
  }

  Widget _summaryTile(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  /// Grafik batang: jumlah workout per hari dalam seminggu.
  Widget _buildWeeklyChart(List<Workout> workouts) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart =
        DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    // Hitung jumlah workout per hari (1=Senin, 7=Minggu)
    final Map<int, int> dailyCounts = {
      for (var i = 1; i <= 7; i++) i: 0,
    };
    for (final w in workouts) {
      if (w.createdAt.isAfter(mondayStart)) {
        final day = w.createdAt.weekday;
        dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      }
    }

    final maxY = dailyCounts.values.fold<int>(0, (a, b) => a > b ? a : b);

    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: BarChart(
        BarChartData(
          maxY: (maxY + 2).toDouble(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} workout',
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  if (value == value.toInt().toDouble()) {
                    return Text(
                      '${value.toInt()}',
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  final idx = value.toInt();
                  if (idx >= 0 && idx < dayLabels.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        dayLabels[idx],
                        style: TextStyle(
                          color: (idx + 1) == now.weekday
                              ? AppColors.primary
                              : AppColors.textHint,
                          fontSize: 11,
                          fontWeight: (idx + 1) == now.weekday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final count = dailyCounts[i + 1] ?? 0;
            final isToday = (i + 1) == now.weekday;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  width: 18,
                  color: isToday ? AppColors.primary : AppColors.primary.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Grafik donut: distribusi workout per kategori.
  Widget _buildCategoryChart(List<Workout> workouts) {
    // Hitung jumlah per kategori
    final Map<String, int> categoryCounts = {};
    for (final w in workouts) {
      categoryCounts[w.category] = (categoryCounts[w.category] ?? 0) + 1;
    }

    if (categoryCounts.isEmpty) return const SizedBox.shrink();

    // Warna untuk setiap kategori
    final colors = [
      AppColors.primary,
      AppColors.accent,
      const Color(0xFFFF9F43),
      const Color(0xFFFF6B6B),
      const Color(0xFF54A0FF),
      const Color(0xFF5F27CD),
      const Color(0xFF01A3A4),
      const Color(0xFFF368E0),
    ];

    final entries = categoryCounts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card(),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                sections: entries.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final cat = entry.value;
                  return PieChartSectionData(
                    value: cat.value.toDouble(),
                    title: '${cat.value}',
                    color: colors[idx % colors.length],
                    radius: 45,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries.asMap().entries.map((entry) {
              final idx = entry.key;
              final cat = entry.value;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${Workout.iconForCategory(cat.key)} ${cat.key}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Widget empty state.
  Widget _buildEmptyState() {
    return const LottieEmptyState(
      message: 'Belum ada data progress',
      subtitle: 'Mulai catat workout untuk melihat progress kamu!',
    );
  }

  Widget _buildMeasurementJournal(WidgetRef ref) {
    final measurementAsync = ref.watch(measurementStreamProvider);

    return measurementAsync.when(
      data: (measurements) {
        if (measurements.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: AppDecorations.card(),
            child: const Center(
              child: Text(
                'Belum ada catatan jurnal fisik.\nTambah catatan pertamamu!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: measurements.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final m = measurements[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card(),
              child: Row(
                children: [
                  if (m.photoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        m.photoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.monitor_weight, color: Colors.grey),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(m.createdAt),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${m.weight.toStringAsFixed(1)} kg',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (m.waistCirc != null) ...[
                              const SizedBox(width: 8),
                              const Text('|', style: TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              Text(
                                '${m.waistCirc!.toStringAsFixed(1)} cm',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                        if (m.notes != null && m.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            m.notes!,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}