import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final doctorPatientsProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return Stream.value([]);

      // Listen to the 'doctor_patient' junction table
      return Supabase.instance.client
          .from('doctor_patient')
          .stream(primaryKey: ['doctor_id', 'patient_id'])
          .eq('doctor_id', user.id)
          .asyncMap((assignments) async {
            if (assignments.isEmpty) return [];

            // Extract patient IDs
            final patientIds = assignments.map((e) => e['patient_id']).toList();

            // Fetch details for these patients
            final patientsData = await Supabase.instance.client
                .from('patients')
                .select()
                .inFilter('id', patientIds);

            // Manually Query-Join in memory
            return assignments.map((assignment) {
              final patientDetails = patientsData.firstWhere(
                (p) => p['id'] == assignment['patient_id'],
                orElse: () => {},
              );

              // Reconstruct the expected structure: { ..., patients: { ... } }
              return {...assignment, 'patients': patientDetails};
            }).toList();
          });
    });

final patientSearchProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredPatientsProvider =
    Provider.autoDispose<AsyncValue<List<Map<String, dynamic>>>>((ref) {
      final searchQuery = ref.watch(patientSearchProvider).toLowerCase();
      final patientsAsync = ref.watch(doctorPatientsProvider);

      return patientsAsync.whenData((patients) {
        if (searchQuery.isEmpty) return patients;
        return patients.where((item) {
          final patient = item['patients'] as Map<String, dynamic>;
          final name = (patient['name'] ?? '').toString().toLowerCase();
          // You can add email search if email is available in the patient map
          return name.contains(searchQuery);
        }).toList();
      });
    });

class DoctorPatientsScreen extends ConsumerWidget {
  const DoctorPatientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(filteredPatientsProvider);
    // Removed unused controller. Using onChanged for simplicity.

    return Scaffold(
      appBar: AppBar(title: const Text('My Patients')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Patients',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(patientSearchProvider.notifier).state = '';
                    // Also clear text field locally if using controller
                    // But for simplicity in this stateless widget:
                    // If we want to clear the field visually, we might need stateful or controller management.
                    // Let's rely on onChanged update.
                  },
                ),
              ),
              onChanged: (value) {
                ref.read(patientSearchProvider.notifier).state = value;
              },
            ),
          ),
          Expanded(
            child: patientsAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  // Check if it's empty because of search or no patients at all
                  final isSearching = ref
                      .read(patientSearchProvider)
                      .isNotEmpty;
                  return Center(
                    child: Text(
                      isSearching
                          ? 'No patients found matching "${ref.read(patientSearchProvider)}"'
                          : 'No patients assigned yet.',
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: data.length,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final patient = item['patients'] as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(patient['name'] ?? 'Unknown'),
                        subtitle: Text('HPHT: ${patient['hpht'] ?? 'N/A'}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.push('/patients/${patient['id']}');
                        },
                      ),
                    );
                  },
                );
              },
              error: (err, stack) => Center(child: Text('Error: $err')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientDialog(context, ref),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddPatientDialog(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Patient'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the patient\'s email address to assign them.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Patient Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              Navigator.pop(context); // Close dialog

              try {
                // Call Supabase RPC
                final res = await Supabase.instance.client.rpc(
                  'assign_patient_by_email',
                  params: {'patient_email': email},
                );

                // res is Map<String, dynamic> due to jsonb return
                final data = res as Map<String, dynamic>;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(data['message'] ?? 'Unknown result'),
                    ),
                  );
                  if (data['success'] == true) {
                    // Force refresh as fallback until Realtime completely propagates
                    ref.invalidate(doctorPatientsProvider);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
