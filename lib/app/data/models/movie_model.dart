/// 电影数据模型。
import '../../config/app_config.dart';

/// 演员 / 主创信息。
class Cast {
  final String name;
  final String role;
  final String avatar;

  const Cast({required this.name, required this.role, this.avatar = ''});

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        name: (json['name'] as String?) ?? '',
        role: (json['role'] as String?) ?? '',
        avatar: (json['avatar'] as String?) ?? '',
      );

  /// 实际展示用的头像地址（相对路径自动拼接后端 baseUrl）。
  String get displayAvatar => avatar.startsWith('/')
      ? '${AppConfig.apiBaseUrl}$avatar'
      : avatar;
}

class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String releaseDate;
  final String videoUrl;
  final List<String> genres;
  final int runtime; // 时长（分钟）

  /// 演员表（导演 / 主演等）。
  final List<Cast> casts;

  /// 是否已收藏（由影片查询接口列表项返回）。
  final bool favorited;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.releaseDate,
    this.videoUrl = '',
    this.genres = const <String>[],
    this.runtime = 0,
    this.casts = const <Cast>[],
    this.favorited = false,
  });

  /// 返回字段被替换后的副本（用于更新列表项的收藏状态）。
  Movie copyWith({
    int? id,
    String? title,
    String? overview,
    String? posterPath,
    double? voteAverage,
    String? releaseDate,
    String? videoUrl,
    List<String>? genres,
    int? runtime,
    List<Cast>? casts,
    bool? favorited,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      overview: overview ?? this.overview,
      posterPath: posterPath ?? this.posterPath,
      voteAverage: voteAverage ?? this.voteAverage,
      releaseDate: releaseDate ?? this.releaseDate,
      videoUrl: videoUrl ?? this.videoUrl,
      genres: genres ?? this.genres,
      runtime: runtime ?? this.runtime,
      casts: casts ?? this.casts,
      favorited: favorited ?? this.favorited,
    );
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] as String?) ?? '',
      overview: (json['overview'] as String?) ?? '',
      posterPath: (json['posterPath'] as String?) ?? (json['poster_path'] as String?) ?? '',
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: (json['releaseDate'] as String?) ?? (json['release_date'] as String?) ?? '',
      videoUrl: (json['videoUrl'] as String?) ?? (json['video_url'] as String?) ?? '',
      genres: (json['genres'] as List?)?.map((e) => e as String).toList() ?? const <String>[],
      runtime: (json['runtime'] as int?) ?? 0,
      casts: (json['casts'] as List?)
              ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Cast>[],
      favorited: (json['favorited'] as bool?) ?? (json['favourited'] as bool?) ?? false,
    );
  }

  /// 将分钟格式化为「X小时Y分钟」。
  String get runtimeText {
    if (runtime <= 0) return '--';
    final int h = runtime ~/ 60;
    final int m = runtime % 60;
    if (h <= 0) return '${m}分钟';
    if (m <= 0) return '${h}小时';
    return '${h}小时${m}分钟';
  }

  /// 实际展示用的海报地址。
  ///
  /// 后端可能返回：
  /// - 相对路径（如 `/api/proxy/image?url=...`）：自动拼接后端 baseUrl；
  /// - 绝对地址（以 http 开头）：原样使用。
  String get displayPoster => posterPath.startsWith('/')
      ? '${AppConfig.apiBaseUrl}$posterPath'
      : posterPath;
}
