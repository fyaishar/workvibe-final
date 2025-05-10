import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../lib/app/theme/theme.dart';
import '../../lib/app/theme/colors.dart';
import '../../lib/app/theme/text_styles.dart';
import '../../lib/app/theme/spacing.dart';

void main() {
  group('App Theme System Tests', () {
    testWidgets('Dark theme is properly configured', (WidgetTester tester) async {
      // Build a widget with the dark theme
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Builder(
              builder: (context) {
                final theme = Theme.of(context);
                // Return a widget that displays theme properties
                return Column(
                  children: [
                    Text('Test', style: theme.textTheme.bodyLarge),
                    Container(color: theme.colorScheme.background),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Button'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Verify the widget builds successfully
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Button'), findsOneWidget);
    });

    test('AppColors provides consistent color palette', () {
      // Verify essential colors are defined
      expect(AppColors.appBackground, isNotNull);
      expect(AppColors.moduleBackground, isNotNull);
      expect(AppColors.sessionCardBackground, isNotNull);
      expect(AppColors.primaryText, isNotNull);
      expect(AppColors.secondaryText, isNotNull);
      expect(AppColors.placeholder, isNotNull);
      expect(AppColors.active, isNotNull);
      expect(AppColors.error, isNotNull);
      expect(AppColors.connected, isNotNull);
      expect(AppColors.disconnected, isNotNull);
      expect(AppColors.inputBackground, isNotNull);
    });
    
    test('TextStyles provides consistent text styling', () {
      // Verify essential text styles exist (using our main text styles based on previous implementations)
      expect(TextStyles.task, isNotNull);
      expect(TextStyles.username, isNotNull);
      expect(TextStyles.placeholder, isNotNull);
      expect(TextStyles.inputLabel, isNotNull);
      expect(TextStyles.inputText, isNotNull);
    });
    
    test('Spacing provides consistent layout values', () {
      // Verify essential spacing values are defined (using known values from our implementation)
      expect(Spacing.small, isNotNull);
      expect(Spacing.medium, isNotNull);
      expect(Spacing.large, isNotNull);
      expect(Spacing.borderRadius, isNotNull);
      expect(Spacing.borderWidth, isNotNull);
    });
    
    testWidgets('Theme elements appear correctly in the UI', (WidgetTester tester) async {
      // Build a widget that demonstrates theme elements
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              backgroundColor: AppColors.appBackground,
              body: Padding(
                padding: EdgeInsets.all(Spacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Username Text', style: TextStyles.username),
                    SizedBox(height: Spacing.small),
                    Text('Task Text', style: TextStyles.task),
                    SizedBox(height: Spacing.medium),
                    Container(
                      padding: EdgeInsets.all(Spacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.sessionCardBackground,
                        borderRadius: BorderRadius.circular(Spacing.borderRadius),
                        border: Border.all(
                          color: AppColors.active,
                          width: Spacing.borderWidth,
                        ),
                      ),
                      child: Text('Card Content', style: TextStyles.inputText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      // Verify the texts are displayed
      expect(find.text('Username Text'), findsOneWidget);
      expect(find.text('Task Text'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });
  });
} 