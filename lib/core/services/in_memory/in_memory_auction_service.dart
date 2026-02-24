import 'dart:async';

import '../../domain/domain.dart';
import '../auction_service.dart';
import 'id_generator.dart';

class InMemoryAuctionService implements AuctionService {
  final Map<String, Auction> _auctions = <String, Auction>{};
  final StreamController<List<Auction>> _controller =
      StreamController<List<Auction>>.broadcast();

  @override
  Future<Auction> createAuction(AuctionDraft draft) async {
    final DateTime now = DateTime.now();
    final Auction auction = Auction(
      id: generateId('auc'),
      farmerId: draft.farmerId,
      inventoryId: draft.inventoryId,
      crop: draft.crop,
      quantity: draft.quantity,
      minBidQuantity: draft.minBidQuantity,
      durationHours: draft.durationHours,
      status: AuctionStatus.live,
      startAt: now,
      endAt: now.add(Duration(hours: draft.durationHours)),
      reservePricePerUnit: draft.reservePricePerUnit,
      createdAt: now,
    );
    _auctions[auction.id] = auction;
    _emit();
    return auction;
  }

  @override
  Future<Auction?> getById(String auctionId) async => _auctions[auctionId];

  @override
  Future<void> updateStatus({
    required String auctionId,
    required AuctionStatus status,
  }) async {
    final Auction? existing = _auctions[auctionId];
    if (existing == null) {
      return;
    }
    _auctions[auctionId] = existing.copyWith(status: status);
    _emit();
  }

  @override
  Stream<List<Auction>> watchAuctions({
    String? crop,
    String? farmerId,
    AuctionStatus? status,
  }) async* {
    yield _filtered(crop: crop, farmerId: farmerId, status: status);
    yield* _controller.stream.map(
      (_) => _filtered(crop: crop, farmerId: farmerId, status: status),
    );
  }

  List<Auction> _filtered({
    String? crop,
    String? farmerId,
    AuctionStatus? status,
  }) {
    return _auctions.values.where((Auction auction) {
      final bool cropMatch = crop == null || auction.crop == crop;
      final bool farmerMatch = farmerId == null || auction.farmerId == farmerId;
      final bool statusMatch = status == null || auction.status == status;
      return cropMatch && farmerMatch && statusMatch;
    }).toList()
      ..sort((Auction a, Auction b) => b.createdAt.compareTo(a.createdAt));
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(_auctions.values.toList());
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
