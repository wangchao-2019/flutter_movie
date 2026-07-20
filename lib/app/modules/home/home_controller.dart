import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../auth/auth_controller.dart';

/// 首页控制器：负责电影列表的状态管理与业务逻辑。
class HomeController extends GetxController {
  HomeController(this._repository);

  final MovieRepository _repository;

  final RxList<Movie> movies = <Movie>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      isLoading.value = true;
      error.value = '';
      final List<Movie> result =
          await _repository.getLatestMovies(token: AuthController.to.token.value);
      movies.assignAll(result);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 同步列表项里指定影片的 favorited 字段（来自详情页操作同步）。
  ///
  /// 不重复提示，提示由 FavoritesController.setFavorite 统一给出。
  void setFavorite(int id, bool favorited) {
    for (int i = 0; i < movies.length; i++) {
      if (movies[i].id == id) {
        movies[i] = movies[i].copyWith(favorited: favorited);
      }
    }
    update(['fav_$id']);
  }
}
