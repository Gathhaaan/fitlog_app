import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import '../../providers/user_provider.dart';
import '../../models/body_measurement_model.dart';
import '../../repositories/measurement_repository.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _gender = 'Laki-laki';
  String _goal = 'Menurunkan Berat Badan';

  final List<String> _goals = [
    'Menurunkan Berat Badan',
    'Membangun Otot',
    'Menjaga Kebugaran',
    'Meningkatkan Kelenturan'
  ];

  bool _isLoading = false;

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan: User tidak ditemukan.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);

      // 1. Simpan ke Profile (Firestore)
      final repo = ref.read(userRepositoryProvider);
      await repo.updateProfile(user.uid, {
        'weight': weight,
        'height': height,
        'gender': _gender,
        'goal': _goal,
        'isOnboarded': true,
      });

      // 2. Simpan sebagai entri Jurnal Fisik Pertama
      final measurementRepo = MeasurementRepository();
      final measurement = BodyMeasurement(
        userId: user.uid,
        weight: weight,
        createdAt: DateTime.now(),
        notes: 'Data awal saat Onboarding',
      );
      await measurementRepo.addMeasurement(measurement);

      if (mounted) {
        // Arahkan ke Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Selamat Datang di FitLog!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mari sesuaikan aplikasi dengan kebutuhan Anda untuk mendapatkan rekomendasi yang tepat.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                      ),
                      const SizedBox(height: 40),

                      // Input Berat & Tinggi
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _weightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Berat (kg)',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.monitor_weight, color: AppColors.textSecondary),
                              ),
                              validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _heightController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Tinggi (cm)',
                                labelStyle: const TextStyle(color: AppColors.textSecondary),
                                filled: true,
                                fillColor: AppColors.surface,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                prefixIcon: const Icon(Icons.height, color: AppColors.textSecondary),
                              ),
                              validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Jenis Kelamin
                      const Text('Jenis Kelamin', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSelectionCard(
                              icon: Icons.male,
                              label: 'Laki-laki',
                              isSelected: _gender == 'Laki-laki',
                              color: AppColors.primary,
                              onTap: () => setState(() => _gender = 'Laki-laki'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSelectionCard(
                              icon: Icons.female,
                              label: 'Perempuan',
                              isSelected: _gender == 'Perempuan',
                              color: Colors.pink,
                              onTap: () => setState(() => _gender = 'Perempuan'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Goal Utama
                      const Text('Apa Tujuan Utama Anda?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ..._goals.map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => setState(() => _goal = goal),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _goal == goal ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _goal == goal ? AppColors.primary : Colors.transparent, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getGoalIcon(goal),
                                  color: _goal == goal ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    goal,
                                    style: TextStyle(
                                      color: _goal == goal ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: _goal == goal ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (_goal == goal)
                                  const Icon(Icons.check_circle, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      )),

                      const SizedBox(height: 40),

                      // Tombol Selesai
                      ElevatedButton(
                        onPressed: _submitData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Mulai Perjalanan FitLog!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 32),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSelected ? color : AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Menurunkan Berat Badan': return Icons.directions_run;
      case 'Membangun Otot': return Icons.fitness_center;
      case 'Menjaga Kebugaran': return Icons.favorite;
      case 'Meningkatkan Kelenturan': return Icons.self_improvement;
      default: return Icons.flag;
    }
  }
}
