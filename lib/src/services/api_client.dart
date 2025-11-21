import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = AppConfig.apiBaseUrl;
  static const String tokenKey = AppConfig.tokenKey;

  final http.Client _client;

  /// Normalize URL to avoid double slashes
  String _normalizeUrl(String baseUrl, String endpoint) {
    // Remove trailing slash from baseUrl
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    // Ensure endpoint starts with /
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$cleanBaseUrl$cleanEndpoint';
  }

  /// Get stored JWT token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Store JWT token
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Remove stored token
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  /// Get headers with authorization if token exists
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// Handle HTTP response and check for authentication errors
  void _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // Token expired or invalid, remove it
      _removeToken();
      throw ApiException('Token expirado. Por favor, inicia sesión nuevamente.', 401);
    }

    if (response.statusCode >= 400) {
      String message = 'Error del servidor';
      try {
        final data = jsonDecode(response.body);
        message = data['message'] ?? data['error'] ?? message;
      } catch (_) {
        // If we can't parse the error, use status code
        message = 'Error ${response.statusCode}';
      }
      throw ApiException(message, response.statusCode);
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse(_normalizeUrl(baseUrl, endpoint));
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.get(uri, headers: headers);
      _handleResponse(response);
      
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('No hay conexión a internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_normalizeUrl(baseUrl, endpoint));
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.post(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      _handleResponse(response);
      
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('No hay conexión a internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      final uri = Uri.parse(_normalizeUrl(baseUrl, endpoint));
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.put(
        uri,
        headers: headers,
        body: jsonEncode(data),
      );
      _handleResponse(response);
      
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('No hay conexión a internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse(_normalizeUrl(baseUrl, endpoint));
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.delete(uri, headers: headers);
      _handleResponse(response);
      
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on SocketException {
      throw ApiException('No hay conexión a internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }

  /// Login and store token
  Future<Map<String, dynamic>> login(String identity, String password) async {
    final response = await post('/auth/login', {
      'identity': identity,
      'password': password,
    }, requireAuth: false);

    // Store the JWT token from response
    if (response['token'] != null) {
      await _storeToken(response['token']);
    }

    return response;
  }

  /// Logout and remove token
  Future<void> logout() async {
    await _removeToken();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }

  /// Get current token
  Future<String?> getToken() async {
    return _getToken();
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
