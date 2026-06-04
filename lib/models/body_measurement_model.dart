import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data untuk satu entri pengukuran tubuh pengguna.
///
/// Digunakan di fitur Jurnal Progres Fisik untuk melacak
/// perkembangan berat badan, lingkar perut, dan foto progres.
class BodyMeasurement {
  final String? id;
  final String userId;
  final double weight;       // Berat badan dalam kg
  final double? waistCirc;   // Lingkar perut dalam cm (opsional)
  final String? photoUrl;    // URL foto dari Firebase Storage (opsional)
  final String? notes;       // Catatan tambahan (opsional)
  final DateTime createdAt;

  BodyMeasurement({
    this.id,
    required this.userId,
    required this.weight,
    this.waistCirc,
    this.photoUrl,
    this.notes,
    required this.createdAt,
  });

  /// Konversi dari dokumen Firestore ke objek BodyMeasurement.
  factory BodyMeasurement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BodyMeasurement(
      id: doc.id,
      userId: data['userId'] ?? '',
      weight: (data['weight'] as num?)?.toDouble() ?? 0,
      waistCirc: (data['waistCirc'] as num?)?.toDouble(),
      photoUrl: data['photoUrl'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Konversi ke Map untuk disimpan di Firestore.
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'weight': weight,
        'waistCirc': waistCirc,
        'photoUrl': photoUrl,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Konversi dari JSON (Hive cache).
  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      userId: json['userId'] ?? '',
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      waistCirc: (json['waistCirc'] as num?)?.toDouble(),
      photoUrl: json['photoUrl'],
      notes: json['notes'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Konversi ke JSON (untuk Hive cache).
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'weight': weight,
        'waistCirc': waistCirc,
        'photoUrl': photoUrl,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };
}
