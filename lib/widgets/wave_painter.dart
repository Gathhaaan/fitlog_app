import 'dart:math' as math;
import 'package:flutter/material.dart';


/// CustomPainter untuk menggambar animasi gelombang air.
/// Memenuhi requirement animasi di UAS Level 4.
class WavePainter extends CustomPainter {
  final double fillLevel;     // 0.0 sampai 1.0
  final double animationValue; // Nilai dari AnimationController (0.0 - 1.0)
  final Color color;

  WavePainter({
    required this.fillLevel,
    required this.animationValue,
    this.color = const Color(0xFF3B82F6), // Biru air default
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fillLevel <= 0.0) return; // Wadah kosong
    if (fillLevel >= 1.0) {
      // Wadah penuh, tidak perlu gelombang, cukup gambar kotak
      final paint = Paint()..color = color;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    
    final paintBackground = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final path = Path();
    final pathBackground = Path();

    final double yOffset = size.height * (1.0 - fillLevel);

    path.moveTo(0, size.height);
    path.lineTo(0, yOffset);

    pathBackground.moveTo(0, size.height);
    pathBackground.lineTo(0, yOffset);

    // Menggambar gelombang dengan kurva sinus
    for (double i = 0.0; i <= size.width; i++) {
      // Gelombang depan
      final double wave1 = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) * 8;
      path.lineTo(i, yOffset + wave1);

      // Gelombang belakang (berbeda fase)
      final double wave2 = math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi) + math.pi) * 8;
      pathBackground.lineTo(i, yOffset + wave2 - 4); // Agak lebih tinggi
    }

    path.lineTo(size.width, size.height);
    path.close();

    pathBackground.lineTo(size.width, size.height);
    pathBackground.close();

    // Gambar gelombang belakang dulu (lebih transparan)
    canvas.drawPath(pathBackground, paintBackground);
    // Gambar gelombang depan
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel || 
           oldDelegate.animationValue != animationValue;
  }
}
