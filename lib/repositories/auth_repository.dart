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
  /// 1. signIn() — buka dialog pilih akun Google
  /// 2. Ambil accessToken dan idToken dari authentication
  /// 3. Gunakan credential untuk login ke Firebase
  ///
  /// Jika user sudah punya akun Firebase → login
  /// Jika belum punya → otomatis dibuatkan akun baru
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Tampilkan dialog pilih akun Google
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User membatalkan dialog
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Login dibatalkan oleh pengguna.',
      );
    }

    // Ambil token autentikasi
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Buat credential Firebase dari token Google
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _auth.signInWithCredential(credential);
  }

  /// Logout dari semua provider (Google + Firebase).
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {
      // Abaikan error Google Sign-Out (mungkin belum login via Google)
    }
    await _auth.signOut();
  }

  /// Mendapatkan user yang sedang login saat ini.
  User? get currentUser => _auth.currentUser;
}