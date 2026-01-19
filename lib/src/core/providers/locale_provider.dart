import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale state notifier for managing app language
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('id')) {
    _loadLocale();
  }

  static const String _localeKey = 'app_locale';
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('id'), // Indonesian
  ];

  /// Load saved locale or detect system locale
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      // Use saved preference
      state = Locale(savedLocale);
    } else {
      // Detect system locale on first launch
      final systemLocale = PlatformDispatcher.instance.locale;

      // Check if system locale is supported
      final isSupported = supportedLocales.any(
        (locale) => locale.languageCode == systemLocale.languageCode,
      );

      if (isSupported) {
        state = Locale(systemLocale.languageCode);
        // Save detected locale
        await prefs.setString(_localeKey, systemLocale.languageCode);
      } else {
        // Default to Indonesian if system locale not supported
        state = const Locale('id');
        await prefs.setString(_localeKey, 'id');
      }
    }
  }

  /// Change app locale and persist to storage
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  /// Get locale name for display
  String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      default:
        return locale.languageCode;
    }
  }
}

/// Provider for app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
