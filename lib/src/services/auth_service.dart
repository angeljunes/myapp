import '../models/app_user.dart';
import 'api_client.dart';

class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AppUser> login(String identity, String password) async {
    try {
      final response = await _apiClient.login(identity, password);
      
      if (response['user'] == null) {
        throw Exception('Respuesta inválida del servidor');
      }

      return AppUser.fromJson(response['user'] as Map<String, dynamic>);
    } catch (e) {
      if (e.toString().contains('401')) {
        throw Exception('Credenciales inválidas');
      }
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String role,
    required String zone,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', {
        'email': email,
        'username': username,
        'password': password,
        'fullName': fullName,
        'role': role,
        'zone': zone,
      }, requireAuth: false);

      if (response['user'] != null) {
        return AppUser.fromJson(response['user'] as Map<String, dynamic>);
      } else if (response['userId'] != null) {
        // If backend returns userId instead of user object
        return AppUser(
          id: response['userId'].toString(),
          fullName: fullName,
          email: email,
          username: username,
          role: role,
          zone: zone,
        );
      } else {
        throw Exception('Respuesta inválida del servidor');
      }
    } catch (e) {
      throw Exception('Error al registrarse: $e');
    }
  }

  Future<AppUser> getProfile() async {
    try {
      final response = await _apiClient.get('/auth/profile');
      return AppUser.fromJson(response);
    } catch (e) {
      throw Exception('No se pudo obtener el perfil: $e');
    }
  }

  Future<void> logout() async {
    await _apiClient.logout();
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }

  void dispose() {
    _apiClient.dispose();
  }
}
