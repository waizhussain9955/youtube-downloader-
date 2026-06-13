/// API constants — backend URL configuration
class ApiConstants {
  ApiConstants._();

  /// Change this IP if your device is on the same WiFi network.
  /// Use 10.0.2.2 for Android Emulator, or your PC's LAN IP for physical device.
  static const String baseUrl = 'http://localhost:8000';

  // Endpoints
  static const String infoEndpoint = '/info/';
  static const String audioDownloadEndpoint = '/download/audio';
  static const String videoDownloadEndpoint = '/download/video';
  static const String bulkDownloadEndpoint = '/download/bulk';
  static const String historyEndpoint = '/history/';
  static const String activeDownloadsEndpoint = '/history/active';
  static const String cancelEndpoint = '/history/cancel';
  static const String statusEndpoint = '/history/status';
  static const String healthEndpoint = '/health';

  /// WebSocket base URL
  static String get wsBaseUrl => baseUrl.replaceFirst('http', 'ws');
  static String wsProgressUrl(String jobId) => '${wsBaseUrl}/ws/progress/$jobId';

  // Timeouts
  static const int connectTimeout = 10000; // ms
  static const int receiveTimeout = 30000; // ms
}
