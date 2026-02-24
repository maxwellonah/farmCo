import '../../domain/domain.dart';
import '../bid_service.dart';
import 'api_client.dart';
import 'json_helpers.dart';
import 'polling_stream.dart';

class ApiBidService implements BidService {
  ApiBidService(this._client, {required this.pollInterval});

  final ApiClient _client;
  final Duration pollInterval;

  @override
  Future<Bid> placeBid(BidDraft draft) async {
    final dynamic response = await _client.post(
      '/bids',
      body: <String, dynamic>{
        'auctionId': draft.auctionId,
        'buyerId': draft.buyerId,
        'pricePerUnit': draft.pricePerUnit,
        'quantity': draft.quantity,
      },
    );
    return _fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> updateBidStatus({
    required String bidId,
    required BidStatus status,
  }) async {
    await _client.patch(
      '/bids/$bidId/status',
      body: <String, dynamic>{'status': status.name},
    );
  }

  @override
  Stream<List<Bid>> watchAllBids() {
    return pollingStream<List<Bid>>(
      () async {
        final dynamic response = await _client.get('/bids');
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
  Stream<List<Bid>> watchBidsForAuction(String auctionId) {
    return pollingStream<List<Bid>>(
      () async {
        final dynamic response = await _client.get(
          '/bids',
          queryParameters: <String, String>{'auctionId': auctionId},
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
  Stream<List<Bid>> watchBidsForBuyer(String buyerId) {
    return pollingStream<List<Bid>>(
      () async {
        final dynamic response = await _client.get(
          '/bids',
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

  Bid _fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id']?.toString() ?? '',
      auctionId: json['auctionId']?.toString() ?? '',
      buyerId: json['buyerId']?.toString() ?? '',
      pricePerUnit: parseDouble(json['pricePerUnit']),
      quantity: parseDouble(json['quantity']),
      status: enumByNameOr<BidStatus>(
        BidStatus.values,
        json['status']?.toString(),
        BidStatus.active,
      ),
      createdAt: parseDateTime(json['createdAt']),
    );
  }
}
