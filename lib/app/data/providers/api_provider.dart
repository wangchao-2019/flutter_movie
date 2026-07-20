import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/movie_model.dart';
import '../models/paged_result_model.dart';
import '../../config/app_config.dart';


/// 数据提供层（Provider）：负责与远程 / 本地数据源通信。
class ApiProvider {
  static final String _baseUrl = AppConfig.apiBaseUrl;


  Future<List<Movie>> fetchMovies() async {
    // 模拟网络延迟
    await Future<void>.delayed(const Duration(milliseconds: 800));

    return const <Movie>[
      Movie(
        id: 1,
        title: '星际穿越',
        overview: '一支探险队穿越虫洞，为人类寻找新的家园。',
        posterPath: '',
        voteAverage: 9.2,
        releaseDate: '2014-11-07',
        videoUrl: 'https://ukzyvod3.ukubf5.com/20260707/PUNT5tOk/index.m3u8',
        genres: <String>['科幻', '冒险'],
        runtime: 169,
      ),
      Movie(
        id: 2,
        title: '盗梦空间',
        overview: '潜入梦境窃取潜意识的科幻动作片。',
        posterPath: '',
        voteAverage: 9.0,
        releaseDate: '2010-07-16',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        genres: <String>['科幻', '动作'],
        runtime: 148,
      ),
      Movie(
        id: 3,
        title: '肖申克的救赎',
        overview: '关于希望与自由的经典之作。',
        posterPath: '',
        voteAverage: 9.3,
        releaseDate: '1994-09-23',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        genres: <String>['剧情', '犯罪'],
        runtime: 142,
      ),
      Movie(
        id: 4,
        title: '阿甘正传',
        overview: '一个智商不高却创造传奇的人生命运。',
        posterPath: '',
        voteAverage: 9.1,
        releaseDate: '1994-07-06',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        genres: <String>['剧情', '爱情'],
        runtime: 142,
      ),
      Movie(
        id: 5,
        title: '地心引力',
        overview: '两名宇航员在太空遭遇灾难后艰难求生。',
        posterPath: '',
        voteAverage: 7.9,
        releaseDate: '2013-11-08',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        genres: <String>['科幻', '惊悚'],
        runtime: 91,
      ),
      Movie(
        id: 6,
        title: '火星救援',
        overview: '一名宇航员被遗落在火星，依靠智慧独自求生。',
        posterPath: '',
        voteAverage: 8.0,
        releaseDate: '2015-11-25',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        genres: <String>['科幻', '冒险'],
        runtime: 144,
      ),
    ];
  }

  /// 分页查询影片列表（GET /api/movies/page）。
  ///
  /// [page] 从 0 开始；[genre] 为分类名称，空字符串或 null 表示全部。
  Future<PagedMovies> fetchMoviesByPage({
    required int page,
    int size = 10,
    String? genre,
    String? token,
  }) async {
    final Map<String, String> queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
    };
    if (genre != null && genre.isNotEmpty) {
      queryParameters['genre'] = genre;
    }

