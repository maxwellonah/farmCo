import 'package:flutter/material.dart';

class BuyerOnboardingScreen extends StatefulWidget {
  const BuyerOnboardingScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<BuyerOnboardingScreen> createState() => _BuyerOnboardingScreenState();
}

class _BuyerOnboardingScreenState extends State<BuyerOnboardingScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyer Registration'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            LinearProgressIndicator(value: (_step + 1) / 4),
            const SizedBox(height: 8),
            Text('Step ${_step + 1} of 4'),
            const SizedBox(height: 12),
            Expanded(child: _buildStep()),
            FilledButton(
              onPressed: _step < 3
                  ? () {
                      setState(() {
                        _step += 1;
                      });
                    }
                  : widget.onComplete,
              child: Text(_step < 3 ? 'Continue' : 'Complete Buyer Setup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_step == 0) {
      return ListView(
        children: <Widget>[
          const Text(
            'Business Type',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const <Widget>[
              Chip(label: Text('Processor')),
              Chip(label: Text('Trader')),
              Chip(label: Text('Exporter')),
              Chip(label: Text('Retail Aggregator')),
              Chip(label: Text('Institutional')),
            ],
          ),
        ],
      );
    }
    if (_step == 1) {
      return ListView(
        children: const <Widget>[
          Text(
            'Business Verification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'RC Number / Registration',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Tax Identification Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Business Address',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    if (_step == 2) {
      return ListView(
        children: const <Widget>[
          Text(
            'Volume & Requirements',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              labelText: 'Monthly Purchase Volume (tons)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Preferred Crops',
              hintText: 'Maize, Rice, Cassava...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Regions of Operation',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Quality Standards Required',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: const <Widget>[
        Text(
          'Team Members',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            labelText: 'Purchasing Manager Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            labelText: 'Role & Permission',
            hintText: 'Bid only / Full order approval',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 12),
        Card(
          child: ListTile(
            title: Text('Ready to start sourcing'),
            subtitle: Text('You can now browse and bid on auctions'),
          ),
        ),
      ],
    );
  }
}
