import 'dart:async';

import 'package:flutter/material.dart';

import '../core/demo/demo_ids.dart';
import '../core/domain/domain.dart';
import '../core/services/app_services.dart';
import '../features/admin/presentation/screens/admin_home_screen.dart';
import '../features/admin/presentation/screens/admin_login_screen.dart';
import '../features/agent/presentation/screens/agent_home_screen.dart';
import '../features/agent/presentation/screens/agent_login_screen.dart';
import '../features/agent/presentation/screens/agent_onboarding_screen.dart';
import '../features/buyer/presentation/screens/buyer_home_screen.dart';
import '../features/buyer/presentation/screens/buyer_onboarding_screen.dart';
import '../features/farmer/presentation/screens/farmer_home_screen.dart';
import '../features/farmer/presentation/screens/farmer_registration_screen.dart';
import '../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';

enum AppStage {
  splash,
  language,
  roleSelection,
  farmerRegistration,
  farmerHome,
  buyerOnboarding,
  buyerHome,
  agentLogin,
  agentOnboarding,
  agentHome,
  adminLogin,
  adminHome,
}

class RootFlow extends StatefulWidget {
  const RootFlow({super.key, required this.services});

  final AppServices services;

  @override
  State<RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<RootFlow> {
  AppStage _stage = AppStage.splash;
  Timer? _timer;
  late final AppServices _services;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _services = widget.services;
    unawaited(_seedInMemoryData());
    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _stage = AppStage.language;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setStage(AppStage stage) {
    setState(() {
      _stage = stage;
    });
  }

  Future<void> _seedInMemoryData() async {
    if (_seeded) {
      return;
    }
    _seeded = true;

    final DateTime now = DateTime.now();

    await _services.profiles.saveFarmerProfile(
      FarmerProfile(
        userId: demoFarmerId,
        firstName: 'Chika',
        lastName: 'N.',
        phoneNumber: '+2348031234567',
        farmerId: 'FC-FARMER-038472',
        farmName: "Chika's Maize Farm",
        location: 'Kaduna State',
        primaryCrops: const <String>['Maize'],
        createdAt: now,
      ),
    );

    await _services.profiles.saveBuyerProfile(
      BuyerProfile(
        userId: demoBuyerId,
        companyName: 'Green Mills',
        businessType: 'Processor',
        contactPhone: '+2348030000001',
        regions: const <String>['Kaduna', 'Lagos'],
        preferredCrops: const <String>['Maize', 'Rice'],
        createdAt: now,
      ),
    );

    await _services.profiles.saveBuyerProfile(
      BuyerProfile(
        userId: demoBuyerTwoId,
        companyName: 'Prime Foods',
        businessType: 'Trader',
        contactPhone: '+2348030000002',
        regions: const <String>['Kaduna', 'Kano'],
        preferredCrops: const <String>['Maize'],
        createdAt: now,
      ),
    );

    await _services.profiles.saveAgentProfile(
      AgentProfile(
        userId: demoAgentId,
        fullName: 'Tunde A.',
        agentId: 'FC-AGENT-0092',
        coverageArea: const <String>['Kaduna North', 'Kaduna South'],
        vehicleType: 'Bike',
        rating: 4.9,
        createdAt: now,
      ),
    );

    await _services.wallet.credit(
      userId: demoFarmerId,
      amount: 1978300,
      reference: 'seed-farmer-balance',
    );
    await _services.wallet.credit(
      userId: demoBuyerId,
      amount: 5000000,
      reference: 'seed-buyer-balance',
    );
    await _services.wallet.credit(
      userId: demoBuyerTwoId,
      amount: 4000000,
      reference: 'seed-buyer2-balance',
    );
    await _services.wallet.credit(
      userId: demoAgentId,
      amount: 4200,
      reference: 'seed-agent-balance',
    );

    final InventoryItem inventory = await _services.inventory.declareHarvest(
      farmerId: demoFarmerId,
      crop: 'Maize',
      quantity: 120,
      unit: 'bags',
      storageLocation: 'On-farm storage',
      harvestDate: now.subtract(const Duration(days: 1)),
    );

    await _services.inventory.updateStatus(
      inventoryId: inventory.id,
      status: InventoryStatus.verifiedReady,
      verificationType: VerificationType.photo,
    );

    final Auction auction = await _services.auctions.createAuction(
      AuctionDraft(
        farmerId: demoFarmerId,
        inventoryId: inventory.id,
        crop: 'Maize',
        quantity: 120,
        minBidQuantity: 10,
        durationHours: 24,
        reservePricePerUnit: 24500,
      ),
    );

    await _services.bids.placeBid(
      BidDraft(
        auctionId: auction.id,
        buyerId: demoBuyerId,
        pricePerUnit: 25700,
        quantity: 20,
      ),
    );

    await _services.bids.placeBid(
      BidDraft(
        auctionId: auction.id,
        buyerId: demoBuyerTwoId,
        pricePerUnit: 25600,
        quantity: 50,
      ),
    );

    final Order order = await _services.orders.createOrder(
      auctionId: auction.id,
      farmerId: demoFarmerId,
      buyerId: demoBuyerId,
      quantity: 20,
      pricePerUnit: 25500,
    );
    await _services.orders.updateOrderStatus(
      orderId: order.id,
      status: OrderStatus.inTransit,
    );

    await _services.wallet.holdInEscrow(
      userId: demoBuyerId,
      amount: order.totalValue,
      reference: 'order-${order.id}-hold',
    );

    await _services.notifications.send(
      FarmNotification(
        id: 'notif-${now.microsecondsSinceEpoch}-1',
        userId: demoFarmerId,
        type: FarmNotificationType.bidPlaced,
        title: 'New bid on your auction',
        body: 'Green Mills placed N25,700/bag for 20 bags.',
        createdAt: now,
        isRead: false,
      ),
    );
    await _services.notifications.send(
      FarmNotification(
        id: 'notif-${now.microsecondsSinceEpoch}-2',
        userId: demoBuyerId,
        type: FarmNotificationType.orderUpdate,
        title: 'Order in transit',
        body: 'Order #${order.id} is currently in transit.',
        createdAt: now,
        isRead: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case AppStage.splash:
        return const SplashScreen();
      case AppStage.language:
        return LanguageSelectionScreen(
          onContinue: () => _setStage(AppStage.roleSelection),
        );
      case AppStage.roleSelection:
        return RoleSelectionScreen(
          onFarmerSelected: () => _setStage(AppStage.farmerRegistration),
          onBuyerSelected: () => _setStage(AppStage.buyerOnboarding),
          onAgentSelected: () => _setStage(AppStage.agentLogin),
          onAdminSelected: () => _setStage(AppStage.adminLogin),
        );
      case AppStage.farmerRegistration:
        return FarmerRegistrationScreen(
          services: _services,
          userId: demoFarmerId,
          onBack: () => _setStage(AppStage.roleSelection),
          onComplete: () => _setStage(AppStage.farmerHome),
        );
      case AppStage.farmerHome:
        return FarmerHomeScreen(
          services: _services,
          farmerId: demoFarmerId,
          onLogout: () => _setStage(AppStage.roleSelection),
        );
      case AppStage.buyerOnboarding:
        return BuyerOnboardingScreen(
          services: _services,
          userId: demoBuyerId,
          onBack: () => _setStage(AppStage.roleSelection),
          onComplete: () => _setStage(AppStage.buyerHome),
        );
      case AppStage.buyerHome:
        return BuyerHomeScreen(
          services: _services,
          buyerId: demoBuyerId,
          onLogout: () => _setStage(AppStage.roleSelection),
        );
      case AppStage.agentLogin:
        return AgentLoginScreen(
          services: _services,
          userId: demoAgentId,
          onBack: () => _setStage(AppStage.roleSelection),
          onLogin: () => _setStage(AppStage.agentOnboarding),
          onQuickEnter: () => _setStage(AppStage.agentHome),
        );
      case AppStage.agentOnboarding:
        return AgentOnboardingScreen(
          services: _services,
          userId: demoAgentId,
          onBack: () => _setStage(AppStage.agentLogin),
          onComplete: () => _setStage(AppStage.agentHome),
        );
      case AppStage.agentHome:
        return AgentHomeScreen(
          services: _services,
          agentId: demoAgentId,
          onLogout: () => _setStage(AppStage.roleSelection),
        );
      case AppStage.adminLogin:
        return AdminLoginScreen(
          services: _services,
          userId: demoAdminId,
          onBack: () => _setStage(AppStage.roleSelection),
          onLogin: () => _setStage(AppStage.adminHome),
        );
      case AppStage.adminHome:
        return AdminHomeScreen(
          services: _services,
          onLogout: () => _setStage(AppStage.roleSelection),
        );
    }
  }
}
