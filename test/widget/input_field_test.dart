import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/shared/widgets/input/custom_text_field.dart';
import '../../lib/app/theme/colors.dart';

void main() {
  group('Custom Input Field Tests', () {
    testWidgets('Custom TextField renders correctly', (WidgetTester tester) async {
      // Test controller to track input
      final controller = TextEditingController();
      bool onChangedCalled = false;
      
      // Build a custom text field
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: controller,
                placeholder: 'Enter your text',
                prefixIcon: Icons.edit,
                onChanged: (value) {
                  onChangedCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify the field renders with the expected placeholder text and icon
      expect(find.text('Enter your text'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      
      // Test entering text
      await tester.enterText(find.byType(TextField), 'Test input');
      await tester.pump();
      
      // Verify the controller received the text and onChanged was called
      expect(controller.text, 'Test input');
      expect(onChangedCalled, true);
    });

    testWidgets('Custom TextField displays error text', (WidgetTester tester) async {
      // Test controller
      final controller = TextEditingController();
      
      // Build a custom text field with error
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: controller,
                placeholder: 'Required field',
                errorText: 'Field cannot be empty',
              ),
            ),
          ),
        ),
      );

      // Error should be displayed below the field
      expect(find.text('Field cannot be empty'), findsOneWidget);
    });

    testWidgets('Custom TextField respects theme styling', (WidgetTester tester) async {
      // Build a custom text field
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: CustomTextField(
                controller: TextEditingController(),
                placeholder: 'Themed input',
              ),
            ),
          ),
        ),
      );

      // The field should be rendered with the theme's styling
      // We can't easily test exact colors in widget tests, 
      // but we can verify the widget builds successfully
      expect(find.text('Themed input'), findsOneWidget);
    });
    
    testWidgets('Custom TextField with custom suffix icon', (WidgetTester tester) async {
      bool suffixTapped = false;
      
      // Build a custom text field with suffix icon
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: TextEditingController(),
                placeholder: 'With suffix',
                suffixIcon: Icons.clear,
                onSuffixIconPressed: () {
                  suffixTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Verify suffix icon is shown
      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      // Tap the suffix icon
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      
      // Verify the callback was called
      expect(suffixTapped, true);
    });
    
    testWidgets('Custom TextField with label shows required indicator', (WidgetTester tester) async {
      // Build a custom text field with label and required indicator
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CustomTextField(
                controller: TextEditingController(),
                placeholder: 'Labeled field',
                label: 'Important Field',
                isRequired: true,
              ),
            ),
          ),
        ),
      );

      // Verify the label is displayed
      expect(find.text('Important Field'), findsOneWidget);
      
      // Required indicator (*) should be visible
      expect(find.text('*'), findsOneWidget);
    });
  });
} 