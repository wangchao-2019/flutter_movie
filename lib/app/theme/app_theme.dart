import 'package:flutter/material.dart';

/// 应用主题配置（亮色 / 暗色）。
class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  static final dark = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );
}
