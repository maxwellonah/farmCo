import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class BuyerOnboardingScreen extends StatefulWidget {
  const BuyerOnboardingScreen({
    super.key,
    required this.services,
    required this.userId,
    required this.onBack,
    required this.onComplete,
  });

  final AppServices services;
  final String userId;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<BuyerOnboardingScreen> createState() => _BuyerOnboardingScreenState();
}

class _BuyerOnboardingScreenState extends State<BuyerOnboardingScreen> {
  int _step = 0;
  String _businessType = 'Processor';
  final TextEditingController _companyController =
      TextEditingController(text: 'Green Mills');
  final TextEditingController _phoneController =
      TextEditingController(text: '+2348030000001');
  final TextEditingController _regionsController =
      TextEditingController(text: 'Kaduna, Lagos');
  final TextEditingController _cropsController =
      TextEditingController(text: 'Maize, Rice');

  @override
  void dispose() {
    _companyController.dispose();
    _phoneController.dispose();
    _regionsController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.services.auth.signInWithCredentials(
      username: _phoneController.text.trim(),
      password: 'demo-password',
      role: UserRole.buyer,
      displayName: _companyController.text.trim(),
    );

    await widget.services.profiles.saveBuyerProfile(
      BuyerProfile(
        userId: widget.userId,
        companyName: _companyController.text.trim(),
        businessType: _businessType,
        contactPhone: _phoneController.text.trim(),
        regions: _regionsController.text
            .split(',')
            .map((String value) => value.trim())
            .where((String value) => value.isNotEmpty)
            .toList(),
        preferredCrops: _cropsController.text
            .split(',')
            .map((String value) => value.trim())
            .where((String value) => value.isNotEmpty)
            .toList(),
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }
    widget.onComplete();
  }

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
                  : _completeOnboarding,
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
            children: <String>[
              'Processor',
              'Trader',
              'Exporter',
              'Retail Aggregator',
              'Institutional',
            ]
                .map(
                  (String type) => ChoiceChip(
                    label: Text(type),
                    selected: _businessType == type,
                    onSelected: (_) {
                      setState(() {
                        _businessType = type;
                      });
                    },
                  ),
                )
                .toList(),
          ),
        ],
      );
    }
    if (_step == 1) {
      return ListView(
        children: <Widget>[
          const Text(
            'Business Verification',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _companyController,
            decoration: InputDecoration(
              labelText: 'Company Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'RC Number / Registration',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Tax Identification Number',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
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
        children: <Widget>[
          const Text(
            'Volume & Requirements',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Monthly Purchase Volume (tons)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cropsController,
            decoration: InputDecoration(
              labelText: 'Preferred Crops',
              hintText: 'Maize, Rice, Cassava...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _regionsController,
            decoration: InputDecoration(
              labelText: 'Regions of Operation',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Quality Standards Required',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    return ListView(
      children: <Widget>[
        const Text(
          'Team Members',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Purchasing Manager Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Role & Permission',
            hintText: 'Bid only / Full order approval',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Ready to start sourcing'),
            subtitle: Text('You can now browse and bid on auctions'),
          ),
        ),
      ],
    );
  }
}
