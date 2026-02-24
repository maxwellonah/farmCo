import 'package:flutter/material.dart';

import '../core/services/app_services.dart';
import '../core/services/api/api_config.dart';
import 'root_flow.dart';

class FarmConnectApp extends StatefulWidget {
  const FarmConnectApp({super.key});

  @override
  State<FarmConnectApp> createState() => _FarmConnectAppState();
}

class _FarmConnectAppState extends State<FarmConnectApp> {
  static const bool _useInMemory = bool.fromEnvironment(
    'FARMCONNECT_USE_IN_MEMORY',
    defaultValue: false,
  );
  static const String _apiBaseUrl = String.fromEnvironment(
    'FARMCONNECT_API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );

  late final AppServices _services;

  @override
  void initState() {
    super.initState();
    _services = _useInMemory
        ? AppServices.inMemory()
        : AppServices.api(
            config: const ApiConfig(
              baseUrl: _apiBaseUrl,
              defaultHeaders: <String, String>{
                'x-client-platform': 'flutter',
              },
            ),
          );
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
