class AppConstants {
  static const int serverPort = 8080;
  static const int maxLogs = 50;
  static const String modelStorageDir = 'models';

  // API Endpoints
  static const String healthEndpoint = '/health';
  static const String generateEndpoint = '/generate';
  static const String modelEndpoint = '/model';
  static const String chatEndpoint = '/chat';
}