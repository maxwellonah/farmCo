import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

enum Stage { splash, language, role, farmerReg, farmerHome, buyer, agent, admin }
enum VerifyMethod { photo, agent, warehouse }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmConnect NG',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32))),
      home: const RootFlow(),
    );
  }
}

class RootFlow extends StatefulWidget {
  const RootFlow({super.key});
  @override
  State<RootFlow> createState() => _RootFlowState();
}

class _RootFlowState extends State<RootFlow> {
  Stage _stage = Stage.splash;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () => mounted ? setState(() => _stage = Stage.language) : null);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (_stage) {
      case Stage.splash:
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.eco, size: 90, color: Colors.white), SizedBox(height: 12), Text('FarmConnect NG', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)), SizedBox(height: 8), Text("Connecting Nigeria's Farmers to Fair Markets", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)), SizedBox(height: 16), CircularProgressIndicator(color: Colors.white)])),
          ),
        );
      case Stage.language:
        return Scaffold(
          appBar: AppBar(title: const Text('Language Selection')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Text('Language can be changed later in settings'),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: const ['English', 'Pidgin (Phase 2)', 'Hausa (Phase 2)', 'Yoruba (Phase 2)', 'Igbo (Phase 2)']
                      .map((e) => Card(child: Center(child: Text(e, textAlign: TextAlign.center))))
                      .toList(),
                ),
              ),
              FilledButton(onPressed: () => setState(() => _stage = Stage.role), child: const Text('Continue'))
            ]),
          ),
        );
      case Stage.role:
        return Scaffold(
          appBar: AppBar(title: const Text('I am a...')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Expanded(child: _roleCard(Icons.agriculture_outlined, 'FARMER', 'I want to sell my harvest', () => setState(() => _stage = Stage.farmerReg))),
              const SizedBox(height: 10),
              Expanded(child: _roleCard(Icons.apartment_outlined, 'BUYER', 'I want to buy farm produce', () => setState(() => _stage = Stage.buyer))),
              TextButton(onPressed: () => setState(() => _stage = Stage.agent), child: const Text('Verification Agent? Switch to Agent App')),
              TextButton(onPressed: () => setState(() => _stage = Stage.admin), child: const Text('Open Admin Portal Demo')),
            ]),
          ),
        );
      case Stage.farmerReg:
        return FarmerRegistration(onBack: () => setState(() => _stage = Stage.role), onDone: () => setState(() => _stage = Stage.farmerHome));
      case Stage.farmerHome:
        return FarmerHome(onLogout: () => setState(() => _stage = Stage.role));
      case Stage.buyer:
        return PlaceholderScreen(title: 'Buyer Dashboard', subtitle: 'Sourcing, bids, and order fulfillment flow scaffolded.', onBack: () => setState(() => _stage = Stage.role));
      case Stage.agent:
        return PlaceholderScreen(title: 'Agent Portal', subtitle: 'Task acceptance and field verification flow scaffolded.', onBack: () => setState(() => _stage = Stage.role));
      case Stage.admin:
        return PlaceholderScreen(title: 'Admin Dashboard', subtitle: 'Dispute, verification, and finance workflows scaffolded.', onBack: () => setState(() => _stage = Stage.role));
    }
  }

  Widget _roleCard(IconData icon, String title, String subtitle, VoidCallback onTap) => Card(
        child: InkWell(
          onTap: onTap,
          child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 70), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26)), Text(subtitle)])),
        ),
      );
}

class FarmerRegistration extends StatefulWidget {
  const FarmerRegistration({super.key, required this.onBack, required this.onDone});
  final VoidCallback onBack, onDone;
  @override
  State<FarmerRegistration> createState() => _FarmerRegistrationState();
}

