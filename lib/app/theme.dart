import 'package:flutter/material.dart';

/// Kumpulan warna utama aplikasi FitLog — Light Theme.
/// Palet: Cream / Off-white background, Orange primary, Purple accent.
abstract class AppColors {
  // Background utama — krem hangat
  static const background = Color(0xFFF5F0EA);
  // Permukaan kartu / panel putih
  static const surface = Color(0xFFFFFFFF);
  // Surface redup (grey muda)
  static const surfaceVariant = Color(0xFFF0EBE3);
  // Warna aksen utama — orange amber
  static const primary = Color(0xFFF59E0B);
  // Warna aksen sekunder — ungu
  static const accent = Color(0xFF7C3AED);
  // Orange lebih gelap untuk text di atas orange bg
  static const primaryDark = Color(0xFFD97706);
  // Warna peringatan/error
  static const error = Color(0xFFEF4444);
  // Warna sukses
  static const success = Color(0xFF10B981);
  // Teks utama — hitam pekat
  static const textPrimary = Color(0xFF1A1A1A);
  // Teks sekunder — abu
  static const textSecondary = Color(0xFF6B7280);
  // Teks sangat redup
  static const textHint = Color(0xFFADB5BD);
  // Border halus
  static const border = Color(0xFFE5E7EB);
  // Selected pill nav (hitam)
  static const navSelected = Color(0xFF1A1A1A);
  // Warna card orange (daily calories)
  static const cardOrange = Color(0xFFF59E0B);
  // Warna card ungu (activity banner)
  static const cardPurple = Color(0xFF7C3AED);
  // Shadow color
  static const shadow = Color(0x1A000000);
}

/// Kumpulan gradien yang dipakai di seluruh app.
abstract class AppGradients {
  // Gradien orange utama
  static const primary = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Gradien ungu
  static const purple = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Gradien latar splash/onboarding — hitam ke abu gelap
  static const onboarding = LinearGradient(
    colors: [Color(0xFF0A0A0A), Color(0xFF2D2D2D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  // Gradien kartu workout (thumbnail)
  static const workoutCard = LinearGradient(
    colors: [Color(0xFF374151), Color(0xFF111827)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  // Gradien background untuk splash atlet
  static const athleteBg = LinearGradient(
    colors: [Color(0xFFF5F0EA), Color(0xFFE8E0D5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Dekorasi umum yang sering dipakai.
abstract class AppDecorations {
  // Dekorasi kartu standar — putih dengan shadow
  static BoxDecoration card({double radius = 16}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      );

  // Kartu orange (calories)
  static BoxDecoration cardOrange({double radius = 16}) => BoxDecoration(
        gradient: AppGradients.primary,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      );

  // Kartu ungu (activity banner)
  static BoxDecoration cardPurple({double radius = 16}) => BoxDecoration(
        gradient: AppGradients.purple,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}

/// ThemeData lengkap untuk MaterialApp — Light Theme.
ThemeData appTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.background,
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
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
      selectedItemColor: AppColors.navSelected,
      unselectedItemColor: AppColors.textHint,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.navSelected,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white);
        }
        return const IconThemeData(color: AppColors.textHint);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: AppColors.navSelected,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          );
        }
        return const TextStyle(
          color: AppColors.textHint,
          fontSize: 12,
        );
      }),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
        textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size(double.infinity, 52),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
