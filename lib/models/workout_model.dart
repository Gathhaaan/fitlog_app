import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data Workout yang merepresentasikan satu sesi latihan.
///
/// Class ini berisi:
/// - Serialisasi ke/dari Firestore (toFirestore / fromFirestore)
/// - Daftar kategori olahraga yang tersedia
/// - Method copyWith untuk update parsial
class Workout {
  final String? id;
  final String name;        // Nama latihan (contoh: "Push Up")
  final String category;    // Kategori (contoh: "Dada", "Kaki")
  final int sets;           // Jumlah set
  final int reps;           // Jumlah repetisi per set
  final double? weight;     // Berat beban dalam kg (opsional)
  final String? notes;      // Catatan tambahan (opsional)
  final String? imageUrl;   // URL foto dari Firebase Storage (opsional)
  final DateTime createdAt; // Waktu dibuat
  final String userId;      // ID user pemilik workout

  Workout({
    this.id,
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    this.weight,
    this.notes,
    this.imageUrl,
    required this.createdAt,
    required this.userId,
  });

  /// Daftar kategori latihan yang tersedia.
  static const List<String> categories = [
    'Dada',
    'Punggung',
    'Bahu',
    'Lengan',
    'Kaki',
    'Perut',
    'Kardio',
    'Full Body',
  ];

  /// Konversi dari dokumen Firestore ke objek Workout.
  factory Workout.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
      weight: (data['weight'] as num?)?.toDouble(),
      notes: data['notes'],
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
    );
  }

  /// Konversi dari objek Workout ke Map yang bisa disimpan di Firestore.
  Map<String, dynamic> toFirestore() => {
        'name': name,
        'category': category,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'notes': notes,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
        'userId': userId,
      };

  /// Konversi dari JSON (dari Hive) ke objek Workout.
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      notes: json['notes'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userId: json['userId'] ?? '',
    );
  }

  /// Konversi dari objek Workout ke JSON stringifiable map (untuk Hive).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sets': sets,
        'reps': reps,
        'weight': weight,
        'notes': notes,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'userId': userId,
      };

  /// Membuat salinan Workout dengan beberapa field yang diubah.
  Workout copyWith({
    String? id,
    String? name,
    String? category,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
    String? imageUrl,
    DateTime? createdAt,
    String? userId,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  /// Mendapatkan ikon yang sesuai dengan kategori latihan.
  /// Dipakai di UI untuk menampilkan ikon pada kartu workout.
  static String iconForCategory(String category) {
    return switch (category) {
      'Dada' => '💪',
      'Punggung' => '🔙',
      'Bahu' => '🏋️',
      'Lengan' => '💪',
      'Kaki' => '🦵',
      'Perut' => '🎯',
      'Kardio' => '🏃',
      'Full Body' => '⚡',
      _ => '🏋️',
    };
  }
}
