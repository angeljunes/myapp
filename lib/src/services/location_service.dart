import '../models/country.dart';
import '../models/city.dart';
import 'api_client.dart';

class LocationService {
  LocationService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  /// Get all countries
  Future<List<Country>> getCountries() async {
    try {
      final response = await _apiClient.get('/location/countries');
      
      if (response['countries'] != null) {
        final List<dynamic> countriesData = response['countries'] as List<dynamic>;
        return countriesData
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        // If response is directly a list
        return (response as List<dynamic>)
            .map((json) => Country.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      throw Exception('Error al cargar países: $e');
    }
  }

  /// Get cities by country ID
  Future<List<City>> getCitiesByCountry(String countryId) async {
    try {
      final response = await _apiClient.get('/location/cities/$countryId');
      
      if (response['cities'] != null) {
        final List<dynamic> citiesData = response['cities'] as List<dynamic>;
        return citiesData
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();
      } else if (response is List) {
        // If response is directly a list
        return (response as List<dynamic>)
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Formato de respuesta inválido');
      }
    } catch (e) {
      throw Exception('Error al cargar ciudades: $e');
    }
  }

  void dispose() {
    _apiClient.dispose();
  }
}
