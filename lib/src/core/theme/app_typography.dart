import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Dopply Typography System
///
/// Uses Nunito - a well-balanced sans-serif with rounded terminals
/// that conveys warmth and approachability while remaining professional.

class AppTypography {
  AppTypography._();

  // ============================================================================
  // BASE TEXT THEME
  // ============================================================================

  /// Creates the base TextTheme using Nunito font
  static TextTheme get textTheme {
    return GoogleFonts.nunitoTextTheme(
      const TextTheme(
        // Display styles - Large headers
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          height: 1.12,
        ),
        displayMedium: TextStyle(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
          height: 1.16,
        ),
        displaySmall: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.22,
        ),

        // Headline styles - Section headers
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.25,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.29,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.33,
        ),

        // Title styles - Card titles, list headers
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          height: 1.27,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          height: 1.50,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),

        // Body styles - Main content
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.50,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.43,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.33,
        ),

        // Label styles - Buttons, chips, form labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          height: 1.43,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.33,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          height: 1.45,
        ),
      ),
    );
  }

  // ============================================================================
  // THEMED TEXT THEME (with colors applied)
  // ============================================================================

  /// TextTheme with appropriate colors applied
  static TextTheme get themedTextTheme {
    return textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  // ============================================================================
  // CUSTOM TEXT STYLES
  // ============================================================================

  /// Extra-large BPM display for monitoring screen
  static TextStyle get bpmDisplay => GoogleFonts.nunito(
    fontSize: 72,
    fontWeight: FontWeight.w800,
    letterSpacing: -1,
    height: 1.0,
    color: AppColors.primary,
  );

  /// BPM unit label
  static TextStyle get bpmUnit => GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  /// Status indicator text
  static TextStyle get statusLabel => GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.43,
  );

  /// Small caption for timestamps
  static TextStyle get timestamp => GoogleFonts.nunito(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );
}
