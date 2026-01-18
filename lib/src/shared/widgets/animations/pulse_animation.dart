import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Pulse Animation Widget
///
/// A gentle pulsing animation for displaying vital data like BPM.
/// Creates a calming visual effect that matches heartbeat rhythm.
///
/// Usage:
/// ```dart
/// PulseAnimation(
///   child: Text('120', style: TextStyle(fontSize: 72)),
///   bpm: 120, // Optional: sync with actual BPM
/// )
/// ```

class PulseAnimation extends StatefulWidget {
  const PulseAnimation({
    super.key,
    required this.child,
    this.bpm,
    this.minScale = 0.95,
    this.maxScale = 1.0,
    this.isAnimating = true,
  });

  /// The widget to animate
  final Widget child;

  /// Optional BPM to sync animation speed
  /// If null, uses default 80 BPM rhythm
  final int? bpm;

  /// Minimum scale during pulse (default 0.95)
  final double minScale;

  /// Maximum scale during pulse (default 1.0)
  final double maxScale;

  /// Whether animation is active
  final bool isAnimating;

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    final bpm = widget.bpm ?? 80;
    // Convert BPM to duration (60000ms / bpm)
    final durationMs = (60000 / bpm).round();

    _controller = AnimationController(
      duration: Duration(milliseconds: durationMs),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.maxScale,
      end: widget.minScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation if BPM changes significantly
    if (widget.bpm != oldWidget.bpm) {
      _controller.dispose();
      _initAnimation();
    }

    // Handle animation state changes
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isAnimating) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// Pulsing Glow Effect
///
/// Adds a subtle glow that pulses around a widget.
class PulsingGlow extends StatefulWidget {
  const PulsingGlow({
    super.key,
    required this.child,
    this.glowColor,
    this.isAnimating = true,
  });

  final Widget child;
  final Color? glowColor;
  final bool isAnimating;

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingGlow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppColors.primary;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: widget.isAnimating
                ? [
                    BoxShadow(
                      color: glowColor.withValues(
                        alpha: 0.3 * _glowAnimation.value,
                      ),
                      blurRadius: 20 + (10 * _glowAnimation.value),
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                  ]
                : null,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