    final Uri uri = Uri.parse('$_baseUrl/api/movies/page')
        .replace(queryParameters: queryParameters);
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;
      return PagedResult<Movie>.fromJson(data, Movie.fromJson);
    } else {
      final Map<String, dynamic> errorBody =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['error'] ?? errorBody['message'] ?? '加载影片失败');
    }
  }

  /// 获取最新上映电影列表。
  Future<List<Movie>> fetchLatestMovies({String? token}) async {
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/latest-movies'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((dynamic e) => (e as Map<String, dynamic>)['movie'] as Map<String, dynamic>)
          .map((Map<String, dynamic> e) => Movie.fromJson(e))
          .toList();
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '加载最新电影失败');
    }
  }

  /// 搜索影片。
  Future<List<Movie>> searchMovies(String keyword, {String? token}) async {
    final Uri uri = Uri.parse('$_baseUrl/api/movies/search').replace(
      queryParameters: <String, String>{'keyword': keyword},
    );
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      return data.map((dynamic e) {
        final Map<String, dynamic> item = e as Map<String, dynamic>;
        final Map<String, dynamic> movieJson =
            (item['movie'] as Map<String, dynamic>?) ?? item;
        return Movie.fromJson(movieJson);
      }).toList();
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '搜索失败');
    }
  }

  /// 添加收藏（POST /api/favorites）。
  ///
  /// [movieId] 影片 ID；[token] 为登录后拿到的 token，会拼成
  /// `Bearer <token>` 放入 Authorization 请求头。
  Future<String> addFavorite({required int movieId, String? token}) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/favorites'),
      headers: headers,
      body: jsonEncode(<String, dynamic>{'movieId': movieId}),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '收藏失败');
    }
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    return (body['message'] ?? '收藏成功') as String;
  }

  /// 取消收藏（DELETE /api/favorites/{movieId}）。
  ///
  /// [movieId] 影片 ID（作为路径参数）；[token] 为登录后拿到的 token，
  /// 会拼成 `Bearer <token>` 放入 Authorization 请求头。无需 Body。
  Future<String> removeFavorite({required int movieId, String? token}) async {
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final Uri uri = Uri.parse('$_baseUrl/api/favorites/$movieId');
    final response = await http.delete(uri, headers: headers);

    if (response.statusCode != 200) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '取消收藏失败');
    }
    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    return (body['message'] ?? '取消收藏成功') as String;
  }

  /// 从接口响应体解析影片列表，兼容多种后端返回格式：
  /// - 直接是数组：`[ {movie:{...}}, ... ]` 或 `[ {...}, ... ]`
  /// - 分页对象：`{content:[...]}` / `{data:[...]}` / `{records:[...]}` /
  ///   `{list:[...]}` / `{items:[...]}` / `{result:[...]}`
  /// 每个数组元素兼容 `{movie:{...}}` 嵌套或直接就是影片对象。
  List<Movie> _parseMovieList(dynamic decoded) {
    List<dynamic> list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map) {
      list = <dynamic>[];
      for (final String key in const <String>[
        'content',
        'data',
        'records',
        'list',
        'items',
        'result',
      ]) {
        final dynamic v = decoded[key];
        if (v is List) {
          list = v;
          break;
        }
      }
    } else {
      list = <dynamic>[];
    }

    return list.map((dynamic e) {
      final Map<String, dynamic> item = e as Map<String, dynamic>;
      final Map<String, dynamic> movieJson =
          (item['movie'] as Map<String, dynamic>?) ?? item;
      return Movie.fromJson(movieJson);
    }).toList();
  }

  /// 获取我的收藏列表（GET /api/favorites）。
  ///
  /// [token] 为登录后拿到的 token，会拼成 `Bearer <token>` 放入 Authorization 请求头。
  Future<List<Movie>> fetchFavorites({String? token}) async {
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/favorites'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // 收藏列表中的影片 favorited 必为 true
      return _parseMovieList(jsonDecode(response.body))
          .map((Movie m) => m.copyWith(favorited: true))
          .toList();
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '获取收藏列表失败');
    }
  }

  /// 获取观看历史（GET /api/watch-history）。
  ///
  /// [token] 为登录后拿到的 token，会拼成 `Bearer <token>` 放入 Authorization 请求头。
  Future<List<Movie>> fetchWatchHistory({String? token}) async {
    final Map<String, String> headers = <String, String>{};
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/watch-history'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return _parseMovieList(jsonDecode(response.body));
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '获取观看历史失败');
    }
  }

  /// 添加观看历史（POST /api/watch-history）。
  ///
  /// [token] 为登录后拿到的 token，会拼成 `Bearer <token>` 放入 Authorization 请求头。
  /// [movieId] 为影片 ID。
  Future<void> addWatchHistory({required int movieId, String? token}) async {
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/watch-history'),
      headers: headers,
      body: jsonEncode(<String, dynamic>{'movieId': movieId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(body['error'] ?? body['message'] ?? '添加观看历史失败');
    }
  }
}

