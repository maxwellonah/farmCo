import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({
    super.key,
    required this.services,
    required this.buyerId,
    required this.onLogout,
  });

  final AppServices services;
  final String buyerId;
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
      _BuyerDashboardTab(
        services: widget.services,
        buyerId: widget.buyerId,
      ),
      _SourcingTab(
        services: widget.services,
        buyerId: widget.buyerId,
      ),
      _OrdersTab(
        services: widget.services,
        buyerId: widget.buyerId,
      ),
      _SuppliersTab(
        services: widget.services,
        buyerId: widget.buyerId,
      ),
      _FinanceTab(
        services: widget.services,
        buyerId: widget.buyerId,
        onLogout: widget.onLogout,
      ),
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
  const _BuyerDashboardTab({
    required this.services,
    required this.buyerId,
  });

  final AppServices services;
  final String buyerId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<List<Auction>>(
          stream: services.auctions.watchAuctions(status: AuctionStatus.live),
          builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
            final int count = (snapshot.data ?? <Auction>[]).length;
            return Card(
              child: ListTile(
                title: const Text('Sourcing Alerts'),
                subtitle: Text('$count live auctions matching your filters'),
              ),
            );
          },
        ),
        StreamBuilder<List<Bid>>(
          stream: services.bids.watchBidsForBuyer(buyerId),
          builder: (BuildContext context, AsyncSnapshot<List<Bid>> snapshot) {
            final List<Bid> bids = snapshot.data ?? <Bid>[];
            final Bid? topBid = bids.isEmpty ? null : bids.first;
            return Card(
              child: ListTile(
                title: const Text('Active Bids'),
                subtitle: Text(
                  topBid == null
                      ? 'No bids placed yet'
                      : 'Auction ${topBid.auctionId}: N${topBid.pricePerUnit.toStringAsFixed(0)} (${topBid.quantity.toStringAsFixed(0)} bags)',
                ),
              ),
            );
          },
        ),
        StreamBuilder<List<Order>>(
          stream: services.orders.watchOrdersForBuyer(buyerId),
          builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
            final List<Order> inFlight = (snapshot.data ?? <Order>[])
                .where((Order order) => order.status != OrderStatus.paymentReleased)
                .toList();
            return Card(
              child: ListTile(
                title: const Text('Orders Pending Delivery'),
                subtitle: Text('${inFlight.length} orders in progress'),
              ),
            );
          },
        ),
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(buyerId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final WalletBalance balance = snapshot.data ??
                WalletBalance(
                  userId: buyerId,
                  available: 0,
                  inEscrow: 0,
                  updatedAt: DateTime.now(),
                );
            return Card(
              child: ListTile(
                title: const Text('Market Intelligence'),
                subtitle: Text(
                  'Wallet available N${balance.available.toStringAsFixed(0)} • Escrow N${balance.inEscrow.toStringAsFixed(0)}',
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SourcingTab extends StatelessWidget {
  const _SourcingTab({
    required this.services,
    required this.buyerId,
  });

  final AppServices services;
  final String buyerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Auction>>(
      stream: services.auctions.watchAuctions(status: AuctionStatus.live),
      builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
        final List<Auction> auctions = snapshot.data ?? <Auction>[];
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
            if (auctions.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No live auctions'),
                  subtitle: Text('Check back shortly for new inventory'),
                ),
              )
            else
              ...auctions.map(
                (Auction auction) => _AuctionListCard(
                  auction: auction,
                  services: services,
                  buyerId: buyerId,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AuctionListCard extends StatelessWidget {
  const _AuctionListCard({
    required this.auction,
    required this.services,
    required this.buyerId,
  });

  final Auction auction;
  final AppServices services;
  final String buyerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('LIVE AUCTION', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '${auction.crop.toUpperCase()} - ${auction.quantity.toStringAsFixed(0)} bags',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Min bid: ${auction.minBidQuantity} bags'),
            Text('Auction ID: ${auction.id}'),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BuyerAuctionDetailsScreen(auction: auction),
                        ),
                      );
                    },
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      const double price = 25700;
                      final double qty = auction.minBidQuantity.toDouble();
                      await services.bids.placeBid(
                        BidDraft(
                          auctionId: auction.id,
                          buyerId: buyerId,
                          pricePerUnit: price,
                          quantity: qty,
                        ),
                      );
                      await services.wallet.holdInEscrow(
                        userId: buyerId,
                        amount: price * qty,
                        reference: 'bid-${auction.id}',
                      );
                      if (!context.mounted) {
                        return;
                      }
                      showDialog<void>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Bid Submitted'),
                          content: Text('N${(price * qty).toStringAsFixed(0)} reserved from wallet.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Place Bid'),
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

class BuyerAuctionDetailsScreen extends StatelessWidget {
  const BuyerAuctionDetailsScreen({super.key, required this.auction});

  final Auction auction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: ListTile(
              title: Text('Photo Carousel'),
              subtitle: Text('Verified inventory photos placeholder'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Auction Summary'),
              subtitle: Text(
                'Auction ID: ${auction.id}\n'
                'Crop: ${auction.crop}\n'
                'Quantity: ${auction.quantity.toStringAsFixed(0)} bags\n'
                'Min bid quantity: ${auction.minBidQuantity}',
              ),
            ),
          ),
          const Card(
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
  const _OrdersTab({
    required this.services,
    required this.buyerId,
  });

  final AppServices services;
  final String buyerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: services.orders.watchOrdersForBuyer(buyerId),
      builder: (BuildContext context, AsyncSnapshot<List<Order>> snapshot) {
        final List<Order> orders = snapshot.data ?? <Order>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (orders.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No orders yet'),
                  subtitle: Text('Won auctions will appear here.'),
                ),
              )
            else
              ...orders.map(
                (Order order) => Card(
                  child: ListTile(
                    title: Text('ORDER ${order.id}'),
                    subtitle: Text(
                      'Status: ${order.status.name}\n'
                      'Quantity: ${order.quantity.toStringAsFixed(0)}\n'
                      'Total: N${order.totalValue.toStringAsFixed(0)}',
                    ),
                    trailing: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BuyerQualityCheckScreen(
                              services: services,
                              order: order,
                            ),
                          ),
                        );
                      },
                      child: const Text('Quality Check'),
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

class BuyerQualityCheckScreen extends StatelessWidget {
  const BuyerQualityCheckScreen({
    super.key,
    required this.services,
    required this.order,
  });

  final AppServices services;
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quality Check & Payment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FilledButton(
            onPressed: () async {
              await services.orders.updateOrderStatus(
                orderId: order.id,
                status: OrderStatus.paymentReleased,
              );
              await services.wallet.releaseFromEscrow(
                userId: order.buyerId,
                amount: order.totalValue,
                reference: 'order-${order.id}-release',
              );
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
            },
            child: const Text('Accept & Release Payment'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              await services.orders.updateOrderStatus(
                orderId: order.id,
                status: OrderStatus.disputed,
              );
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).pop();
            },
            child: const Text('Raise Issue'),
          ),
          const SizedBox(height: 8),
          const Card(
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
  const _SuppliersTab({
    required this.services,
    required this.buyerId,
  });

  final AppServices services;
  final String buyerId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Bid>>(
      stream: services.bids.watchBidsForBuyer(buyerId),
      builder: (BuildContext context, AsyncSnapshot<List<Bid>> snapshot) {
        final List<Bid> bids = snapshot.data ?? <Bid>[];
        final int active = bids.where((Bid bid) => bid.status == BidStatus.active).length;
        final int won = bids.where((Bid bid) => bid.status == BidStatus.won).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Card(
              child: ListTile(
                title: const Text('My Bids - Active'),
                subtitle: Text('$active active bids'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Won Auctions'),
                subtitle: Text('$won won bids'),
              ),
            ),
            const Card(
              child: ListTile(
                title: Text('Supplier Scorecard'),
                subtitle: Text('Quality consistency, on-time delivery, dispute history'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab({
    required this.services,
    required this.buyerId,
    required this.onLogout,
  });

  final AppServices services;
  final String buyerId;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(buyerId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final WalletBalance balance = snapshot.data ??
                WalletBalance(
                  userId: buyerId,
                  available: 0,
                  inEscrow: 0,
                  updatedAt: DateTime.now(),
                );
            return Card(
              child: ListTile(
                title: const Text('Wallet Balance'),
                subtitle: Text(
                  'Available N${balance.available.toStringAsFixed(0)} • Escrow N${balance.inEscrow.toStringAsFixed(0)}',
                ),
              ),
            );
          },
        ),
        StreamBuilder<List<WalletTransaction>>(
          stream: services.wallet.watchTransactions(buyerId),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<WalletTransaction>> snapshot,
          ) {
            final int count = (snapshot.data ?? <WalletTransaction>[]).length;
            return Card(
              child: ListTile(
                title: const Text('Transactions'),
                subtitle: Text('$count records'),
              ),
            );
          },
        ),
        FilledButton(
          onPressed: onLogout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
