import 'package:get/get.dart';

import '../../data/providers/api_provider.dart';
import '../../data/repositories/movie_repository.dart';
import 'favorites_controller.dart';

/// 收藏页 Binding：注入 Provider -> Repository -> Controller。
class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiProvider>()) {
      Get.put<ApiProvider>(ApiProvider(), permanent: true);
    }
    if (!Get.isRegistered<MovieRepository>()) {
      Get.put<MovieRepository>(
        MovieRepository(Get.find<ApiProvider>()),
        permanent: true,
      );
    }
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put<FavoritesController>(
        FavoritesController(Get.find<MovieRepository>()),
        permanent: true,
      );
    }
  }
}
