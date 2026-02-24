enum AuctionStatus {
  draft,
  live,
  completed,
  cancelled,
  noBids,
}

class Auction {
  const Auction({
    required this.id,
    required this.farmerId,
    required this.inventoryId,
    required this.crop,
    required this.quantity,
    required this.minBidQuantity,
    required this.durationHours,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.reservePricePerUnit,
    required this.createdAt,
  });

  final String id;
  final String farmerId;
  final String inventoryId;
  final String crop;
  final double quantity;
  final int minBidQuantity;
  final int durationHours;
  final AuctionStatus status;
  final DateTime startAt;
  final DateTime endAt;
  final double? reservePricePerUnit;
  final DateTime createdAt;

  Auction copyWith({
    AuctionStatus? status,
    DateTime? endAt,
  }) {
    return Auction(
      id: id,
      farmerId: farmerId,
      inventoryId: inventoryId,
      crop: crop,
      quantity: quantity,
      minBidQuantity: minBidQuantity,
      durationHours: durationHours,
      status: status ?? this.status,
      startAt: startAt,
      endAt: endAt ?? this.endAt,
      reservePricePerUnit: reservePricePerUnit,
      createdAt: createdAt,
    );
  }
}

class AuctionDraft {
  const AuctionDraft({
    required this.farmerId,
    required this.inventoryId,
    required this.crop,
    required this.quantity,
    required this.minBidQuantity,
    required this.durationHours,
    this.reservePricePerUnit,
  });

  final String farmerId;
  final String inventoryId;
  final String crop;
  final double quantity;
  final int minBidQuantity;
  final int durationHours;
  final double? reservePricePerUnit;
}
