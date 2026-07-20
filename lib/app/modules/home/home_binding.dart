import 'package:get/get.dart';

import '../../data/providers/api_provider.dart';
import '../../data/repositories/movie_repository.dart';
import 'home_controller.dart';

/// 电影页 Binding：按层级注入 Provider -> Repository -> Controller。
class HomeBinding extends Bindings {
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
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(
        HomeController(Get.find<MovieRepository>()),
        permanent: true,
      );
    }
  }
}
