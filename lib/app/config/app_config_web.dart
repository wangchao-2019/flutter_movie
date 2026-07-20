/// Web 平台配置。
class AppConfig {
  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// API 基础地址。
  ///
  /// 优先级：
  /// 1. 编译期注入：flutter run --dart-define=API_BASE_URL=http://host:port
  /// 2. 回退到 localhost
  static String get apiBaseUrl =>
      _envBaseUrl.isNotEmpty ? _envBaseUrl : 'http://localhost:8080';
}
