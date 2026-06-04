import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// Provider untuk instance Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Stream profil user saat ini dari Firestore koleksi 'users/{uid}'.
///
/// Mengembalikan Map berisi field profil (photoUrl, displayName, dll).
/// Null jika user belum login atau dokumen belum ada.
final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snap) => snap.exists ? snap.data() : null);
});

/// Repository untuk operasi profil user di Firestore.
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Simpan atau perbarui dokumen profil user di Firestore.
  /// Menggunakan merge: true supaya tidak menimpa field lain.
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).set(
          data,
          SetOptions(merge: true),
        );
  }

  /// Baca profil user satu kali (non-stream).
  Future<Map<String, dynamic>?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }
}

/// Provider untuk instance UserRepository.
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
