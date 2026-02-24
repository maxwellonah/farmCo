import 'package:flutter/material.dart';

import '../../domain/verification_method.dart';
import 'verification_status_screen.dart';

class HarvestFlowScreen extends StatefulWidget {
  const HarvestFlowScreen({super.key});

  @override
  State<HarvestFlowScreen> createState() => _HarvestFlowScreenState();
}

class _HarvestFlowScreenState extends State<HarvestFlowScreen> {
  int _step = 0;
  int _quantity = 120;
  VerificationMethod _method = VerificationMethod.agent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harvest Declaration')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 2) {
            setState(() {
              _step += 1;
            });
            return;
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => VerificationStatusScreen(method: _method),
            ),
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
                onPressed: details.onStepContinue,
                child: Text(_step < 2 ? 'Next' : 'Submit for Verification'),
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
            title: const Text('What have you harvested?'),
            content: Column(
              children: <Widget>[
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Crop',
                    hintText: 'Maize, Rice, Cassava...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Quantity (bags)',
                    border: const OutlineInputBorder(),
                    hintText: _quantity.toString(),
                  ),
                  onChanged: (String value) {
                    final int? parsed = int.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return;
                    }
                    setState(() {
                      _quantity = parsed;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Current Storage',
                    hintText: 'On-farm / shed / warehouse',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const Step(
            title: Text('Add verification photos'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Take at least 3 clear photos showing:'),
                Text('1. Full bulk quantity'),
                Text('2. Close-up sample quality'),
                Text('3. Storage bags/containers'),
              ],
            ),
          ),
          Step(
            title: const Text('Choose verification'),
            content: Column(
              children: <Widget>[
                RadioListTile<VerificationMethod>(
                  value: VerificationMethod.photo,
                  groupValue: _method,
                  onChanged: _quantity <= 50
                      ? (VerificationMethod? method) {
                          if (method == null) {
                            return;
                          }
                          setState(() {
                            _method = method;
                          });
                        }
                      : null,
                  title: const Text('Photo Verification (Free)'),
                  subtitle: Text(
                    _quantity <= 50
                        ? '2-4 hours'
                        : 'Unavailable for quantity > 50 bags',
                  ),
                ),
                RadioListTile<VerificationMethod>(
                  value: VerificationMethod.agent,
                  groupValue: _method,
                  onChanged: _quantity <= 500
                      ? (VerificationMethod? method) {
                          if (method == null) {
                            return;
                          }
                          setState(() {
                            _method = method;
                          });
                        }
                      : null,
                  title: const Text('Agent Verification (N500)'),
                  subtitle: Text(
                    _quantity <= 500
                        ? '24-48 hours'
                        : 'Unavailable for quantity > 500 bags',
                  ),
                ),
                RadioListTile<VerificationMethod>(
                  value: VerificationMethod.warehouse,
                  groupValue: _method,
                  onChanged: (VerificationMethod? method) {
                    if (method == null) {
                      return;
                    }
                    setState(() {
                      _method = method;
                    });
                  },
                  title: const Text('Warehouse Verification (N1,000+)'),
                  subtitle: const Text('4-6 hours'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
