import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_movie/app/app.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('应用启动并渲染 GetMaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(App.init());

    // 初始路由为电影页，应展示 GetMaterialApp 与顶部标题
    expect(find.byType(GetMaterialApp), findsOneWidget);
    expect(find.text('电影列表'), findsWidgets);
  });
}
