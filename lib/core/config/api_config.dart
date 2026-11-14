class ApiConfig {
  // Android emulator to host localhost: http://10.0.2.2:8080/api/v1
  // Render production URL: https://storepulse-web-application.onrender.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://storepulse-platform-production.up.railway.app/api/v1',
  );
}