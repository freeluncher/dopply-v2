import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Breathing Loader Widget
///
/// A calm, non-aggressive loading indicator that uses a "breathing"
/// animation pattern. Designed to reduce anxiety during loading states.
///
/// Usage:
/// ```dart
/// BreathingLoader(
///   size: 60,
///   message: 'Menghubungkan...',
/// )
/// ```

class BreathingLoader extends StatefulWidget {
  const BreathingLoader({
    super.key,
    this.size = 60,
    this.color,
    this.message,
    this.duration = const Duration(milliseconds: 2000),
  });

  /// Size of the loader circle
  final double size;

  /// Primary color (uses theme primary if not specified)
  final Color? color;

  /// Optional calming message below the loader
  final String? message;

  /// Duration of one breath cycle
  final Duration duration;

  @override
  State<BreathingLoader> createState() => _BreathingLoaderState();
}

class _BreathingLoaderState extends State<BreathingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: _opacityAnimation.value),
                      color.withValues(alpha: _opacityAnimation.value * 0.3),
                      color.withValues(alpha: 0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: widget.size * 0.5,
                    height: widget.size * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Wave Loader
///
/// A soft wave animation for loading states.
class WaveLoader extends StatefulWidget {
  const WaveLoader({super.key, this.size = 40, this.color, this.waveCount = 3});

  final double size;
  final Color? color;
  final int waveCount;

  @override
  State<WaveLoader> createState() => _WaveLoaderState();
}

class _WaveLoaderState extends State<WaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
    final color = widget.color ?? AppColors.primary;

    return SizedBox(
      width: widget.size * widget.waveCount,
      height: widget.size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.waveCount, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final delay = index / widget.waveCount;
              final value = math.sin((_controller.value + delay) * 2 * math.pi);
              return Container(
                width: widget.size * 0.25,
                height: widget.size * (0.4 + 0.3 * (value + 1) / 2),
                margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.6 + 0.4 * (value + 1) / 2),
                  borderRadius: BorderRadius.circular(widget.size * 0.125),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
