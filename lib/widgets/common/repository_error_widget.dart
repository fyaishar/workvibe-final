import 'package:flutter/material.dart';
import '../../core/models/exceptions/repository_exceptions.dart';

/// A widget that displays repository errors in a user-friendly way
class RepositoryErrorWidget extends StatelessWidget {
  /// The exception to display
  final RepositoryException exception;
  
  /// Callback when retry button is pressed
  final VoidCallback? onRetry;
  
  /// Custom widget to display instead of the default message
  final Widget? customErrorWidget;
  
  /// Create a new repository error widget
  const RepositoryErrorWidget({
    super.key,
    required this.exception,
    this.onRetry,
    this.customErrorWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    // Use custom widget if provided
    if (customErrorWidget != null) {
      return customErrorWidget!;
    }
    
    // Determine if we should show a retry button
    final bool showRetryButton = onRetry != null && _isRetryableException(exception);
    
    // Get the appropriate icon
    final IconData icon = _getIconForException(exception);
    
    // Get the user-friendly message
    final String message = exception.toUserFriendlyMessage();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: _getColorForException(exception, context),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (showRetryButton) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Returns the appropriate icon for the exception type
  IconData _getIconForException(RepositoryException exception) {
    if (exception is ResourceNotFoundException) {
      return Icons.search_off;
    } else if (exception is ValidationException) {
      return Icons.error_outline;
    } else if (exception is DuplicateResourceException) {
      return Icons.copy;
    } else if (exception is PermissionDeniedException) {
      return Icons.no_accounts;
    } else if (exception is NetworkException) {
      return Icons.wifi_off;
    } else if (exception is TimeoutException) {
      return Icons.timer_off;
    } else if (exception is ConstraintViolationException) {
      return Icons.link_off;
    } else {
      return Icons.warning_amber;
    }
  }
  
  /// Returns the appropriate color for the exception type
  Color _getColorForException(RepositoryException exception, BuildContext context) {
    if (exception is ResourceNotFoundException) {
      return Colors.orange;
    } else if (exception is ValidationException) {
      return Colors.red;
    } else if (exception is DuplicateResourceException) {
      return Colors.amber;
    } else if (exception is PermissionDeniedException) {
      return Colors.red.shade800;
    } else if (exception is NetworkException) {
      return Colors.blue;
    } else if (exception is TimeoutException) {
      return Colors.purple;
    } else if (exception is ConstraintViolationException) {
      return Colors.deepOrange;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }
  
  /// Determines if an exception is retryable
  bool _isRetryableException(RepositoryException exception) {
    if (exception is NetworkException) {
      return exception.isRetryable;
    } else if (exception is TimeoutException) {
      return exception.isRetryable;
    }
    
    return false;
  }
}

/// An extension to use repository errors in FutureBuilder and StreamBuilder
extension RepositoryErrorBuilderExtension on AsyncSnapshot {
  /// Returns true if this snapshot contains a repository error
  bool get hasRepositoryError => 
      hasError && error is RepositoryException;
  
  /// Returns the repository exception if one exists
  RepositoryException? get repositoryError => 
      hasRepositoryError ? error as RepositoryException : null;
      
  /// Builds a repository error widget if this snapshot has a repository error
  Widget buildRepositoryError({
    VoidCallback? onRetry,
    Widget? customErrorWidget,
  }) {
    if (!hasRepositoryError) {
      return const SizedBox.shrink();
    }
    
    return RepositoryErrorWidget(
      exception: repositoryError!,
      onRetry: onRetry,
      customErrorWidget: customErrorWidget,
    );
  }
} 