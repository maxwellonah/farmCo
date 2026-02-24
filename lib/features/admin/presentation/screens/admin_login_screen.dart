import 'package:flutter/material.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({
    super.key,
    required this.onBack,
    required this.onLogin,
  });

  final VoidCallback onBack;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Portal Login'),
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
                labelText: 'Email / Username',
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
            const TextField(
              decoration: InputDecoration(
                labelText: '2FA Code',
                hintText: '6-digit code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onLogin,
              child: const Text('Login to Admin Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
