import 'app_notification_service.dart';
import 'api/api_services.dart';
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
    required this.supportsLocalSeeding,
  });

  final AuthService auth;
  final ProfileService profiles;
  final InventoryService inventory;
  final AuctionService auctions;
  final BidService bids;
  final OrderService orders;
  final WalletService wallet;
  final AppNotificationService notifications;
  final bool supportsLocalSeeding;

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
      supportsLocalSeeding: true,
    );
  }

  factory AppServices.api({
    required ApiConfig config,
  }) {
    final ApiClient client = ApiClient(config);
    return AppServices(
      auth: ApiAuthService(client),
      profiles: ApiProfileService(client),
      inventory: ApiInventoryService(client, pollInterval: config.pollInterval),
      auctions: ApiAuctionService(client, pollInterval: config.pollInterval),
      bids: ApiBidService(client, pollInterval: config.pollInterval),
      orders: ApiOrderService(client, pollInterval: config.pollInterval),
      wallet: ApiWalletService(client, pollInterval: config.pollInterval),
      notifications: ApiAppNotificationService(
        client,
        pollInterval: config.pollInterval,
      ),
      supportsLocalSeeding: false,
    );
  }
}
