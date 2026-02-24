import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';
import '../../domain/verification_method.dart';
import 'auction_flow_screen.dart';
import 'harvest_flow_screen.dart';

class VerificationStatusScreen extends StatelessWidget {
  const VerificationStatusScreen({
    super.key,
    required this.services,
    required this.farmerId,
    required this.inventoryId,
    required this.method,
  });

  final AppServices services;
  final String farmerId;
  final String inventoryId;
  final VerificationMethod method;

  VerificationType get _verificationType => switch (method) {
        VerificationMethod.photo => VerificationType.photo,
        VerificationMethod.agent => VerificationType.agent,
        VerificationMethod.warehouse => VerificationType.warehouse,
      };

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
              onPressed: () async {
                await services.inventory.updateStatus(
                  inventoryId: inventoryId,
                  status: InventoryStatus.verifiedReady,
                  verificationType: _verificationType,
                );
                await services.notifications.send(
                  FarmNotification(
                    id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
                    userId: farmerId,
                    type: FarmNotificationType.verificationUpdate,
                    title: 'Inventory Verified',
                    body: 'Your inventory has been verified successfully.',
                    createdAt: DateTime.now(),
                    isRead: false,
                  ),
                );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerificationSuccessScreen(
                      services: services,
                      farmerId: farmerId,
                      inventoryId: inventoryId,
                    ),
                  ),
                );
              },
              child: const Text('Simulate Success'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                await services.inventory.updateStatus(
                  inventoryId: inventoryId,
                  status: InventoryStatus.unverified,
                  verificationType: _verificationType,
                );
                if (!context.mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VerificationFailedScreen(
                      services: services,
                      farmerId: farmerId,
                    ),
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
  const VerificationSuccessScreen({
    super.key,
    required this.services,
    required this.farmerId,
    required this.inventoryId,
  });

  final AppServices services;
  final String farmerId;
  final String inventoryId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Success')),
      body: FutureBuilder<InventoryItem?>(
        future: services.inventory.getById(inventoryId),
        builder: (BuildContext context, AsyncSnapshot<InventoryItem?> snapshot) {
          final InventoryItem? item = snapshot.data;
          return ListView(
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Certificate #FC-VER-235678\n'
                    'Crop: ${item?.crop ?? 'Unknown'}\n'
                    'Quantity: ${item?.quantity.toStringAsFixed(0) ?? '0'} ${item?.unit ?? 'bags'}\n'
                    'Quality Grade: A\n'
                    'Moisture: 12%\n'
                    'Verified by: ${item?.verificationType.name ?? 'photo'}\n'
                    'Date: ${DateTime.now().toLocal()}',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => AuctionFlowScreen(
                        services: services,
                        farmerId: farmerId,
                        inventoryId: inventoryId,
                        crop: item?.crop ?? 'Maize',
                        quantity: item?.quantity ?? 0,
                      ),
                    ),
                  );
                },
                child: const Text('Create Auction Now'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class VerificationFailedScreen extends StatelessWidget {
  const VerificationFailedScreen({
    super.key,
    required this.services,
    required this.farmerId,
  });

  final AppServices services;
  final String farmerId;

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
                    builder: (_) => HarvestFlowScreen(
                      services: services,
                      farmerId: farmerId,
                    ),
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
