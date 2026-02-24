enum InventoryStatus {
  unverified,
  underReview,
  verifiedReady,
  inAuction,
  sold,
}

enum VerificationType {
  photo,
  agent,
  warehouse,
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.farmerId,
    required this.crop,
    required this.quantity,
    required this.unit,
    required this.storageLocation,
    required this.harvestDate,
    required this.status,
    required this.verificationType,
    required this.createdAt,
  });

  final String id;
  final String farmerId;
  final String crop;
  final double quantity;
  final String unit;
  final String storageLocation;
  final DateTime harvestDate;
  final InventoryStatus status;
  final VerificationType verificationType;
  final DateTime createdAt;

  InventoryItem copyWith({
    InventoryStatus? status,
    VerificationType? verificationType,
    double? quantity,
  }) {
    return InventoryItem(
      id: id,
      farmerId: farmerId,
      crop: crop,
      quantity: quantity ?? this.quantity,
      unit: unit,
      storageLocation: storageLocation,
      harvestDate: harvestDate,
      status: status ?? this.status,
      verificationType: verificationType ?? this.verificationType,
      createdAt: createdAt,
    );
  }
}
