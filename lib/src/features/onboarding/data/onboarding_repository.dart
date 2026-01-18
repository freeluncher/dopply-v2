import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  throw UnimplementedError('Provider was not initialized');
});

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
