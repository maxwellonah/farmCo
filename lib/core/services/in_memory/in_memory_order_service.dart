import 'dart:async';

import '../../domain/domain.dart';
import '../order_service.dart';
import 'id_generator.dart';

class InMemoryOrderService implements OrderService {
  final Map<String, Order> _orders = <String, Order>{};
  final StreamController<List<Order>> _controller =
      StreamController<List<Order>>.broadcast();

  @override
  Future<Order> createOrder({
    required String auctionId,
    required String farmerId,
    required String buyerId,
    required double quantity,
    required double pricePerUnit,
  }) async {
    final Order order = Order(
      id: generateId('ord'),
      auctionId: auctionId,
      farmerId: farmerId,
      buyerId: buyerId,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      status: OrderStatus.auctionWon,
      createdAt: DateTime.now(),
    );
    _orders[order.id] = order;
    _emit();
    return order;
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final Order? existing = _orders[orderId];
    if (existing == null) {
      return;
    }
    _orders[orderId] = existing.copyWith(status: status);
    _emit();
  }

  @override
  Stream<List<Order>> watchOrdersForBuyer(String buyerId) async* {
    yield _forBuyer(buyerId);
    yield* _controller.stream.map((_) => _forBuyer(buyerId));
  }

  @override
  Stream<List<Order>> watchOrdersForFarmer(String farmerId) async* {
    yield _forFarmer(farmerId);
    yield* _controller.stream.map((_) => _forFarmer(farmerId));
  }

  List<Order> _forBuyer(String buyerId) {
    return _orders.values
        .where((Order order) => order.buyerId == buyerId)
        .toList()
      ..sort((Order a, Order b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Order> _forFarmer(String farmerId) {
    return _orders.values
        .where((Order order) => order.farmerId == farmerId)
        .toList()
      ..sort((Order a, Order b) => b.createdAt.compareTo(a.createdAt));
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(_orders.values.toList());
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
