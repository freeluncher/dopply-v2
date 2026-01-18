import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              ref
                  .read(notificationsControllerProvider.notifier)
                  .markAllAsRead()
                  .then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('All marked as read')),
                      );
                    }
                  })
                  .catchError((e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  });
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final isUnread = n['status'] == 'unread';
              final date = DateTime.parse(n['created_at']);

              return Container(
                color: isUnread ? Colors.blue.withOpacity(0.1) : null,
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(
                    n['title'],
                    style: TextStyle(
                      fontWeight: isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n['message']),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM HH:mm').format(date.toLocal()),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Mark as read on tap
                    if (isUnread) {
                      ref
                          .read(notificationsControllerProvider.notifier)
                          .markAsRead(n['id']);
                    }
                  },
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
