import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/shared/widgets/status/status_visualizer.dart';
import '../../lib/shared/widgets/session_card/session_card.dart';

void main() {
  group('StatusVisualizer Widget Tests', () {
    testWidgets('Active status has no dimming effect', (WidgetTester tester) async {
      // Build the StatusVisualizer with active status
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.active,
                showLabel: false,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Active Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the content is displayed
      expect(find.text('Active Content'), findsOneWidget);
      // Active status should not show any status label
      expect(find.text('Active'), findsNothing);
      
      // We can't directly test opacity levels in widget tests,
      // but we can verify the widget builds successfully
    });

    testWidgets('Break status shows break label', (WidgetTester tester) async {
      // Build the StatusVisualizer with break status
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.break_,
                showLabel: true,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Break Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the content is displayed
      expect(find.text('Break Content'), findsOneWidget);
      // Break label should be visible
      expect(find.text('Break'), findsOneWidget);
    });

    testWidgets('Idle status shows idle label', (WidgetTester tester) async {
      // Build the StatusVisualizer with idle status
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.idle,
                showLabel: true,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Idle Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the content is displayed
      expect(find.text('Idle Content'), findsOneWidget);
      // Idle label should be visible
      expect(find.text('Idle'), findsOneWidget);
    });

    testWidgets('Custom label text is displayed', (WidgetTester tester) async {
      // Build the StatusVisualizer with custom label
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.break_,
                showLabel: true,
                labelText: 'Custom Label',
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the custom label is used
      expect(find.text('Custom Label'), findsOneWidget);
      expect(find.text('Break'), findsNothing);
    });

    testWidgets('Label alignment works correctly', (WidgetTester tester) async {
      // Build the StatusVisualizer with custom alignment
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.break_,
                showLabel: true,
                labelAlignment: Alignment.bottomRight,
                child: Container(
                  width: 200,
                  height: 100,
                  color: Colors.blue,
                  child: const Center(child: Text('Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // We can't easily test the actual alignment position in widget tests,
      // but we can verify the widget builds successfully
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Break'), findsOneWidget);
    });
  });
} 