enum BidStatus {
  active,
  withdrawn,
  won,
  lost,
}

class Bid {
  const Bid({
    required this.id,
    required this.auctionId,
    required this.buyerId,
    required this.pricePerUnit,
    required this.quantity,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String auctionId;
  final String buyerId;
  final double pricePerUnit;
  final double quantity;
  final BidStatus status;
  final DateTime createdAt;

  Bid copyWith({BidStatus? status}) {
    return Bid(
      id: id,
      auctionId: auctionId,
      buyerId: buyerId,
      pricePerUnit: pricePerUnit,
      quantity: quantity,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}

class BidDraft {
  const BidDraft({
    required this.auctionId,
    required this.buyerId,
    required this.pricePerUnit,
    required this.quantity,
  });

  final String auctionId;
  final String buyerId;
  final double pricePerUnit;
  final double quantity;
}
