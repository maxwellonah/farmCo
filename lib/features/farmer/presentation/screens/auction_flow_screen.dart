import 'package:flutter/material.dart';

class AuctionFlowScreen extends StatefulWidget {
  const AuctionFlowScreen({super.key});

  @override
  State<AuctionFlowScreen> createState() => _AuctionFlowScreenState();
}

class _AuctionFlowScreenState extends State<AuctionFlowScreen> {
  int _step = 0;
  int _durationHours = 24;
  bool _agreed = true;

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
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const LiveAuctionScreen()),
          );
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
          const Step(
            title: Text('Select Verified Inventory'),
            content: Card(
              child: ListTile(
                title: Text('Maize - 120 bags'),
                subtitle: Text('Grade A • Moisture 12% • Verified Jan 12'),
              ),
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
                const Text('Minimum bid quantity: 10 bags'),
                const Text('Reserve price: Optional'),
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
  const LiveAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Auction Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Card(
            child: ListTile(
              title: Text('Auction #FC-AU-78901 • LIVE'),
              subtitle: Text('Countdown: 23:45:12'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Current highest bid'),
              subtitle: Text('N25,700/bag • 4 buyers active'),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Allocation Preview'),
              subtitle: Text('Green Mills 20 • Abdul Trader 10 • Prime Foods 50'),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AuctionCompletedScreen(),
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
  const AuctionCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Completed')),
      body: ListView(
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
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Total Sale Value: N2,040,000\n'
                'Average Price: N25,500/bag\n'
                'Platform Fee: N61,200\n'
                'Your Earnings: N1,978,800',
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PaymentReceivedScreen(),
                ),
              );
            },
            child: const Text('View Payment Schedule'),
          ),
        ],
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
              title: Text('Abdul Trader - 10 bags @ N25,200'),
              subtitle: Text('Location: Kano • Buyer pickup'),
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
  const PaymentReceivedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Received')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Icon(Icons.payments_outlined, size: 72, color: Colors.green),
          const SizedBox(height: 10),
          const Text(
            'TOTAL CREDITED: N1,978,300',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Sale value: N2,040,000\n'
                'Platform fee: -N61,200\n'
                'Verification: -N500\n'
                'Transport: +N20,000\n'
                'Withdrawal fee: -N500\n'
                'Net: N1,978,300',
              ),
            ),
          ),
          FilledButton(onPressed: () {}, child: const Text('Withdraw Now')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () {}, child: const Text('Keep in Wallet')),
        ],
      ),
    );
  }
}
