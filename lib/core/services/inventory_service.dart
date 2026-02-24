import '../domain/domain.dart';

abstract class InventoryService {
  Stream<List<InventoryItem>> watchInventoryForFarmer(String farmerId);

  Future<InventoryItem> declareHarvest({
    required String farmerId,
    required String crop,
    required double quantity,
    required String unit,
    required String storageLocation,
    required DateTime harvestDate,
  });

  Future<InventoryItem?> getById(String inventoryId);

  Future<void> updateStatus({
    required String inventoryId,
    required InventoryStatus status,
    VerificationType? verificationType,
  });
}
