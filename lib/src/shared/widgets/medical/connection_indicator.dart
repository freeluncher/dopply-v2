import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/medical_status_colors.dart';

/// Connection Status Indicator
///
/// Visual indicator for Bluetooth device connection status.
/// Uses appropriate colors from MedicalStatusColors extension.
///
/// Usage:
/// ```dart
/// ConnectionIndicator(
///   isConnected: bluetoothState.isConnected,
///   deviceName: 'Doppler FHR-100',
/// )
/// ```

class ConnectionIndicator extends StatelessWidget {
  const ConnectionIndicator({
    super.key,
    required this.isConnected,
    this.deviceName,
    this.showLabel = true,
    this.size = ConnectionIndicatorSize.medium,
    this.isConnecting = false,
  });

  /// Whether device is connected
  final bool isConnected;

  /// Optional device name to display
  final String? deviceName;

  /// Whether to show text label
  final bool showLabel;

  /// Size variant
  final ConnectionIndicatorSize size;

  /// Whether currently attempting to connect
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final medicalColors = Theme.of(context).extension<MedicalStatusColors>();
    final textTheme = Theme.of(context).textTheme;

    final Color activeColor =
        medicalColors?.connectionActive ?? AppColors.primary;
    final Color inactiveColor =
        medicalColors?.connectionInactive ?? AppColors.textTertiary;
    final Color containerActive =
        medicalColors?.connectionActiveContainer ?? AppColors.primaryLight;
    final Color containerInactive =
        medicalColors?.connectionInactiveContainer ?? AppColors.surfaceVariant;

    final color = isConnected ? activeColor : inactiveColor;
    final containerColor = isConnected ? containerActive : containerInactive;

    final dimensions = size.dimensions;

    String statusText;
    if (isConnecting) {
      statusText = 'Menghubungkan...';
    } else if (isConnected) {
      statusText = deviceName ?? 'Terhubung';
    } else {
      statusText = 'Tidak Terhubung';
    }

    return Semantics(
      label: isConnected
          ? 'Perangkat terhubung${deviceName != null ? ': $deviceName' : ''}'
          : 'Perangkat tidak terhubung',
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
            // Icon
            if (isConnecting)
              SizedBox(
                width: dimensions.iconSize,
                height: dimensions.iconSize,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            else
              Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                size: dimensions.iconSize,
                color: color,
              ),

            if (showLabel) ...[
              SizedBox(width: dimensions.spacing),
              Text(
                statusText,
                style: textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact connection dot
///
/// A minimal connection status indicator (just a colored dot)
class ConnectionDot extends StatefulWidget {
  const ConnectionDot({
    super.key,
    required this.isConnected,
    this.size = 12,
    this.animate = true,
  });

  final bool isConnected;
  final double size;
  final bool animate;

  @override
  State<ConnectionDot> createState() => _ConnectionDotState();
}

class _ConnectionDotState extends State<ConnectionDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    if (widget.animate && widget.isConnected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected ||
        widget.animate != oldWidget.animate) {
      if (widget.animate && widget.isConnected) {
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
    final medicalColors = Theme.of(context).extension<MedicalStatusColors>();

    final activeColor = medicalColors?.connectionActive ?? AppColors.primary;
    final inactiveColor =
        medicalColors?.connectionInactive ?? AppColors.textTertiary;

    final color = widget.isConnected ? activeColor : inactiveColor;

    return Semantics(
      label: widget.isConnected ? 'Terhubung' : 'Tidak terhubung',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glowOpacity = widget.animate && widget.isConnected
              ? 0.3 + (_controller.value * 0.4)
              : 0.3;

          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: widget.isConnected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: glowOpacity),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Size variants for connection indicator
enum ConnectionIndicatorSize { small, medium, large }

extension on ConnectionIndicatorSize {
  _ConnectionDimensions get dimensions {
    switch (this) {
      case ConnectionIndicatorSize.small:
        return const _ConnectionDimensions(
          iconSize: 16,
          horizontalPadding: 8,
          verticalPadding: 4,
          spacing: 6,
          borderRadius: 12,
        );
      case ConnectionIndicatorSize.medium:
        return const _ConnectionDimensions(
          iconSize: 20,
          horizontalPadding: 12,
          verticalPadding: 6,
          spacing: 8,
          borderRadius: 16,
        );
      case ConnectionIndicatorSize.large:
        return const _ConnectionDimensions(
          iconSize: 24,
          horizontalPadding: 16,
          verticalPadding: 8,
          spacing: 10,
          borderRadius: 20,
        );
    }
  }
}

class _ConnectionDimensions {
  const _ConnectionDimensions({
    required this.iconSize,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.spacing,
    required this.borderRadius,
  });

  final double iconSize;
  final double horizontalPadding;
  final double verticalPadding;
  final double spacing;
  final double borderRadius;
}
