import 'package:flutter/material.dart';

import '../../domain/verification_method.dart';
import 'auction_flow_screen.dart';
import 'harvest_flow_screen.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({super.key, required this.method});

  final VerificationMethod method;

  @override
  Widget build(BuildContext context) {
    final String reviewStatus = switch (method) {
      VerificationMethod.photo => 'AI analyzing your photos',
      VerificationMethod.agent => 'Agent assigned for physical inspection',
      VerificationMethod.warehouse => 'Warehouse verification in progress',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Verification Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('SUBMITTED'),
                subtitle: Text('10:30 AM, Jan 12'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.hourglass_bottom, color: Colors.orange),
                title: const Text('UNDER REVIEW'),
                subtitle: Text('$reviewStatus • Estimated 1-2 hours remaining'),
              ),
            ),
            const Card(
              child: ListTile(
                leading: Icon(Icons.radio_button_unchecked),
                title: Text('VERIFIED'),
                subtitle: Text('Pending completion'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const VerificationSuccessScreen(),
                  ),
                );
              },
              child: const Text('Simulate Success'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const VerificationFailedScreen(),
                  ),
                );
              },
              child: const Text('Simulate Failure'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Success')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const Icon(Icons.verified, size: 76, color: Colors.green),
          const SizedBox(height: 12),
          const Text(
            'Your Inventory is VERIFIED!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Certificate #FC-VER-235678\n'
                'Crop: Maize\n'
                'Quantity: 120 bags\n'
                'Quality Grade: A\n'
                'Moisture: 12%\n'
                'Verified by: Photo AI\n'
                'Date: Jan 12, 2026 14:30',
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AuctionFlowScreen()),
              );
            },
            child: const Text('Create Auction Now'),
          ),
        ],
      ),
    );
  }
}

class VerificationFailedScreen extends StatelessWidget {
  const VerificationFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Needs Attention')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Card(
              color: Color(0xFFFFEBEE),
              child: ListTile(
                leading: Icon(Icons.error_outline, color: Colors.red),
                title: Text('Photos unclear - cannot verify quantity'),
                subtitle: Text('Retry with clearer photos or upgrade verification.'),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const HarvestFlowScreen(),
                  ),
                );
              },
              child: const Text('Retry with New Photos'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel Request'),
            ),
          ],
        ),
      ),
    );
  }
}
