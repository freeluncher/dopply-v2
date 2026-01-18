import 'package:flutter/material.dart';

/// Medical Status Colors Extension
///
/// Custom ThemeExtension for medical-specific colors that don't fit
/// into Material 3 standard color slots.
///
/// Usage:
/// ```dart
/// final medicalColors = Theme.of(context).extension<MedicalStatusColors>()!;
/// Color normalColor = medicalColors.fetalHeartRateNormal;
/// ```

class MedicalStatusColors extends ThemeExtension<MedicalStatusColors> {
  const MedicalStatusColors({
    required this.fetalHeartRateNormal,
    required this.fetalHeartRateNormalContainer,
    required this.fetalHeartRateLow,
    required this.fetalHeartRateLowContainer,
    required this.fetalHeartRateHigh,
    required this.fetalHeartRateHighContainer,
    required this.connectionActive,
    required this.connectionActiveContainer,
    required this.connectionInactive,
    required this.connectionInactiveContainer,
    required this.recordingActive,
    required this.recordingActiveContainer,
  });

  /// Normal fetal heart rate (110-160 BPM)
  final Color fetalHeartRateNormal;
  final Color fetalHeartRateNormalContainer;

  /// Low fetal heart rate (<110 BPM) - Bradycardia warning
  final Color fetalHeartRateLow;
  final Color fetalHeartRateLowContainer;

  /// High fetal heart rate (>160 BPM) - Tachycardia warning
  final Color fetalHeartRateHigh;
  final Color fetalHeartRateHighContainer;

  /// Bluetooth connection active
  final Color connectionActive;
  final Color connectionActiveContainer;

  /// Bluetooth connection inactive/disconnected
  final Color connectionInactive;
  final Color connectionInactiveContainer;

  /// Recording in progress
  final Color recordingActive;
  final Color recordingActiveContainer;

  /// Default medical status colors for the Soft & Organic theme
  static const MedicalStatusColors defaults = MedicalStatusColors(
    // Normal - Soft green (calming, positive)
    fetalHeartRateNormal: Color(0xFF66BB6A),
    fetalHeartRateNormalContainer: Color(0xFFE8F5E9),

    // Low - Soft amber (cautionary, not alarming)
    fetalHeartRateLow: Color(0xFFFFB74D),
    fetalHeartRateLowContainer: Color(0xFFFFF3E0),

    // High - Soft coral (alert, but not aggressive)
    fetalHeartRateHigh: Color(0xFFF08080),
    fetalHeartRateHighContainer: Color(0xFFFFEBEE),

    // Connection Active - Teal (matches primary)
    connectionActive: Color(0xFF64B6AC),
    connectionActiveContainer: Color(0xFFE0F2F1),

    // Connection Inactive - Slate grey
    connectionInactive: Color(0xFFA8BCC6),
    connectionInactiveContainer: Color(0xFFECEFF1),

    // Recording Active - Warm peach/coral pulse
    recordingActive: Color(0xFFF48FB1),
    recordingActiveContainer: Color(0xFFFCE4EC),
  );

  @override
  MedicalStatusColors copyWith({
    Color? fetalHeartRateNormal,
    Color? fetalHeartRateNormalContainer,
    Color? fetalHeartRateLow,
    Color? fetalHeartRateLowContainer,
    Color? fetalHeartRateHigh,
    Color? fetalHeartRateHighContainer,
    Color? connectionActive,
    Color? connectionActiveContainer,
    Color? connectionInactive,
    Color? connectionInactiveContainer,
    Color? recordingActive,
    Color? recordingActiveContainer,
  }) {
    return MedicalStatusColors(
      fetalHeartRateNormal: fetalHeartRateNormal ?? this.fetalHeartRateNormal,
      fetalHeartRateNormalContainer:
          fetalHeartRateNormalContainer ?? this.fetalHeartRateNormalContainer,
      fetalHeartRateLow: fetalHeartRateLow ?? this.fetalHeartRateLow,
      fetalHeartRateLowContainer:
          fetalHeartRateLowContainer ?? this.fetalHeartRateLowContainer,
      fetalHeartRateHigh: fetalHeartRateHigh ?? this.fetalHeartRateHigh,
      fetalHeartRateHighContainer:
          fetalHeartRateHighContainer ?? this.fetalHeartRateHighContainer,
      connectionActive: connectionActive ?? this.connectionActive,
      connectionActiveContainer:
          connectionActiveContainer ?? this.connectionActiveContainer,
      connectionInactive: connectionInactive ?? this.connectionInactive,
      connectionInactiveContainer:
          connectionInactiveContainer ?? this.connectionInactiveContainer,
      recordingActive: recordingActive ?? this.recordingActive,
      recordingActiveContainer:
          recordingActiveContainer ?? this.recordingActiveContainer,
    );
  }

  @override
  MedicalStatusColors lerp(MedicalStatusColors? other, double t) {
    if (other is! MedicalStatusColors) return this;
    return MedicalStatusColors(
      fetalHeartRateNormal: Color.lerp(
        fetalHeartRateNormal,
        other.fetalHeartRateNormal,
        t,
      )!,
      fetalHeartRateNormalContainer: Color.lerp(
        fetalHeartRateNormalContainer,
        other.fetalHeartRateNormalContainer,
        t,
      )!,
      fetalHeartRateLow: Color.lerp(
        fetalHeartRateLow,
        other.fetalHeartRateLow,
        t,
      )!,
      fetalHeartRateLowContainer: Color.lerp(
        fetalHeartRateLowContainer,
        other.fetalHeartRateLowContainer,
        t,
      )!,
      fetalHeartRateHigh: Color.lerp(
        fetalHeartRateHigh,
        other.fetalHeartRateHigh,
        t,
      )!,
      fetalHeartRateHighContainer: Color.lerp(
        fetalHeartRateHighContainer,
        other.fetalHeartRateHighContainer,
        t,
      )!,
      connectionActive: Color.lerp(
        connectionActive,
        other.connectionActive,
        t,
      )!,
      connectionActiveContainer: Color.lerp(
        connectionActiveContainer,
        other.connectionActiveContainer,
        t,
      )!,
      connectionInactive: Color.lerp(
        connectionInactive,
        other.connectionInactive,
        t,
      )!,
      connectionInactiveContainer: Color.lerp(
        connectionInactiveContainer,
        other.connectionInactiveContainer,
        t,
      )!,
      recordingActive: Color.lerp(recordingActive, other.recordingActive, t)!,
      recordingActiveContainer: Color.lerp(
        recordingActiveContainer,
        other.recordingActiveContainer,
        t,
      )!,
    );
  }
}
