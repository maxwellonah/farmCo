import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';
import 'auction_flow_screen.dart';
import 'harvest_flow_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({
    super.key,
    required this.services,
    required this.farmerId,
    required this.onLogout,
  });

  final AppServices services;
  final String farmerId;
  final VoidCallback onLogout;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _index = 0;

  void _openHarvestFlow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HarvestFlowScreen(
          services: widget.services,
          farmerId: widget.farmerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const List<String> titles = <String>[
      'Dashboard',
      'Inventory',
      'Wallet',
      'Market',
      'Profile',
    ];

    final List<Widget> pages = <Widget>[
      _DashboardTab(
        services: widget.services,
        farmerId: widget.farmerId,
        onDeclareHarvest: _openHarvestFlow,
      ),
      _InventoryTab(
        services: widget.services,
        farmerId: widget.farmerId,
        onDeclareHarvest: _openHarvestFlow,
      ),
      _WalletTab(services: widget.services, farmerId: widget.farmerId),
      _MarketTab(services: widget.services),
      _ProfileTab(
        services: widget.services,
        farmerId: widget.farmerId,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: _index < 2
          ? FloatingActionButton.extended(
              onPressed: _openHarvestFlow,
              icon: const Icon(Icons.add),
              label: const Text('New Harvest'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({
    required this.services,
    required this.farmerId,
    required this.onDeclareHarvest,
  });

  final AppServices services;
  final String farmerId;
  final VoidCallback onDeclareHarvest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        FutureBuilder<FarmerProfile?>(
          future: services.profiles.getFarmerProfile(farmerId),
          builder: (BuildContext context, AsyncSnapshot<FarmerProfile?> snapshot) {
            final FarmerProfile? profile = snapshot.data;
            final String firstName = profile?.firstName ?? 'Farmer';
            final String farmName = profile?.farmName ?? 'Farm';
            final String location = profile?.location ?? 'Nigeria';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Good morning, $firstName!',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                Text('$farmName • $location'),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(farmerId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final double available = snapshot.data?.available ?? 0;
            return Card(
              child: ListTile(
                title: const Text('Total Sales (Wallet Available)'),
                subtitle: Text('N${available.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<List<Auction>>(
          stream: services.auctions.watchAuctions(
            farmerId: farmerId,
            status: AuctionStatus.live,
          ),
          builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
            final List<Auction> auctions = snapshot.data ?? <Auction>[];
            final double activeValue = auctions.fold<double>(
              0,
              (double prev, Auction auction) => prev + (auction.quantity * 25000),
            );
            return Card(
              child: ListTile(
                title: const Text('Active Auctions'),
                subtitle: Text('${auctions.length} auctions • N${activeValue.toStringAsFixed(0)} value'),
              ),
            );
          },
        ),
        StreamBuilder<List<InventoryItem>>(
          stream: services.inventory.watchInventoryForFarmer(farmerId),
          builder: (BuildContext context, AsyncSnapshot<List<InventoryItem>> snapshot) {
            final List<InventoryItem> items = snapshot.data ?? <InventoryItem>[];
            final double verifiedQty = items
                .where((InventoryItem item) => item.status == InventoryStatus.verifiedReady)
                .fold<double>(0, (double prev, InventoryItem item) => prev + item.quantity);
            return Card(
              child: ListTile(
                title: const Text('Verified Stock'),
                subtitle: Text('${verifiedQty.toStringAsFixed(0)} bags'),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onDeclareHarvest,
          icon: const Icon(Icons.add),
          label: const Text('New Harvest Declaration'),
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<FarmNotification>>(
          stream: services.notifications.watchNotifications(farmerId),
          builder: (BuildContext context, AsyncSnapshot<List<FarmNotification>> snapshot) {
            final FarmNotification? latest =
                (snapshot.data ?? <FarmNotification>[]).isEmpty
                    ? null
                    : snapshot.data!.first;
            return Card(
              child: ListTile(
                title: const Text('Recent Activity'),
                subtitle: Text(latest?.body ?? 'No activity yet'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InventoryTab extends StatefulWidget {
  const _InventoryTab({
    required this.services,
    required this.farmerId,
    required this.onDeclareHarvest,
  });

  final AppServices services;
  final String farmerId;
  final VoidCallback onDeclareHarvest;

  @override
  State<_InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<_InventoryTab> {
  InventoryStatus? _selected;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, InventoryStatus?>> filters =
        <MapEntry<String, InventoryStatus?>>[
      const MapEntry<String, InventoryStatus?>('All', null),
      const MapEntry<String, InventoryStatus?>('Verified', InventoryStatus.verifiedReady),
      const MapEntry<String, InventoryStatus?>('In Auction', InventoryStatus.inAuction),
      const MapEntry<String, InventoryStatus?>('Sold', InventoryStatus.sold),
      const MapEntry<String, InventoryStatus?>('Unverified', InventoryStatus.unverified),
    ];

    return StreamBuilder<List<InventoryItem>>(
      stream: widget.services.inventory.watchInventoryForFarmer(widget.farmerId),
      builder: (BuildContext context, AsyncSnapshot<List<InventoryItem>> snapshot) {
        final List<InventoryItem> items = snapshot.data ?? <InventoryItem>[];
        final List<InventoryItem> filtered = _selected == null
            ? items
            : items.where((InventoryItem item) => item.status == _selected).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filters
                  .map(
                    (MapEntry<String, InventoryStatus?> entry) => ChoiceChip(
                      label: Text(entry.key),
                      selected: _selected == entry.value,
                      onSelected: (_) {
                        setState(() {
                          _selected = entry.value;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: <Widget>[
                      const Icon(Icons.inventory_2_outlined, size: 48),
                      const SizedBox(height: 8),
                      const Text('No inventory in this filter'),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: widget.onDeclareHarvest,
                        child: const Text('Declare First Harvest'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...filtered.map((InventoryItem item) => _InventoryCard(
                    item: item,
                    services: widget.services,
                    farmerId: widget.farmerId,
                  )),
          ],
        );
      },
    );
  }
}

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.item,
    required this.services,
    required this.farmerId,
  });

  final InventoryItem item;
  final AppServices services;
  final String farmerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '${item.crop.toUpperCase()} - ${item.unit.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('Stored: ${item.storageLocation}'),
            Text('Quantity: ${item.quantity.toStringAsFixed(0)} ${item.unit}'),
            Text('Harvested: ${item.harvestDate.toLocal().toString().split(' ').first}'),
            Text('Status: ${item.status.name}'),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: item.status == InventoryStatus.verifiedReady
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => AuctionFlowScreen(
                                  services: services,
                                  farmerId: farmerId,
                                  inventoryId: item.id,
                                  crop: item.crop,
                                  quantity: item.quantity,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: const Text('Create Auction'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab({required this.services, required this.farmerId});

  final AppServices services;
  final String farmerId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(farmerId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final WalletBalance balance = snapshot.data ??
                WalletBalance(
                  userId: farmerId,
                  available: 0,
                  inEscrow: 0,
                  updatedAt: DateTime.now(),
                );
            return Card(
              child: ListTile(
                title: const Text('Available Balance'),
                subtitle: Text('N${balance.available.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(farmerId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final double escrow = snapshot.data?.inEscrow ?? 0;
            return Card(
              child: ListTile(
                title: const Text('In Escrow'),
                subtitle: Text('N${escrow.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<List<WalletTransaction>>(
          stream: services.wallet.watchTransactions(farmerId),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<WalletTransaction>> snapshot,
          ) {
            final List<WalletTransaction> txns =
                snapshot.data ?? <WalletTransaction>[];
            final WalletTransaction? latest = txns.isEmpty ? null : txns.first;
            return Card(
              child: ListTile(
                title: const Text('Recent Transaction'),
                subtitle: Text(
                  latest == null
                      ? 'No transactions yet'
                      : '${latest.type.name} • N${latest.amount.toStringAsFixed(0)} • ${latest.reference}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MarketTab extends StatelessWidget {
  const _MarketTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Auction>>(
      stream: services.auctions.watchAuctions(status: AuctionStatus.live),
      builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
        final List<Auction> auctions = snapshot.data ?? <Auction>[];
        final int maizeLive = auctions.where((Auction a) => a.crop == 'Maize').length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Price Trends'),
                subtitle: Text('Live maize auctions: $maizeLive'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Demand Heatmap'),
                subtitle: Text('High demand in Kaduna, Kano, Oyo'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Buyer Requests'),
                subtitle: Text(
                  auctions.isEmpty
                      ? 'No active requests'
                      : '${auctions.length} active auction opportunities',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.services,
    required this.farmerId,
    required this.onLogout,
  });

  final AppServices services;
  final String farmerId;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FarmerProfile?>(
      future: services.profiles.getFarmerProfile(farmerId),
      builder: (BuildContext context, AsyncSnapshot<FarmerProfile?> snapshot) {
        final FarmerProfile? profile = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Farmer ID'),
                subtitle: Text(profile?.farmerId ?? 'FC-FARMER-038472'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Profile'),
                subtitle: Text(
                  profile == null
                      ? 'Profile not loaded'
                      : '${profile.firstName} ${profile.lastName} • ${profile.farmName}',
                ),
              ),
            ),
            FilledButton(
              onPressed: onLogout,
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
