import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/medical_status_colors.dart';

/// BPM Status Indicator
///
/// Visual indicator for fetal heart rate status using medical-appropriate colors.
/// Provides clear visual feedback without causing alarm.
///
/// Usage:
/// ```dart
/// BpmStatusIndicator(
///   bpm: 135,
///   showLabel: true,
/// )
/// ```

enum BpmStatus {
  /// Below normal range (<110 BPM) - Bradycardia
  low,

  /// Within normal range (110-160 BPM)
  normal,

  /// Above normal range (>160 BPM) - Tachycardia
  high,

  /// No reading available
  unknown,
}

class BpmStatusIndicator extends StatelessWidget {
  const BpmStatusIndicator({
    super.key,
    required this.bpm,
    this.showLabel = true,
    this.size = BpmIndicatorSize.medium,
    this.animate = true,
  });

  /// Current BPM value
  final int? bpm;

  /// Whether to show status label text
  final bool showLabel;

  /// Size variant
  final BpmIndicatorSize size;

  /// Whether to animate the indicator
  final bool animate;

  /// Normal FHR range constants
  static const int minNormal = 110;
  static const int maxNormal = 160;

  /// Get status from BPM value
  static BpmStatus getStatus(int? bpm) {
    if (bpm == null || bpm <= 0) return BpmStatus.unknown;
    if (bpm < minNormal) return BpmStatus.low;
    if (bpm > maxNormal) return BpmStatus.high;
    return BpmStatus.normal;
  }

  /// Get status label text
  static String getStatusLabel(BpmStatus status) {
    switch (status) {
      case BpmStatus.low:
        return 'Di Bawah Normal';
      case BpmStatus.normal:
        return 'Normal';
      case BpmStatus.high:
        return 'Di Atas Normal';
      case BpmStatus.unknown:
        return 'Tidak Tersedia';
    }
  }

  /// Get status color from theme extension
  static Color getStatusColor(BuildContext context, BpmStatus status) {
    final medicalColors = Theme.of(context).extension<MedicalStatusColors>();
    if (medicalColors == null) {
      // Fallback colors
      switch (status) {
        case BpmStatus.low:
          return AppColors.warning;
        case BpmStatus.normal:
          return AppColors.success;
        case BpmStatus.high:
          return AppColors.error;
        case BpmStatus.unknown:
          return AppColors.textTertiary;
      }
    }

    switch (status) {
      case BpmStatus.low:
        return medicalColors.fetalHeartRateLow;
      case BpmStatus.normal:
        return medicalColors.fetalHeartRateNormal;
      case BpmStatus.high:
        return medicalColors.fetalHeartRateHigh;
      case BpmStatus.unknown:
        return AppColors.textTertiary;
    }
  }

  /// Get container color from theme extension
  static Color getContainerColor(BuildContext context, BpmStatus status) {
    final medicalColors = Theme.of(context).extension<MedicalStatusColors>();
    if (medicalColors == null) {
      switch (status) {
        case BpmStatus.low:
          return AppColors.warningContainer;
        case BpmStatus.normal:
          return AppColors.successContainer;
        case BpmStatus.high:
          return AppColors.errorContainer;
        case BpmStatus.unknown:
          return AppColors.surfaceVariant;
      }
    }

    switch (status) {
      case BpmStatus.low:
        return medicalColors.fetalHeartRateLowContainer;
      case BpmStatus.normal:
        return medicalColors.fetalHeartRateNormalContainer;
      case BpmStatus.high:
        return medicalColors.fetalHeartRateHighContainer;
      case BpmStatus.unknown:
        return AppColors.surfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatus(bpm);
    final color = getStatusColor(context, status);
    final containerColor = getContainerColor(context, status);
    final label = getStatusLabel(status);

    final dimensions = size.dimensions;

    return Semantics(
      label: 'Status detak jantung janin: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dimensions.horizontalPadding,
          vertical: dimensions.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status dot with optional animation
            _StatusDot(
              color: color,
              size: dimensions.dotSize,
              animate: animate && status != BpmStatus.unknown,
            ),

            if (showLabel) ...[
              SizedBox(width: dimensions.spacing),
              Text(
                label,
                style: TextStyle(
                  fontSize: dimensions.fontSize,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Status dot with optional pulse animation
class _StatusDot extends StatefulWidget {
  const _StatusDot({
    required this.color,
    required this.size,
    required this.animate,
  });

  final Color color;
  final double size;
  final bool animate;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
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
    if (!widget.animate) {
      return _buildDot(1.0);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => _buildDot(_animation.value),
    );
  }

  Widget _buildDot(double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

/// Size variants for BPM indicator
enum BpmIndicatorSize { small, medium, large }

extension on BpmIndicatorSize {
  _BpmIndicatorDimensions get dimensions {
    switch (this) {
      case BpmIndicatorSize.small:
        return const _BpmIndicatorDimensions(
          dotSize: 8,
          fontSize: 12,
          horizontalPadding: 8,
          verticalPadding: 4,
          spacing: 6,
          borderRadius: 12,
        );
      case BpmIndicatorSize.medium:
        return const _BpmIndicatorDimensions(
          dotSize: 10,
          fontSize: 14,
          horizontalPadding: 12,
          verticalPadding: 6,
          spacing: 8,
          borderRadius: 16,
        );
      case BpmIndicatorSize.large:
        return const _BpmIndicatorDimensions(
          dotSize: 12,
          fontSize: 16,
          horizontalPadding: 16,
          verticalPadding: 8,
          spacing: 10,
          borderRadius: 20,
        );
    }
  }
}

class _BpmIndicatorDimensions {
  const _BpmIndicatorDimensions({
    required this.dotSize,
    required this.fontSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
    required this.borderRadius,
  });

  final double dotSize;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double spacing;
  final double borderRadius;
}
