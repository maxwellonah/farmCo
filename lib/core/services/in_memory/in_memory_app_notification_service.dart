import 'dart:async';

import '../../domain/domain.dart';
import '../app_notification_service.dart';

class InMemoryAppNotificationService implements AppNotificationService {
  final Map<String, List<FarmNotification>> _data =
      <String, List<FarmNotification>>{};
  final Map<String, StreamController<List<FarmNotification>>> _controllers =
      <String, StreamController<List<FarmNotification>>>{};

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    final List<FarmNotification> notifications = _data[userId] ?? <FarmNotification>[];
    final int index = notifications.indexWhere(
      (FarmNotification item) => item.id == notificationId,
    );
    if (index == -1) {
      return;
    }
    notifications[index] = notifications[index].copyWith(isRead: true);
    _emit(userId);
  }

  @override
  Future<void> send(FarmNotification notification) async {
    final List<FarmNotification> notifications =
        _data.putIfAbsent(notification.userId, () => <FarmNotification>[]);
    notifications.insert(0, notification);
    _emit(notification.userId);
  }

  @override
  Stream<List<FarmNotification>> watchNotifications(String userId) {
    final StreamController<List<FarmNotification>> controller =
        _controllers.putIfAbsent(
      userId,
      () => StreamController<List<FarmNotification>>.broadcast(),
    );
    _emit(userId);
    return controller.stream;
  }

  void _emit(String userId) {
    final StreamController<List<FarmNotification>>? controller =
        _controllers[userId];
    if (controller == null || controller.isClosed) {
      return;
    }
    controller.add(List<FarmNotification>.unmodifiable(_data[userId] ?? <FarmNotification>[]));
  }

  Future<void> dispose() async {
    for (final StreamController<List<FarmNotification>> controller
        in _controllers.values) {
      await controller.close();
    }
  }
}
