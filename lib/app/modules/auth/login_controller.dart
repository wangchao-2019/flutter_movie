import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../routes/app_routes.dart';
import '../favorites/favorites_controller.dart';
import '../home/home_controller.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRegisterMode = false.obs;

  void toggleObscure() => obscurePassword.toggle();
  void toggleMode() => isRegisterMode.toggle();

  DateTime? _lastSubmitAt;

  /// 防抖：两次提交间隔小于 [interval] 时忽略后一次点击。
  bool _canSubmit([Duration interval = const Duration(milliseconds: 800)]) {
    final DateTime now = DateTime.now();
    if (_lastSubmitAt != null && now.difference(_lastSubmitAt!) < interval) {
      return false;
    }
    _lastSubmitAt = now;
    return true;
  }

  Future<void> login() async {
    if (!_canSubmit()) return;
    final String email = usernameController.text.trim();
    final String pwd = passwordController.text;
    if (email.isEmpty) {
      _toast('请输入邮箱');
      return;
    }
    if (!_isValidEmail(email)) {
      _toast('请输入有效的邮箱地址');
      return;
    }
    if (pwd.isEmpty) {
      _toast('请输入密码');
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': pwd,
        }),
      );

      if (response.statusCode == 200) {
        final String? token = _parseToken(response.body);
        await AuthController.to.login(email, token);
        _refreshMoviePages();
        isLoading.value = false;
        Get.offAllNamed(AppRoutes.profile);
      } else {
        isLoading.value = false;
        _toast(_parseErrorMessage(response.body));
      }
    } catch (e) {
      isLoading.value = false;
      _toast('网络错误，请检查网络连接');
    }
  }

  Future<void> register() async {
    if (!_canSubmit()) return;
    final String email = usernameController.text.trim();
    final String pwd = passwordController.text;
    final String confirm = confirmPasswordController.text;
    if (email.isEmpty) {
      _toast('请输入邮箱');
      return;
    }
    if (!_isValidEmail(email)) {
      _toast('请输入有效的邮箱地址');
      return;
    }
    if (pwd.length < 6) {
      _toast('密码至少 6 位');
      return;
    }
    if (pwd != confirm) {
      _toast('两次输入的密码不一致');
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/auth/register'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': email,
          'password': pwd,
        }),
      );

      if (response.statusCode == 200) {
        final String? token = _parseToken(response.body);
        await AuthController.to.login(email, token);
        _refreshMoviePages();
        isLoading.value = false;
        Get.offAllNamed(AppRoutes.profile);
      } else {
        isLoading.value = false;
        _toast(_parseErrorMessage(response.body));
      }
    } catch (e) {
      isLoading.value = false;
      _toast('网络错误，请检查网络连接');
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  String _parseErrorMessage(String body) {
    try {
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      return (data['error'] ?? data['message']) as String? ?? '请求失败，请重试';
    } catch (_) {
      return '请求失败，请重试';
    }
  }

  /// 登录/注册成功后刷新「为你推荐」与「最近更新」页面。
  ///
  /// 这两个页面以 permanent 方式常驻内存，登录前后收藏状态（favorited）
  /// 不同，需重新拉取以反映最新登录态。仅当页面已初始化时才刷新。
  void _refreshMoviePages() {
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().loadMovies();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadMovies();
    }
  }

  /// 从登录响应中解析 token（兼容多种字段命名）。
  String? _parseToken(String body) {
    try {
      final Map<String, dynamic> data = jsonDecode(body) as Map<String, dynamic>;
      final dynamic token = data['token'] ??
          data['accessToken'] ??
          data['access_token'] ??
          data['jwt'];
      return token is String ? token : null;
    } catch (_) {
      return null;
    }
  }

  void _toast(String msg) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF7A2E),
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1A1F3A).withValues(alpha: 0.95),
      borderRadius: 16,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      barBlur: 12,
      overlayColor: Colors.black.withValues(alpha: 0.2),
      overlayBlur: 0,
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
