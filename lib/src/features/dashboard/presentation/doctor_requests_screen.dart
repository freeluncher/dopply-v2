import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final requestsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return Stream.value([]);

  return Supabase.instance.client
      .from('monitoring_requests')
      .stream(primaryKey: ['id'])
      .eq('doctor_id', user.id)
      .order('created_at', ascending: false)
      .asyncMap((requests) async {
        if (requests.isEmpty) return [];

        // Filter pending requests locally if needed, or rely on stream filter?
        // .stream() supports basic filters. Let's filter in memory to be safe as .eq on stream acts as filter.
        final pendingRequests = requests
            .where((r) => r['status'] == 'pending')
            .toList();
        if (pendingRequests.isEmpty) return [];

        final patientIds = pendingRequests.map((e) => e['patient_id']).toList();

        final patientsData = await Supabase.instance.client
            .from('patients')
            .select('id, name')
            .inFilter('id', patientIds);

        return pendingRequests.map((req) {
          final patient = patientsData.firstWhere(
            (p) => p['id'] == req['patient_id'],
            orElse: () => {'name': 'Unknown'},
          );
          return {...req, 'patients': patient};
        }).toList();
      });
});

class DoctorRequestsScreen extends ConsumerWidget {
  const DoctorRequestsScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    int requestId,
    String status,
  ) async {
    try {
      await Supabase.instance.client
          .from('monitoring_requests')
          .update({'status': status})
          .eq('id', requestId);

      // Refresh list - via Stream now
      // ref.invalidate(requestsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Request $status successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(requestsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring Requests')),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return const Center(child: Text("No pending requests."));
          }
          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final req = requests[index];
              final patientName = req['patients']?['name'] ?? 'Unknown';
              final date = DateTime.parse(req['created_at']);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patientName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        "Requested: ${DateFormat('dd MMM HH:mm').format(date.toLocal())}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => _updateStatus(
                              context,
                              ref,
                              req['id'],
                              'rejected',
                            ),
                            child: const Text("Reject"),
                          ),
                          const SizedBox(width: 12),
                          FilledButton(
                            onPressed: () => _updateStatus(
                              context,
                              ref,
                              req['id'],
                              'approved',
                            ),
                            child: const Text("Approve"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
