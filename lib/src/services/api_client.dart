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

  /// Build URI from baseUrl and endpoint, avoiding double slashes
  /// This method ensures proper URL construction without // issues
  Uri _buildUri(String endpoint) {
    // Get baseUrl and ensure it's clean - remove ALL trailing slashes
    String cleanBaseUrl = baseUrl.trim();
    while (cleanBaseUrl.endsWith('/')) {
      cleanBaseUrl = cleanBaseUrl.substring(0, cleanBaseUrl.length - 1);
    }
    
    // Remove ALL leading slashes from endpoint and trim whitespace
    String cleanEndpoint = endpoint.trim();
    while (cleanEndpoint.startsWith('/')) {
      cleanEndpoint = cleanEndpoint.substring(1);
    }
    
    // Ensure endpoint is not empty
    if (cleanEndpoint.isEmpty) {
      return Uri.parse(cleanBaseUrl);
    }
    
    // Build the complete URL string with exactly one slash between base and endpoint
    // This guarantees: baseUrl (no trailing /) + / + endpoint (no leading /) = correct URL
    final fullUrl = '$cleanBaseUrl/$cleanEndpoint';
    
    // Parse and return the URI
    return Uri.parse(fullUrl);
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

  /// GET request - returns Map or handles List responses
  Future<Map<String, dynamic>> get(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.get(uri, headers: headers);
      _handleResponse(response);
      
      final decoded = jsonDecode(response.body);
      
      // If backend returns a List, wrap it in a Map for consistency
      if (decoded is List) {
        return {'data': decoded};
      }
      
      // If it's already a Map, return it
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      
      // Fallback: wrap in a Map
      return {'data': decoded};
    } on SocketException {
      throw ApiException('No hay conexión a internet');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Error de conexión: $e');
    }
  }
  
  /// GET request that returns raw response (dynamic) - for cases where response format is unknown
  Future<dynamic> getRaw(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = _buildUri(endpoint);
      final headers = await _getHeaders(includeAuth: requireAuth);
      
      final response = await _client.get(uri, headers: headers);
      _handleResponse(response);
      
      return jsonDecode(response.body);
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
      final uri = _buildUri(endpoint);
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
      final uri = _buildUri(endpoint);
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
      final uri = _buildUri(endpoint);
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
