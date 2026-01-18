import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dopply_v2/src/app.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: DopplyApp()));

    // Verify that the app launches and shows something reasonable (e.g. Login screen by default)
    // Since we are mocking nothing, it might try to hit Supabase and fail or show loading.
    // However, for a smoke test, just checking it doesn't crash is often enough or checking for a widget.

    // We expect at least one widget to be present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
