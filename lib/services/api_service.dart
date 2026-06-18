/// Base API service with HTTP client configuration.
/// Centralizes the base URL and common HTTP operations.
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  /// Auto-detect the correct host:
  /// - Android emulator: 10.0.2.2 (maps to host localhost)
  /// - Web / Desktop / iOS simulator: localhost
  /// - Physical device: change to your computer's IP (e.g. 192.168.x.x)
  static String get _host {
    return '10.40.57.241';
  }

  static String get baseUrl => 'http://$_host:8000/api';

  final http.Client _client = http.Client();

  /// GET request
  Future<dynamic> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  /// POST request
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// PUT request
  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// DELETE request
  Future<dynamic> delete(String endpoint) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  /// Handle HTTP response and errors
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final body = jsonDecode(response.body);
      final detail = body['detail'] ?? 'Error desconocido';
      throw ApiException(
        statusCode: response.statusCode,
        message: detail is String ? detail : jsonEncode(detail),
      );
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
