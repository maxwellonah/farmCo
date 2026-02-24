import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({
    super.key,
    required this.services,
    required this.agentId,
    required this.onLogout,
  });

  final AppServices services;
  final String agentId;
  final VoidCallback onLogout;

  @override
  State<AgentHomeScreen> createState() => _AgentHomeScreenState();
}

class _AgentHomeScreenState extends State<AgentHomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const List<String> titles = <String>[
      'Agent Home',
      'Tasks',
      'Assist Registration',
      'Earnings',
    ];

    final List<Widget> pages = <Widget>[
      _AgentDashboardTab(
        services: widget.services,
        agentId: widget.agentId,
      ),
      _AgentTasksTab(
        services: widget.services,
        agentId: widget.agentId,
      ),
      _AssistedRegistrationTab(
        services: widget.services,
      ),
      _AgentEarningsTab(
        services: widget.services,
        agentId: widget.agentId,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.app_registration_outlined), label: 'Assist'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Earnings'),
        ],
      ),
    );
  }
}

class _AgentDashboardTab extends StatelessWidget {
  const _AgentDashboardTab({
    required this.services,
    required this.agentId,
  });

  final AppServices services;
  final String agentId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(agentId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final double available = snapshot.data?.available ?? 0;
            return Card(
              child: ListTile(
                title: const Text('Today\'s Earnings'),
                subtitle: Text('N${available.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<List<InventoryItem>>(
          stream: services.inventory.watchAllInventory(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<InventoryItem>> snapshot,
          ) {
            final List<InventoryItem> all = snapshot.data ?? <InventoryItem>[];
            final int pending = all
                .where((InventoryItem item) => item.status == InventoryStatus.underReview)
                .length;
            final int verified = all
                .where((InventoryItem item) => item.status == InventoryStatus.verifiedReady)
                .length;
            return Card(
              child: ListTile(
                title: const Text('Verification Metrics'),
                subtitle: Text('Pending tasks: $pending • Verified today: $verified'),
              ),
            );
          },
        ),
        Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AgentTaskExecutionScreen(
                    services: services,
                    agentId: agentId,
                  ),
                ),
              );
            },
            child: const ListTile(
              title: Text('Task Map View'),
              subtitle: Text('Open task execution flow'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentTasksTab extends StatelessWidget {
  const _AgentTasksTab({
    required this.services,
    required this.agentId,
  });

  final AppServices services;
  final String agentId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<InventoryItem>>(
      stream: services.inventory.watchAllInventory(),
      builder: (BuildContext context, AsyncSnapshot<List<InventoryItem>> snapshot) {
        final List<InventoryItem> tasks = (snapshot.data ?? <InventoryItem>[])
            .where((InventoryItem item) => item.status == InventoryStatus.underReview)
            .toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            if (tasks.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('No pending verification tasks'),
                  subtitle: Text('New tasks will appear here.'),
                ),
              )
            else
              ...tasks.map(
                (InventoryItem item) => Card(
                  child: ListTile(
                    title: Text('TASK ${item.id}'),
                    subtitle: Text(
                      'Farmer: ${item.farmerId} • Crop: ${item.crop} • Qty: ${item.quantity.toStringAsFixed(0)}',
                    ),
                    trailing: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => AgentTaskExecutionScreen(
                              services: services,
                              agentId: agentId,
                              taskInventoryId: item.id,
                              farmerId: item.farmerId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Accept'),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class AgentTaskExecutionScreen extends StatefulWidget {
  const AgentTaskExecutionScreen({
    super.key,
    required this.services,
    required this.agentId,
    this.taskInventoryId,
    this.farmerId,
  });

  final AppServices services;
  final String agentId;
  final String? taskInventoryId;
  final String? farmerId;

  @override
  State<AgentTaskExecutionScreen> createState() => _AgentTaskExecutionScreenState();
}

class _AgentTaskExecutionScreenState extends State<AgentTaskExecutionScreen> {
  int _step = 0;

  Future<void> _completeTask() async {
    if (widget.taskInventoryId != null) {
      await widget.services.inventory.updateStatus(
        inventoryId: widget.taskInventoryId!,
        status: InventoryStatus.verifiedReady,
        verificationType: VerificationType.agent,
      );
    }
    await widget.services.wallet.credit(
      userId: widget.agentId,
      amount: 500,
      reference: 'verification-task-${widget.taskInventoryId ?? 'manual'}',
    );
    if (widget.farmerId != null) {
      await widget.services.notifications.send(
        FarmNotification(
          id: 'notif-${DateTime.now().microsecondsSinceEpoch}',
          userId: widget.farmerId!,
          type: FarmNotificationType.verificationUpdate,
          title: 'Agent verification complete',
          body: 'Your inventory has been verified by an agent.',
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    }

    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Certificate Generated'),
        content: const Text('Certificate submitted to platform.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verification Task Execution')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 3) {
            setState(() {
              _step += 1;
            });
            return;
          }
          _completeTask();
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
        steps: const <Step>[
          Step(
            title: Text('Task Acceptance'),
            content: Text('Estimated travel: 25 min • Task time: 45 min • Total: 1h10m'),
          ),
          Step(
            title: Text('Navigation to Farm'),
            content: Text('Route, ETA tracking, contact farmer button.'),
          ),
          Step(
            title: Text('Verification Checklist'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('1. Identity Verification'),
                Text('2. Quantity Verification'),
                Text('3. Quality Assessment'),
                Text('4. Storage Condition'),
                Text('5. Signature Capture'),
              ],
            ),
          ),
          Step(
            title: Text('Certificate Generation'),
            content: Text('Generate digital certificate with QR code and submit.'),
          ),
        ],
      ),
    );
  }
}

class _AssistedRegistrationTab extends StatelessWidget {
  const _AssistedRegistrationTab({required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('Assist New Farmer Registration'),
            subtitle: Text('Biometric capture, OTP, farm details, bank setup'),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AssistedRegistrationFlowScreen(),
              ),
            );
          },
          child: const Text('Start Assisted Registration'),
        ),
      ],
    );
  }
}

class AssistedRegistrationFlowScreen extends StatefulWidget {
  const AssistedRegistrationFlowScreen({super.key});

