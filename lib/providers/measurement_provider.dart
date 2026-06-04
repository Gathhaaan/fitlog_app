import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/body_measurement_model.dart';
import '../repositories/measurement_repository.dart';
import 'auth_provider.dart';

/// Provider untuk instance MeasurementRepository.
final measurementRepositoryProvider = Provider<MeasurementRepository>((ref) {
  return MeasurementRepository();
});

/// Provider yang memantau semua pengukuran tubuh milik user yang sedang login
/// secara real-time dari Firestore.
///
/// Jika user belum login, mengembalikan list kosong.
/// Data otomatis update setiap kali ada perubahan di Firestore.
final measurementStreamProvider = StreamProvider<List<BodyMeasurement>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(measurementRepositoryProvider).watchUserMeasurements(user.uid);
});
