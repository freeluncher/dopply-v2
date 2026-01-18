import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';

class DopplyApp extends ConsumerWidget {
  const DopplyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Dopply',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: DopplyTheme.light,
    );
  }
}
