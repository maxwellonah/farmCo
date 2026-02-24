import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class AgentOnboardingScreen extends StatefulWidget {
  const AgentOnboardingScreen({
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
  State<AgentOnboardingScreen> createState() => _AgentOnboardingScreenState();
}

class _AgentOnboardingScreenState extends State<AgentOnboardingScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Onboarding'),
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 3) {
            setState(() {
              _step += 1;
            });
            return;
          }
          _completeOnboarding();
        },
        onStepCancel: () {
          if (_step == 0) {
            widget.onBack();
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
                onPressed: details.onStepContinue,
                child: Text(_step < 3 ? 'Continue' : 'Finish Onboarding'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
            ],
          );
        },
        steps: const <Step>[
          Step(
            title: Text('Complete Profile'),
            content: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: 'Coverage Area (LGA)', border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(labelText: 'Bank Details', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Training Modules'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Module 1: Ethics and conduct'),
                Text('Module 2: Verification checklist'),
                Text('Module 3: App usage'),
                Text('Module 4: Offline mode'),
                Text('Module 5: Dispute evidence handling'),
                SizedBox(height: 8),
                Text('Each quiz requires >80% pass score'),
              ],
            ),
          ),
          Step(
            title: Text('Equipment Check'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Camera test')),
                ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('GPS accuracy test')),
                ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Offline mode sync test')),
              ],
            ),
          ),
          Step(
            title: Text('Contract Signing'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Digital agreement and code of conduct'),
                Text('Commission structure acknowledgement'),
                CheckboxListTile(value: true, onChanged: null, title: Text('I agree to terms')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    await widget.services.profiles.saveAgentProfile(
      AgentProfile(
        userId: widget.userId,
        fullName: 'Tunde A.',
        agentId: 'FC-AGENT-0092',
        coverageArea: const <String>['Kaduna North', 'Kaduna South'],
        vehicleType: 'Bike',
        rating: 4.9,
        createdAt: DateTime.now(),
      ),
    );

    if (!mounted) {
      return;
    }
    widget.onComplete();
  }
}
