class ApiConfig {
  const ApiConfig({
    required this.baseUrl,
    this.defaultHeaders = const <String, String>{},
    this.requestTimeout = const Duration(seconds: 15),
    this.pollInterval = const Duration(seconds: 5),
  });

  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration requestTimeout;
  final Duration pollInterval;
}
