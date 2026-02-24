import '../../domain/domain.dart';
import '../inventory_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiInventoryService implements InventoryService {
  ApiInventoryService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<InventoryItem> declareHarvest({
    required String farmerId,
    required String crop,
    required double quantity,
    required String unit,
    required String storageLocation,
    required DateTime harvestDate,
  }) async {
    final dynamic response = await _client.post(
      '/inventory',
      body: <String, dynamic>{
        'farmerId': farmerId,
        'crop': crop,
        'quantity': quantity,
        'unit': unit,
        'storageLocation': storageLocation,
        'harvestDate': harvestDate.toIso8601String(),
      },
    );
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<InventoryItem?> getById(String inventoryId) async {
    final dynamic response = await _client.get('/inventory/$inventoryId');
    if (response == null) {
      return null;
    }
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateStatus({
    required String inventoryId,
    required InventoryStatus status,
    VerificationType? verificationType,
  }) async {
    await _client.patch(
      '/inventory/$inventoryId/status',
      body: <String, dynamic>{
        'status': status.name,
        if (verificationType != null) 'verificationType': verificationType.name,
      },
    );
  }

  @override
  Stream<List<InventoryItem>> watchAllInventory() {
    return pollingStream<List<InventoryItem>>(
      () async {
        final dynamic response = await _client.get('/inventory');
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
  Stream<List<InventoryItem>> watchInventoryForFarmer(String farmerId) {
    return pollingStream<List<InventoryItem>>(
      () async {
        final dynamic response = await _client.get(
          '/inventory',
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

  InventoryItem _fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      crop: json['crop']?.toString() ?? '',
      quantity: parseDouble(json['quantity']),
      unit: json['unit']?.toString() ?? 'bags',
      storageLocation: json['storageLocation']?.toString() ?? '',
      harvestDate: parseDateTime(json['harvestDate']),
      status: enumByNameOr<InventoryStatus>(
        InventoryStatus.values,
        json['status']?.toString(),
        InventoryStatus.unverified,
      ),
      verificationType: enumByNameOr<VerificationType>(
        VerificationType.values,
        json['verificationType']?.toString(),
        VerificationType.photo,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
