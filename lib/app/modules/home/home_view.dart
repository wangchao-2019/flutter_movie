import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../modules/main/bottom_nav.dart';
import '../../routes/app_routes.dart';
import 'home_controller.dart';

const Color _accentOrange = Color(0xFFFF7A2E);

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

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
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: _accentOrange),
              );
            }

            if (controller.error.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      '加载失败',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.error.value,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: controller.loadMovies,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              );
            }

            if (controller.movies.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 24, 28, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '最近更新',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '最新上线的精彩内容',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(
                            Icons.movie_outlined,
                            size: 56,
                            color: Colors.white24,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '暂无电影',
                            style: TextStyle(color: Colors.white54, fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: controller.loadMovies,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const AppBottomNav(),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // 标题区
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '最近更新',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '最新上线的精彩内容',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 电影卡片横向滑动
                Expanded(child: _MovieCarousel(movies: controller.movies)),

                // 底部导航
                const AppBottomNav(),
              ],
            );
          }),
        ),
      ),
    );
  }
}

/// 横向滑动电影卡片列表 + 下方选中电影详情。
///
/// 使用横向 [ListView] 实现连续自由滑动（相比 PageView 翻页更贴近参考图），
/// 通过 [ScrollController] 监听滚动位置，计算当前居中卡片并联动下方详情。
class _MovieCarousel extends StatefulWidget {
  const _MovieCarousel({required this.movies});

  final RxList<Movie> movies;

  @override
  State<_MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<_MovieCarousel> {
  int _selectedIndex = 0;
  late final ScrollController _scrollController;

  double _cardWidth = 0;
  static const double _spacing = 16;
  double _itemWidth = 1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _MovieCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 列表变化后，把选中索引收敛到合法范围，避免越界。
    if (_selectedIndex >= widget.movies.length) {
      _selectedIndex = widget.movies.isEmpty ? 0 : widget.movies.length - 1;
    }
  }

  void _onScroll() {
    if (_itemWidth <= 0) return;
    final int index = (_scrollController.offset / _itemWidth).round();
    if (index != _selectedIndex && index >= 0 && index < widget.movies.length) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const Center(
        child: Text('暂无电影', style: TextStyle(color: Colors.white54)),
      );
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    _cardWidth = screenWidth * 0.68;
    _itemWidth = _cardWidth + _spacing;
    // 让首尾卡片也能居中：左右内边距 = (屏宽 - 卡片宽 - 间距) / 2
    final double startPadding = (screenWidth - _cardWidth - _spacing) / 2;

    return Column(
      children: <Widget>[
        // 卡片区域：横向自由滑动
        Expanded(
          flex: 5,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: startPadding),
            itemCount: widget.movies.length,
            itemBuilder: (_, int index) {
              final bool isSelected = index == _selectedIndex;
              return SizedBox(
                width: _itemWidth,
                child: Center(
                  child: SizedBox(
                    width: _cardWidth,
                    child: GestureDetector(
                      onTap: () {
                        // ignore: avoid_print
                        print('卡片被点击了 index=$index title=${widget.movies[index].title}');
                        Get.toNamed(
                          AppRoutes.movieDetail,
                          arguments: widget.movies[index],
                        );
                      },
                      child: _MovieCard(
                        movie: widget.movies[index],
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 下方详情
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _MovieDetail(movie: widget.movies[_selectedIndex]),
          ),
        ),
      ],
    );
  }
}

/// 单张电影卡片（海报 + 评分角标 + 推荐徽章）。
class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.isSelected});

  final Movie movie;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isSelected ? 1.0 : 0.65,
      child: Transform.scale(
        scale: isSelected ? 1.05 : 0.92,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              // 海报图 / 占位
              _buildPoster(),

              // 渐变遮罩
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
              ),

              // 左上角评分
              Positioned(
                left: 12,
                top: 12,
                child: _RatingBadge(rating: movie.voteAverage),
              ),

              // 右上角推荐徽章
              if (isSelected)
                const Positioned(right: 10, top: 10, child: _RecommendBadge()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    if (movie.posterPath.isEmpty) {
      // 占位背景：随机深色渐变
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
            size: 48,
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

/// 评分角标（星 + 分数）。
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// 推荐徽章（右上角缎带）。
class _RecommendBadge extends StatelessWidget {
  const _RecommendBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 46,
      decoration: const BoxDecoration(
        color: Color(0xFFFF7A2E),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// 下方选中电影的详细信息。
class _MovieDetail extends StatelessWidget {
  const _MovieDetail({required this.movie});

  final Movie movie;

  String get _year => movie.releaseDate.isNotEmpty
      ? movie.releaseDate.substring(0, math.min(4, movie.releaseDate.length))
      : '--';

  String get _genre {
    if (movie.genres.isNotEmpty) return movie.genres.first;
    return '--';
  }

  /// 片长（分钟）格式化为 "2h 13m" / "1h 30m" / "113分钟"。
  String get _duration {
    final int minutes = movie.runtime;
    if (minutes <= 0) return '--';
    final int h = minutes ~/ 60;
    final int m = minutes % 60;
    if (h > 0) {
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${m}分钟';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              _year,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '\u00B7',
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
            ),
            Text(
              _genre,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '\u00B7',
                style: TextStyle(color: Colors.white38, fontSize: 15),
              ),
            ),
            Text(
              _duration,
              style: const TextStyle(color: Colors.white60, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: _accentOrange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
