import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/models/movie_model.dart';
import '../../data/providers/api_provider.dart';
import '../../data/repositories/movie_repository.dart';
import '../../routes/app_routes.dart';
import '../auth/auth_controller.dart';
import '../main/bottom_nav.dart';

const Color _accentOrange = Color(0xFFFF7A2E);
const String _avatarUrl =
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _selectedTab = 0;
  final List<String> _tabs = <String>['我的收藏', '历史记录'];

  /// 收藏列表（来自后端接口 GET /api/favorites）。
  final List<Movie> _favoriteMovies = <Movie>[];

  /// 是否正在加载收藏列表。
  bool _isLoadingFavorites = true;

  /// 收藏列表加载错误信息。
  String _favoritesError = '';

  /// 观看历史列表（来自后端接口 GET /api/watch-history）。
  final List<Movie> _watchHistoryMovies = <Movie>[];

  /// 已收藏影片的 ID 集合（用于历史记录 tab 判断星星状态）。
  final Set<int> _favoriteIds = <int>{};

  /// 是否正在加载观看历史。
  bool _isLoadingHistory = false;

  /// 观看历史加载错误信息。
  String _historyError = '';

  late final MovieRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = MovieRepository(ApiProvider());
    // 兜底：未登录则跳转登录页
    if (!AuthController.to.isLoggedIn.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(AppRoutes.login);
      });
    } else {
      _loadFavorites();
      // 进入页面即刷新观看历史（如播放后返回，统计数字与历史 tab 均为最新）
      _loadWatchHistory();
    }
  }

  /// 从后端加载收藏列表。
  Future<void> _loadFavorites() async {
    setState(() => _isLoadingFavorites = true);
    try {
      final List<Movie> result = await _repository.getFavorites(
        token: AuthController.to.token.value,
      );
      if (mounted) {
        setState(() {
          _favoriteMovies.clear();
          _favoriteMovies.addAll(result);
          _favoriteIds
            ..clear()
            ..addAll(result.map((Movie m) => m.id));
          _isLoadingFavorites = false;
          _favoritesError = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorites = false;
          _favoritesError = e.toString();
        });
      }
    }
  }

  /// 从后端加载观看历史。
  Future<void> _loadWatchHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final List<Movie> result = await _repository.getWatchHistory(
        token: AuthController.to.token.value,
      );
      if (mounted) {
        setState(() {
          _watchHistoryMovies.clear();
          _watchHistoryMovies.addAll(result);
          _isLoadingHistory = false;
          _historyError = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _historyError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1021),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStats(),
                const SizedBox(height: 24),
                _buildTabs(),
                const SizedBox(height: 20),
                _buildMovieGrid(),
                // 有内容时留出底部导航栏空间；空状态时只留安全区高度
                SizedBox(
                  height: (_selectedTab == 0 && _favoriteMovies.isNotEmpty) ||
                          (_selectedTab == 1 && _watchHistoryMovies.isNotEmpty)
                      ? 120 + bottomInset
                      : bottomInset,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(),
      extendBody: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white70),
              onPressed: () => Get.toNamed(AppRoutes.settings),
            ),
          ],
        ),
        const SizedBox(height: 4),
            GestureDetector(
              onTap: _showAvatarPicker,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: <Widget>[
                  ClipOval(
                    child: _buildAvatarImage(),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),
        Text(
          AuthController.to.username.value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Obx(
          () {
            final String username = AuthController.to.username.value;
            final String handle = username.contains('@')
                ? '@${username.split('@').first}'
                : '@$username';
            return Text(
              handle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAvatarImage() {
    return Obx(() {
      final String url = AuthController.to.avatarUrl.value;
      final Widget placeholder = _buildAvatarPlaceholder();
      if (url.isEmpty || url.startsWith('http')) {
        return Image.network(
          url.isEmpty ? _avatarUrl : url,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
        );
      }
      if (url.startsWith('data:')) {
        return Image.memory(
          base64Decode(url.split(',').last),
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
        );
      }
      return Image.file(
        File(url),
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    });
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: Colors.grey.shade300,
      child: const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  void _showAvatarPicker() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1F3A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text(
                  '从相册选择',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: const Text(
                  '拍照',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.white70),
                title: const Text(
                  '恢复默认头像',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.back();
                  AuthController.to.updateAvatar(_avatarUrl);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);
    if (file == null) return;

    // Web 不支持写本地文件，转成 base64 data URL 直接用作头像（刷新也不丢）。
    if (kIsWeb) {
      final Uint8List bytes = await file.readAsBytes();
      final String mime = file.mimeType ?? 'image/jpeg';
      final String dataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
      await AuthController.to.updateAvatar(dataUrl);
      return;
    }

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File saved = File('${appDir.path}/$fileName');
    await saved.writeAsBytes(await file.readAsBytes());

    await AuthController.to.updateAvatar(saved.path);
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildStatItem(_favoriteMovies.length.toString(), '我的收藏'),
          _buildStatItem(_watchHistoryMovies.length.toString(), '历史记录'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: <Widget>[
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: List<Widget>.generate(_tabs.length, (int index) {
              final bool isSelected = index == _selectedTab;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = index);
                  if (index == 1 && _watchHistoryMovies.isEmpty && !_isLoadingHistory) {
                    _loadWatchHistory();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _accentOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Icon(Icons.filter_alt, color: Colors.white70, size: 20),
      ],
    );
  }

  Widget _buildMovieGrid() {
    // 历史记录 tab
    if (_selectedTab == 1) {
      return _buildHistoryGrid();
    }
    // 收藏 tab
    if (_isLoadingFavorites) {
      return const Center(
        child: CircularProgressIndicator(color: _accentOrange),
      );
    }
    if (_favoritesError.isNotEmpty) {
      return Center(
        child: Text(
          '加载失败',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    if (_favoriteMovies.isEmpty) {
      return const Center(
        child: Text(
          '暂无收藏',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return _gridView(_favoriteMovies, (Movie m) => m.favorited);
  }

  /// 历史记录列表。
  Widget _buildHistoryGrid() {
    if (_isLoadingHistory) {
      return const Center(
        child: CircularProgressIndicator(color: _accentOrange),
      );
    }
    if (_historyError.isNotEmpty) {
      return Center(
        child: Text(
          '加载失败',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    if (_watchHistoryMovies.isEmpty) {
      return const Center(
        child: Text(
          '暂无观看历史',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      );
    }
    return _gridView(
      _watchHistoryMovies,
      (Movie m) => _favoriteIds.contains(m.id),
    );
  }

  Widget _gridView(
    List<Movie> movies,
    bool Function(Movie) isFavorite,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: movies.length,
      itemBuilder: (_, int index) => _MovieCard(
        movie: movies[index],
        favorited: isFavorite(movies[index]),
      ),
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, required this.favorited});

  final Movie movie;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.movieDetail, arguments: movie),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            movie.displayPoster,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: const Color(0xFF1E2235),
              child: const Center(
                child: Icon(Icons.movie, color: Colors.white24),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.thumb_up, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                favorited ? Icons.star : Icons.star_border,
                color: favorited
                    ? const Color(0xFFFFC107)
                    : Colors.white.withValues(alpha: 0.5),
                size: 18,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
