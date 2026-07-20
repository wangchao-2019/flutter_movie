import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../main/bottom_nav.dart';
import '../../routes/app_routes.dart';
import 'favorites_controller.dart';

const Color _accentOrange = Color(0xFFFF7A2E);

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0D1021),
              Color(0xFF1A1F3A),
              Color(0xFF0D1021),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // 标题区
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      '为您推荐',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GetBuilder<FavoritesController>(
                      builder: (FavoritesController c) => Text(
                        '为您找到 ${c.totalElements} 部可能感兴趣的影片',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 分类筛选标签
              _buildCategoryChips(),

              const SizedBox(height: 8),

              // 列表
              Expanded(
                child: GetBuilder<FavoritesController>(
                  builder: (FavoritesController c) {
                    if (c.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: _accentOrange),
                      );
                    }
                    if (c.error.value.isNotEmpty) {
                      return Center(
                        child: Text(
                          c.error.value,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    final List<Movie> list = c.filteredMovies.toList();
                    if (list.isEmpty) {
                      return const Center(
                        child: Text(
                          '该分类下暂无影片',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      );
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo is ScrollEndNotification &&
                            scrollInfo.metrics.extentAfter < 120) {
                          controller.loadMoreMovies();
                        }
                        return false;
                      },
                      child: RefreshIndicator(
                        color: _accentOrange,
                        backgroundColor: const Color(0xFF1A1F3A),
                        onRefresh: () => controller.loadMovies(showLoading: false),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          itemCount: list.length + (c.isLoadingMore.value ? 1 : 0),
                          separatorBuilder: (_, int index) {
                            if (index >= list.length) {
                              return const SizedBox.shrink();
                            }
                            return const SizedBox(height: 18);
                          },
                          itemBuilder: (_, int index) {
                            if (index >= list.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(
                                    color: _accentOrange,
                                  ),
                                ),
                              );
                            }
                            return _MovieListItem(movie: list[index]);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 底部导航
              const AppBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  /// 横向分类标签（选中态橙色高亮）。
  Widget _buildCategoryChips() {
    return GetBuilder<FavoritesController>(
      builder: (FavoritesController c) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: c.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, int i) {
            final String category = c.categories[i];
            final bool selected =
                c.selectedCategory.value ==
                (category == '所有' ? 'all' : category);
            return GestureDetector(
              onTap: () => c.selectCategory(category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? _accentOrange
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    category,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 单个电影列表项：左侧海报 + 右上角收藏星标，右侧信息。
class _MovieListItem extends StatelessWidget {
  const _MovieListItem({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.movieDetail, arguments: movie),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 海报
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 110,
              height: 150,
              child: _buildPoster(movie),
            ),
          ),

          const SizedBox(width: 14),

          // 右侧信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 4),
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 星级评分
                Row(
                  children: <Widget>[
                    ...List<Widget>.generate(5, (int i) {
                      final bool filled = movie.voteAverage >= (i + 1) * 2 - 1;
                      return Icon(
                        filled ? Icons.star : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFFFB300),
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // 类型标签
                if (movie.genres.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: movie.genres
                        .map(
                          (String g) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              g,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                const SizedBox(height: 10),
                // 时长
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: Colors.white54,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      movie.runtimeText,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(Movie movie) {
    if (movie.posterPath.isEmpty) {
      final int hash = movie.id % 6;
      final List<List<Color>> gradients = <List<Color>>[
        <Color>[const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
        <Color>[const Color(0xFF141E30), const Color(0xFF243B55)],
        <Color>[const Color(0xFF232526), const Color(0xFF414345)],
        <Color>[
          const Color(0xFF0F2027),
          const Color(0xFF203A43),
          const Color(0xFF2C5364),
        ],
        <Color>[const Color(0xFF200122), const Color(0xFF6f0000)],
        <Color>[
          const Color(0xFF1a2a6c),
          const Color(0xFFb21f1f),
          const Color(0xFFfdbb2d),
        ],
      ];
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradients[hash]),
        ),
        child: Center(
          child: Icon(
            Icons.movie_outlined,
            size: 36,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      );
    }
    return Image.network(
      movie.displayPoster,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1E2235),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white24),
        ),
      ),
    );
  }
}
