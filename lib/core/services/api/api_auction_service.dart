import '../../domain/domain.dart';
import '../auction_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiAuctionService implements AuctionService {
  ApiAuctionService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<Auction> createAuction(AuctionDraft draft) async {
    final dynamic response = await _client.post(
      '/auctions',
      body: <String, dynamic>{
        'farmerId': draft.farmerId,
        'inventoryId': draft.inventoryId,
        'crop': draft.crop,
        'quantity': draft.quantity,
        'minBidQuantity': draft.minBidQuantity,
        'durationHours': draft.durationHours,
        'reservePricePerUnit': draft.reservePricePerUnit,
      },
    );
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<Auction?> getById(String auctionId) async {
    final dynamic response = await _client.get('/auctions/$auctionId');
    if (response == null) {
      return null;
    }
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateStatus({
    required String auctionId,
    required AuctionStatus status,
  }) async {
    await _client.patch(
      '/auctions/$auctionId/status',
      body: <String, dynamic>{'status': status.name},
    );
  }

  @override
  Stream<List<Auction>> watchAuctions({
    String? crop,
    String? farmerId,
    AuctionStatus? status,
  }) {
    return pollingStream<List<Auction>>(
      () async {
        final Map<String, String> query = <String, String>{
          if (crop != null) 'crop': crop,
          if (farmerId != null) 'farmerId': farmerId,
          if (status != null) 'status': status.name,
        };
        final dynamic response = await _client.get(
          '/auctions',
          queryParameters: query.isEmpty ? null : query,
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

  Auction _fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['id']?.toString() ?? '',
      farmerId: json['farmerId']?.toString() ?? '',
      inventoryId: json['inventoryId']?.toString() ?? '',
      crop: json['crop']?.toString() ?? '',
      quantity: parseDouble(json['quantity']),
      minBidQuantity: parseInt(json['minBidQuantity']),
      durationHours: parseInt(json['durationHours']),
      status: enumByNameOr<AuctionStatus>(
        AuctionStatus.values,
        json['status']?.toString(),
        AuctionStatus.live,
      ),
      startAt: parseDateTime(json['startAt']),
      endAt: parseDateTime(json['endAt']),
      reservePricePerUnit: json['reservePricePerUnit'] == null
          ? null
          : parseDouble(json['reservePricePerUnit']),
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
