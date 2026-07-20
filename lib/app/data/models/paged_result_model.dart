import 'movie_model.dart';

/// 分页查询结果包装类。
class PagedResult<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool last;

  const PagedResult({
    required this.content,
    required this.page,
    required this.size,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final List<dynamic> contentJson = (json['content'] as List?) ?? <dynamic>[];
    return PagedResult<T>(
      content: contentJson
          .map((dynamic e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['number'] as int?) ?? (json['page'] as int?) ?? 0,
      size: (json['size'] as int?) ?? 10,
      totalPages: (json['totalPages'] as int?) ?? 0,
      totalElements: (json['totalElements'] as int?) ?? 0,
      last: (json['last'] as bool?) ?? true,
    );
  }
}

/// 电影分页结果类型别名，便于使用。
typedef PagedMovies = PagedResult<Movie>;
