import 'package:get/get.dart';

import '../../data/providers/api_provider.dart';
import '../../data/repositories/movie_repository.dart';
import 'discover_controller.dart';

/// 发现页 Binding：注入搜索依赖。
class DiscoverBinding extends Bindings {
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
    if (!Get.isRegistered<DiscoverController>()) {
      Get.put<DiscoverController>(
        DiscoverController(Get.find<MovieRepository>()),
        permanent: true,
      );
    }
  }
}
