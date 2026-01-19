import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_styles.dart';

/// Language Selector Widget
///
/// Allows users to change app language between supported locales.
/// Shows current selection with visual indicator.
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.paddingMedium,
            child: Row(
              children: [
                Icon(Icons.language, color: AppColors.primary, size: 24),
                const SizedBox(width: AppSpacing.small),
                Text(
                  'Language / Bahasa',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...LocaleNotifier.supportedLocales.map((locale) {
            final isSelected =
                currentLocale.languageCode == locale.languageCode;
            final localeName = localeNotifier.getLocaleName(locale);

            return InkWell(
              onTap: () async {
                await localeNotifier.setLocale(locale);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $localeName'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Container(
                padding: AppSpacing.paddingMedium,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : null,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    // Flag or icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: AppRadius.borderRadiusSmall,
                      ),
                      child: Center(
                        child: Text(
                          _getFlag(locale.languageCode),
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.medium),
                    // Language name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localeName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                          ),
                          Text(
                            _getNativeName(locale.languageCode),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Check indicator
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _getFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇬🇧';
      case 'id':
        return '🇮🇩';
      default:
        return '🌐';
    }
  }

  String _getNativeName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return languageCode;
    }
  }
}