class _FarmerRegistrationState extends State<FarmerRegistration> {
  int step = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Farmer Registration'), leading: IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          LinearProgressIndicator(value: (step + 1) / 4),
          const SizedBox(height: 8),
          Text('Step ${step + 1} of 4'),
          const SizedBox(height: 10),
          Expanded(
            child: step == 0
                ? ListView(children: const [TextField(decoration: InputDecoration(labelText: 'First Name *', border: OutlineInputBorder())), SizedBox(height: 8), TextField(decoration: InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder())), SizedBox(height: 8), TextField(decoration: InputDecoration(labelText: 'Phone Number (+234)', border: OutlineInputBorder()))])
                : step == 1
                    ? ListView(children: const [TextField(decoration: InputDecoration(labelText: 'Farm Name', border: OutlineInputBorder())), SizedBox(height: 8), TextField(decoration: InputDecoration(labelText: 'Farm Size', border: OutlineInputBorder())), SizedBox(height: 8), TextField(decoration: InputDecoration(labelText: 'Primary Crop', border: OutlineInputBorder()))])
                    : step == 2
                        ? ListView(children: const [TextField(decoration: InputDecoration(labelText: 'Bank', border: OutlineInputBorder())), SizedBox(height: 8), TextField(decoration: InputDecoration(labelText: 'Account Number', border: OutlineInputBorder())), SizedBox(height: 8), CheckboxListTile(value: true, onChanged: null, title: Text('Confirm this account is correct'))])
                        : const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.celebration_outlined, size: 70), SizedBox(height: 8), Text('Welcome to FarmConnect NG!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), SizedBox(height: 6), Text('Farmer ID: FC-FARMER-038472')])),
          ),
          FilledButton(onPressed: step < 3 ? () => setState(() => step++) : widget.onDone, child: Text(step < 3 ? 'Continue' : 'Go to Dashboard')),
        ]),
      ),
    );
  }
}

class FarmerHome extends StatefulWidget {
  const FarmerHome({super.key, required this.onLogout});
  final VoidCallback onLogout;
  @override
  State<FarmerHome> createState() => _FarmerHomeState();
}

class _FarmerHomeState extends State<FarmerHome> {
  int idx = 0;
  void _openHarvest() => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HarvestFlow()));
  @override
  Widget build(BuildContext context) {
    final pages = [
      ListView(padding: const EdgeInsets.all(16), children: [const Text('Good morning, Chika!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const Text("Chika's Maize Farm • Kaduna"), const Card(child: ListTile(title: Text('Total Sales'), subtitle: Text('N2,450,000'))), FilledButton(onPressed: _openHarvest, child: const Text('New Harvest Declaration'))]),
      ListView(padding: const EdgeInsets.all(16), children: [const Card(child: ListTile(title: Text('MAIZE - GRADE A'), subtitle: Text('120 bags • VERIFIED READY'))), FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AuctionFlow())), child: const Text('Create Auction'))]),
      const Center(child: Text('Wallet: N1,978,300')),
      const Center(child: Text('Market: Maize avg N25,000/bag')),
      ListView(padding: const EdgeInsets.all(16), children: [const Card(child: ListTile(title: Text('Farmer ID'), subtitle: Text('FC-FARMER-038472'))), FilledButton(onPressed: widget.onLogout, child: const Text('Logout'))]),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(const ['Dashboard', 'Inventory', 'Wallet', 'Market', 'Profile'][idx])),
      body: pages[idx],
      floatingActionButton: idx < 2 ? FloatingActionButton.extended(onPressed: _openHarvest, icon: const Icon(Icons.add), label: const Text('New Harvest')) : null,
      bottomNavigationBar: NavigationBar(selectedIndex: idx, onDestinationSelected: (v) => setState(() => idx = v), destinations: const [NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Dashboard'), NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'), NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'), NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Market'), NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile')]),
    );
  }
}

class HarvestFlow extends StatefulWidget {
  const HarvestFlow({super.key});
  @override
  State<HarvestFlow> createState() => _HarvestFlowState();
}

