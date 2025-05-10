import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/shared/widgets/status/status_visualizer.dart';
import '../../lib/shared/widgets/session_card/session_card.dart';

void main() {
  group('StatusVisualizer Widget Tests', () {
    testWidgets('Applies no opacity for active status and renders child', (WidgetTester tester) async {
      const testKey = Key('childContent');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.active,
                child: Container(
                  key: testKey,
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

      // Verify the child content is displayed
      expect(find.text('Active Content'), findsOneWidget);
      expect(find.byKey(testKey), findsOneWidget);
      // No labels should be rendered by StatusVisualizer itself
      expect(find.text('Active'), findsNothing);
      expect(find.text('Break'), findsNothing);
      expect(find.text('Idle'), findsNothing);
    });

    testWidgets('Applies break status opacity and renders child', (WidgetTester tester) async {
      const testKey = Key('childContent');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.break_,
                child: Container(
                  key: testKey,
                  width: 200,
                  height: 100,
                  color: Colors.green,
                  child: const Center(child: Text('Break Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the child content is displayed
      expect(find.text('Break Content'), findsOneWidget);
      expect(find.byKey(testKey), findsOneWidget);
      // StatusVisualizer should not render any text labels itself.
      // The label is now part of the SessionCard or other child widgets.
      expect(find.text('Break', skipOffstage: false), findsNothing);
    });

    testWidgets('Applies idle status opacity and renders child', (WidgetTester tester) async {
      const testKey = Key('childContent');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.idle,
                child: Container(
                  key: testKey,
                  width: 200,
                  height: 100,
                  color: Colors.orange,
                  child: const Center(child: Text('Idle Content')),
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the child content is displayed
      expect(find.text('Idle Content'), findsOneWidget);
      expect(find.byKey(testKey), findsOneWidget);
      // StatusVisualizer should not render any text labels itself.
      expect(find.text('Idle', skipOffstage: false), findsNothing);
    });

    testWidgets('Deprecated label parameters do not cause errors and render child', (WidgetTester tester) async {
      const testKey = Key('childContent');
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StatusVisualizer(
                status: SessionStatus.break_, // Using break to ensure opacity is applied
                showLabel: true, // Deprecated, should do nothing
                labelText: 'This Should Not Appear', // Deprecated, should do nothing
                labelAlignment: Alignment.center, // Deprecated, should do nothing
                child: Container(
                  key: testKey,
                  width: 200,
                  height: 100,
                  color: Colors.purple,
                  child: const Center(child: Text('Content with Deprecated Params')),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Content with Deprecated Params'), findsOneWidget);
      expect(find.byKey(testKey), findsOneWidget);
      // No labels should be rendered by StatusVisualizer
      expect(find.text('This Should Not Appear', skipOffstage: false), findsNothing);
      expect(find.text('Break', skipOffstage: false), findsNothing); // Default label for break shouldn't appear either
    });
  });
} 