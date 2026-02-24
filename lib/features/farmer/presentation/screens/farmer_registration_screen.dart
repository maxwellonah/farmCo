import 'package:flutter/material.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<FarmerRegistrationScreen> createState() => _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  int _step = 0;

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
                  : widget.onComplete,
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
        children: const <Widget>[
          Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'First Name *',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Middle Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Last Name *',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
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
        children: const <Widget>[
          Text(
            'Tell us about your farm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Farm Name/Nickname',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Farm Location',
              hintText: 'Use my location / select on map',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              labelText: 'Farm Size',
              hintText: 'Acres or Hectares',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8),
          TextField(
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
