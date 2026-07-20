import 'dart:io';

/// 非 Web 平台配置（Android / iOS / 桌面）。
class AppConfig {
  static const String _envBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// API 基础地址。
  ///
  /// 优先级：
  /// 1. 编译期注入：flutter run --dart-define=API_BASE_URL=http://host:port
  /// 2. Android 模拟器回退到 10.0.2.2（访问宿主机 localhost）
  /// 3. 其它平台回退到 localhost
  static String get apiBaseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }
}
