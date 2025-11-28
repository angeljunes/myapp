/// Configuración centralizada de la aplicación
class AppConfig {
  // MongoDB Connection String
  static const String mongodbConnectionString =
      'mongodb+srv://edgarangelja_db_user:M3TEIlEqdGh2eT09@cluster0.iwfms3i.mongodb.net/?appName=Cluster0';

  // API Base URL (sin slash final - formato GitHub Codespaces)
  // IMPORTANTE: No debe terminar con "/"
  static const String apiBaseUrl = 'https://verbose-waddle-4jwx57wqj7qq3jp77-8081.app.github.dev/api';

  // Database Name (si es necesario)
  static const String databaseName = 'rcas_db';

  // App Name
  static const String appName = 'RCAS';

  // Token Key
  static const String tokenKey = 'rcas_token';
}