  @override
  State<AssistedRegistrationFlowScreen> createState() => _AssistedRegistrationFlowScreenState();
}

class _AssistedRegistrationFlowScreenState extends State<AssistedRegistrationFlowScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assisted Registration')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () {
          if (_step < 2) {
            setState(() {
              _step += 1;
            });
            return;
          }
          Navigator.of(context).pop();
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
        steps: const <Step>[
          Step(
            title: Text('Capture & Setup'),
            content: Text('Biometric capture, OTP verification, farm profile, bank setup.'),
          ),
          Step(
            title: Text('Credential Delivery'),
            content: Text('SMS confirmation and optional printed farmer ID card.'),
          ),
          Step(
            title: Text('Post Registration Options'),
            content: Text('Start verification, schedule training, add to cooperative.'),
          ),
        ],
      ),
    );
  }
}

class _AgentEarningsTab extends StatelessWidget {
  const _AgentEarningsTab({
    required this.services,
    required this.agentId,
    required this.onLogout,
  });

  final AppServices services;
  final String agentId;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        StreamBuilder<WalletBalance>(
          stream: services.wallet.watchBalance(agentId),
          builder: (BuildContext context, AsyncSnapshot<WalletBalance> snapshot) {
            final WalletBalance balance = snapshot.data ??
                WalletBalance(
                  userId: agentId,
                  available: 0,
                  inEscrow: 0,
                  updatedAt: DateTime.now(),
                );
            return Card(
              child: ListTile(
                title: const Text('Available Earnings'),
                subtitle: Text('N${balance.available.toStringAsFixed(0)}'),
              ),
            );
          },
        ),
        StreamBuilder<List<WalletTransaction>>(
          stream: services.wallet.watchTransactions(agentId),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<WalletTransaction>> snapshot,
          ) {
            final int taskCredits = (snapshot.data ?? <WalletTransaction>[])
                .where((WalletTransaction txn) =>
                    txn.type == WalletTransactionType.credit &&
                    txn.reference.startsWith('verification-task'))
                .length;
            return Card(
              child: ListTile(
                title: const Text('Performance Metrics'),
                subtitle: Text('Completed paid tasks: $taskCredits'),
              ),
            );
          },
        ),
        FilledButton(
          onPressed: onLogout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
