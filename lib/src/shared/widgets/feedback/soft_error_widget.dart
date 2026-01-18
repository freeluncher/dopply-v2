import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';

/// Soft Error Widget
///
/// A non-alarming error display using soft coral colors.
/// Designed to communicate issues without causing user anxiety.
///
/// Usage:
/// ```dart
/// SoftErrorWidget(
///   message: 'Tidak dapat terhubung ke perangkat',
///   onRetry: () => retryConnection(),
/// )
/// ```

class SoftErrorWidget extends StatelessWidget {
  const SoftErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryLabel,
    this.isInline = false,
  });

  /// Error message to display
  final String message;

  /// Optional title (defaults to "Terjadi Kesalahan")
  final String? title;

  /// Optional custom icon
  final IconData? icon;

  /// Callback when retry button is pressed
  final VoidCallback? onRetry;

  /// Custom retry button label
  final String? retryLabel;

  /// Whether to show inline (smaller) version
  final bool isInline;

  @override
  Widget build(BuildContext context) {
    if (isInline) {
      return _buildInline(context);
    }
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: AppSpacing.paddingLarge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with soft background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.cloud_off_outlined,
                size: 40,
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            // Title
            Text(
              title ?? 'Terjadi Kesalahan',
              style: textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.small),

            // Message
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Coba Lagi'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInline(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: AppSpacing.paddingMedium,
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: AppRadius.borderRadiusMedium,
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info_outline, size: 20, color: AppColors.error),
          const SizedBox(width: AppSpacing.small),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: AppSpacing.small),
            SizedBox(
              height: AppSizes.minTouchTarget,
              child: TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(retryLabel ?? 'Coba Lagi'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Preset error widgets for common scenarios
class SoftErrors {
  SoftErrors._();

  /// Network error
  static Widget network({VoidCallback? onRetry}) {
    return SoftErrorWidget(
      icon: Icons.wifi_off_outlined,
      title: 'Tidak Ada Koneksi',
      message: 'Periksa koneksi internet Anda dan coba lagi',
      onRetry: onRetry,
    );
  }

  /// Bluetooth error
  static Widget bluetooth({VoidCallback? onRetry}) {
    return SoftErrorWidget(
      icon: Icons.bluetooth_disabled,
      title: 'Bluetooth Tidak Aktif',
      message: 'Aktifkan Bluetooth untuk menghubungkan perangkat',
      onRetry: onRetry,
      retryLabel: 'Buka Pengaturan',
    );
  }

  /// Device not found
  static Widget deviceNotFound({VoidCallback? onRetry}) {
    return SoftErrorWidget(
      icon: Icons.bluetooth_searching,
      title: 'Perangkat Tidak Ditemukan',
      message: 'Pastikan perangkat Doppler Anda menyala dan dalam jangkauan',
      onRetry: onRetry,
      retryLabel: 'Cari Ulang',
    );
  }

  /// Server error
  static Widget server({VoidCallback? onRetry}) {
    return SoftErrorWidget(
      icon: Icons.cloud_off_outlined,
      title: 'Gangguan Server',
      message: 'Terjadi masalah pada server. Silakan coba beberapa saat lagi',
      onRetry: onRetry,
    );
  }

  /// Generic inline error
  static Widget inline(String message, {VoidCallback? onRetry}) {
    return SoftErrorWidget(message: message, isInline: true, onRetry: onRetry);
  }
}
