// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalworkvibe/features/session/presentation/start_page.dart';

void main() {
  testWidgets('StartPage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: StartPage()));

    // Verify that the main sections are present
    expect(find.text('Text Styles'), findsOneWidget);
    expect(find.text('Inputs & Buttons'), findsOneWidget);
    expect(find.text('Session Cards'), findsOneWidget);

    // Verify that some example content is present
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Task'), findsOneWidget);
    expect(find.text('Project'), findsOneWidget);
  });
}
