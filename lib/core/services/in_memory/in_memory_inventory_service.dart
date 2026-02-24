import 'dart:async';

import '../../domain/domain.dart';
import '../inventory_service.dart';
import 'id_generator.dart';

class InMemoryInventoryService implements InventoryService {
  final Map<String, InventoryItem> _items = <String, InventoryItem>{};
  final Map<String, StreamController<List<InventoryItem>>> _controllers =
      <String, StreamController<List<InventoryItem>>>{};
  final StreamController<List<InventoryItem>> _allController =
      StreamController<List<InventoryItem>>.broadcast();

  @override
  Future<InventoryItem> declareHarvest({
    required String farmerId,
    required String crop,
    required double quantity,
    required String unit,
    required String storageLocation,
    required DateTime harvestDate,
  }) async {
    final InventoryItem item = InventoryItem(
      id: generateId('inv'),
      farmerId: farmerId,
      crop: crop,
      quantity: quantity,
      unit: unit,
      storageLocation: storageLocation,
      harvestDate: harvestDate,
      status: InventoryStatus.unverified,
      verificationType: VerificationType.photo,
      createdAt: DateTime.now(),
    );
    _items[item.id] = item;
    _emit(farmerId);
    _emitAll();
    return item;
  }

  @override
  Future<InventoryItem?> getById(String inventoryId) async => _items[inventoryId];

  @override
  Future<void> updateStatus({
    required String inventoryId,
    required InventoryStatus status,
    VerificationType? verificationType,
  }) async {
    final InventoryItem? existing = _items[inventoryId];
    if (existing == null) {
      return;
    }
    _items[inventoryId] = existing.copyWith(
      status: status,
      verificationType: verificationType,
    );
    _emit(existing.farmerId);
    _emitAll();
  }

  @override
  Stream<List<InventoryItem>> watchInventoryForFarmer(String farmerId) {
    final StreamController<List<InventoryItem>> controller =
        _controllers.putIfAbsent(
      farmerId,
      () => StreamController<List<InventoryItem>>.broadcast(),
    );
    _emit(farmerId);
    return controller.stream;
  }

  @override
  Stream<List<InventoryItem>> watchAllInventory() async* {
    _emitAll();
    yield* _allController.stream;
  }

  void _emit(String farmerId) {
    final StreamController<List<InventoryItem>>? controller =
        _controllers[farmerId];
    if (controller == null || controller.isClosed) {
      return;
    }
    final List<InventoryItem> data = _items.values
        .where((InventoryItem item) => item.farmerId == farmerId)
        .toList()
      ..sort((InventoryItem a, InventoryItem b) => b.createdAt.compareTo(a.createdAt));
    controller.add(data);
  }

  void _emitAll() {
    if (_allController.isClosed) {
      return;
    }
    final List<InventoryItem> data = _items.values.toList()
      ..sort((InventoryItem a, InventoryItem b) => b.createdAt.compareTo(a.createdAt));
    _allController.add(data);
  }

  Future<void> dispose() async {
    for (final StreamController<List<InventoryItem>> controller
        in _controllers.values) {
      await controller.close();
    }
    await _allController.close();
  }
}
