import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

/// Layar login — pintu masuk utama ke aplikasi.
///
/// Fitur:
/// - Login dengan Email/Password
/// - Login dengan Google
/// - Error handling dengan pesan ramah pengguna (bahasa Indonesia)
/// - Animasi fade-in pada form
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Animasi fade-in form
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Konversi kode error Firebase ke pesan Indonesia yang ramah.
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-not-found' => 'Akun tidak ditemukan.',
        'wrong-password' => 'Password salah.',
        'invalid-email' => 'Format email tidak valid.',
        'user-disabled' => 'Akun dinonaktifkan.',
        'too-many-requests' => 'Terlalu banyak percobaan. Coba lagi nanti.',
        'invalid-credential' => 'Email atau password salah.',
        _ => 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.fitness_center,
                        size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Selamat Datang! 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Login untuk melanjutkan ke FitLog',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration:
                        AppDecorations.inputDecoration('Email', Icons.email),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!v.contains('@') || !v.contains('.')) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppDecorations.inputDecoration(
                            'Password', Icons.lock)
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v != null && v.length < 6)
                        ? 'Password minimal 6 karakter'
                        : null,
                  ),
                  const SizedBox(height: 24),

                  // Tombol Login
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('atau',
                            style: TextStyle(color: AppColors.textHint)),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tombol Google
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Login dengan Google'),
                  ),
                  const SizedBox(height: 24),

                  // Link ke Register
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'Belum punya akun? Daftar',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}