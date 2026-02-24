import '../domain/domain.dart';

abstract class OrderService {
  Stream<List<Order>> watchOrdersForFarmer(String farmerId);

  Stream<List<Order>> watchOrdersForBuyer(String buyerId);

  Future<Order> createOrder({
    required String auctionId,
    required String farmerId,
    required String buyerId,
    required double quantity,
    required double pricePerUnit,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });
}
