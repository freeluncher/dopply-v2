import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notifications_repository.dart';

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<Map<String, dynamic>>>(
      () {
        return NotificationsController();
      },
    );

final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsControllerProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) =>
        notifications.where((n) => n['status'] == 'unread').length,
    orElse: () => 0,
  );
});

class NotificationsController
    extends AsyncNotifier<List<Map<String, dynamic>>> {
  late final NotificationsRepository _repository;
  StreamSubscription? _subscription;

  @override
  FutureOr<List<Map<String, dynamic>>> build() {
    _repository = ref.read(notificationsRepositoryProvider);

    // Subscribe to stream
    _subscription?.cancel();
    _subscription = _repository.getNotificationsStream().listen((data) {
      state = AsyncValue.data(data);
    });

    return []; // Initial empty state, will update from stream immediately
  }

  Future<void> markAsRead(int id) async {
    await _repository.markAsRead(id);
    // Optimistic update isn't strictly needed as stream will update, but can be added if latency is high
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
  }
}
