import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides a [OnboardingRepository] instance.
///
/// This provider is used to create a [OnboardingRepository] instance.
/// It requires a [SharedPreferences] instance to be provided.

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  throw UnimplementedError('Provider was not initialized');
});

/// Repository for managing onboarding state.
///
/// This repository is used to manage the onboarding state of the application.
/// It provides methods to check if the user has seen the onboarding,
/// if the user has accepted the terms of service, and to complete the onboarding.
///
/// Usage:
/// ```dart
/// final onboardingRepository = ref.watch(onboardingRepositoryProvider);
/// final hasSeenOnboarding = onboardingRepository.hasSeenOnboarding;
/// final hasAcceptedTos = onboardingRepository.hasAcceptedTos;
/// onboardingRepository.completeOnboarding();
/// onboardingRepository.acceptTos();
/// ```

class OnboardingRepository {
  final SharedPreferences _prefs;
  static const String _onboardingKey = 'has_seen_onboarding';
  static const String _tosKey = 'has_accepted_tos';

  OnboardingRepository(this._prefs);

  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;
  bool get hasAcceptedTos => _prefs.getBool(_tosKey) ?? false;

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  Future<void> acceptTos() async {
    await _prefs.setBool(_tosKey, true);
  }
}
