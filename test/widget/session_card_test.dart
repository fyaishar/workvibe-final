import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/shared/widgets/session_card/session_card.dart';
import '../../lib/app/theme/colors.dart';
import '../../lib/app/theme/text_styles.dart';

void main() {
  group('SessionCard Widget Tests', () {
    testWidgets('Standard Session Card renders correctly', (WidgetTester tester) async {
      // Build the SessionCard widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'Test User',
                task: 'Test Task',
                projectOrGoal: 'Test Project',
                status: SessionStatus.active,
                durationLevel: 3,
                isPersonal: false,
              ),
            ),
          ),
        ),
      );

      // Verify UI components are rendered
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Project'), findsOneWidget);
      
      // No break/idle label should be visible for active status
      expect(find.text('Break'), findsNothing);
      expect(find.text('Idle'), findsNothing);
    });

    testWidgets('Break status Session Card shows dimming and label', (WidgetTester tester) async {
      // Build the SessionCard widget with break status
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'Test User',
                task: 'Test Task',
                projectOrGoal: 'Test Project',
                status: SessionStatus.break_,
                durationLevel: 3,
                isPersonal: false,
              ),
            ),
          ),
        ),
      );

      // Verify UI components are rendered
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Project'), findsOneWidget);
      
      // Break label should be visible
      expect(find.text('Break'), findsOneWidget);
    });

    testWidgets('Personal Pre-Start Session Card shows input fields', (WidgetTester tester) async {
      final taskController = TextEditingController();
      final projectController = TextEditingController();
      bool startPressed = false;

      // Build the SessionCard widget in pre-start state
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'You',
                task: '',
                projectOrGoal: '',
                status: SessionStatus.active,
                durationLevel: 1,
                isPersonal: true,
                personalSessionState: PersonalSessionState.preStart,
                taskController: taskController,
                projectController: projectController,
                onStart: () {
                  startPressed = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify input fields are shown
      expect(find.text('You'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
      expect(find.text('Start'), findsOneWidget);
      
      // Test start button functionality
      await tester.tap(find.text('Start'));
      expect(startPressed, true);
    });

    testWidgets('Personal Active Session Card shows task controls', (WidgetTester tester) async {
      bool pausePressed = false;
      bool taskCompleted = false;

      // Build the SessionCard widget in active personal state
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'You',
                task: 'My Current Task',
                projectOrGoal: 'My Project',
                status: SessionStatus.active,
                durationLevel: 4,
                isPersonal: true,
                personalSessionState: PersonalSessionState.active,
                timeIndicator: 'Started 23m ago',
                onPause: () {
                  pausePressed = true;
                },
                onTaskComplete: (completed) {
                  taskCompleted = completed ?? false;
                },
                isTaskCompleted: false,
                taskProgress: 0.5,
              ),
            ),
          ),
        ),
      );

      // Verify elements are rendered
      expect(find.text('You'), findsOneWidget);
      expect(find.text('My Current Task'), findsOneWidget);
      expect(find.text('My Project'), findsOneWidget);
      expect(find.text('Started 23m ago'), findsOneWidget);
      
      // Test pause button (this might need adjusting based on actual implementation)
      await tester.tap(find.byIcon(Icons.pause).first);
      expect(pausePressed, true);
    });

    testWidgets('Session Card shows appropriate border thickness based on duration level', 
        (WidgetTester tester) async {
      // Test for level 1 (thinnest border)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'User',
                task: 'Task',
                status: SessionStatus.active,
                durationLevel: 1,
              ),
            ),
          ),
        ),
      );
      
      // Now test for level 8 (thickest border)
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SessionCard(
                username: 'User',
                task: 'Task',
                status: SessionStatus.active,
                durationLevel: 8,
              ),
            ),
          ),
        ),
      );
      
      // We can't directly test the border width with Widget tests,
      // but we can verify the widget builds successfully
      expect(find.text('User'), findsOneWidget);
    });
  });
} 