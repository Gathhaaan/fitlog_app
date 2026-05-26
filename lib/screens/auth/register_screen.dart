import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

/// Layar registrasi akun baru.
///
/// Fitur:
/// - Form lengkap: Nama, Email, Password, Konfirmasi Password
/// - Validasi form yang ketat
/// - Error handling dengan pesan Indonesia
/// - Animasi fade-in
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  /// Konversi kode error Firebase ke pesan Indonesia yang ramah.
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'email-already-in-use' => 'Email sudah terdaftar.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah.',
        'operation-not-allowed' => 'Registrasi dinonaktifkan.',
        _ => 'Terjadi kesalahan. Silakan coba lagi.',
      };
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).registerWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            _nameController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Registrasi berhasil! Silakan login.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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

  /// Registrasi menggunakan Google.
  /// Firebase Auth otomatis membuat akun baru jika belum ada,
  /// atau login jika sudah punya akun.
  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
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
                  const Text(
                    'Buat Akun Baru 🚀',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Mulai perjalanan fitnessmu sekarang!',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),

                  // Nama Lengkap
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppDecorations.inputDecoration(
                        'Nama Lengkap', Icons.person),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 16),

                  // Konfirmasi Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: AppDecorations.inputDecoration(
                        'Konfirmasi Password', Icons.lock_outline),
                    validator: (v) =>
                        v != _passwordController.text
                            ? 'Password tidak sama'
                            : null,
                  ),
                  const SizedBox(height: 28),

                  // Tombol Daftar
                  ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Daftar'),
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

                  // Tombol Daftar dengan Google
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _registerWithGoogle,
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Daftar dengan Google'),
                  ),
                  const SizedBox(height: 16),

                  // Link ke Login
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Sudah punya akun? Login',
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