import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';
import '../../../../generated/l10n/app_localizations.dart';

/// Empty State Widget
///
/// A friendly, encouraging empty state display that reduces user anxiety.
/// Uses warm messaging instead of cold "No data" text.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   icon: Icons.favorite_border,
///   title: 'Belum ada rekaman',
///   message: 'Mari mulai pemeriksaan pertama Anda',
///   actionLabel: 'Mulai Monitoring',
///   onAction: () => startMonitoring(),
/// )
/// ```

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    this.icon,
    this.iconWidget,
    this.message,
    this.actionLabel,
    this.onAction,
    this.padding,
  }) : assert(icon != null || iconWidget != null);

  /// Icon to display (mutually exclusive with iconWidget)
  final IconData? icon;

  /// Custom icon widget (mutually exclusive with icon)
  final Widget? iconWidget;

  /// Primary title text
  final String title;

  /// Optional supportive message
  final String? message;

  /// Optional action button label
  final String? actionLabel;

  /// Callback when action button is pressed
  final VoidCallback? onAction;

  /// Padding around the widget
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding ?? AppSpacing.paddingLarge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with soft background
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child:
                  iconWidget ?? Icon(icon, size: 48, color: AppColors.primary),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Title
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Message
            if (message != null) ...[
              const SizedBox(height: AppSpacing.small),
              Text(
                message!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Preset empty states for common scenarios
class EmptyStates {
  EmptyStates._();

  /// No records empty state
  static Widget noRecords(
    BuildContext context, {
    VoidCallback? onStartMonitoring,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: l10n.noRecordsYet,
      message: l10n.noRecordsMessage,
      actionLabel: onStartMonitoring != null ? l10n.startMonitoring : null,
      onAction: onStartMonitoring,
    );
  }

  /// No patients for doctor
  static Widget noPatients(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: l10n.noPatientsYet,
      message: l10n.noPatientsMessage,
    );
  }

  /// No notifications
  static Widget noNotifications(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.notifications_none,
      title: l10n.noNotifications,
      message: l10n.noNotificationsMessage,
    );
  }

  /// Search no results
  static Widget noSearchResults(String query) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Tidak Ditemukan',
      message: 'Tidak ada hasil untuk "$query"',
    );
  }

  /// Connection waiting
  static Widget waitingConnection() {
    return const EmptyStateWidget(
      icon: Icons.bluetooth_searching,
      title: 'Mencari Perangkat',
      message: 'Pastikan perangkat Doppler Anda dalam jangkauan',
    );
  }
}
