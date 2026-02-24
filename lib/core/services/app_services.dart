import 'app_notification_service.dart';
import 'auction_service.dart';
import 'auth_service.dart';
import 'bid_service.dart';
import 'in_memory/in_memory_services.dart';
import 'inventory_service.dart';
import 'order_service.dart';
import 'profile_service.dart';
import 'wallet_service.dart';

class AppServices {
  const AppServices({
    required this.auth,
    required this.profiles,
    required this.inventory,
    required this.auctions,
    required this.bids,
    required this.orders,
    required this.wallet,
    required this.notifications,
  });

  final AuthService auth;
  final ProfileService profiles;
  final InventoryService inventory;
  final AuctionService auctions;
  final BidService bids;
  final OrderService orders;
  final WalletService wallet;
  final AppNotificationService notifications;

  factory AppServices.inMemory() {
    return AppServices(
      auth: InMemoryAuthService(),
      profiles: InMemoryProfileService(),
      inventory: InMemoryInventoryService(),
      auctions: InMemoryAuctionService(),
      bids: InMemoryBidService(),
      orders: InMemoryOrderService(),
      wallet: InMemoryWalletService(),
      notifications: InMemoryAppNotificationService(),
    );
  }
}
