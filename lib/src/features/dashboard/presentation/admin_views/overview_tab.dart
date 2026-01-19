import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminStatsProvider = FutureProvider.autoDispose<Map<String, int>>((
  ref,
) async {
  final client = Supabase.instance.client;

  // Run in parallel for efficiency
  final results = await Future.wait([
    client.from('profiles').count(),
    client.from('patients').count(),
    client.from('records').count(),
    client
        .from('transfer_requests')
        .count(CountOption.exact)
        .eq('status', 'pending'),
  ]);

  return {
    'total_users': results[0],
    'total_patients': results[1],
    'total_records': results[2],
    'pending_transfers': results[3],
  };
});

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return statsAsync.when(
      data: (stats) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatsCard(
              title: 'Total Users',
              value: stats['total_users'].toString(),
              icon: Icons.people,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _StatsCard(
              title: 'Patients',
              value: stats['total_patients'].toString(),
              icon: Icons.pregnant_woman,
              color: Colors.pink,
            ),
            const SizedBox(height: 16),
            _StatsCard(
              title: 'Measurements',
              value: stats['total_records'].toString(),
              icon: Icons.monitor_heart,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            _StatsCard(
              title: 'Pending Transfers',
              value: stats['pending_transfers'].toString(),
              icon: Icons.swap_horiz,
              color: Colors.orange,
            ),
          ],
        );
      },
      error: (err, stack) => Center(child: Text('Error loading stats: $err')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(title, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
