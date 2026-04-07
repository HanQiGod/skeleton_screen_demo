import 'package:flutter_test/flutter_test.dart';

import 'package:skeleton_screen_demo/main.dart';

void main() {
  testWidgets('renders skeleton demo and toggles loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter 骨架屏 Demo'), findsOneWidget);
    expect(find.text('告别白屏焦虑'), findsOneWidget);
    expect(find.text('模拟请求'), findsOneWidget);
    expect(find.text('结束加载'), findsOneWidget);

    await tester.tap(find.text('结束加载'));
    await tester.pumpAndSettle();

    expect(find.text('直接显示内容'), findsOneWidget);
  });
}
