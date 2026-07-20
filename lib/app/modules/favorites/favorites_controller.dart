import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../data/models/paged_result_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../auth/auth_controller.dart';

/// 收藏/推荐页控制器：管理影片列表、分页查询、分类筛选与收藏状态。
class FavoritesController extends GetxController {
  FavoritesController(this._repository);

  final MovieRepository _repository;

  /// 全部已加载影片（来自分页接口）。
  final RxList<Movie> movies = <Movie>[].obs;

  /// 是否加载中。
  final RxBool isLoading = true.obs;

  /// 是否正在加载更多。
  final RxBool isLoadingMore = false.obs;

  /// 错误信息。
  final RxString error = ''.obs;

  /// 已选分类筛选（'all' 表示全部）。
  final RxString selectedCategory = 'all'.obs;

  /// 可选分类标签。
  final List<String> categories = <String>['所有', '动作', '冒险', '科幻', '剧情'];

  /// 收藏状态（记录已收藏影片的 id）。
  final RxSet<int> favoriteIds = <int>{}.obs;

  /// 当前分类下展示影片（后端已按分类过滤）。
  final RxList<Movie> filteredMovies = <Movie>[].obs;

  /// 当前分类下影片总数（来自后端分页结果）。
  int totalElements = 0;

  /// 当前页码（从 0 开始，与后端分页保持一致）。
  int currentPage = 0;

  /// 每页条数。
  final int pageSize = 10;

  /// 是否还有更多数据。
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadMovies();
  }

  /// 加载第一页（刷新/初始化/切换分类）。
  Future<void> loadMovies({bool showLoading = true}) async {
    await _loadPage(0, showLoading: showLoading);
  }

  /// 加载下一页（触底时调用）。
  Future<void> loadMoreMovies() async {
    if (!hasMore || isLoadingMore.value) return;
    await _loadPage(currentPage + 1);
  }

  /// 实际分页请求。
  Future<void> _loadPage(int page, {bool showLoading = true}) async {
    try {
      if (page == 0) {
        if (showLoading) isLoading.value = true;
      } else {
        isLoadingMore.value = true;
      }
      error.value = '';

      final String? genre =
          selectedCategory.value == 'all' ? null : selectedCategory.value;
      final PagedMovies result = await _repository.getMoviesByPage(
        page: page,
        size: pageSize,
        genre: genre,
        token: AuthController.to.token.value,
      );

      if (page == 0) {
        favoriteIds.clear();
        movies.assignAll(result.content);
      } else {
        movies.addAll(result.content);
      }
      filteredMovies.assignAll(movies.toList());
      // 仅把后端标记为已收藏的影片加入收藏集合
      favoriteIds.addAll(
        result.content.where((Movie m) => m.favorited).map((Movie m) => m.id),
      );

      totalElements = result.totalElements;
      currentPage = result.page;
      hasMore = !result.last;
      update();
    } catch (e) {
      error.value = e.toString();
      update();
    } finally {
      if (page == 0) {
        if (showLoading) isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
      update();
    }
  }

  /// 切换分类筛选，并重新加载第一页。
  void selectCategory(String category) {
    selectedCategory.value = category == '所有' ? 'all' : category;
    currentPage = 0;
    hasMore = true;
    movies.clear();
    filteredMovies.clear();
    update();
    loadMovies();
  }

  /// 设置某部影片的收藏状态（来自详情页操作同步），并给出提示。
  void setFavorite(int id, bool favorited) {
    if (favorited) {
      favoriteIds.add(id);
      _showTip('收藏成功');
    } else {
      favoriteIds.remove(id);
      _showTip('已取消收藏');
    }
    // 同步列表项里 Movie 的 favorited 字段，保证重新进入详情页时状态正确
    _syncMovieFavorited(id, favorited);
    update(['fav_$id']);
  }

  /// 更新 movies / filteredMovies 中指定影片的 favorited 字段。
  void _syncMovieFavorited(int id, bool favorited) {
    for (int i = 0; i < movies.length; i++) {
      if (movies[i].id == id) {
        movies[i] = movies[i].copyWith(favorited: favorited);
      }
    }
    for (int i = 0; i < filteredMovies.length; i++) {
      if (filteredMovies[i].id == id) {
        filteredMovies[i] = filteredMovies[i].copyWith(favorited: favorited);
      }
    }
  }

  /// 项目风格提示条。
  void _showTip(String msg) {
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

  /// 是否收藏。
  bool isFavorite(int id) => favoriteIds.contains(id);
}
