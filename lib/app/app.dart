import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes/app_pages.dart';
import 'theme/app_theme.dart';

/// 应用根：集中配置 GetMaterialApp（路由、主题、依赖注入等）。
class App {
  App._();

  static GetMaterialApp init() {
    AppPages.initDependencies();
    return GetMaterialApp(
      title: 'Flutter Movie',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
    );
  }
}
