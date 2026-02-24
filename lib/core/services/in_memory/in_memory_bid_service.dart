import 'dart:async';

import '../../domain/domain.dart';
import '../bid_service.dart';
import 'id_generator.dart';

class InMemoryBidService implements BidService {
  final Map<String, Bid> _bids = <String, Bid>{};
  final StreamController<List<Bid>> _controller =
      StreamController<List<Bid>>.broadcast();

  @override
  Future<Bid> placeBid(BidDraft draft) async {
    final Bid bid = Bid(
      id: generateId('bid'),
      auctionId: draft.auctionId,
      buyerId: draft.buyerId,
      pricePerUnit: draft.pricePerUnit,
      quantity: draft.quantity,
      status: BidStatus.active,
      createdAt: DateTime.now(),
    );
    _bids[bid.id] = bid;
    _emit();
    return bid;
  }

  @override
  Future<void> updateBidStatus({
    required String bidId,
    required BidStatus status,
  }) async {
    final Bid? existing = _bids[bidId];
    if (existing == null) {
      return;
    }
    _bids[bidId] = existing.copyWith(status: status);
    _emit();
  }

  @override
  Stream<List<Bid>> watchAllBids() async* {
    yield _bids.values.toList()
      ..sort((Bid a, Bid b) => b.createdAt.compareTo(a.createdAt));
    yield* _controller.stream.map((List<Bid> data) => data.toList()
      ..sort((Bid a, Bid b) => b.createdAt.compareTo(a.createdAt)));
  }

  @override
  Stream<List<Bid>> watchBidsForAuction(String auctionId) async* {
    yield _forAuction(auctionId);
    yield* _controller.stream.map((_) => _forAuction(auctionId));
  }

  @override
  Stream<List<Bid>> watchBidsForBuyer(String buyerId) async* {
    yield _forBuyer(buyerId);
    yield* _controller.stream.map((_) => _forBuyer(buyerId));
  }

  List<Bid> _forAuction(String auctionId) {
    return _bids.values
        .where((Bid bid) => bid.auctionId == auctionId)
        .toList()
      ..sort((Bid a, Bid b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Bid> _forBuyer(String buyerId) {
    return _bids.values
        .where((Bid bid) => bid.buyerId == buyerId)
        .toList()
      ..sort((Bid a, Bid b) => b.createdAt.compareTo(a.createdAt));
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    _controller.add(_bids.values.toList());
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
