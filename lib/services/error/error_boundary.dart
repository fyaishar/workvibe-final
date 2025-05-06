import 'package:flutter/material.dart';
import 'logging_service.dart';

/// A widget that catches errors in its child widget tree and displays a fallback UI
class ErrorBoundary extends StatefulWidget {
  /// The child widget that might throw errors
  final Widget child;
  
  /// The widget to display when an error occurs
  final Widget Function(FlutterErrorDetails errorDetails)? errorBuilder;
  
  /// Optional callback that is called when an error occurs
  final void Function(FlutterErrorDetails errorDetails)? onError;
  
  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  /// Error details if an error occurs
  FlutterErrorDetails? _errorDetails;
  
  /// The logging service
  final _loggingService = LoggingService();

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      // If an error has occurred, display the error widget
      return widget.errorBuilder != null
          ? widget.errorBuilder!(_errorDetails!)
          : _DefaultErrorWidget(errorDetails: _errorDetails!);
    }
    
    // Otherwise, display the child widget inside an error catcher
    return _ErrorCatcher(
      child: widget.child,
      onError: (errorDetails) {
        _loggingService.error(
          'Widget error caught by ErrorBoundary',
          category: LogCategory.ui,
          error: errorDetails.exception,
          stackTrace: errorDetails.stack,
        );
        
        // Call the onError callback if provided
        if (widget.onError != null) {
          widget.onError!(errorDetails);
        }
        
        // Update state to display the error widget
        setState(() {
          _errorDetails = errorDetails;
        });
      },
    );
  }
}

/// A widget that catches errors in its child widget
class _ErrorCatcher extends StatelessWidget {
  final Widget child;
  final void Function(FlutterErrorDetails) onError;

  const _ErrorCatcher({
    Key? key,
    required this.child,
    required this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use ErrorWidget.builder to catch errors
    final originalErrorWidgetBuilder = ErrorWidget.builder;
    
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      // Call the onError callback
      onError(errorDetails);
      
      // Return an empty container for now, we'll replace it with our error widget
      return Container();
    };
    
    // Ensure we reset the error widget builder
    Future.microtask(() {
      ErrorWidget.builder = originalErrorWidgetBuilder;
    });
    
    return child;
  }
}

/// The default error widget to display when an error occurs
class _DefaultErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const _DefaultErrorWidget({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The application encountered an error.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Reset the error boundary by forcing a rebuild
                (context.findAncestorStateOfType<_ErrorBoundaryState>() 
                  ?..setState(() {
                    context.findAncestorStateOfType<_ErrorBoundaryState>()?._errorDetails = null;
                  }));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
} 