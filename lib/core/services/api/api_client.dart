import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiClient {
  ApiClient(this.config, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final ApiConfig config;
  final http.Client _httpClient;

  Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final Uri base = Uri.parse(config.baseUrl);
    final String normalizedPath = path.startsWith('/') ? path : '/$path';
    final String mergedPath = base.path.endsWith('/')
        ? '${base.path.substring(0, base.path.length - 1)}$normalizedPath'
        : '${base.path}$normalizedPath';

    final Map<String, String> qp = <String, String>{
      ...base.queryParameters,
      ...?queryParameters,
    };

    return base.replace(path: mergedPath, queryParameters: qp.isEmpty ? null : qp);
  }

  Map<String, String> _headers(Map<String, String>? headers) {
    return <String, String>{
      'Content-Type': 'application/json',
      ...config.defaultHeaders,
      ...?headers,
    };
  }

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path, queryParameters: queryParameters);
    final http.Response response = await _httpClient
        .get(uri, headers: _headers(headers))
        .timeout(config.requestTimeout);
    return _decodeResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path, queryParameters: queryParameters);
    final http.Response response = await _httpClient
        .post(
          uri,
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(config.requestTimeout);
    return _decodeResponse(response);
  }

  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path, queryParameters: queryParameters);
    final http.Response response = await _httpClient
        .put(
          uri,
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(config.requestTimeout);
    return _decodeResponse(response);
  }

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path, queryParameters: queryParameters);
    final http.Response response = await _httpClient
        .patch(
          uri,
          headers: _headers(headers),
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(config.requestTimeout);
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    final int status = response.statusCode;
    final String text = response.body;
    final bool isJson = response.headers['content-type']?.contains('application/json') ?? false;

    if (status < 200 || status >= 300) {
      throw ApiException(
        statusCode: status,
        message: text.isEmpty ? 'Request failed with status $status' : text,
      );
    }

    if (text.isEmpty) {
      return null;
    }

    if (isJson) {
      return jsonDecode(text);
    }
    return text;
  }

  void close() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
  });

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
