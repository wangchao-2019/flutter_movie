import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../favorites/favorites_controller.dart';
import '../home/home_controller.dart';

class SettingsController extends GetxController {
  /// 退出登录并跳转回登录页。
  ///
  /// 退出后 token 已清空，重新拉取「为你推荐」与「最近更新」页面，
  /// 请求不再携带 Authorization，后端返回 favorited=false，从而刷新回未登录态。
  Future<void> logout() async {
    await AuthController.to.logout();
    _refreshMoviePages();
    Get.offAllNamed(AppRoutes.login);
  }

  /// 刷新「为你推荐」与「最近更新」页面（仅对已初始化的页面生效）。
  void _refreshMoviePages() {
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().loadMovies();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadMovies();
    }
  }
}
