import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../onboarding/data/onboarding_repository.dart';

class TosScreen extends ConsumerWidget {
  const TosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medical Alert
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'MEDICAL DISCLAIMER: This app is NOT a diagnostic device. It is intended for informational purposes only.',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '1. Usage Agreement',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'By using Dopply, you agree that this application calculates Fetal Heart Rate based on audio input and algorithmic analysis. While we strive for accuracy, environmental factors can affect results.',
            ),
            const SizedBox(height: 16),

            Text(
              '2. Not Medical Advice',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The results provided by Dopply should never replace professional medical advice, diagnosis, or treatment. Always consult with your healthcare provider for any concerns regarding your pregnancy health.',
            ),
            const SizedBox(height: 16),

            Text(
              '3. Data Privacy',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your data is stored securely. We respect your privacy and do not sell your personal health information to third parties.',
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  await ref.read(onboardingRepositoryProvider).acceptTos();
                  if (context.mounted) {
                    // Navigate to root, which will redirect to Login/Home based on Auth
                    context.go('/');
                  }
                },
                child: const Text('I Agree & Continue'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // Exit app? Or just show dialog.
                  // For now just show "You must accept"
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You must accept the Terms to use Dopply.'),
                    ),
                  );
                },
                child: const Text('Decline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
