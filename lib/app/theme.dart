import 'package:flutter/material.dart';

/// Kumpulan warna utama aplikasi FitLog.
/// Gunakan class ini di seluruh app supaya warna konsisten
/// dan mudah diubah dari satu tempat.
abstract class AppColors {
  // Warna latar belakang utama (gelap)
  static const background = Color(0xFF1A1A2E);
  // Warna permukaan kartu, input field, dll
  static const surface = Color(0xFF16213E);
  // Warna aksen utama (ungu)
  static const primary = Color(0xFF6C63FF);
  // Warna aksen sekunder (hijau teal)
  static const accent = Color(0xFF43B89C);
  // Warna peringatan/error
  static const error = Color(0xFFFF6B6B);
  // Warna sukses
  static const success = Color(0xFF43B89C);
  // Warna teks utama
  static const textPrimary = Colors.white;
  // Warna teks sekunder (lebih redup)
  static const textSecondary = Colors.white54;
  // Warna teks yang sangat redup
  static const textHint = Colors.white38;
  // Warna border/garis halus
  static const border = Colors.white12;
}

/// Kumpulan gradien yang dipakai di seluruh app.
abstract class AppGradients {
  // Gradien utama (ungu)
  static const primary = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A3FCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Gradien kartu (gelap halus)
  static const card = LinearGradient(
    colors: [Color(0xFF1E2746), Color(0xFF16213E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Gradien aksen (hijau teal)
  static const accent = LinearGradient(
    colors: [Color(0xFF43B89C), Color(0xFF2E8B7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Dekorasi umum yang sering dipakai (kartu, input, dll).
abstract class AppDecorations {
  // Dekorasi kartu standar dengan border halus
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        gradient: AppGradients.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      );

  // Dekorasi input field
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

/// ThemeData lengkap untuk MaterialApp.
ThemeData appTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
  );
}
