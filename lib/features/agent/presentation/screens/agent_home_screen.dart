import 'package:flutter/material.dart';

class AgentHomeScreen extends StatefulWidget {
  const AgentHomeScreen({super.key, required this.onLogout});

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
      const _AgentDashboardTab(),
      const _AgentTasksTab(),
      const _AssistedRegistrationTab(),
      _AgentEarningsTab(onLogout: widget.onLogout),
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
  const _AgentDashboardTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('Today\'s Earnings'),
            subtitle: Text('N3,500'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Tasks Completed'),
            subtitle: Text('7/10 • Rating 4.9/5'),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Pending Tasks'),
            subtitle: Text('3 tasks in queue'),
          ),
        ),
        Card(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AgentTaskExecutionScreen(),
                ),
              );
            },
            child: const ListTile(
              title: Text('Task Map View'),
              subtitle: Text('Open interactive task execution flow'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ],
    );
  }
}

class _AgentTasksTab extends StatelessWidget {
  const _AgentTasksTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('VERIFICATION TASK #VT-78901'),
            subtitle: Text('Farmer: Chika N. • Crop: Maize • 120 bags • Fee N500'),
          ),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AgentTaskExecutionScreen(),
              ),
            );
          },
          child: const Text('Accept Task & Start'),
        ),
      ],
    );
  }
}

class AgentTaskExecutionScreen extends StatefulWidget {
  const AgentTaskExecutionScreen({super.key});

  @override
  State<AgentTaskExecutionScreen> createState() => _AgentTaskExecutionScreenState();
}

class _AgentTaskExecutionScreenState extends State<AgentTaskExecutionScreen> {
  int _step = 0;

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
          showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Certificate Generated'),
              content: const Text('Certificate #FC-VER-235678 submitted to platform.'),
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
            content: Text('Google Maps/OSM route, ETA tracking, contact farmer button.'),
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
  const _AssistedRegistrationTab();

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
  const _AgentEarningsTab({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const Card(
          child: ListTile(
            title: Text('Earnings Breakdown'),
            subtitle: Text(
              'Verification: N500 x 7 = N3,500\n'
              'Assisted registrations: N200 x 2 = N400\n'
              'Quality bonus: N300\n'
              'Total: N4,200',
            ),
          ),
        ),
        const Card(
          child: ListTile(
            title: Text('Performance Metrics'),
            subtitle: Text('Completion rate 98% • Accuracy 4.9/5 • Avg task time 52 min'),
          ),
        ),
        FilledButton(
          onPressed: onLogout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
