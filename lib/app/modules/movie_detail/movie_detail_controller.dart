import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../auth/auth_controller.dart';
import '../favorites/favorites_controller.dart';
import '../home/home_controller.dart';

class MovieDetailController extends GetxController {
  MovieDetailController({required this.movie, required this.repository}) {
    isFavorited.value = movie.favorited;
  }

  final Movie movie;
  final MovieRepository repository;

  final RxBool showFullOverview = false.obs;

  /// 是否已收藏（来自影片列表项返回的 favorited 字段）。
  final RxBool isFavorited = false.obs;

  /// 是否正在执行收藏操作（用于防重复点击 / 节流期间禁用按钮）。
  final RxBool isToggling = false.obs;

  /// 节流间隔（毫秒）：两次有效点击最小间隔。
  static const int _throttleIntervalMs = 800;

  /// 上次有效点击的时间戳（毫秒），用于节流。
  int _lastToggleAt = 0;

  void toggleOverview() => showFullOverview.value = !showFullOverview.value;

  /// 是否已收藏。
  bool get isFavorite => isFavorited.value;

  FavoritesController? get _favoritesController {
    try { return Get.find<FavoritesController>(); } catch (_) { return null; }
  }

  HomeController? get _homeController {
    try { return Get.find<HomeController>(); } catch (_) { return null; }
  }

  /// 切换收藏状态：判断登录 -> 已收藏则 DELETE 取消 / 未收藏则 POST 添加 -> 更新本地状态。
  ///
  /// 内置防抖（请求进行中忽略重复点击）与节流（[_throttleIntervalMs] 内只响应一次）。
  Future<void> toggleFavorite() async {
    // 节流：固定间隔内只响应一次点击
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastToggleAt < _throttleIntervalMs) return;
    _lastToggleAt = now;

    // 防抖：上一次请求尚未完成则忽略本次点击
    if (isToggling.value) return;

    if (!AuthController.to.isLoggedIn.value) {
      Get.defaultDialog(
        title: '提示',
        middleText: '请先登录后再收藏影片',
        radius: 16,
        backgroundColor: const Color(0xFF1A1F3A),
        titleStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        middleTextStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        textCancel: '取消',
        cancelTextColor: Colors.white70,
        textConfirm: '去登录',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFFF7A2E),
        onConfirm: () { Get.back(); Get.offAllNamed('/login'); },
      );
      return;
    }
    final bool currentlyFavorite = isFavorite;
    isToggling.value = true;
    try {
      final String message = currentlyFavorite
          ? await repository.removeFavorite(
              movieId: movie.id,
              token: AuthController.to.token.value,
            )
          : await repository.addFavorite(
              movieId: movie.id,
              token: AuthController.to.token.value,
            );
      // 同步本地收藏状态（基于后端 favorited 字段）
      isFavorited.value = !currentlyFavorite;
      _favoritesController?.setFavorite(movie.id, isFavorited.value);
      _homeController?.setFavorite(movie.id, isFavorited.value);
      _showSuccessTip(message);
      update();
    } catch (e) {
      Get.snackbar(
        '',
        '',
        messageText: Text('操作失败: $e', style: const TextStyle(color: Colors.white)),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935).withValues(alpha: 0.95),
        borderRadius: 12,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 2),
      );
    } finally {
      isToggling.value = false;
    }
  }

  /// 显示后端返回的成功提示。
  void _showSuccessTip(String msg) {
    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline_rounded,
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
}
