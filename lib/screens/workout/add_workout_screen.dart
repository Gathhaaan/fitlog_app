import 'dart:io';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../app/theme.dart';
import '../../models/workout_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';

/// Layar untuk menambahkan workout baru.
///
/// Fitur:
/// - Form dengan validasi (nama, kategori, sets, reps, berat)
/// - Dropdown kategori latihan
/// - Upload foto workout via kamera/galeri (Firebase Storage)
/// - Animasi slide-up + fade saat form muncul
/// - Confetti celebration saat berhasil simpan
class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = Workout.categories.first;
  File? _selectedImage;
  bool _isLoading = false;

  // Confetti controller untuk animasi celebration
  late ConfettiController _confettiController;

  // Animasi slide-up untuk form
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _animController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  /// Pilih foto dari galeri atau kamera.
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  /// Simpan workout baru ke Firestore (dan upload foto jika ada).
  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // Upload foto ke Firebase Storage jika user memilih foto
      if (_selectedImage != null) {
        imageUrl = await ref
            .read(storageRepositoryProvider)
            .uploadWorkoutPhoto(user.uid, _selectedImage!);
      }

      // Buat objek Workout baru
      final workout = Workout(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        sets: int.parse(_setsController.text.trim()),
        reps: int.parse(_repsController.text.trim()),
        weight: _weightController.text.trim().isNotEmpty
            ? double.tryParse(_weightController.text.trim())
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        userId: user.uid,
      );

      // Simpan ke Firestore
      await ref.read(workoutRepositoryProvider).addWorkout(workout);

      if (mounted) {
        // Tampilkan confetti celebration!
        _confettiController.play();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Workout berhasil ditambahkan!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Tunggu sebentar supaya user bisa lihat confetti
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Tambah Workout'),
            backgroundColor: AppColors.surface,
          ),
          body: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // === Header ===
                      const Text(
                        '🏋️ Catat Latihan Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Isi detail latihan kamu di bawah ini',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 24),

                      // === Nama Latihan ===
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: AppDecorations.inputDecoration(
                            'Nama Latihan', Icons.fitness_center),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama latihan wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // === Kategori ===
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
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
                          if (v != null) setState(() => _selectedCategory = v);
                        },
                      ),
                      const SizedBox(height: 16),

                      // === Sets & Reps (baris horizontal) ===
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _setsController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: AppColors.textPrimary),
                              decoration: AppDecorations.inputDecoration(
                                  'Sets', Icons.repeat),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }
                                if (int.tryParse(v.trim()) == null) {
                                  return 'Angka saja';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _repsController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                  color: AppColors.textPrimary),
                              decoration: AppDecorations.inputDecoration(
                                  'Reps', Icons.numbers),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Wajib diisi';
                                }
                                if (int.tryParse(v.trim()) == null) {
                                  return 'Angka saja';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // === Berat (opsional) ===
                      TextFormField(
                        controller: _weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: AppDecorations.inputDecoration(
                                'Berat (kg)', Icons.monitor_weight)
                            .copyWith(hintText: 'Opsional'),
                      ),
                      const SizedBox(height: 16),

                      // === Catatan (opsional) ===
                      TextFormField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: AppDecorations.inputDecoration(
                                'Catatan', Icons.note_alt)
                            .copyWith(hintText: 'Opsional'),
                      ),
                      const SizedBox(height: 20),

                      // === Upload Foto ===
                      const Text(
                        'Foto Latihan (opsional)',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImage != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Kamera'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galeri'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // === Tombol Simpan ===
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveWorkout,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ))
                              : const Icon(Icons.save),
                          label: Text(
                              _isLoading ? 'Menyimpan...' : 'Simpan Workout'),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // === Confetti Overlay ===
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // ke bawah
            maxBlastForce: 10,
            minBlastForce: 5,
            emissionFrequency: 0.06,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              Color(0xFFFF9F43),
              Color(0xFF54A0FF),
              Color(0xFF5F27CD),
            ],
          ),
        ),
      ],
    );
  }
}
