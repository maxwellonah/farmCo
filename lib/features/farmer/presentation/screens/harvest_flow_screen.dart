import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';
import '../../domain/verification_method.dart';
import 'verification_status_screen.dart';

class HarvestFlowScreen extends StatefulWidget {
  const HarvestFlowScreen({
    super.key,
    required this.services,
    required this.farmerId,
  });

  final AppServices services;
  final String farmerId;

  @override
  State<HarvestFlowScreen> createState() => _HarvestFlowScreenState();
}

class _HarvestFlowScreenState extends State<HarvestFlowScreen> {
  int _step = 0;
  String _crop = 'Maize';
  String _storage = 'On-farm storage';
  int _quantity = 120;
  VerificationMethod _method = VerificationMethod.agent;

  VerificationType get _verificationType => switch (_method) {
        VerificationMethod.photo => VerificationType.photo,
        VerificationMethod.agent => VerificationType.agent,
        VerificationMethod.warehouse => VerificationType.warehouse,
      };

  Future<void> _submitForVerification() async {
    final InventoryItem item = await widget.services.inventory.declareHarvest(
      farmerId: widget.farmerId,
      crop: _crop,
      quantity: _quantity.toDouble(),
      unit: 'bags',
      storageLocation: _storage,
      harvestDate: DateTime.now(),
    );

    await widget.services.inventory.updateStatus(
      inventoryId: item.id,
      status: InventoryStatus.underReview,
      verificationType: _verificationType,
    );

    await widget.services.notifications.send(
      FarmNotification(
        id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
        userId: widget.farmerId,
        type: FarmNotificationType.verificationUpdate,
        title: 'Verification submitted',
        body: 'Harvest declaration for $_crop has been submitted for review.',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VerificationStatusScreen(
          services: widget.services,
          farmerId: widget.farmerId,
          inventoryId: item.id,
          method: _method,
        ),
      ),
    );
  }

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
          _submitForVerification();
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
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Crop',
                    hintText: 'Maize, Rice, Cassava...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    if (value.trim().isEmpty) {
                      return;
                    }
                    setState(() {
                      _crop = value.trim();
                    });
                  },
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
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Current Storage',
                    hintText: 'On-farm / shed / warehouse',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (String value) {
                    if (value.trim().isEmpty) {
                      return;
                    }
                    setState(() {
                      _storage = value.trim();
                    });
                  },
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
