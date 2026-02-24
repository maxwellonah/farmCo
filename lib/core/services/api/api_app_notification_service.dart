import '../../domain/domain.dart';
import '../app_notification_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiAppNotificationService implements AppNotificationService {
  ApiAppNotificationService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _client.patch(
      '/notifications/$notificationId/read',
      body: <String, dynamic>{'userId': userId},
    );
  }

  @override
  Future<void> send(FarmNotification notification) async {
    await _client.post(
      '/notifications',
      body: <String, dynamic>{
        'id': notification.id,
        'userId': notification.userId,
        'type': notification.type.name,
        'title': notification.title,
        'body': notification.body,
        'createdAt': notification.createdAt.toIso8601String(),
        'isRead': notification.isRead,
      },
    );
  }

  @override
  Stream<List<FarmNotification>> watchNotifications(String userId) {
    return pollingStream<List<FarmNotification>>(
      () async {
        final dynamic response = await _client.get(
          '/notifications',
          queryParameters: <String, String>{'userId': userId},
        );
        final List<dynamic> list = response is List ? response : <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_fromJson)
            .toList();
      },
      interval: pollInterval,
    );
  }

  FarmNotification _fromJson(Map<String, dynamic> json) {
    return FarmNotification(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: enumByNameOr<FarmNotificationType>(
        FarmNotificationType.values,
        json['type']?.toString(),
        FarmNotificationType.systemAlert,
      ),
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: parseDateTime(json['createdAt']),
      isRead: json['isRead'] == true,
    );
  }
}
