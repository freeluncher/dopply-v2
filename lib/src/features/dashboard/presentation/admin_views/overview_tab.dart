import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [adminStatsProvider] instance.
///
/// This provider creates and manages the application's statistics.
/// It handles statistics operations such as fetching and calculating statistics.
///
/// Usage:
/// ```dart
/// final adminStats = ref.watch(adminStatsProvider);
/// adminStats.when(
///   data: (stats) {
///     // Handle statistics
///   },
///   error: (error, stack) {
///     // Handle error
///   },
///   loading: () {
///     // Handle loading
///   },
/// );
/// ```
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

/// The [OverviewTab] widget displays an overview of the application's statistics.
///
/// This widget shows key metrics such as total users, patients, measurements, and pending transfers.
/// It uses the [adminStatsProvider] to fetch and display the statistics.
///
/// Usage:
/// ```dart
/// OverviewTab()
/// ```

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

/// A card widget that displays a statistic with an icon and title.
///
/// This widget displays a statistic with an icon and title.
/// It is used in the [OverviewTab] widget to display key metrics.
///
/// Usage:
/// ```dart
/// _StatsCard(
///   title: 'Total Users',
///   value: '100',
///   icon: Icons.people,
///   color: Colors.blue,
/// )
/// ```

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
                color: color.withValues(alpha: 0.1),
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
