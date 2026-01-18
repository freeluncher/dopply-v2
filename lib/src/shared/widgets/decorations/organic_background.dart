import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Organic Wave Background
///
/// A soft, calming background with organic wave patterns.
/// Creates a nurturing atmosphere appropriate for a maternal health app.
///
/// Usage:
/// ```dart
/// Stack(
///   children: [
///     const OrganicBackground(),
///     // Your content here
///   ],
/// )
/// ```

class OrganicBackground extends StatelessWidget {
  const OrganicBackground({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    this.animate = false,
  });

  /// Primary wave color (defaults to theme primary light)
  final Color? primaryColor;

  /// Secondary wave color (defaults to theme secondary light)
  final Color? secondaryColor;

  /// Whether to animate the waves (use sparingly for performance)
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedOrganicBackground(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
    }

    return CustomPaint(
      painter: _OrganicWavePainter(
        primaryColor:
            primaryColor ?? AppColors.primaryLight.withValues(alpha: 0.3),
        secondaryColor:
            secondaryColor ?? AppColors.secondaryLight.withValues(alpha: 0.2),
        phase: 0,
      ),
      size: Size.infinite,
    );
  }
}

class _AnimatedOrganicBackground extends StatefulWidget {
  const _AnimatedOrganicBackground({this.primaryColor, this.secondaryColor});

  final Color? primaryColor;
  final Color? secondaryColor;

  @override
  State<_AnimatedOrganicBackground> createState() =>
      _AnimatedOrganicBackgroundState();
}

class _AnimatedOrganicBackgroundState extends State<_AnimatedOrganicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OrganicWavePainter(
            primaryColor:
                widget.primaryColor ??
                AppColors.primaryLight.withValues(alpha: 0.3),
            secondaryColor:
                widget.secondaryColor ??
                AppColors.secondaryLight.withValues(alpha: 0.2),
            phase: _controller.value * 2 * math.pi,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _OrganicWavePainter extends CustomPainter {
  _OrganicWavePainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.phase,
  });

  final Color primaryColor;
  final Color secondaryColor;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom wave (primary color)
    _drawWave(
      canvas,
      size,
      color: primaryColor,
      amplitude: size.height * 0.08,
      frequency: 1.5,
      verticalOffset: size.height * 0.85,
      phaseOffset: phase,
    );

    // Middle wave (secondary color)
    _drawWave(
      canvas,
      size,
      color: secondaryColor,
      amplitude: size.height * 0.06,
      frequency: 2.0,
      verticalOffset: size.height * 0.9,
      phaseOffset: phase + math.pi / 4,
    );

    // Top accent wave
    _drawWave(
      canvas,
      size,
      color: primaryColor.withValues(alpha: 0.15),
      amplitude: size.height * 0.03,
      frequency: 3.0,
      verticalOffset: size.height * 0.15,
      phaseOffset: -phase,
      fillToTop: true,
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required Color color,
    required double amplitude,
    required double frequency,
    required double verticalOffset,
    required double phaseOffset,
    bool fillToTop = false,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (fillToTop) {
      path.moveTo(0, 0);
      path.lineTo(0, verticalOffset);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(0, verticalOffset);
    }

    for (double x = 0; x <= size.width; x++) {
      final y =
          verticalOffset +
          amplitude *
              math.sin(
                (x / size.width) * frequency * math.pi * 2 + phaseOffset,
              );
      path.lineTo(x, y);
    }

    if (fillToTop) {
      path.lineTo(size.width, 0);
    } else {
      path.lineTo(size.width, size.height);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_OrganicWavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

/// Soft Blob Background
///
/// Creates soft, organic blob shapes in the background.
class SoftBlobBackground extends StatelessWidget {
  const SoftBlobBackground({super.key, this.color, this.blobCount = 3});

  final Color? color;
  final int blobCount;

  @override
  Widget build(BuildContext context) {
    final blobColor = color ?? AppColors.primaryLight.withValues(alpha: 0.2);

    return CustomPaint(
      painter: _BlobPainter(color: blobColor, blobCount: blobCount),
      size: Size.infinite,
    );
  }
}

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.color, required this.blobCount});

  final Color color;
  final int blobCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Top right blob
    _drawBlob(
      canvas,
      paint,
      center: Offset(size.width * 0.85, size.height * 0.1),
      radius: size.width * 0.4,
    );

    if (blobCount >= 2) {
      // Bottom left blob
      _drawBlob(
        canvas,
        paint,
        center: Offset(size.width * 0.1, size.height * 0.85),
        radius: size.width * 0.35,
      );
    }

    if (blobCount >= 3) {
      // Center blob (smaller, more transparent)
      _drawBlob(
        canvas,
        paint..color = color.withValues(alpha: color.a * 0.5),
        center: Offset(size.width * 0.6, size.height * 0.5),
        radius: size.width * 0.25,
      );
    }
  }

  void _drawBlob(
    Canvas canvas,
    Paint paint, {
    required Offset center,
    required double radius,
  }) {
    final path = Path();

    // Create organic blob shape using bezier curves
    const points = 8;
    final random = math.Random(center.dx.toInt() + center.dy.toInt());

    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final variation = 0.7 + random.nextDouble() * 0.6;
      final r = radius * variation;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Use quadratic bezier for smooth curves
        final prevAngle = ((i - 0.5) / points) * 2 * math.pi;
        final ctrlVariation = 0.7 + random.nextDouble() * 0.6;
        final ctrlR = radius * ctrlVariation * 1.1;
        final ctrlX = center.dx + ctrlR * math.cos(prevAngle);
        final ctrlY = center.dy + ctrlR * math.sin(prevAngle);
        path.quadraticBezierTo(ctrlX, ctrlY, x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.blobCount != blobCount;
  }
}
