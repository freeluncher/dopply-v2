import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(Supabase.instance.client);
});

class NotificationsRepository {
  final SupabaseClient _client;

  NotificationsRepository(this._client);

  Stream<List<Map<String, dynamic>>> getNotificationsStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('recipient_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data);
  }

  Future<void> markAsRead(int notificationId) async {
    await _client
        .from('notifications')
        .update({'status': 'read'})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client
        .from('notifications')
        .update({'status': 'read'})
        .eq('recipient_id', userId);
    // Note: Removing .eq('status', 'unread') to ensure all are caught and avoid potential enum matching issues
  }
}
