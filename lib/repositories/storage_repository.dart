import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Repository untuk operasi upload/download file ke Firebase Storage.
///
/// Digunakan untuk:
/// - Upload foto profil pengguna
/// - Upload foto workout (sebelum/sesudah latihan)
/// - Mendapatkan URL download dari file yang sudah diupload
class StorageRepository {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload foto profil pengguna ke Firebase Storage.
  ///
  /// File disimpan di path: `users/{userId}/profile.jpg`
  /// Mengembalikan URL download yang bisa ditampilkan di UI.
  Future<String> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final ref = _storage.ref('users/$userId/profile.jpg');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengupload foto profil: ${e.message}');
    }
  }

  /// Upload foto workout ke Firebase Storage.
  ///
  /// File disimpan di path: `workouts/{userId}/{timestamp}.jpg`
  /// Mengembalikan URL download.
  Future<String> uploadWorkoutPhoto(String userId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('workouts/$userId/$timestamp.jpg');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengupload foto workout: ${e.message}');
    }
  }

  /// Upload foto progres fisik ke Firebase Storage.
  ///
  /// File disimpan di path: `progress/{userId}/{timestamp}.jpg`
  /// Mengembalikan URL download.
  Future<String> uploadProgressPhoto(String userId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final ref = _storage.ref('progress/$userId/$timestamp.jpg');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Gagal mengupload foto progres: ${e.message}');
    }
  }

  /// Hapus file dari Firebase Storage berdasarkan URL-nya.
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } on FirebaseException catch (e) {
      throw Exception('Gagal menghapus file: ${e.message}');
    }
  }
}
