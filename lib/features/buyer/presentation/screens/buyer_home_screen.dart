import 'package:flutter/material.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const List<String> titles = <String>[
      'Buyer Dashboard',
      'Sourcing',
      'Orders',
      'Suppliers',
      'Finance',
    ];

    final List<Widget> pages = <Widget>[
      const _BuyerDashboardTab(),
      const _SourcingTab(),
      const _OrdersTab(),
      const _SuppliersTab(),
      _FinanceTab(onLogout: widget.onLogout),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.search_outlined), label: 'Sourcing'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.handshake_outlined), label: 'Suppliers'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Finance'),
        ],
      ),
    );
  }
}

class _BuyerDashboardTab extends StatelessWidget {
  const _BuyerDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Sourcing Alerts'),
            subtitle: Text('3 new auctions matching your preferences'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Active Bids'),
            subtitle: Text('Auction #78901: Leading with N25,700 (20 bags)'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Orders Pending Delivery'),
            subtitle: Text('20 bags Maize from Chika\'s Farm • Delivery Jan 14'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Market Intelligence'),
            subtitle: Text('Price drop on Maize in Kaduna'),
          ),
        ),
      ],
    );
  }
}

class _SourcingTab extends StatelessWidget {
  const _SourcingTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const <Widget>[
            Chip(label: Text('Crop: Maize')),
            Chip(label: Text('Radius: 100km')),
            Chip(label: Text('Quality: Grade A')),
            Chip(label: Text('Verification: Agent')),
            Chip(label: Text('Ending: Soonest')),
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
                  'ENDING IN 3:45:12',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'MAIZE - GRADE A',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('Kaduna • 120 bags • Agent verified'),
                const Text('Current bid: N25,500/bag • 4 buyers bidding'),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const BuyerAuctionDetailsScreen(),
                            ),
                          );
                        },
                        child: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          _showBidConfirmation(context);
                        },
                        child: const Text('Place Bid'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBidConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Bid Submitted'),
        content: const Text('N255,000 will be reserved from your wallet.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class BuyerAuctionDetailsScreen extends StatelessWidget {
  const BuyerAuctionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Photo Carousel'),
              subtitle: Text('Verified inventory photos placeholder'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Farmer Profile'),
              subtitle: Text('Rating: 4.8/5 • 24 successful auctions'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Quality Metrics'),
              subtitle: Text('Grade A • Moisture 12% • Foreign matter <1%'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Bid Panel'),
              subtitle: Text('Your bid: N25,700/bag • Quantity: 10 bags'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('ORDER #FC-ORD-78901'),
            subtitle: Text(
              'Status: In Transit\n'
              '1. Auction won\n'
              '2. Payment reserved\n'
              '3. Logistics arranged\n'
              '4. In transit',
            ),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const BuyerQualityCheckScreen(),
              ),
            );
          },
          child: const Text('Open Quality Check'),
        ),
      ],
    );
  }
}

class BuyerQualityCheckScreen extends StatelessWidget {
  const BuyerQualityCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quality Check & Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Accept & Release Payment'),
              subtitle: Text('Rate quality and confirm acceptance'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Raise Issue'),
              subtitle: Text('Short quantity / poor quality / damaged goods'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Request Extension'),
              subtitle: Text('Need 24 hours more for testing'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuppliersTab extends StatelessWidget {
  const _SuppliersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('My Bids - Active'),
            subtitle: Text('Auction #78901 • Leading • N25,700/bag'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Won Auctions'),
            subtitle: Text('20 bags Maize @ N25,500 • Payment held in escrow'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Supplier Scorecard'),
            subtitle: Text('Quality consistency, on-time delivery, dispute history'),
          ),
        ),
      ],
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('Spend Analysis'),
            subtitle: Text('By crop, month, and supplier'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Price Benchmarking'),
            subtitle: Text('Compared to market average and historical spend'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Savings Calculator'),
            subtitle: Text('Savings vs traditional sourcing channels'),
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
