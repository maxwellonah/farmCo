import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({
    super.key,
    required this.services,
    required this.onLogout,
  });

  final AppServices services;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: <Widget>[
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'Disputes'),
              Tab(text: 'Verification'),
              Tab(text: 'Finance'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _OverviewTab(services: services),
            _UsersTab(services: services),
            _DisputesTab(services: services),
            _VerificationTab(services: services),
            _FinanceTab(services: services),
            _AnalyticsTab(services: services),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<List<Order>>(
          stream: services.orders.watchAllOrders(),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
            final double gmv = (snapshot.data ?? <Order>[])
                .fold<double>(0, (double prev, Order item) => prev + item.totalValue);
            return Card(
              child: ListTile(
                title: const Text('Total GMV'),
                subtitle: Text('N${gmv.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<List<Auction>>(
          stream: services.auctions.watchAuctions(status: AuctionStatus.live),
          builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
            final int active = (snapshot.data ?? <Auction>[]).length;
            return Card(
              child: ListTile(
                title: const Text('Active Auctions'),
                subtitle: Text('$active'),
              ),
            );
          },
        ),
        StreamBuilder<List<InventoryItem>>(
          stream: services.inventory.watchAllInventory(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<InventoryItem>> snapshot,
          ) {
            final int pending = (snapshot.data ?? <InventoryItem>[])
                .where((InventoryItem item) => item.status == InventoryStatus.underReview)
                .length;
            return Card(
              child: ListTile(
                title: const Text('Pending Verifications'),
                subtitle: Text('$pending'),
              ),
            );
          },
        ),
        StreamBuilder<List<Order>>(
          stream: services.orders.watchAllOrders(),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
            final List<Order> orders = snapshot.data ?? <Order>[];
            final int disputed = orders
                .where((Order order) => order.status == OrderStatus.disputed)
                .length;
            final double disputeRate = orders.isEmpty ? 0 : (disputed / orders.length) * 100;
            return Card(
              child: ListTile(
                title: const Text('Dispute Rate'),
                subtitle: Text('${disputeRate.toStringAsFixed(1)}%'),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Object>>(
      future: Future.wait<List<Object>>(
        <Future<List<Object>>>[
          services.profiles.listFarmers().then((List<FarmerProfile> value) => value),
          services.profiles.listBuyers().then((List<BuyerProfile> value) => value),
          services.profiles.listAgents().then((List<AgentProfile> value) => value),
        ],
      ),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        final List<Object> list = snapshot.data ?? <Object>[];
        final int farmers = list.isNotEmpty ? (list[0] as List<Object>).length : 0;
        final int buyers = list.length > 1 ? (list[1] as List<Object>).length : 0;
        final int agents = list.length > 2 ? (list[2] as List<Object>).length : 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Farmers'),
                subtitle: Text('$farmers registered'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Buyers'),
                subtitle: Text('$buyers registered'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Agents'),
                subtitle: Text('$agents active'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Bulk Actions'),
                subtitle: Text('Verify in bulk, send notification, export CSV, assign to agent'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DisputesTab extends StatelessWidget {
  const _DisputesTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: services.orders.watchAllOrders(),
      builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
        final List<Order> disputes = (snapshot.data ?? <Order>[])
            .where((Order order) => order.status == OrderStatus.disputed)
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (disputes.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No active disputes'),
                  subtitle: Text('All recent orders are progressing normally.'),
                ),
              )
            else
              ...disputes.map(
                (Order order) => Card(
                  child: ListTile(
                    title: Text('DISPUTE: ${order.id}'),
                    subtitle: Text(
                      'Farmer ${order.farmerId} vs Buyer ${order.buyerId}\n'
                      'Amount: N${order.totalValue.toStringAsFixed(0)}',
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VerificationTab extends StatelessWidget {
  const _VerificationTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: services.inventory.watchAllInventory(),
      builder: (BuildContext context, AsyncSnapshot<List<InventoryItem>> snapshot) {
        final List<InventoryItem> items = snapshot.data ?? <InventoryItem>[];
        final int pending = items
            .where((InventoryItem item) => item.status == InventoryStatus.underReview)
            .length;
        final int verified = items
            .where((InventoryItem item) => item.status == InventoryStatus.verifiedReady)
            .length;
        final int unverified = items
            .where((InventoryItem item) => item.status == InventoryStatus.unverified)
            .length;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Verification Monitor'),
                subtitle: Text(
                  'Pending: $pending\n'
                  'Verified: $verified\n'
                  'Unverified: $unverified',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Fraud Detection Panel'),
                subtitle: Text('Duplicate photos, GPS spoofing, collusion alerts'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: services.orders.watchAllOrders(),
      builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
        final List<Order> orders = snapshot.data ?? <Order>[];
        final double total = orders.fold<double>(
          0,
          (double prev, Order order) => prev + order.totalValue,
        );
        final double fee = total * 0.03;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('Daily Reconciliation'),
                subtitle: Text(
                  'Total transactions: N${total.toStringAsFixed(0)}\n'
                  'Platform fees (3%): N${fee.toStringAsFixed(0)}',
                ),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Payout Processing'),
                subtitle: Text('Batch payouts, commission runs, settlement reports'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Object>>(
      future: Future.wait<List<Object>>(
        <Future<List<Object>>>[
          services.profiles.listFarmers().then((List<FarmerProfile> value) => value),
          services.profiles.listBuyers().then((List<BuyerProfile> value) => value),
          services.profiles.listAgents().then((List<AgentProfile> value) => value),
        ],
      ),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        final List<Object> list = snapshot.data ?? <Object>[];
        final int farmers = list.isNotEmpty ? (list[0] as List<Object>).length : 0;
        final int buyers = list.length > 1 ? (list[1] as List<Object>).length : 0;
        final int agents = list.length > 2 ? (list[2] as List<Object>).length : 0;

        return StreamBuilder<List<Order>>(
          stream: services.orders.watchAllOrders(),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> orderSnapshot) {
            final int orders = (orderSnapshot.data ?? <Order>[]).length;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: const Text('Platform Metrics'),
                    subtitle: Text(
                      'Farmers: $farmers\nBuyers: $buyers\nAgents: $agents\nOrders: $orders',
                    ),
                  ),
                ),
                const Card(
                  child: ListTile(
                    title: Text('Predictive Analytics'),
                    subtitle: Text('Price forecasts, demand prediction, fraud probability, churn risk'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
