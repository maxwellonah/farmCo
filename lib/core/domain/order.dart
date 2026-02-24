enum OrderStatus {
  auctionWon,
  paymentReserved,
  logisticsArranged,
  inTransit,
  delivered,
  paymentReleased,
  disputed,
}

class Order {
  const Order({
    required this.id,
    required this.auctionId,
    required this.farmerId,
    required this.buyerId,
    required this.quantity,
    required this.pricePerUnit,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String auctionId;
  final String farmerId;
  final String buyerId;
  final double quantity;
  final double pricePerUnit;
  final OrderStatus status;
  final DateTime createdAt;

  double get totalValue => quantity * pricePerUnit;

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      auctionId: auctionId,
      farmerId: farmerId,
      buyerId: buyerId,
      quantity: quantity,
      pricePerUnit: pricePerUnit,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
