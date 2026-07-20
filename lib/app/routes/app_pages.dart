import 'package:get/get.dart';

import '../data/models/movie_model.dart';
import '../data/repositories/movie_repository.dart';
import '../modules/discover/discover_binding.dart';
import '../modules/discover/discover_view.dart';
import '../modules/favorites/favorites_binding.dart';
import '../modules/favorites/favorites_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/movie_detail/movie_detail_controller.dart';
import '../modules/movie_detail/movie_detail_view.dart';
import '../modules/movie_player/movie_player_controller.dart';
import '../modules/movie_player/movie_player_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/auth/auth_controller.dart';
import '../modules/auth/login_binding.dart';
import '../modules/auth/login_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import 'app_routes.dart';

/// 全局路由表：集中管理页面与对应的 Binding。
class AppPages {
  AppPages._();

  static const initial = AppRoutes.movies;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.movies,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.movieDetail,
      page: () => const MovieDetailView(),
      binding: BindingsBuilder(() {
        final dynamic args = Get.arguments;
        if (args is Movie) {
          Get.put<MovieDetailController>(
            MovieDetailController(
              movie: args,
              repository: Get.find<MovieRepository>(),
            ),
          );
        }
      }),
    ),
    GetPage(
      name: AppRoutes.moviePlayer,
      page: () => const MoviePlayerView(),
      binding: BindingsBuilder(() {
        final dynamic args = Get.arguments;
        if (args is Movie) {
          Get.put<MoviePlayerController>(MoviePlayerController(args));
        }
      }),
    ),
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesView(),
      binding: FavoritesBinding(),
    ),
    GetPage(
      name: AppRoutes.discover,
      page: () => const DiscoverView(),
      binding: DiscoverBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];

  /// 应用启动时注册全局单例依赖。
  static void initDependencies() {
    Get.put<AuthController>(AuthController());
  }
}
