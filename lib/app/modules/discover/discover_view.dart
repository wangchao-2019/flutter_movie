import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../routes/app_routes.dart';
import '../main/bottom_nav.dart';
import 'discover_controller.dart';

const Color _accentOrange = Color(0xFFFF7A2E);

class DiscoverView extends GetView<DiscoverController> {
  const DiscoverView({super.key});

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
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  '搜索',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSearchBox(),
              ),
              const SizedBox(height: 16),
              Expanded(child: _buildResults()),
              const AppBottomNav(),
            ],
          ),
        ),
      ),
      extendBody: true,
    );
  }

  Widget _buildSearchBox() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller.keywordController,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '输入影片名',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: controller.search,
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => controller.search(controller.keywordController.text),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accentOrange,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: _accentOrange),
        );
      }
      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Text(
            controller.error.value,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        );
      }
      final List<Movie> list = controller.results.toList();
      if (controller.keywordController.text.trim().isEmpty) {
        return _buildEmptyState(
          icon: Icons.search_outlined,
          text: '输入影片名开始搜索',
        );
      }
      if (list.isEmpty) {
        return _buildEmptyState(
          icon: Icons.movie_outlined,
          text: '未找到相关影片',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 18),
        itemBuilder: (_, int index) => _MovieListItem(movie: list[index]),
      );
    });
  }

  Widget _buildEmptyState({required IconData icon, required String text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

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
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 110,
              height: 150,
              child: _buildPoster(movie),
            ),
          ),
          const SizedBox(width: 14),
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
