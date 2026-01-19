import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

final adminNotificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final data = await Supabase.instance.client
          .from('notifications')
          .select('*, recipient:recipient_id(full_name, email)')
          .order('created_at', ascending: false)
          .limit(50);
      return List<Map<String, dynamic>>.from(data);
    });

class NotificationsTab extends ConsumerStatefulWidget {
  const NotificationsTab({super.key});

  @override
  ConsumerState<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<NotificationsTab> {
  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(adminNotificationsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNotificationDialog(context, ref),
        label: const Text('Send Notification'),
        icon: const Icon(Icons.send),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("No notifications sent yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final recipient = notif['recipient'];
              final recipientName = recipient != null
                  ? recipient['full_name']
                  : 'System/Broadcast';
              final date = DateTime.parse(notif['created_at']).toLocal();

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: const Icon(Icons.notifications, color: Colors.orange),
                ),
                title: Text(notif['title'] ?? 'No Title'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif['message'] ?? ''),
                    const SizedBox(height: 4),
                    Text(
                      'To: $recipientName • ${DateFormat('dd MMM HH:mm').format(date)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: notif['status'] == 'read'
                    ? const Icon(Icons.done_all, color: Colors.blue, size: 16)
                    : const Icon(Icons.done, color: Colors.grey, size: 16),
              );
            },
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _showCreateNotificationDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool isBroadcast = false;
    String? selectedUserId;

    // Fetch users for dropdown
    List<Map<String, dynamic>> users = [];
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('id, full_name, email')
          .order('full_name');
      users = List<Map<String, dynamic>>.from(res);
    } catch (e) {
      // Handle error gracefully
    }

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Send Notification'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'e.g. System Maintenance',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'e.g. Creating downtime...',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Broadcast to ALL Users'),
                    value: isBroadcast,
                    onChanged: (val) => setState(() => isBroadcast = val),
                  ),
                  if (!isBroadcast) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Select Recipient',
                      ),
                      items: users
                          .map(
                            (u) => DropdownMenuItem(
                              value: u['id'] as String,
                              child: Text(
                                '${u['full_name']} (${u['email']})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => selectedUserId = val),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.isEmpty ||
                      messageController.text.isEmpty)
                    return;

                  try {
                    if (isBroadcast) {
                      // Call RPC
                      await Supabase.instance.client.rpc(
                        'send_broadcast_notification',
                        params: {
                          'title': titleController.text,
                          'message': messageController.text,
                          'sender_id':
                              Supabase.instance.client.auth.currentUser?.id,
                        },
                      );
                    } else {
                      if (selectedUserId == null) return;
                      // Regular Insert
                      await Supabase.instance.client
                          .from('notifications')
                          .insert({
                            'recipient_id': selectedUserId,
                            'sender_id':
                                Supabase.instance.client.auth.currentUser?.id,
                            'title': titleController.text,
                            'message': messageController.text,
                          });
                    }

                    if (context.mounted) {
                      Navigator.pop(context);
                      ref.invalidate(adminNotificationsProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isBroadcast
                                ? 'Broadcast sent!'
                                : 'Notification sent!',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }
}
