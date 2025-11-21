import '../models/alert.dart';
import 'api_client.dart';

class AlertsService {
  AlertsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Get all alerts
  Future<List<AlertModel>> fetchAlerts() async {
    try {
      final response = await _apiClient.get('/alerts');
      
      if (response['alerts'] != null) {
        final List<dynamic> alertsData = response['alerts'] as List<dynamic>;
        return alertsData
            .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        // If response is directly a list
        return (response as List<dynamic>)
            .map((json) => AlertModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      throw Exception('Error al cargar alertas: $e');
    }
  }

  /// Create a new alert
  Future<AlertModel> createAlert({
    required String title,
    required String description,
    required double latitude,
    required double longitude,
    String priority = 'MEDIA',
    String? address,
  }) async {
    try {
      final payload = {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'priority': priority,
        if (address != null) 'address': address,
      };

      final response = await _apiClient.post('/alerts', payload);
      
      if (response['alert'] != null) {
        return AlertModel.fromJson(response['alert'] as Map<String, dynamic>);
      } else {
        return AlertModel.fromJson(response);
      }
    } catch (e) {
      throw Exception('Error al crear alerta: $e');
    }
  }

  /// Update an existing alert
  Future<AlertModel> updateAlert(String alertId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/alerts/$alertId', updates);
      
      if (response['alert'] != null) {
        return AlertModel.fromJson(response['alert'] as Map<String, dynamic>);
      } else {
        return AlertModel.fromJson(response);
      }
    } catch (e) {
      throw Exception('Error al actualizar alerta: $e');
    }
  }

  /// Delete an alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _apiClient.delete('/alerts/$alertId');
    } catch (e) {
      throw Exception('Error al eliminar alerta: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
