import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

/// Provider untuk instance AuthRepository.
/// Semua screen yang butuh akses ke auth harus memakai provider ini.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Provider yang memantau status autentikasi secara real-time.
/// Mengembalikan stream User? — null jika belum login, User jika sudah login.
/// Digunakan untuk menentukan apakah user perlu ke halaman login atau home.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});