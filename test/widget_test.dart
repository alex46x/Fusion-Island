import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fusion Island Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Fusion Island')),
        ),
      ),
    );
    expect(find.text('Fusion Island'), findsOneWidget);
  });
}
