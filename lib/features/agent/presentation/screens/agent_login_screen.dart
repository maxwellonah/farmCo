import 'package:flutter/material.dart';

import '../../../../core/domain/domain.dart';
import '../../../../core/services/app_services.dart';

class AgentLoginScreen extends StatelessWidget {
  const AgentLoginScreen({
    super.key,
    required this.services,
    required this.userId,
    required this.onBack,
    required this.onLogin,
    required this.onQuickEnter,
  });

  final AppServices services;
  final String userId;
  final VoidCallback onBack;
  final VoidCallback onLogin;
  final VoidCallback onQuickEnter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FarmConnect Agent Portal'),
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const TextField(
              decoration: InputDecoration(
                labelText: 'Agent ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                await services.auth.signInWithCredentials(
                  username: userId,
                  password: 'demo-password',
                  role: UserRole.agent,
                  displayName: 'Tunde A.',
                );
                onLogin();
              },
              child: const Text('Login & Start Onboarding'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                await services.auth.signInWithCredentials(
                  username: userId,
                  password: 'demo-password',
                  role: UserRole.agent,
                  displayName: 'Tunde A.',
                );
                onQuickEnter();
              },
              child: const Text('Quick Enter Existing Agent'),
            ),
            const SizedBox(height: 8),
            const ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric login option available'),
            ),
          ],
        ),
      ),
    );
  }
}
