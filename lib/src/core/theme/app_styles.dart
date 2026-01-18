import 'package:flutter/material.dart';

/// Dopply Styles System
///
/// Defines shared shapes, shadows, spacing, and other visual constants
/// for the "Soft & Organic" theme.

// ============================================================================
// BORDER RADIUS
// ============================================================================

/// Border radius constants for organic, rounded shapes
class AppRadius {
  AppRadius._();

  /// Extra small radius - subtle rounding (8dp)
  static const double xs = 8.0;

  /// Small radius - inputs, small buttons (12dp)
  static const double small = 12.0;

  /// Medium radius - cards, dialogs (20dp)
  static const double medium = 20.0;

  /// Large radius - prominent elements (30dp)
  static const double large = 30.0;

  /// Extra large radius - hero elements, bottom sheets (40dp)
  static const double xl = 40.0;

  /// Full radius - circular elements
  static const double full = 999.0;

  // BorderRadius instances
  static BorderRadius get borderRadiusXs => BorderRadius.circular(xs);
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(small);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(medium);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(large);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(xl);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(full);
}

// ============================================================================
// SHADOWS
// ============================================================================

/// Soft shadow definitions for depth without harsh edges
class AppShadows {
  AppShadows._();

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra soft shadow - subtle elevation
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Soft shadow - cards, buttons (primary elevation)
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x05000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// Medium shadow - elevated cards, dropdowns
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Strong shadow - modals, dialogs
  static const List<BoxShadow> strong = [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// Colored soft shadow - for primary colored elements
  static List<BoxShadow> primarySoft(Color primaryColor) => [
    BoxShadow(
      color: primaryColor.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

// ============================================================================
// SPACING
// ============================================================================

/// Consistent spacing values based on 4dp grid
class AppSpacing {
  AppSpacing._();

  /// 4dp - tight spacing
  static const double xxs = 4.0;

  /// 8dp - compact spacing
  static const double xs = 8.0;

  /// 12dp - small spacing
  static const double small = 12.0;

  /// 16dp - default spacing
  static const double medium = 16.0;

  /// 20dp - comfortable spacing
  static const double large = 20.0;

  /// 24dp - section spacing
  static const double xl = 24.0;

  /// 32dp - large section spacing
  static const double xxl = 32.0;

  /// 48dp - major section breaks
  static const double xxxl = 48.0;

  // EdgeInsets helpers
  static EdgeInsets get paddingXs => const EdgeInsets.all(xs);
  static EdgeInsets get paddingSmall => const EdgeInsets.all(small);
  static EdgeInsets get paddingMedium => const EdgeInsets.all(medium);
  static EdgeInsets get paddingLarge => const EdgeInsets.all(large);
  static EdgeInsets get paddingXl => const EdgeInsets.all(xl);

  /// Horizontal padding for screen edges
  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: medium);

  /// Card content padding
  static EdgeInsets get cardPadding => const EdgeInsets.all(large);
}

// ============================================================================
// DURATIONS
// ============================================================================

/// Animation duration constants
class AppDurations {
  AppDurations._();

  /// Fast animations - button states (100ms)
  static const Duration fast = Duration(milliseconds: 100);

  /// Normal animations - most transitions (200ms)
  static const Duration normal = Duration(milliseconds: 200);

  /// Slow animations - page transitions (300ms)
  static const Duration slow = Duration(milliseconds: 300);

  /// Extra slow - complex animations (500ms)
  static const Duration extraSlow = Duration(milliseconds: 500);
}

// ============================================================================
// SIZES
// ============================================================================

/// Common size constants
class AppSizes {
  AppSizes._();

  /// Minimum touch target size (48dp - WCAG requirement)
  static const double minTouchTarget = 48.0;

  /// Icon sizes
  static const double iconXs = 16.0;
  static const double iconSmall = 20.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXl = 48.0;

  /// Button heights
  static const double buttonSmall = 36.0;
  static const double buttonMedium = 48.0;
  static const double buttonLarge = 56.0;

  /// Input field height
  static const double inputHeight = 56.0;

  /// AppBar height
  static const double appBarHeight = 64.0;

  /// Bottom nav height
  static const double bottomNavHeight = 80.0;

  /// Card min height
  static const double cardMinHeight = 80.0;
}
