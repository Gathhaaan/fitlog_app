import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

/// Provider untuk mengelola target harian air.
final waterTargetProvider = Provider<int>((ref) => 2000); // 2000 ml default

/// Notifier untuk melacak jumlah air yang sudah diminum hari ini.
/// Menggunakan Hive untuk persistensi data agar tidak hilang saat app ditutup.
class WaterIntakeNotifier extends Notifier<int> {
  // Gunakan tanggal hari ini sebagai key agar data reset otomatis tiap hari
  String get _todayKey => 'water_${DateFormat('yyyy_MM_dd').format(DateTime.now())}';
  
  Box get _box => Hive.box('settings');

  @override
  int build() {
    return _box.get(_todayKey, defaultValue: 0) as int;
  }

  void addWater(int amount) {
    state = state + amount;
    _box.put(_todayKey, state);
  }

  void reset() {
    state = 0;
    _box.put(_todayKey, 0);
  }
}

/// Provider utama untuk state konsumsi air.
final waterIntakeProvider = NotifierProvider<WaterIntakeNotifier, int>(() {
  return WaterIntakeNotifier();
});
