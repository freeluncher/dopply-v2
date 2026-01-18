import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final adminTransfersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final data = await Supabase.instance.client
          .from('transfer_requests')
          .select(
            '*, patients(name), from_doctor:from_doctor_id(full_name), to_doctor:to_doctor_id(full_name)',
          )
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    });

class TransfersTab extends ConsumerWidget {
  const TransfersTab({super.key});

  Future<void> _approveTransfer(
    BuildContext context,
    WidgetRef ref,
    int requestId,
  ) async {
    try {
      final res = await Supabase.instance.client.rpc(
        'approve_patient_transfer',
        params: {'request_id': requestId},
      );

      if (context.mounted) {
        if (res['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Transfer Approved')));
          ref.invalidate(adminTransfersProvider);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${res['message']}')));
        }
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('RPC Error: $e')));
    }
  }

  Future<void> _rejectTransfer(
    BuildContext context,
    WidgetRef ref,
    int requestId,
  ) async {
    try {
      await Supabase.instance.client
          .from('transfer_requests')
          .update({'status': 'rejected'})
          .eq('id', requestId);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Transfer Rejected')));
        ref.invalidate(adminTransfersProvider);
      }
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(adminTransfersProvider);

    return transfersAsync.when(
      data: (requests) {
        if (requests.isEmpty)
          return const Center(child: Text("No pending transfers."));

        return ListView.builder(
          itemCount: requests.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final req = requests[index];
            final patientName = req['patients']?['name'] ?? 'Unknown';
            final fromDoc = req['from_doctor']?['full_name'] ?? 'Unknown';
            final toDoc = req['to_doctor']?['full_name'] ?? 'Unknown';

            return Card(
              child: ListTile(
                title: Text("Transfer: $patientName"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("From: $fromDoc"),
                    Text("To: $toDoc"),
                    Text(
                      "Requested: ${DateFormat('dd MMM').format(DateTime.parse(req['created_at']))}",
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _rejectTransfer(context, ref, req['id']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () =>
                          _approveTransfer(context, ref, req['id']),
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
    );
  }
}
