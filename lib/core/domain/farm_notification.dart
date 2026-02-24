enum FarmNotificationType {
  bidPlaced,
  outbid,
  auctionCompleted,
  verificationUpdate,
  paymentUpdate,
  orderUpdate,
  systemAlert,
}

class FarmNotification {
  const FarmNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String userId;
  final FarmNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  FarmNotification copyWith({bool? isRead}) {
    return FarmNotification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
