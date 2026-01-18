import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/auth_repository.dart';
import '../../notifications/presentation/notification_bell.dart';
import '../../../core/services/update_service.dart';
import '../../shared/widgets/update_dialog.dart';

import 'doctor_requests_screen.dart';
// ... (keep earlier imports)

// Controller to fetch user profile
final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) throw Exception('No user');

  final profile = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  final patient = await Supabase.instance.client
      .from('patients')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();
  profile['patient_data'] = patient;

  if (patient != null) {
    final assignment = await Supabase.instance.client
        .from('doctor_patient')
        .select('doctor:profiles(full_name)')
        .eq('patient_id', patient['id'])
        .maybeSingle();

    if (assignment != null && assignment['doctor'] != null) {
      profile['assigned_doctor'] = assignment['doctor'];
    }
  }

  return profile;
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdates();
    });
  }

  Future<void> _checkForUpdates() async {
    final updateService = UpdateService();
    // In production, consider triggering this only once per session or day
    final release = await updateService.checkForUpdate();
    if (release != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => UpdateDialog(releaseInfo: release),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dopply Dashboard'),
        actions: [
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          final role = profile['role'];
          final name = profile['full_name'] ?? 'User';

          // Request count for doctors
          final requestsAsync = ref.watch(requestsProvider);
          final pendingCount = requestsAsync.valueOrNull?.length ?? 0;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.monitor_heart,
                  size: 64,
                  color: Color(0xFFE91E63),
                ),
                const SizedBox(height: 16),
                Text(
                  'Hello, $name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  'Role: ${role.toString().toUpperCase()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (role == 'patient') ...[
                  if (profile['patient_data'] == null) ...[
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Profile Incomplete",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        "You must complete your patient profile before you can use the application.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _DashboardButton(
                      icon: Icons.person_add,
                      label: 'Complete Profile Now',
                      onPressed: () {
                        context.push('/create-profile');
                      },
                    ),
                  ] else ...[
                    _DashboardButton(
                      icon: Icons.bluetooth_connected,
                      label: 'Start Monitoring',
                      onPressed: () {
                        context.push('/monitoring');
                      },
                    ),
                    const SizedBox(height: 16),
                    _DashboardButton(
                      icon: Icons.history,
                      label: 'My History',
                      onPressed: () {
                        context.push('/records');
                      },
                    ),
                  ],
                ] else if (role == 'doctor') ...[
                  _DashboardButton(
                    icon: Icons.people,
                    label: 'My Patients',
                    onPressed: () {
                      context.push('/patients');
                    },
                  ),
                  const SizedBox(height: 16),
                  _DashboardButton(
                    icon: Icons.notifications_active,
                    label: 'Requests',
                    badgeCount: pendingCount,
                    onPressed: () {
                      context.push('/requests');
                    },
                  ),
                ] else if (role == 'admin') ...[
                  _DashboardButton(
                    icon: Icons.admin_panel_settings,
                    label: 'Admin Panel',
                    onPressed: () {
                      context.push('/admin');
                    },
                  ),
                ],
                if (role == 'patient' && profile['patient_data'] != null) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.push('/transfer-request'),
                    child: const Text("Request Doctor Transfer"),
                  ),

                  if (profile['assigned_doctor'] != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.medical_services_outlined,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Assigned Doctor",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.blue.shade900),
                                ),
                                Text(
                                  profile['assigned_doctor']['full_name'] ??
                                      'Dr. Unknown',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.blue.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final int badgeCount;

  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 60,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: badgeCount > 0
            ? Badge(label: Text('$badgeCount'), child: Icon(icon))
            : Icon(icon),
        label: Text(label),
      ),
    );
  }
}
