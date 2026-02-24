import '../../domain/domain.dart';
import '../order_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiOrderService implements OrderService {
  ApiOrderService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<Order> createOrder({
    required String auctionId,
    required String farmerId,
    required String buyerId,
    required double quantity,
    required double pricePerUnit,
  }) async {
    final dynamic response = await _client.post(
      '/orders',
      body: <String, dynamic>{
        'auctionId': auctionId,
        'farmerId': farmerId,
        'buyerId': buyerId,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
      },
    );
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    await _client.patch(
      '/orders/$orderId/status',
      body: <String, dynamic>{'status': status.name},
    );
  }

  @override
  Stream<List<Order>> watchAllOrders() {
    return pollingStream<List<Order>>(
      () async {
        final dynamic response = await _client.get('/orders');
        final List<dynamic> list = response is List ? response : <dynamic>[];
        return list
            .whereType<Map<String, dynamic>>()
            .map(_fromJson)
            .toList();
      },
      interval: pollInterval,
    );
  }

  @override
  Stream<List<Order>> watchOrdersForBuyer(String buyerId) {
    return pollingStream<List<Order>>(
      () async {
        final dynamic response = await _client.get(
          '/orders',
          queryParameters: <String, String>{'buyerId': buyerId},
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

  @override
  Stream<List<Order>> watchOrdersForFarmer(String farmerId) {
    return pollingStream<List<Order>>(
      () async {
        final dynamic response = await _client.get(
          '/orders',
          queryParameters: <String, String>{'farmerId': farmerId},
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

  Order _fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      auctionId: json['auctionId']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      buyerId: json['buyerId']?.toString() ?? '',
      quantity: parseDouble(json['quantity']),
      pricePerUnit: parseDouble(json['pricePerUnit']),
      status: enumByNameOr<OrderStatus>(
        OrderStatus.values,
        json['status']?.toString(),
        OrderStatus.auctionWon,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
