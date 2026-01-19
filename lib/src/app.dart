import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../generated/l10n/app_localizations.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';

class DopplyApp extends ConsumerWidget {
  const DopplyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Dopply',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: DopplyTheme.light,

      // Localization configuration
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('id'), // Indonesian
      ],
      locale: locale, // Dynamic locale from provider
    );
  }
}
