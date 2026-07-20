import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../modules/auth/auth_controller.dart';
import '../../modules/main/bottom_nav.dart';
import '../../routes/app_routes.dart';
import 'movie_detail_controller.dart';

class MovieDetailView extends GetView<MovieDetailController> {
  const MovieDetailView({super.key});

  static const Color _accentRed = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF1A1A2E), Color(0xFF0D0D0D)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              // 顶部导航栏
              _buildAppBar(),

              // 可滚动内容区
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // 电影信息（海报 + 标题 + 评分）
                      _buildMovieInfo(),

                      const SizedBox(height: 24),

                      // 播放按钮
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // 登录状态下记录观看历史
                            if (AuthController.to.isLoggedIn.value) {
                              controller.repository.addWatchHistory(
                                movieId: controller.movie.id,
                                token: AuthController.to.token.value,
                              ).catchError((_) {}); // 失败不阻断跳转
                            }
                            Get.toNamed(AppRoutes.moviePlayer, arguments: controller.movie);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.play_arrow, size: 22),
                          label: const Text('播放', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 情节介绍
                      _buildOverviewSection(),

                      const SizedBox(height: 28),

                      // 领衔主演
                      _buildCastSection(),
                    ],
                  ),
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

  /// 顶部栏：返回 + 标题 + 菜单。
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          Expanded(
            child: Text(
              '电影详情',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          GetBuilder<MovieDetailController>(
            builder: (MovieDetailController c) => IconButton(
              onPressed: c.isToggling.value ? null : c.toggleFavorite,
              icon: Icon(
                c.isFavorite ? Icons.star : Icons.star_border,
                color: c.isFavorite ? const Color(0xFFFFC107) : Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 电影信息：海报 + 标题 + 星级 + 年份标签。
  Widget _buildMovieInfo() {
    final Movie movie = controller.movie;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // 海报
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 120,
            height: 160,
            child: _buildPoster(movie),
          ),
        ),

        const SizedBox(width: 16),

        // 右侧信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                movie.title,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              _StarRating(rating: movie.voteAverage),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Text(
                    movie.releaseDate.isNotEmpty ? movie.releaseDate : '--',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.circle, size: 4, color: Colors.white38),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('评分', style: TextStyle(color: Colors.white60, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPoster(Movie movie) {
    if (movie.posterPath.isEmpty) {
      final int hash = movie.id % 6;
      final List<List<Color>> gradients = <List<Color>>[
        <Color>[const Color(0xFF2C3E50), const Color(0xFF4CA1AF)],
        <Color>[const Color(0xFF141E30), const Color(0xFF243B55)],
        <Color>[const Color(0xFF232526), const Color(0xFF414345)],
        <Color>[const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
        <Color>[const Color(0xFF200122), const Color(0xFF6f0000)],
        <Color>[const Color(0xFF1a2a6c), const Color(0xFFb21f1f), const Color(0xFFfdbb2d)],
      ];
      return DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(colors: gradients[hash])),
        child: Center(child: Icon(Icons.movie_outlined, size: 40, color: Colors.white.withValues(alpha: 0.25))),
      );
    }
    return Image.network(
      movie.displayPoster,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF1E2235),
        child: const Center(child: Icon(Icons.broken_image, color: Colors.white24)),
      ),
    );
  }

  /// 情节介绍区域。
  Widget _buildOverviewSection() {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('情节介绍',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              controller.movie.overview,
              style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.55),
              maxLines: controller.showFullOverview.value ? null : 3,
              overflow: controller.showFullOverview.value ? null : TextOverflow.ellipsis,
            ),
            if (!controller.showFullOverview.value)
              GestureDetector(
                onTap: controller.toggleOverview,
                child: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('查看全部 >', style: TextStyle(color: _accentRed, fontSize: 13)),
                ),
              )
            else
              GestureDetector(
                onTap: controller.toggleOverview,
                child: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('收起', style: TextStyle(color: _accentRed, fontSize: 13)),
                ),
              ),
          ]));
  }

  /// 领衔主演区域（横向演员卡片）。
  Widget _buildCastSection() {
    final List<Cast> casts = controller.movie.casts;
    if (casts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('领衔主演',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: casts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (_, int i) => _CastCard(cast: casts[i]),
          ),
        ),
      ],
    );
  }
}

/// 星级评分组件。
class _StarRating extends StatelessWidget {
  const _StarRating({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(5, (int i) {
        final double threshold = i + 1;
        final bool filled = rating >= threshold || rating >= threshold - 0.5;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(filled ? Icons.star : Icons.star_border, size: 19, color: const Color(0xFFFFB300)),
        );
      }),
    );
  }
}

/// 演员卡片（头像 + 名字 + 角色）。
class _CastCard extends StatelessWidget {
  const _CastCard({required this.cast});
  final Cast cast;

  @override
  Widget build(BuildContext context) {
    final String avatar = cast.displayAvatar;
    return SizedBox(
      width: 92,
      child: ClipRect(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3C),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: avatar.isEmpty
                    ? Icon(Icons.person_rounded,
                        size: 30, color: Colors.white.withValues(alpha: 0.25))
                    : Image.network(
                        avatar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          size: 30,
                          color: Colors.white.withValues(alpha: 0.25),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(cast.name,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Flexible(
              child: Text(cast.role,
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
