import '../domain/domain.dart';

abstract class BidService {
  Stream<List<Bid>> watchAllBids();

  Stream<List<Bid>> watchBidsForAuction(String auctionId);

  Stream<List<Bid>> watchBidsForBuyer(String buyerId);

  Future<Bid> placeBid(BidDraft draft);

  Future<void> updateBidStatus({
    required String bidId,
    required BidStatus status,
  });
}
