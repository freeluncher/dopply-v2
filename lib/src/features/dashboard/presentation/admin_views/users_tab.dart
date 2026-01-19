import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminUsersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, query) async {
      var dbQuery = Supabase.instance.client.from('profiles').select('*');

      if (query.isNotEmpty) {
        dbQuery = dbQuery.or('full_name.ilike.%$query%,email.ilike.%$query%');
      }

      final data = await dbQuery.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    });

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider(_searchQuery));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by name or email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _onSearch,
              ),
            ),
            onSubmitted: (_) => _onSearch(),
          ),
        ),
        Expanded(
          child: usersAsync.when(
            data: (users) {
              if (users.isEmpty)
                return const Center(child: Text("No users found."));

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final role = user['role'] ?? 'patient';
                  final isDoctor = role == 'doctor';
                  final isAdmin = role == 'admin';

                  return ListTile(
                    onTap: () => _showEditUserDialog(context, ref, user),
                    leading: CircleAvatar(
                      backgroundColor: isAdmin
                          ? Colors.red
                          : (isDoctor ? Colors.blue : Colors.green),
                      child: Icon(
                        isAdmin
                            ? Icons.admin_panel_settings
                            : (isDoctor
                                  ? Icons.medical_services
                                  : Icons.person),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(user['full_name'] ?? 'No Name'),
                    subtitle: Text(user['email'] ?? 'No Email'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(role.toUpperCase()),
                          backgroundColor: isAdmin
                              ? Colors.red[100]
                              : (isDoctor
                                    ? Colors.blue[100]
                                    : Colors.green[100]),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () =>
                              _confirmDeleteUser(context, ref, user),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            error: (err, stack) => Center(child: Text('Error: $err')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New User'),
            onPressed: () => _showAddUserDialog(context, ref),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) async {
    final nameController = TextEditingController(text: user['full_name']);
    String selectedRole = user['role'] ?? 'patient';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'patient', child: Text('Patient')),
                    DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await Supabase.instance.client
                        .from('profiles')
                        .update({
                          'full_name': nameController.text.trim(),
                          'role': selectedRole,
                        })
                        .eq('id', user['id']);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ref.invalidate(adminUsersProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('User updated successfully'),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating user: $e')),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDeleteUser(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> user,
  ) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User Permanently'),
        content: Text(
          'Are you sure you want to delete "${user['full_name']}"? \n\nWARNING: This will permanently delete the user from Authentication and Database. They will be logged out immediately and cannot log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              try {
                // Call Edge Function to hard delete from Auth
                final res = await Supabase.instance.client.functions.invoke(
                  'delete-user',
                  body: {'userIdToDelete': user['id']},
                );

                if (res.status != 200) {
                  throw Exception('Failed to delete user: ${res.data}');
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(adminUsersProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User deleted permanently')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting user: $e')),
                  );
                }
              }
            },
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddUserDialog(BuildContext context, WidgetRef ref) async {
    // Creating a user requires Auth API which logs out the current user if done via client SDK.
    // Solution: We instruct the Admin to use the Supabase Dashboard, OR implemented via Edge Function.
    // For this step, we'll show an info dialog instructing to use Dashboard,
    // OR we could implement a "Client-side Invite" flows if we had an Edge Function.

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text(
          'To add a new user without logging out, please create it via the database or Invite feature (coming soon).\n\nCreating a user via this panel currently requires Authentication API access which isn\'t bridged.\n\nRecommended: Use Supabase Dashboard > Authentication > Add User.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
