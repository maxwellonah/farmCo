import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({
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
  State<FarmerRegistrationScreen> createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  int _step = 0;
  final TextEditingController _firstNameController =
      TextEditingController(text: 'Chika');
  final TextEditingController _lastNameController =
      TextEditingController(text: 'N.');
  final TextEditingController _phoneController =
      TextEditingController(text: '+2348031234567');
  final TextEditingController _farmNameController =
      TextEditingController(text: "Chika's Maize Farm");
  final TextEditingController _farmLocationController =
      TextEditingController(text: 'Kaduna State');
  final TextEditingController _cropsController =
      TextEditingController(text: 'Maize');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _cropsController.dispose();
    super.dispose();
  }

  Future<void> _completeRegistration() async {
    await widget.services.auth.signInWithPhoneOtp(
      phoneNumber: _phoneController.text.trim(),
      otpCode: '000000',
      role: UserRole.farmer,
      displayName: '${_firstNameController.text} ${_lastNameController.text}',
    );

    await widget.services.profiles.saveFarmerProfile(
      FarmerProfile(
        userId: widget.userId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        farmerId: 'FC-FARMER-038472',
        farmName: _farmNameController.text.trim(),
        location: _farmLocationController.text.trim(),
        primaryCrops: _cropsController.text
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
        title: const Text('Farmer Registration'),
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
            Expanded(child: _stepBody()),
            FilledButton(
              onPressed: _step < 3
                  ? () {
                      setState(() {
                        _step += 1;
                      });
                    }
                  : _completeRegistration,
              child: Text(_step < 3 ? 'Continue' : 'Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepBody() {
    if (_step == 0) {
      return ListView(
        children: <Widget>[
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: 'First Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: 'Last Name *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number (+234) *',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    }
    if (_step == 1) {
      return ListView(
        children: <Widget>[
          const Text(
            'Tell us about your farm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _farmNameController,
            decoration: InputDecoration(
              labelText: 'Farm Name/Nickname',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _farmLocationController,
            decoration: InputDecoration(
              labelText: 'Farm Location',
              hintText: 'Use my location / select on map',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cropsController,
            decoration: InputDecoration(
              labelText: 'Primary Crops',
              hintText: 'Maize, Rice, Cassava...',
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
            'Set up payments',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Bank',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Account Number',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'BVN (Optional)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          CheckboxListTile(
            value: true,
            onChanged: null,
            title: Text('Confirm this account is correct'),
          ),
        ],
      );
    }
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.celebration_outlined, size: 72),
          SizedBox(height: 12),
          Text(
            'Welcome to FarmConnect NG!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text('Farmer ID: FC-FARMER-038472'),
        ],
      ),
    );
  }
}
