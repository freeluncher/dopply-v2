import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Dopply Theme Configuration
///
/// A factory class that generates theme configurations from a seed color.
/// Supports white-labeling and easy rebranding.

class DopplyThemeConfig {
  DopplyThemeConfig._();

  /// Default Soft & Organic theme configuration
  static const DopplyThemePreset softOrganic = DopplyThemePreset(
    name: 'Soft & Organic',
    seedColor: Color(0xFF64B6AC), // Soft Teal
    primaryColor: Color(0xFF64B6AC),
    secondaryColor: Color(0xFFFAD2E1), // Warm Peach
    backgroundColor: Color(0xFFFDFBF7), // Cream
    surfaceColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFF08080), // Soft Coral
    textColor: Color(0xFF2F4858), // Dark Slate
  );

  /// Clinical/Professional theme preset
  static const DopplyThemePreset clinical = DopplyThemePreset(
    name: 'Clinical',
    seedColor: Color(0xFF0288D1),
    primaryColor: Color(0xFF0288D1), // Blue
    secondaryColor: Color(0xFF00ACC1), // Cyan
    backgroundColor: Color(0xFFF5F5F5), // Light grey
    surfaceColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFD32F2F), // Standard red
    textColor: Color(0xFF212121),
  );

  /// Warm & Nurturing theme preset
  static const DopplyThemePreset warmNurturing = DopplyThemePreset(
    name: 'Warm & Nurturing',
    seedColor: Color(0xFFE57373),
    primaryColor: Color(0xFFE57373), // Soft pink/red
    secondaryColor: Color(0xFFFFCC80), // Warm orange
    backgroundColor: Color(0xFFFFF8E1), // Warm off-white
    surfaceColor: Color(0xFFFFFFFF),
    errorColor: Color(0xFFEF5350),
    textColor: Color(0xFF4E342E),
  );

  /// Generate a ColorScheme from a preset
  static ColorScheme colorSchemeFromPreset(DopplyThemePreset preset) {
    return ColorScheme.fromSeed(
      seedColor: preset.seedColor,
      primary: preset.primaryColor,
      secondary: preset.secondaryColor,
      surface: preset.surfaceColor,
      error: preset.errorColor,
      brightness: Brightness.light,
    ).copyWith(onSurface: preset.textColor);
  }

  /// Get the active preset (currently Soft & Organic)
  static DopplyThemePreset get activePreset => softOrganic;

  /// Get the active ColorScheme
  static ColorScheme get activeColorScheme => AppColors.colorScheme;
}

/// A preset configuration for theming
class DopplyThemePreset {
  const DopplyThemePreset({
    required this.name,
    required this.seedColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.errorColor,
    required this.textColor,
  });

  final String name;
  final Color seedColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color errorColor;
  final Color textColor;

  /// Whether this is a dark theme
  bool get isDark =>
      ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark;
}
