import 'package:flutter/material.dart';

import 'root_flow.dart';

class FarmConnectApp extends StatelessWidget {
  const FarmConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmConnect NG',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF6F9F5),
      ),
      home: const RootFlow(),
    );
  }
}