class _HarvestFlowState extends State<HarvestFlow> {
  int s = 0;
  int qty = 120;
  VerifyMethod method = VerifyMethod.agent;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harvest Declaration')),
      body: Stepper(
        currentStep: s,
        onStepContinue: () {
          if (s < 2) {
            setState(() => s++);
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => VerifyStatus(method: method)));
          }
        },
        onStepCancel: () => s > 0 ? setState(() => s--) : Navigator.of(context).pop(),
        controlsBuilder: (context, details) => Row(children: [FilledButton(onPressed: details.onStepContinue, child: Text(s < 2 ? 'Next' : 'Submit for Verification')), const SizedBox(width: 8), OutlinedButton(onPressed: details.onStepCancel, child: const Text('Back'))]),
        steps: [
          Step(title: const Text('What have you harvested?'), content: TextField(decoration: InputDecoration(labelText: 'Quantity (bags): $qty', border: const OutlineInputBorder()), onChanged: (v) => setState(() => qty = int.tryParse(v) ?? qty))),
          const Step(title: Text('Add verification photos'), content: Text('Take at least 3 photos: full quantity, quality close-up, and storage bags.')),
          Step(
            title: const Text('Choose verification method'),
            content: Column(children: [
              RadioListTile<VerifyMethod>(value: VerifyMethod.photo, groupValue: method, onChanged: qty <= 50 ? (v) => setState(() => method = v!) : null, title: const Text('Photo Verification (Free)')),
              RadioListTile<VerifyMethod>(value: VerifyMethod.agent, groupValue: method, onChanged: qty <= 500 ? (v) => setState(() => method = v!) : null, title: const Text('Agent Verification (N500)')),
              RadioListTile<VerifyMethod>(value: VerifyMethod.warehouse, groupValue: method, onChanged: (v) => setState(() => method = v!), title: const Text('Warehouse Verification (N1,000)')),
            ]),
          ),
        ],
      ),
    );
  }
}

class VerifyStatus extends StatelessWidget {
  const VerifyStatus({super.key, required this.method});
  final VerifyMethod method;
  @override
  Widget build(BuildContext context) {
    final status = switch (method) { VerifyMethod.photo => 'AI analyzing photos', VerifyMethod.agent => 'Agent assigned', VerifyMethod.warehouse => 'Warehouse verification in progress' };
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Card(child: ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('SUBMITTED'))),
          Card(child: ListTile(leading: const Icon(Icons.hourglass_bottom, color: Colors.orange), title: const Text('UNDER REVIEW'), subtitle: Text(status))),
          const SizedBox(height: 10),
          FilledButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AuctionFlow())), child: const Text('Simulate Success -> Create Auction')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const HarvestFlow())), child: const Text('Simulate Failure -> Retry')),
        ]),
      ),
    );
  }
}

class AuctionFlow extends StatefulWidget {
  const AuctionFlow({super.key});
  @override
  State<AuctionFlow> createState() => _AuctionFlowState();
}

class _AuctionFlowState extends State<AuctionFlow> {
  int step = 0;
  int duration = 24;
  bool agreed = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auction Creation')),
      body: Stepper(
        currentStep: step,
        onStepContinue: () => step < 2 ? setState(() => step++) : Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const LiveAuction())),
        onStepCancel: () => step > 0 ? setState(() => step--) : Navigator.of(context).pop(),
        steps: [
          const Step(title: Text('Select verified inventory'), content: Text('Maize - 120 bags (Grade A, 12% moisture)')),
          Step(title: const Text('Auction settings'), content: Wrap(spacing: 8, children: [for (final h in [12, 24, 48]) ChoiceChip(label: Text('$h h'), selected: duration == h, onSelected: (_) => setState(() => duration = h))])),
          Step(title: const Text('Review and fair price'), content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Recommended: N24,500 - N26,000 per bag'), CheckboxListTile(value: agreed, onChanged: (v) => setState(() => agreed = v ?? false), title: const Text('I agree to 3% platform fee'))])),
        ],
      ),
    );
  }
}

class LiveAuction extends StatelessWidget {
  const LiveAuction({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Auction Dashboard')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Card(child: ListTile(title: Text('Auction #FC-AU-78901 • LIVE'), subtitle: Text('Countdown: 23:45:12'))), Card(child: ListTile(title: Text('Current highest bid'), subtitle: Text('N25,700/bag • 4 bids'))), Card(child: ListTile(title: Text('Estimated value'), subtitle: Text('N3,060,000')))]),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.subtitle, required this.onBack});
  final String title, subtitle;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title), leading: IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back))), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.dashboard_customize_outlined, size: 72), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center)]))));
  }
}
