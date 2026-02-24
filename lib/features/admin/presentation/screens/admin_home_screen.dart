import 'package:flutter/material.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: <Widget>[
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Tab>[
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'Disputes'),
              Tab(text: 'Verification'),
              Tab(text: 'Finance'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            _OverviewTab(),
            _UsersTab(),
            _DisputesTab(),
            _VerificationTab(),
            _FinanceTab(),
            _AnalyticsTab(),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Total GMV Today'),
            subtitle: Text('N42,500,000'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Active Auctions'),
            subtitle: Text('1,247'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('New Farmers Today'),
            subtitle: Text('143'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Dispute Rate'),
            subtitle: Text('1.2%'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Alert Panel'),
            subtitle: Text(
              '3 high-priority disputes\n'
              'Payment gateway latency detected\n'
              'Agent network: 98% active',
            ),
          ),
        ),
      ],
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('User Management'),
            subtitle: Text('Tabs: Farmers, Buyers, Agents, Suspended'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Search & Filters'),
            subtitle: Text('Region, volume, rating, fraud risk, activity status'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Bulk Actions'),
            subtitle: Text('Verify in bulk, send notification, export CSV, assign to agent'),
          ),
        ),
      ],
    );
  }
}

class _DisputesTab extends StatelessWidget {
  const _DisputesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('DISPUTE #DP-78901 - HIGH PRIORITY'),
            subtitle: Text(
              'Farmer Chika N. vs Buyer Green Mills\n'
              'Issue: Short delivery by 2 bags\n'
              'Amount: N51,000 • Age: 2 hours',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Resolution Tools'),
            subtitle: Text(
              'Partial refund calculator, penalty points,\n'
              'third-party assessor assignment, final ruling templates',
            ),
          ),
        ),
      ],
    );
  }
}

class _VerificationTab extends StatelessWidget {
  const _VerificationTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Verification Monitor'),
            subtitle: Text(
              'Photo verifications pending: 47\n'
              'Agent verifications in progress: 23\n'
              'Fraud detection alerts: 2',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Agent Performance'),
            subtitle: Text('Accuracy, completion time, farmer satisfaction, coverage'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Fraud Detection Panel'),
            subtitle: Text('Duplicate photos, GPS spoofing, collusion alerts'),
          ),
        ),
      ],
    );
  }
}

class _FinanceTab extends StatelessWidget {
  const _FinanceTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Daily Reconciliation'),
            subtitle: Text(
              'Total transactions: N42.5M\n'
              'Platform fees: N1.275M\n'
              'Verification fees: N235,000\n'
              'Escrow balance: N18.7M',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Payout Processing'),
            subtitle: Text('Batch farmer payouts, agent commissions, settlement reports'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Audit Log'),
            subtitle: Text('Every financial action logged with user, IP, timestamp'),
          ),
        ),
      ],
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const <Widget>[
        Card(
          child: ListTile(
            title: Text('Platform Metrics'),
            subtitle: Text(
              'Farmer acquisition cost: N320\n'
              'Farmer lifetime value: N8,500\n'
              'Buyer retention rate: 78%',
            ),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Predictive Analytics'),
            subtitle: Text('Price forecasts, demand prediction, fraud probability, churn risk'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Report Generator'),
            subtitle: Text('Custom ranges, exports, scheduled reports, BI API access'),
          ),
        ),
      ],
    );
  }
}
