import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/core/services/fcm_service.dart';
import 'src/core/services/offline_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/features/onboarding/data/onboarding_repository.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Init Firebase
  await Firebase.initializeApp();
  final fcmService = FcmService(Supabase.instance.client);
  await fcmService.initialize();

  // Init Offline Service
  final offlineService = OfflineService();
  await offlineService.init();

  // Init Shared Prefs
  final prefs = await SharedPreferences.getInstance();
  final onboardingRepository = OnboardingRepository(prefs);

  runApp(
    ProviderScope(
      overrides: [
        offlineServiceProvider.overrideWithValue(offlineService),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
      ],
      child: const DopplyApp(),
    ),
  );
}
