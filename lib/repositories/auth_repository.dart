import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Repository untuk semua operasi autentikasi.
///
/// Mendukung:
/// - Login dengan Email/Password
/// - Registrasi akun baru
/// - Login dengan Google (google_sign_in v7.x API)
/// - Logout
///
/// Semua operasi Firebase Auth dipusatkan di sini supaya
/// UI tidak perlu tahu detail implementasi Firebase.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream yang memantau perubahan status login.
  /// Otomatis emit null saat logout, User saat login.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login menggunakan email dan password.
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Registrasi akun baru dengan email, password, dan nama.
  Future<UserCredential> registerWithEmail(
      String email, String password, String name) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await result.user?.updateDisplayName(name);
    return result;
  }

  /// Login menggunakan akun Google (google_sign_in v7.x API).
  ///
  /// Alur:
  /// 1. authenticate() — buka dialog pilih akun Google
  /// 2. Ambil idToken dari authentication
  /// 3. Gunakan credential untuk login ke Firebase
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Tampilkan dialog pilih akun Google
      final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

      // Ambil token autentikasi
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Buat credential Firebase dari token Google (v7 hanya butuh idToken untuk default Firebase)
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      // User membatalkan dialog atau terjadi error
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Login Google dibatalkan atau gagal: $e',
      );
    }
  }

  /// Logout dari semua provider (Google + Firebase).
  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Abaikan error Google Sign-Out
    }
    await _auth.signOut();
  }

  /// Mendapatkan user yang sedang login saat ini.
  User? get currentUser => _auth.currentUser;
}