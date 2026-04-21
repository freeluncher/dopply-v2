import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the [doctorsProvider] instance.
///
/// This provider creates and manages the application's doctors.
/// It handles doctor operations such as fetching and updating doctors.
///
/// Usage:
/// ```dart
/// final doctors = ref.watch(doctorsProvider);
/// doctors.when(
///   data: (doctors) {
///     // Handle doctors
///   },
///   error: (error, stack) {
///     // Handle error
///   },
///   loading: () {
///     // Handle loading
///   },
/// );
/// ```
final doctorsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  final data = await Supabase.instance.client
      .from('profiles')
      .select('id, full_name, specialization')
      .eq('role', 'doctor');
  return List<Map<String, dynamic>>.from(data);
});

/// A screen for requesting doctor transfers.
///
/// This widget allows users to request a transfer to a different doctor.
/// The request is sent to the admin for approval.
///
/// Usage:
/// ```dart
/// const RequestTransferScreen()
/// ```
class RequestTransferScreen extends ConsumerStatefulWidget {
  const RequestTransferScreen({super.key});

  @override
  ConsumerState<RequestTransferScreen> createState() =>
      _RequestTransferScreenState();
}

/// State for the [RequestTransferScreen] widget.
///
/// This state holds the selected doctor ID and loading state.
///
/// Usage:
/// ```dart
/// final state = _RequestTransferScreenState();
/// ```
class _RequestTransferScreenState extends ConsumerState<RequestTransferScreen> {
  String? _selectedDoctorId;
  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_selectedDoctorId == null) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Not logged in");

      // Get Patient ID
      final patient = await Supabase.instance.client
          .from('patients')
          .select('id')
          .eq('user_id', user.id)
          .single();

      // Get Current Doctor
      final currentAssignment = await Supabase.instance.client
          .from('doctor_patient')
          .select('doctor_id')
          .eq('patient_id', patient['id'])
          .maybeSingle();

      if (currentAssignment == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You do not have a doctor assigned yet.'),
            ),
          );
        }
        return;
      }

      final fromDoctorId = currentAssignment['doctor_id'];

      if (fromDoctorId == _selectedDoctorId) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already assigned to this doctor.'),
            ),
          );
        }
        return;
      }

      await Supabase.instance.client.from('transfer_requests').insert({
        'patient_id': patient['id'],
        'from_doctor_id': fromDoctorId,
        'to_doctor_id': _selectedDoctorId,
        'requester_id': user.id,
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer request sent to Admin.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Builds the [RequestTransferScreen] widget.
  ///
  /// This method builds the [RequestTransferScreen] widget by watching the [doctorsProvider] and displaying the doctors.
  ///
  /// Usage:
  /// ```dart
  /// @override
  /// Widget build(BuildContext context, WidgetRef ref) {
  ///   return RequestTransferScreen();
  /// }
  /// ```
  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Request Doctor Transfer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Select a new doctor you wish to transfer to. This request will be reviewed by an Admin.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            doctorsAsync.when(
              data: (doctors) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select New Doctor',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedDoctorId,
                  items: doctors.map((doc) {
                    return DropdownMenuItem(
                      value: doc['id'].toString(),
                      child: Text(
                        "${doc['full_name']} (${doc['specialization'] ?? 'General'})",
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedDoctorId = val);
                  },
                );
              },
              error: (err, stack) => Text("Error loading doctors: $err"),
              loading: () => const LinearProgressIndicator(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading || _selectedDoctorId == null
                    ? null
                    : _submitRequest,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Submit Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
