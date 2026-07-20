import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/auth/auth_controller.dart';
import '../../routes/app_routes.dart';

/// 可复用的底部导航栏（深色毛玻璃浮动样式）。
///
/// 点击 Tab 通过 [Get.offAllNamed] 按路由跳转，并高亮当前路由对应的 Tab。
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  static const List<String> _routes = <String>[
    AppRoutes.movies,
    AppRoutes.favorites,
    AppRoutes.discover,
    AppRoutes.profile,
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.movie_creation_outlined,
    Icons.star_outline,
    Icons.search_outlined,
    Icons.person_outline,
  ];

  /// 根据当前路由名计算高亮索引。
  int get _currentIndex {
    final int index = _routes.indexOf(Get.currentRoute);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _currentIndex;
    const Color activeColor = Color(0xFFFF7A2E); // 橙色高亮
    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 8, 16, 20 + bottomInset),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(_icons.length, (int i) {
              final bool selected = currentIndex == i;
              return GestureDetector(
                onTap: () {
                  if (_routes[i] == AppRoutes.profile &&
                      !AuthController.to.isLoggedIn.value) {
                    Get.offAllNamed(AppRoutes.login);
                  } else {
                    Get.offAllNamed(_routes[i]);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? activeColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _icons[i],
                    size: 22,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
