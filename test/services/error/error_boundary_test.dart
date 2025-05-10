import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A simple widget that throws an error during build
class _ErrorThrowingWidget extends StatelessWidget {
  const _ErrorThrowingWidget();

  @override
  Widget build(BuildContext context) {
    throw Exception('Test Error From Widget');
  }
}

// A simple widget that builds normally
class _NormalWidget extends StatelessWidget {
  const _NormalWidget();

  @override
  Widget build(BuildContext context) {
    return const Text('Normal Widget Content');
  }
}

// Conceptual ErrorBoundary. For this test, we'll mostly rely on Flutter's
// default error handling (ErrorWidget) when a child throws.
// A real ErrorBoundary would use ErrorWidget.builder or other mechanisms.
class SimpleErrorBoundary extends StatelessWidget {
  final Widget child;

  const SimpleErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // In a real ErrorBoundary, you might have state to show a fallback UI
    // or use FlutterError.onError to catch and handle errors.
    // For this conceptual test, if the child throws, Flutter's default
    // ErrorWidget will be shown by the test framework.
    return child;
  }
}

void main() {
  group('Error Boundary Conceptual Tests', () {
    testWidgets('Displays child when no error occurs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleErrorBoundary(
            child: _NormalWidget(),
          ),
        ),
      );

      expect(find.text('Normal Widget Content'), findsOneWidget);
      // Ensure no default error widget is shown
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('Flutter default ErrorWidget is shown and correct exception is thrown', (WidgetTester tester) async {
      FlutterErrorDetails? capturedErrorDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        capturedErrorDetails = details;
        // originalOnError?.call(details); // Optionally call original handler
      };

      // We expect an Exception to be thrown
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleErrorBoundary(
            child: _ErrorThrowingWidget(),
          ),
        ),
      );

      // Verify that an ErrorWidget is on screen
      expect(find.byType(ErrorWidget), findsOneWidget, reason: "ErrorWidget should be present.");

      // Verify that the expected exception was caught by FlutterError.onError
      expect(capturedErrorDetails, isNotNull, reason: "FlutterError.onError should have been called.");
      expect(capturedErrorDetails!.exception, isA<Exception>(), reason: "The caught exception should be of type Exception.");
      expect(capturedErrorDetails!.exception.toString(), contains('Test Error From Widget'), 
        reason: "The exception message should match.");

      // Ensure the normal content is not rendered
      expect(find.text('Normal Widget Content'), findsNothing);

      // Restore original error handler
      FlutterError.onError = originalOnError;
    });
  });
} 