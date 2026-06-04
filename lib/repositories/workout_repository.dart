import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_model.dart';

/// Repository untuk operasi CRUD workout di Firestore.
///
/// Semua interaksi dengan database Firestore untuk koleksi 'workouts'
/// dilakukan melalui class ini. Ini memisahkan logika database
/// dari logika UI (sesuai prinsip Repository Pattern).
class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referensi ke koleksi 'workouts' di Firestore.
  CollectionReference get _workoutsRef => _firestore.collection('workouts');

  // ==================== CREATE ====================

  /// Menambahkan workout baru ke Firestore.
  /// Mengembalikan ID dokumen yang baru dibuat.
  Future<String> addWorkout(Workout workout) async {
    try {
      final docRef = await _workoutsRef.add(workout.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Gagal menambah workout: ${e.message}');
    }
  }

  // ==================== READ ====================

  /// Membaca semua workout milik user tertentu secara real-time (stream).
  /// Data akan otomatis update setiap kali ada perubahan di Firestore.
  Stream<List<Workout>> watchUserWorkouts(String userId) {
    return _workoutsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final workouts = snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList();
      // Cache data secara lokal ke Hive (Offline-First)
      _cacheWorkouts(workouts);
      return workouts;
    });
  }

  /// Membaca data yang di-cache di Hive jika Firestore offline.
  Future<List<Workout>> getCachedWorkouts() async {
    try {
      final box = Hive.box('settings');
      final List<dynamic>? cachedData = box.get('workout_cache_list');
      if (cachedData != null) {
        return cachedData.map((e) => Workout.fromJson(Map<String, dynamic>.from(e))).toList();
      }
    } catch (e) {
      // Abaikan error cache
    }
    return [];
  }

  /// Menyimpan backup ke Hive
  void _cacheWorkouts(List<Workout> workouts) {
    try {
      final box = Hive.box('settings');
      final mappedData = workouts.map((w) => w.toJson()).toList();
      box.put('workout_cache_list', mappedData);
    } catch (e) {
      // Abaikan error
    }
  }

  /// Membaca satu workout berdasarkan ID dokumen.
  Future<Workout?> getWorkoutById(String id) async {
    try {
      final doc = await _workoutsRef.doc(id).get();
      if (!doc.exists) return null;
      return Workout.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw Exception('Gagal membaca workout: ${e.message}');
    }
  }

  /// Membaca workout hari ini milik user tertentu.
  Stream<List<Workout>> watchTodayWorkouts(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _workoutsRef
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromFirestore(doc)).toList());
  }

  // ==================== UPDATE ====================

  /// Memperbarui workout yang sudah ada berdasarkan ID.
  /// Hanya field yang dikirim di [data] yang akan diubah.
  Future<void> updateWorkout(String id, Map<String, dynamic> data) async {
    try {
      await _workoutsRef.doc(id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Gagal memperbarui workout: ${e.message}');
    }
  }

  /// Memperbarui workout menggunakan objek Workout lengkap.
  Future<void> updateWorkoutFull(Workout workout) async {
    if (workout.id == null) throw Exception('Workout ID tidak boleh null');
    try {
      await _workoutsRef.doc(workout.id).update(workout.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Gagal memperbarui workout: ${e.message}');
    }
  }

  // ==================== DELETE ====================

  /// Menghapus workout berdasarkan ID dokumen.
  Future<void> deleteWorkout(String id) async {
    try {
      await _workoutsRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Gagal menghapus workout: ${e.message}');
    }
  }

  // ==================== STATISTIK ====================

  /// Mendapatkan jumlah workout per minggu ini untuk grafik.
  Future<Map<int, int>> getWeeklyStats(String userId) async {
    final now = DateTime.now();
    // Hitung Senin awal minggu ini
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final mondayStart = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

    try {
      final snapshot = await _workoutsRef
          .where('userId', isEqualTo: userId)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(mondayStart))
          .get();

      // Hitung jumlah workout per hari (1=Senin, 7=Minggu)
      final Map<int, int> weeklyData = {};
      for (int i = 1; i <= 7; i++) {
        weeklyData[i] = 0;
      }

      for (final doc in snapshot.docs) {
        final workout = Workout.fromFirestore(doc);
        final dayOfWeek = workout.createdAt.weekday;
        weeklyData[dayOfWeek] = (weeklyData[dayOfWeek] ?? 0) + 1;
      }

      return weeklyData;
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil statistik: ${e.message}');
    }
  }

  /// Mendapatkan jumlah workout per kategori untuk chart pie/donut.
  Future<Map<String, int>> getCategoryStats(String userId) async {
    try {
      final snapshot = await _workoutsRef
          .where('userId', isEqualTo: userId)
          .get();

      final Map<String, int> categoryData = {};
      for (final doc in snapshot.docs) {
        final workout = Workout.fromFirestore(doc);
        categoryData[workout.category] =
            (categoryData[workout.category] ?? 0) + 1;
      }

      return categoryData;
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengambil statistik kategori: ${e.message}');
    }
  }
}
