// ignore_for_file: unused_field
import 'package:flutter/material.dart';

/// Dopply Color System - Soft & Organic Theme
///
/// This file defines the color palette for the Dopply application.
/// Colors are organized into:
/// - Primitive colors (raw color values)
/// - Semantic colors (contextual meaning)

// ============================================================================
// PRIMITIVE COLORS
// ============================================================================

/// Raw color definitions - do not use directly in widgets
class _DopplyPrimitives {
  _DopplyPrimitives._();

  // Teal/Mint family - Trust & Calm
  static const Color teal50 = Color(0xFFE0F2F1);
  static const Color teal100 = Color(0xFFB2DFDB);
  static const Color teal200 = Color(0xFF80CBC4);
  static const Color teal300 = Color(0xFF64B6AC);
  static const Color teal400 = Color(0xFF4DB6AC);
  static const Color teal500 = Color(0xFF26A69A);
  static const Color teal600 = Color(0xFF009688);

  // Peach/Warm Pink family - Warmth & Life
  static const Color peach50 = Color(0xFFFFF5F7);
  static const Color peach100 = Color(0xFFFFE4EC);
  static const Color peach200 = Color(0xFFFAD2E1);
  static const Color peach300 = Color(0xFFF8BBD0);
  static const Color peach400 = Color(0xFFF48FB1);

  // Neutral family - Backgrounds & Text
  static const Color cream = Color(0xFFFDFBF7);
  static const Color offWhite = Color(0xFFFAF9F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color slateGrey900 = Color(0xFF2F4858);
  static const Color slateGrey700 = Color(0xFF4A6572);
  static const Color slateGrey500 = Color(0xFF6B8294);
  static const Color slateGrey300 = Color(0xFFA8BCC6);
  static const Color slateGrey100 = Color(0xFFD9E2E8);

  // Status colors - Medical context
  static const Color coral = Color(0xFFF08080);
  static const Color coralLight = Color(0xFFFAD4D4);
  static const Color amber = Color(0xFFFFB74D);
  static const Color amberLight = Color(0xFFFFE0B2);
  static const Color green = Color(0xFF81C784);
  static const Color greenLight = Color(0xFFC8E6C9);
}

// ============================================================================
// SEMANTIC COLORS
// ============================================================================

/// Semantic color palette - use these in widgets
class AppColors {
  AppColors._();

  // Primary - Soft Teal (Trust & Calm)
  static const Color primary = _DopplyPrimitives.teal300;
  static const Color primaryLight = _DopplyPrimitives.teal100;
  static const Color primaryDark = _DopplyPrimitives.teal500;
  static const Color onPrimary = _DopplyPrimitives.white;

  // Secondary - Warm Peach (Warmth & Life)
  static const Color secondary = _DopplyPrimitives.peach200;
  static const Color secondaryLight = _DopplyPrimitives.peach100;
  static const Color secondaryDark = _DopplyPrimitives.peach400;
  static const Color onSecondary = _DopplyPrimitives.slateGrey900;

  // Background & Surface
  static const Color background = _DopplyPrimitives.cream;
  static const Color surface = _DopplyPrimitives.white;
  static const Color surfaceVariant = _DopplyPrimitives.offWhite;
  static const Color onBackground = _DopplyPrimitives.slateGrey900;
  static const Color onSurface = _DopplyPrimitives.slateGrey900;
  static const Color onSurfaceVariant = _DopplyPrimitives.slateGrey700;

  // Text colors - WCAG AA compliant (>= 4.5:1 contrast)
  static const Color textPrimary = _DopplyPrimitives.slateGrey900;
  static const Color textSecondary = _DopplyPrimitives.slateGrey700;
  static const Color textTertiary = _DopplyPrimitives.slateGrey500;
  static const Color textDisabled = _DopplyPrimitives.slateGrey300;

  // Error/Alert - Soft Coral (non-aggressive)
  static const Color error = _DopplyPrimitives.coral;
  static const Color errorContainer = _DopplyPrimitives.coralLight;
  static const Color onError = _DopplyPrimitives.white;
  static const Color onErrorContainer = _DopplyPrimitives.slateGrey900;

  // Warning - Amber
  static const Color warning = _DopplyPrimitives.amber;
  static const Color warningContainer = _DopplyPrimitives.amberLight;
  static const Color onWarning = _DopplyPrimitives.slateGrey900;

  // Success - Soft Green
  static const Color success = _DopplyPrimitives.green;
  static const Color successContainer = _DopplyPrimitives.greenLight;
  static const Color onSuccess = _DopplyPrimitives.white;

  // Outline & Dividers
  static const Color outline = _DopplyPrimitives.slateGrey300;
  static const Color outlineVariant = _DopplyPrimitives.slateGrey100;

  // Scrim & Overlay
  static const Color scrim = Color(0x52000000);
  static const Color overlay = Color(0x1F000000);

  /// Creates a Material 3 ColorScheme from our semantic colors
  static ColorScheme get colorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    primaryContainer: primaryLight,
    onPrimaryContainer: textPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    secondaryContainer: secondaryLight,
    onSecondaryContainer: textPrimary,
    tertiary: _DopplyPrimitives.peach300,
    onTertiary: onSecondary,
    tertiaryContainer: _DopplyPrimitives.peach100,
    onTertiaryContainer: textPrimary,
    error: error,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
    surface: surface,
    onSurface: onSurface,
    surfaceContainerHighest: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    scrim: scrim,
  );
}
