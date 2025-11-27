import '../models/country.dart';
import '../models/city.dart';
import 'api_client.dart';

class LocationService {
  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Get all countries
  /// Handles both List and Map responses from backend
  Future<List<Country>> getCountries() async {
    try {
      final rawResponse = await _apiClient.getRaw('/location/countries');
      
      List<dynamic> countriesData;
      
      if (rawResponse is List) {
        countriesData = rawResponse;
      } else if (rawResponse is Map<String, dynamic>) {
        if (rawResponse['countries'] != null && rawResponse['countries'] is List) {
          countriesData = rawResponse['countries'] as List<dynamic>;
        } else if (rawResponse['data'] != null && rawResponse['data'] is List) {
          countriesData = rawResponse['data'] as List<dynamic>;
        } else {
          final listValue = rawResponse.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No se encontró lista de países en la respuesta'),
          );
          countriesData = listValue as List<dynamic>;
        }
      } else {
        throw Exception('Formato de respuesta inválido: se esperaba List o Map, se recibió ${rawResponse.runtimeType}');
      }
      
      return countriesData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return Country.fromJson(json);
            } else {
              throw Exception('Elemento de país inválido: se esperaba Map, se recibió ${json.runtimeType}');
            }
          })
          .toList();
    } catch (e) {
      throw Exception('Error al cargar países: $e');
    }
  }

  /// Get cities by country ID
  /// Handles both List and Map responses from backend
  Future<List<City>> getCitiesByCountry(String countryId) async {
    try {
      final rawResponse = await _apiClient.getRaw('/location/cities/$countryId');
      
      List<dynamic> citiesData;
      
      if (rawResponse is List) {
        citiesData = rawResponse;
      } else if (rawResponse is Map<String, dynamic>) {
        if (rawResponse['cities'] != null && rawResponse['cities'] is List) {
          citiesData = rawResponse['cities'] as List<dynamic>;
        } else if (rawResponse['data'] != null && rawResponse['data'] is List) {
          citiesData = rawResponse['data'] as List<dynamic>;
        } else {
          final listValue = rawResponse.values.firstWhere(
            (value) => value is List,
            orElse: () => throw Exception('No se encontró lista de ciudades en la respuesta'),
          );
          citiesData = listValue as List<dynamic>;
        }
      } else {
        throw Exception('Formato de respuesta inválido: se esperaba List o Map, se recibió ${rawResponse.runtimeType}');
      }
      
      return citiesData
          .map((json) {
            if (json is Map<String, dynamic>) {
              return City.fromJson(json);
            } else {
              throw Exception('Elemento de ciudad inválido: se esperaba Map, se recibió ${json.runtimeType}');
            }
          })
          .toList();
    } catch (e) {
      throw Exception('Error al cargar ciudades: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
