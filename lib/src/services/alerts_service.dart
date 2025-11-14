import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/alert.dart';

class AlertsService {
  AlertsService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = AppConfig.apiBaseUrl;
  final http.Client _client;

  Future<List<AlertModel>> fetchAlerts() async {
    final uri = Uri.parse('$baseUrl/alerts');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('No se pudieron cargar las alertas');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel> createAlert(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl/alerts');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al registrar la alerta');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AlertModel.fromJson(data);
  }
}
