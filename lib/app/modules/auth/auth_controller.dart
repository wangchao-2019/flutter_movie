import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// 全局登录状态管理。
///
/// 使用 [GetStorage] 持久化登录状态与用户名，应用启动时自动读取。
class AuthController extends GetxController {
  AuthController();

  static AuthController get to => Get.find<AuthController>();

  final GetStorage _box = GetStorage();
  static const String _keyUsername = 'username';
  static const String _keyAvatarUrl = 'avatar_url';
  static const String _keyToken = 'token';
  static const String _keyRegisteredUsers = 'registered_users';

  final RxBool isLoggedIn = false.obs;
  final RxString username = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    username.value = _box.read(_keyUsername) ?? '';
    avatarUrl.value = _box.read(_keyAvatarUrl) ?? '';
    token.value = _box.read(_keyToken) ?? '';
    // 登录态以 token 是否存在为准（需在读取 token 之后判断）
    isLoggedIn.value = token.value.isNotEmpty;
  }

  /// 当前有效 token：优先用内存值，若为空再回退到持久化存储。
  String get tokenValue =>
      token.value.isNotEmpty ? token.value : (_box.read(_keyToken) ?? '');

  Map<String, String> get _registeredUsers =>
      Map<String, String>.from(_box.read(_keyRegisteredUsers) ?? <String, String>{});

  /// 用户名是否已注册。
  bool isRegistered(String name) => _registeredUsers.containsKey(name.trim());

  /// 校验用户名与密码是否匹配。
  bool verify(String name, String pwd) {
    final String key = name.trim();
    return _registeredUsers[key] == pwd;
  }

  /// 注册新用户，返回是否成功（false 表示用户名已存在）。
  Future<bool> register(String name, String pwd) async {
    final String key = name.trim();
    final Map<String, String> map = _registeredUsers;
    if (map.containsKey(key)) return false;
    map[key] = pwd;
    await _box.write(_keyRegisteredUsers, map);
    return true;
  }

  /// 更新头像。
  Future<void> updateAvatar(String url) async {
    await _box.write(_keyAvatarUrl, url);
    avatarUrl.value = url;
  }

  /// 登录（保存用户名、token 并标记已登录）。
  Future<void> login(String name, [String? newToken]) async {
    final String user = name.trim().isEmpty ? 'Jessi wang' : name.trim();
    await _box.write(_keyUsername, user);
    if (newToken != null) {
      await _box.write(_keyToken, newToken);
      token.value = newToken;
    }
    // 登录态以 token 是否存在为准
    isLoggedIn.value = token.value.isNotEmpty;
    username.value = user;
  }

  /// 退出登录。
  Future<void> logout() async {
    await _box.remove(_keyUsername);
    await _box.remove(_keyToken);
    isLoggedIn.value = false;
    username.value = '';
    token.value = '';
  }
}
