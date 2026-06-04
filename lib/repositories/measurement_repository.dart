import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/body_measurement_model.dart';

/// Repository untuk operasi CRUD pengukuran tubuh di Firestore.
///
/// Semua interaksi dengan koleksi 'body_measurements' dilakukan melalui class ini.
class MeasurementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Referensi ke koleksi 'body_measurements' di Firestore.
  CollectionReference get _measurementsRef =>
      _firestore.collection('body_measurements');

  // ==================== CREATE ====================

  /// Menambahkan pengukuran baru ke Firestore.
  Future<String> addMeasurement(BodyMeasurement measurement) async {
    try {
      final docRef = await _measurementsRef.add(measurement.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw Exception('Gagal menambah pengukuran: ${e.message}');
    }
  }

  // ==================== READ ====================

  /// Membaca semua pengukuran milik user secara real-time.
  Stream<List<BodyMeasurement>> watchUserMeasurements(String userId) {
    return _measurementsRef
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BodyMeasurement.fromFirestore(doc))
            .toList());
  }

  // ==================== DELETE ====================

  /// Menghapus pengukuran berdasarkan ID dokumen.
  Future<void> deleteMeasurement(String id) async {
    try {
      await _measurementsRef.doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Gagal menghapus pengukuran: ${e.message}');
    }
  }
}
