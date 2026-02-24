import '../domain/domain.dart';

abstract class AuctionService {
  Stream<List<Auction>> watchAuctions({
    String? crop,
    String? farmerId,
    AuctionStatus? status,
  });

  Future<Auction> createAuction(AuctionDraft draft);

  Future<Auction?> getById(String auctionId);

  Future<void> updateStatus({
    required String auctionId,
    required AuctionStatus status,
  });
}
