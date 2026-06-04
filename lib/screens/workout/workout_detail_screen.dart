import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/workout_provider.dart';

/// Layar detail workout — menampilkan informasi lengkap satu workout.
///
/// Fitur:
/// - Hero animation dari WorkoutListScreen
/// - Tampilkan foto workout (jika ada)
/// - Edit workout via bottom sheet
/// - Hapus workout dengan konfirmasi
class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;

  final String heroTagPrefix;

  const WorkoutDetailScreen({super.key, required this.workout, this.heroTagPrefix = ''});

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  late Workout _workout;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  /// Tampilkan bottom sheet untuk mengedit workout.
  void _showEditSheet() {
    final nameCtrl = TextEditingController(text: _workout.name);
    final setsCtrl = TextEditingController(text: _workout.sets.toString());
    final repsCtrl = TextEditingController(text: _workout.reps.toString());
    final weightCtrl = TextEditingController(
        text: _workout.weight?.toString() ?? '');
    final notesCtrl = TextEditingController(text: _workout.notes ?? '');
    String selectedCategory = _workout.category;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textHint,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '✏️ Edit Workout',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Nama
                    TextFormField(
                      controller: nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                          'Nama Latihan', Icons.fitness_center),
                    ),
                    const SizedBox(height: 12),

                    // Kategori
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: AppDecorations.inputDecoration(
                          'Kategori', Icons.category),
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      items: Workout.categories
                          .map((cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(
                                    '${Workout.iconForCategory(cat)} $cat'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setModalState(() => selectedCategory = v);
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Sets & Reps
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: setsCtrl,
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: AppDecorations.inputDecoration(
                                'Sets', Icons.repeat),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                            decoration: AppDecorations.inputDecoration(
                                'Reps', Icons.numbers),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Berat
                    TextFormField(
                      controller: weightCtrl,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                          'Berat (kg)', Icons.monitor_weight),
                    ),
                    const SizedBox(height: 12),

                    // Catatan
                    TextFormField(
                      controller: notesCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: AppDecorations.inputDecoration(
                          'Catatan', Icons.note_alt),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _updateWorkout(
                            nameCtrl.text.trim(),
                            selectedCategory,
                            int.tryParse(setsCtrl.text.trim()) ?? _workout.sets,
                            int.tryParse(repsCtrl.text.trim()) ?? _workout.reps,
                            double.tryParse(weightCtrl.text.trim()),
                            notesCtrl.text.trim(),
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Kirim perubahan ke Firestore.
  Future<void> _updateWorkout(
    String name,
    String category,
    int sets,
    int reps,
    double? weight,
    String notes,
  ) async {
    if (_workout.id == null) return;

    try {
      final updatedWorkout = _workout.copyWith(
        name: name,
        category: category,
        sets: sets,
        reps: reps,
        weight: weight,
        notes: notes.isNotEmpty ? notes : null,
      );

      await ref
          .read(workoutRepositoryProvider)
          .updateWorkoutFull(updatedWorkout);

      setState(() => _workout = updatedWorkout);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout berhasil diperbarui!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Hapus workout dengan konfirmasi dialog.
  Future<void> _deleteWorkout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Hapus Workout?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Apakah kamu yakin ingin menghapus "${_workout.name}"? Tindakan ini tidak bisa dibatalkan.',
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

    if (confirm == true && _workout.id != null) {
      try {
        // Hapus foto dari Storage jika ada
        if (_workout.imageUrl != null) {
          await ref
              .read(storageRepositoryProvider)
              .deleteFile(_workout.imageUrl!);
        }
        // Hapus dokumen dari Firestore
        await ref
            .read(workoutRepositoryProvider)
            .deleteWorkout(_workout.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Workout dihapus'),
              backgroundColor: AppColors.error,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal hapus: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatted =
        DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(_workout.createdAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Detail Workout'),
        actions: [
          // Tombol edit
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditSheet,
            tooltip: 'Edit',
          ),
          // Tombol hapus
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: _deleteWorkout,
            tooltip: 'Hapus',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Header dengan Hero animation ===
            Row(
              children: [
                Hero(
                  tag: '${widget.heroTagPrefix}workout-icon-${_workout.id}',
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      Workout.iconForCategory(_workout.category),
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: '${widget.heroTagPrefix}workout-name-${_workout.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            _workout.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _workout.category,
                          style: const TextStyle(
                              color: AppColors.primary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // === Statistik latihan ===
            Row(
              children: [
                _statTile('Sets', '${_workout.sets}', Icons.repeat),
                const SizedBox(width: 12),
                _statTile('Reps', '${_workout.reps}', Icons.numbers),
                const SizedBox(width: 12),
                _statTile(
                  'Berat',
                  _workout.weight != null ? '${_workout.weight} kg' : '-',
                  Icons.monitor_weight,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // === Tanggal ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.card(),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateFormatted,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // === Catatan ===
            if (_workout.notes != null && _workout.notes!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.card(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.note_alt,
                            color: AppColors.accent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Catatan',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _workout.notes!,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // === Foto Workout ===
            if (_workout.imageUrl != null) ...[
              const Text(
                'Foto Latihan',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _workout.imageUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 220,
                      decoration: AppDecorations.card(),
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    );
                  },
                  errorBuilder: (_, e, s) => Container(
                    height: 220,
                    decoration: AppDecorations.card(),
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          color: AppColors.textHint, size: 48),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Tile statistik kecil (Sets, Reps, Berat).
  Widget _statTile(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.card(),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
