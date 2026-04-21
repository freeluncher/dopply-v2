import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notifications_repository.dart';

/// Provides a [NotificationsController] instance.
///
/// This provider is used to create a [NotificationsController] instance.
/// It uses the [NotificationsRepository] to fetch and manage notifications.

final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, List<Map<String, dynamic>>>(
      () {
        return NotificationsController();
      },
    );

/// Provides the count of unread notifications.
///
/// This provider is used to get the count of unread notifications.
///
/// Usage:
/// ```dart
/// final unreadCount = ref.watch(unreadCountProvider);
/// ```
final unreadCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsControllerProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) =>
        notifications.where((n) => n['status'] == 'unread').length,
    orElse: () => 0,
  );
});

/// Controller for managing notifications state and operations.
///
/// This controller handles fetching notifications, marking them as read,
/// and managing the state of notifications.
///
/// Usage:
/// ```dart
/// final controller = ref.read(notificationsControllerProvider.notifier);
/// controller.markAsRead(notificationId);
/// ```

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
