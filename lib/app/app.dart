import 'package:flutter/material.dart';

import '../core/services/app_services.dart';
import 'root_flow.dart';

class FarmConnectApp extends StatefulWidget {
  const FarmConnectApp({super.key});

  @override
  State<FarmConnectApp> createState() => _FarmConnectAppState();
}

class _FarmConnectAppState extends State<FarmConnectApp> {
  late final AppServices _services;

  @override
  void initState() {
    super.initState();
    _services = AppServices.inMemory();
  }

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
      home: RootFlow(services: _services),
    );
  }
}
