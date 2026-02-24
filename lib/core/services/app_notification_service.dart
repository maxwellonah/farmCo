import '../domain/domain.dart';

abstract class AppNotificationService {
  Stream<List<FarmNotification>> watchNotifications(String userId);

  Future<void> send(FarmNotification notification);

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  });
}
