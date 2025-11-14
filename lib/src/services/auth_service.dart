import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'http://localhost:8081/api';
  static const String tokenKey = 'rcas_token';

  final http.Client _client;

  Future<AppUser> login(String identity, String password) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'identity': identity,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true || data['user'] == null) {
      throw Exception(data['error'] ?? 'Credenciales inválidas');
    }

    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, user.id);
    return user;
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String role,
    required String zone,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
        'role': role,
        'zone': zone,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al registrarse: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['success'] != true || data['userId'] == null) {
      throw Exception(data['error'] ?? 'No se pudo registrar');
    }

    final user = AppUser(
      id: data['userId'].toString(),
      fullName: fullName,
      email: email,
      username: username,
      role: role,
      zone: zone,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, user.id);
    return user;
  }

  Future<AppUser> getProfile(String token) async {
    final uri = Uri.parse('$baseUrl/auth/user/$token');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('No se pudo obtener el perfil');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AppUser.fromJson(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}
