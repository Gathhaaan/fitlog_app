import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../repositories/workout_repository.dart';
import '../repositories/storage_repository.dart';
import 'auth_provider.dart';

/// Provider untuk instance WorkoutRepository.
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

/// Provider untuk instance StorageRepository.
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

/// Provider yang memantau semua workout milik user yang sedang login
/// secara real-time dari Firestore.
///
/// Jika user belum login, mengembalikan list kosong.
/// Data otomatis update setiap kali ada perubahan di Firestore.
final workoutStreamProvider = StreamProvider<List<Workout>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(workoutRepositoryProvider).watchUserWorkouts(user.uid);
});

/// Provider yang memantau workout hari ini saja.
final todayWorkoutProvider = StreamProvider<List<Workout>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(workoutRepositoryProvider).watchTodayWorkouts(user.uid);
});