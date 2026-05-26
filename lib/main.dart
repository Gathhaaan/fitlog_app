import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app/theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Hive untuk offline caching
  await Hive.initFlutter();
  await Hive.openBox('workout_cache');

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(
    const ProviderScope(
      child: FitLogApp(),
    ),
  );
}

/// Root widget aplikasi FitLog.
class FitLogApp extends ConsumerWidget {
  const FitLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'FitLog - Catat Perjalanan Fitnessmu',
      debugShowCheckedModeBanner: false,
      theme: appTheme(), // Tema terpusat dari lib/app/theme.dart
      home: const SplashScreen(),
    );
  }
}