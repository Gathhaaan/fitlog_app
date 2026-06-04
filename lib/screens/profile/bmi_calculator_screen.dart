import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme.dart';

class BmiCalculatorScreen extends StatefulWidget {
  const BmiCalculatorScreen({super.key});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String _gender = 'Laki-laki'; // 'Laki-laki' atau 'Perempuan'

  double? _bmi;
  double? _bmr;
  String? _bmiCategory;
  Color? _bmiColor;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    
    // Hilangkan fokus keyboard
    FocusScope.of(context).unfocus();

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text); // dalam cm
    final age = int.parse(_ageController.text);

    final heightInMeter = height / 100;
    
    // Kalkulasi BMI: berat(kg) / (tinggi(m) * tinggi(m))
    final bmi = weight / pow(heightInMeter, 2);
    
    // Kalkulasi BMR (Mifflin-St Jeor Equation)
    // Laki-laki: (10 × weight) + (6.25 × height) - (5 × age) + 5
    // Perempuan: (10 × weight) + (6.25 × height) - (5 × age) - 161
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);
    if (_gender == 'Laki-laki') {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    String category;
    Color color;

    if (bmi < 18.5) {
      category = 'Kekurangan Berat Badan';
      color = Colors.blue;
    } else if (bmi >= 18.5 && bmi <= 24.9) {
      category = 'Normal (Ideal)';
      color = Colors.green;
    } else if (bmi >= 25.0 && bmi <= 29.9) {
      category = 'Kelebihan Berat Badan';
      color = Colors.orange;
    } else {
      category = 'Obesitas';
      color = Colors.red;
    }

    setState(() {
      _bmi = bmi;
      _bmr = bmr;
      _bmiCategory = category;
      _bmiColor = color;
    });
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kalkulator BMI & BMR', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppDecorations.card(),
                child: Column(
                  children: [
                    const Text('Jenis Kelamin', style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _gender = 'Laki-laki'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _gender == 'Laki-laki' ? AppColors.primary.withValues(alpha: 0.2) : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _gender == 'Laki-laki' ? AppColors.primary : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.male, color: _gender == 'Laki-laki' ? AppColors.primary : AppColors.textSecondary, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Laki-laki', style: TextStyle(color: _gender == 'Laki-laki' ? AppColors.primary : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _gender = 'Perempuan'),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: _gender == 'Perempuan' ? Colors.pink.withValues(alpha: 0.2) : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _gender == 'Perempuan' ? Colors.pink : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.female, color: _gender == 'Perempuan' ? Colors.pink : AppColors.textSecondary, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Perempuan', style: TextStyle(color: _gender == 'Perempuan' ? Colors.pink : AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Usia (tahun)',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        prefixIcon: const Icon(Icons.cake, color: AppColors.textSecondary),
                      ),
                      validator: (value) => (value == null || value.isEmpty || int.tryParse(value) == null) ? 'Masukkan usia yang valid' : null,
                    ),
                    const SizedBox(height: 16),
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
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.monitor_weight, color: AppColors.textSecondary),
                            ),
                            validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? 'Invalid' : null,
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
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              prefixIcon: const Icon(Icons.height, color: AppColors.textSecondary),
                            ),
                            validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? 'Invalid' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hitung', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              if (_bmi != null && _bmr != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _bmiColor?.withValues(alpha: 0.1) ?? AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _bmiColor ?? Colors.transparent, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text('Hasil Kalkulasi', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('BMI', style: TextStyle(color: AppColors.textSecondary)),
                              Text(_bmi!.toStringAsFixed(1), style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _bmiColor)),
                            ],
                          ),
                          Container(width: 1, height: 50, color: AppColors.border),
                          Column(
                            children: [
                              const Text('BMR (Kalori/hari)', style: TextStyle(color: AppColors.textSecondary)),
                              Text(_bmr!.toStringAsFixed(0), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _bmiColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_bmiCategory!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tubuhmu membutuhkan sekitar ${_bmr!.toStringAsFixed(0)} kalori per hari untuk menjalankan fungsi dasar tanpa aktivitas.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
