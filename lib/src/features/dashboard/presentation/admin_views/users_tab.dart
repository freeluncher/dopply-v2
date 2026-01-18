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
                    trailing: Chip(
                      label: Text(role.toUpperCase()),
                      backgroundColor: isAdmin
                          ? Colors.red[100]
                          : (isDoctor ? Colors.blue[100] : Colors.green[100]),
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
    );
  }
}
