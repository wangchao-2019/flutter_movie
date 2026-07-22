import '../models/message_model.dart';
import '../models/movie_model.dart';
import '../models/paged_result_model.dart';
import '../providers/api_provider.dart';

/// 仓库层（Repository）：对上层屏蔽数据来源细节，统一对外提供业务数据。
class MovieRepository {
  final ApiProvider _apiProvider;

  MovieRepository(this._apiProvider);

  Future<PagedMovies> getMoviesByPage({
    required int page,
    int size = 10,
    String? genre,
    String? token,
  }) =>
      _apiProvider.fetchMoviesByPage(
        page: page,
        size: size,
        genre: genre,
        token: token,
      );

  Future<List<Movie>> getLatestMovies({String? token}) =>
      _apiProvider.fetchLatestMovies(token: token);

  Future<List<Movie>> searchMovies(String keyword, {String? token}) =>
      _apiProvider.searchMovies(keyword, token: token);

  Future<String> addFavorite({required int movieId, String? token}) =>
      _apiProvider.addFavorite(movieId: movieId, token: token);

  Future<String> removeFavorite({required int movieId, String? token}) =>
      _apiProvider.removeFavorite(movieId: movieId, token: token);

  /// 获取当前登录用户的收藏列表（GET /api/favorites，需 token）。
  Future<List<Movie>> getFavorites({String? token}) =>
      _apiProvider.fetchFavorites(token: token);

  /// 获取当前登录用户的观看历史（GET /api/watch-history，需 token）。
  Future<List<Movie>> getWatchHistory({String? token}) =>
      _apiProvider.fetchWatchHistory(token: token);

  /// 添加观看记录（POST /api/watch-history，需 token）。
  Future<void> addWatchHistory({required int movieId, String? token}) =>
      _apiProvider.addWatchHistory(movieId: movieId, token: token);

  /// 提交留言（POST /api/messages，需 token）。
  Future<void> submitMessage(String content, {String? token}) =>
      _apiProvider.submitMessage(content, token: token);

  /// 获取留言列表（GET /api/messages，需 token）。
  Future<List<MessageModel>> getMessages({
    int page = 0,
    int size = 20,
    String? token,
  }) =>
      _apiProvider.fetchMessages(page: page, size: size, token: token);
}
