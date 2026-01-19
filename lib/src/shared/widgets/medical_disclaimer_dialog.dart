import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../../generated/l10n/app_localizations.dart';

/// Medical Disclaimer Dialog
///
/// A non-dismissible dialog requiring user acknowledgment before
/// first monitoring session. Compliant with medical app standards.
///
/// Usage:
/// ```dart
/// await MedicalDisclaimerDialog.showIfNeeded(context);
/// ```

class MedicalDisclaimerDialog extends StatefulWidget {
  const MedicalDisclaimerDialog({super.key});

  /// SharedPreferences key for disclaimer acceptance
  static const String _acceptedKey = 'medical_disclaimer_accepted';

  /// Show dialog if user hasn't accepted yet
  static Future<bool> showIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool(_acceptedKey) ?? false;

    if (!hasAccepted && context.mounted) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierColor: AppColors.scrim,
        builder: (context) => const MedicalDisclaimerDialog(),
      );
      return result ?? false;
    }
    return true;
  }

  /// Reset acceptance (for testing)
  static Future<void> resetAcceptance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_acceptedKey);
  }

  @override
  State<MedicalDisclaimerDialog> createState() =>
      _MedicalDisclaimerDialogState();
}

class _MedicalDisclaimerDialogState extends State<MedicalDisclaimerDialog> {
  bool _isChecked = false;
  bool _isLoading = false;

  Future<void> _onAccept() async {
    if (!_isChecked) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(MedicalDisclaimerDialog._acceptedKey, true);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.borderRadiusLarge),
      child: Padding(
        padding: AppSpacing.paddingLarge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_information_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            // Title
            Center(
              child: Text(
                l10n.medicalDisclaimerSubtitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.medium),

            // Content
            Container(
              padding: AppSpacing.paddingMedium,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.borderRadiusMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoPoint(
                    icon: Icons.info_outline,
                    text: l10n.disclaimerPoint1,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _buildInfoPoint(
                    icon: Icons.warning_amber_outlined,
                    text: l10n.disclaimerPoint3,
                  ),
                  const SizedBox(height: AppSpacing.small),
                  _buildInfoPoint(
                    icon: Icons.local_hospital_outlined,
                    text: l10n.disclaimerPoint4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            // Checkbox
            InkWell(
              onTap: () => setState(() => _isChecked = !_isChecked),
              borderRadius: AppRadius.borderRadiusSmall,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: AppSizes.minTouchTarget,
                      height: AppSizes.minTouchTarget,
                      child: Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() => _isChecked = value ?? false);
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Saya memahami dan menyetujui informasi di atas',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.large),

            // Accept Button
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonMedium,
              child: FilledButton(
                onPressed: _isChecked && !_isLoading ? _onAccept : null,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(l10n.confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPoint({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
