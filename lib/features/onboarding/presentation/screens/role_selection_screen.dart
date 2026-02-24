import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({
    super.key,
    required this.onFarmerSelected,
    required this.onBuyerSelected,
    required this.onAgentSelected,
    required this.onAdminSelected,
  });

  final VoidCallback onFarmerSelected;
  final VoidCallback onBuyerSelected;
  final VoidCallback onAgentSelected;
  final VoidCallback onAdminSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('I am a...')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _RoleCard(
                icon: Icons.agriculture_outlined,
                title: 'FARMER',
                subtitle: 'I want to sell my harvest',
                onTap: onFarmerSelected,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _RoleCard(
                icon: Icons.apartment_outlined,
                title: 'BUYER',
                subtitle: 'I want to buy farm produce',
                onTap: onBuyerSelected,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: onAgentSelected,
              child: const Text('Verification Agent? Switch to Agent App'),
            ),
            TextButton(
              onPressed: onAdminSelected,
              child: const Text('Open Admin Portal Demo'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 72),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
