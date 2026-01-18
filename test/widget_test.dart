// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:logcatviewer/main.dart';

void main() {
  testWidgets('LogcatViewer app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LogcatViewerApp());

    // Verify that the app title is present.
    expect(find.text('LogcatViewer'), findsOneWidget);

    // Verify toolbar buttons exist
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });
}
