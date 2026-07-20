import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/movie_model.dart';
import '../../data/repositories/movie_repository.dart';
import '../auth/auth_controller.dart';

/// 发现页控制器：负责影片搜索。
class DiscoverController extends GetxController {
  DiscoverController(this._repository);

  final MovieRepository _repository;

  final TextEditingController keywordController = TextEditingController();
  final RxList<Movie> results = <Movie>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  /// 根据关键字搜索影片。
  Future<void> search(String keyword) async {
    final String query = keyword.trim();
    if (query.isEmpty) {
      results.clear();
      error.value = '';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final List<Movie> list = await _repository.searchMovies(
        query,
        token: AuthController.to.isLoggedIn.value
            ? AuthController.to.token.value
            : null,
      );
      results.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    keywordController.dispose();
    super.onClose();
  }
}
