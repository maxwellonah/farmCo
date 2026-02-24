import 'package:flutter/material.dart';

import 'auction_flow_screen.dart';
import 'harvest_flow_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _index = 0;

  void _openHarvestFlow() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const HarvestFlowScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      'Dashboard',
      'Inventory',
      'Wallet',
      'Market',
      'Profile',
    ];

    final List<Widget> pages = <Widget>[
      _DashboardTab(onDeclareHarvest: _openHarvestFlow),
      _InventoryTab(onDeclareHarvest: _openHarvestFlow),
      const _WalletTab(),
      const _MarketTab(),
      _ProfileTab(onLogout: widget.onLogout),
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
  const _DashboardTab({required this.onDeclareHarvest});

  final VoidCallback onDeclareHarvest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Text(
          'Good morning, Chika!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const Text("Chika's Maize Farm • Kaduna State"),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Total Sales (Month)'),
            subtitle: Text('N2,450,000 • Up 15% from last month'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Active Auctions'),
            subtitle: Text('3 auctions • N1,200,000 total value'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Verified Stock'),
            subtitle: Text('120 bags of Maize'),
          ),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: onDeclareHarvest,
          icon: const Icon(Icons.add),
          label: const Text('New Harvest Declaration'),
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(
            title: Text('Recent Activity'),
            subtitle: Text('Auction #FC-78901 completed - N2.04M received'),
          ),
        ),
      ],
    );
  }
}

class _InventoryTab extends StatelessWidget {
  const _InventoryTab({required this.onDeclareHarvest});

  final VoidCallback onDeclareHarvest;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 8,
          children: const <Widget>[
            Chip(label: Text('All')),
            Chip(label: Text('Verified')),
            Chip(label: Text('In Auction')),
            Chip(label: Text('Sold')),
            Chip(label: Text('Unverified')),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'MAIZE - GRADE A',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                const Text('Stored: On-farm storage'),
                const Text('Quantity: 120 bags'),
                const Text('Harvested: Jan 12, 2026'),
                const Text('Status: VERIFIED READY'),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AuctionFlowScreen(),
                      ),
                    );
                  },
                  child: const Text('Create Auction'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: onDeclareHarvest,
          child: const Text('Declare First Harvest'),
        ),
      ],
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Available Balance'),
            subtitle: Text('N1,978,300'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('In Escrow'),
            subtitle: Text('N0'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Recent Transaction'),
            subtitle: Text('Jan 13 - Credit: N1,978,300'),
          ),
        ),
      ],
    );
  }
}

class _MarketTab extends StatelessWidget {
  const _MarketTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Price Trends'),
            subtitle: Text('Maize average: N25,000/bag (Kaduna)'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Demand Heatmap'),
            subtitle: Text('High demand in Kaduna, Kano, Oyo'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Buyer Requests'),
            subtitle: Text('Green Mills needs 500 bags Maize'),
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('Farmer ID'),
            subtitle: Text('FC-FARMER-038472'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Performance'),
            subtitle: Text('Total sales: N4.5M • Rating: 4.8/5'),
          ),
        ),
        FilledButton(
          onPressed: onLogout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
