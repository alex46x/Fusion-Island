// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fusion_island/main.dart';

void main() {
  testWidgets('FusionIslandApp builds test', (WidgetTester tester) async {
    Animate.restartOnHotReload = false;
    await tester.pumpWidget(const ProviderScope(child: FusionIslandApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(FusionIslandApp), findsOneWidget);
  });
}
