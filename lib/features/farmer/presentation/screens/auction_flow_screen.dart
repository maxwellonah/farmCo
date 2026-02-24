import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class AuctionFlowScreen extends StatefulWidget {
  const AuctionFlowScreen({
    super.key,
    required this.services,
    required this.farmerId,
    required this.inventoryId,
    required this.crop,
    required this.quantity,
  });

  final AppServices services;
  final String farmerId;
  final String inventoryId;
  final String crop;
  final double quantity;

  @override
  State<AuctionFlowScreen> createState() => _AuctionFlowScreenState();
}

class _AuctionFlowScreenState extends State<AuctionFlowScreen> {
  int _step = 0;
  int _durationHours = 24;
  int _minBidQuantity = 10;
  bool _agreed = true;
  late double _sellQuantity;

  @override
  void initState() {
    super.initState();
    _sellQuantity = widget.quantity > 0 ? widget.quantity : 10;
  }

  Future<void> _startAuction() async {
    final Auction auction = await widget.services.auctions.createAuction(
      AuctionDraft(
        farmerId: widget.farmerId,
        inventoryId: widget.inventoryId,
        crop: widget.crop,
        quantity: _sellQuantity,
        minBidQuantity: _minBidQuantity,
        durationHours: _durationHours,
        reservePricePerUnit: 24500,
      ),
    );

    await widget.services.inventory.updateStatus(
      inventoryId: widget.inventoryId,
      status: InventoryStatus.inAuction,
    );

    await widget.services.notifications.send(
      FarmNotification(
        id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
        userId: widget.farmerId,
        type: FarmNotificationType.auctionCompleted,
        title: 'Auction Started',
        body: 'Auction ${auction.id} is now live.',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LiveAuctionScreen(
          services: widget.services,
          auctionId: auction.id,
          farmerId: widget.farmerId,
          inventoryId: widget.inventoryId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Creation')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 2) {
            setState(() {
              _step += 1;
            });
            return;
          }
          _startAuction();
        },
        onStepCancel: () {
          if (_step == 0) {
            Navigator.of(context).pop();
            return;
          }
          setState(() {
            _step -= 1;
          });
        },
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: <Widget>[
              FilledButton(
                onPressed: (_step == 2 && !_agreed) ? null : details.onStepContinue,
                child: Text(_step == 2 ? 'Start Auction - N500 fee' : 'Next'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ],
          );
        },
        steps: <Step>[
          Step(
            title: const Text('Select Verified Inventory'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: ListTile(
                    title: Text('${widget.crop} - ${widget.quantity.toStringAsFixed(0)} bags'),
                    subtitle: const Text('Grade A • Moisture 12% • Verified stock'),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Sell quantity: ${_sellQuantity.toStringAsFixed(0)} bags'),
                Slider(
                  value: _sellQuantity,
                  min: 1,
                  max: widget.quantity > 1 ? widget.quantity : 1,
                  divisions: widget.quantity >= 2 ? widget.quantity.toInt() - 1 : null,
                  onChanged: (double value) {
                    setState(() {
                      _sellQuantity = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Step(
            title: const Text('Auction Settings'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Auction Duration'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: <int>[12, 24, 48]
                      .map(
                        (int hours) => ChoiceChip(
                          label: Text('$hours hours'),
                          selected: _durationHours == hours,
                          onSelected: (_) {
                            setState(() {
                              _durationHours = hours;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minimum bid quantity',
                    border: const OutlineInputBorder(),
                    hintText: _minBidQuantity.toString(),
                  ),
                  onChanged: (String value) {
                    final int? parsed = int.tryParse(value);
                    if (parsed == null || parsed < 1) {
                      return;
                    }
                    setState(() {
                      _minBidQuantity = parsed;
                    });
                  },
                ),
                const SizedBox(height: 8),
                Text('Selected duration: $_durationHours hours'),
              ],
            ),
          ),
          Step(
            title: const Text('Review & Fair Price'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Market Average: N25,000/bag\n'
                      '7-day trend: +5%\n'
                      'Demand: HIGH\n'
                      'Recommended range: N24,500 - N26,000',
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agreed,
                  onChanged: (bool? value) {
                    setState(() {
                      _agreed = value ?? false;
                    });
                  },
                  title: const Text('I agree to 3% platform fee and sale terms'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LiveAuctionScreen extends StatelessWidget {
  const LiveAuctionScreen({
    super.key,
    required this.services,
    required this.auctionId,
    required this.farmerId,
    required this.inventoryId,
  });

  final AppServices services;
  final String auctionId;
  final String farmerId;
  final String inventoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Auction Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          StreamBuilder<List<Auction>>(
            stream: services.auctions.watchAuctions(),
            builder: (BuildContext context, AsyncSnapshot<List<Auction>> snapshot) {
              final Auction? auction = (snapshot.data ?? <Auction>[])
                  .where((Auction item) => item.id == auctionId)
                  .cast<Auction?>()
                  .firstOrNull;
              return Card(
                child: ListTile(
                  title: Text('${auction?.id ?? auctionId} • ${auction?.status.name ?? 'live'}'),
                  subtitle: Text('Ends: ${auction?.endAt.toLocal() ?? '-'}'),
                ),
              );
            },
          ),
          StreamBuilder<List<Bid>>(
            stream: services.bids.watchBidsForAuction(auctionId),
            builder: (BuildContext context, AsyncSnapshot<List<Bid>> snapshot) {
              final List<Bid> bids = snapshot.data ?? <Bid>[];
              final Bid? topBid = bids.isEmpty
                  ? null
                  : bids.reduce((Bid a, Bid b) => a.pricePerUnit > b.pricePerUnit ? a : b);
              return Card(
                child: ListTile(
                  title: const Text('Current highest bid'),
                  subtitle: Text(
                    topBid == null
                        ? 'No bids yet'
                        : 'N${topBid.pricePerUnit.toStringAsFixed(0)}/bag by ${topBid.buyerId}',
                  ),
                ),
              );
            },
          ),
          FilledButton(
            onPressed: () async {
              await services.auctions.updateStatus(
                auctionId: auctionId,
                status: AuctionStatus.completed,
              );
              await services.inventory.updateStatus(
                inventoryId: inventoryId,
                status: InventoryStatus.sold,
              );
              if (!context.mounted) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AuctionCompletedScreen(
                    services: services,
                    auctionId: auctionId,
                    farmerId: farmerId,
                  ),
                ),
              );
            },
            child: const Text('Complete Auction'),
          ),
        ],
      ),
    );
  }
}

class AuctionCompletedScreen extends StatelessWidget {
  const AuctionCompletedScreen({
    super.key,
    required this.services,
    required this.auctionId,
    required this.farmerId,
  });

  final AppServices services;
  final String auctionId;
  final String farmerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Completed')),
      body: StreamBuilder<List<Bid>>(
        stream: services.bids.watchBidsForAuction(auctionId),
        builder: (BuildContext context, AsyncSnapshot<List<Bid>> snapshot) {
          final List<Bid> bids = snapshot.data ?? <Bid>[];
          final double totalValue = bids.fold<double>(
            0,
            (double prev, Bid bid) => prev + (bid.pricePerUnit * bid.quantity),
          );
          final double fee = totalValue * 0.03;
          final double earnings = totalValue - fee;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const Icon(Icons.emoji_events_outlined, size: 70, color: Colors.amber),
              const SizedBox(height: 10),
              const Text(
                'Auction Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Total Sale Value: N${totalValue.toStringAsFixed(0)}\n'
                    'Platform Fee: N${fee.toStringAsFixed(0)}\n'
                    'Your Earnings: N${earnings.toStringAsFixed(0)}',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LogisticsScreen(),
                    ),
                  );
                },
                child: const Text('Arrange Logistics with Buyers'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await services.wallet.credit(
                    userId: farmerId,
                    amount: earnings,
                    reference: 'auction-$auctionId-settlement',
                  );
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PaymentReceivedScreen(
                        services: services,
                        farmerId: farmerId,
                        amount: earnings,
                      ),
                    ),
                  );
                },
                child: const Text('View Payment Schedule'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LogisticsScreen extends StatelessWidget {
  const LogisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Logistics Coordination')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          Card(
            child: ListTile(
              title: Text('Green Mills - 20 bags @ N25,500'),
              subtitle: Text('Location: Ikeja, Lagos • Suggested transport N15k-N20k'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Prime Foods - 50 bags @ N25,600'),
              subtitle: Text('Location: Kaduna • Farmer delivery'),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentReceivedScreen extends StatelessWidget {
  const PaymentReceivedScreen({
    super.key,
    required this.services,
    required this.farmerId,
    required this.amount,
  });

  final AppServices services;
  final String farmerId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Received')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Icon(Icons.payments_outlined, size: 72, color: Colors.green),
          const SizedBox(height: 10),
          Text(
            'TOTAL CREDITED: N${amount.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Wallet available: N${balance.available.toStringAsFixed(0)}\n'
                    'In escrow: N${balance.inEscrow.toStringAsFixed(0)}',
                  ),
                ),
              );
            },
          ),
          FilledButton(onPressed: () {}, child: const Text('Withdraw Now')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () {}, child: const Text('Keep in Wallet')),
        ],
      ),
    );
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
