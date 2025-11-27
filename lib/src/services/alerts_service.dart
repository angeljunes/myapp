import '../models/alert.dart';
import 'api_client.dart';

class AlertsService {
  AlertsService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Get all alerts (unfiltered)
  /// Handles both List and Map responses from backend
  Future<List<AlertModel>> fetchAlerts() async {
    try {
      // Use getRaw to handle both List and Map responses
      final rawResponse = await _apiClient.getRaw('/alerts');
      
      List<dynamic> alertsData;
      
      // Case 1: Backend returns a List directly: [{...}, {...}]
      if (rawResponse is List) {
        alertsData = rawResponse;
      }
      // Case 2: Backend returns a Map with 'alerts' key: {"alerts": [...]}
      else if (rawResponse is Map<String, dynamic>) {
        if (rawResponse['alerts'] != null && rawResponse['alerts'] is List) {
          alertsData = rawResponse['alerts'] as List<dynamic>;
        }
        // Case 3: Backend returns a Map with 'data' key (from our wrapper)
        else if (rawResponse['data'] != null && rawResponse['data'] is List) {
          alertsData = rawResponse['data'] as List<dynamic>;
        }
        // Case 4: Try to find any List value in the Map
        else {
          final listValue = rawResponse.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No se encontró lista de alertas en la respuesta'),
          );
          alertsData = listValue as List<dynamic>;
        }
      }
      // Case 5: Unexpected format
      else {
        throw Exception('Formato de respuesta inválido: se esperaba List o Map, se recibió ${rawResponse.runtimeType}');
      }
      
      // Convert List<dynamic> to List<AlertModel>
      return alertsData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return AlertModel.fromJson(json);
            } else {
              throw Exception('Elemento de alerta inválido: se esperaba Map, se recibió ${json.runtimeType}');
            }
          })
          .toList();
    } catch (e) {
      throw Exception('Error al cargar alertas: $e');
    }
  }

  /// Get alerts filtered by user role:
  /// - ADMIN: sees all alerts
  /// - USER: sees only alerts from their zone
  Future<List<AlertModel>> fetchAlertsByUser(String userId) async {
    try {
      final rawResponse = await _apiClient.getRaw('/alerts/user/$userId');
      
      List<dynamic> alertsData;
      
      if (rawResponse is List) {
        alertsData = rawResponse;
      } else if (rawResponse is Map<String, dynamic>) {
        if (rawResponse['alerts'] != null && rawResponse['alerts'] is List) {
          alertsData = rawResponse['alerts'] as List<dynamic>;
        } else if (rawResponse['data'] != null && rawResponse['data'] is List) {
          alertsData = rawResponse['data'] as List<dynamic>;
        } else {
          final listValue = rawResponse.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No se encontró lista de alertas en la respuesta'),
          );
          alertsData = listValue as List<dynamic>;
        }
      } else {
        throw Exception('Formato de respuesta inválido');
      }
      
      return alertsData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return AlertModel.fromJson(json);
            } else {
              throw Exception('Elemento de alerta inválido');
            }
          })
          .toList();
    } catch (e) {
      throw Exception('Error al cargar alertas filtradas: $e');
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
    String? userId,
  }) async {
    try {
      final payload = {
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'priority': priority,
        if (address != null) 'address': address,
        if (userId != null) 'userId': userId,
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
