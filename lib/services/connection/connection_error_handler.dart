import 'package:flutter/foundation.dart';
import '../error/error_service.dart';
import '../error/error_types.dart';

/// Handles and categorizes WebSocket and Realtime connection errors
class ConnectionErrorHandler {
  /// Error service for general error handling
  final ErrorService _errorService;
  
  /// Whether to show debug information
  final bool _debug;

  /// Creates a new connection error handler.
  ConnectionErrorHandler({
    ErrorService? errorService,
    bool debug = false,
  }) : _errorService = errorService ?? ErrorService(),
       _debug = debug;
  
  /// Handles a connection error and returns a user-friendly message.
  ConnectionErrorResult handleConnectionError(dynamic error, {String? context}) {
    // Determine error type
    final errorType = _categorizeError(error);
    
    // Get user-friendly message based on error type
    final userMessage = _getUserMessage(errorType, error);
    
    // Additional context for logging
    final errorContext = context != null ? '$context: ' : '';
    
    // Log the error with the error service
    _errorService.logError(
      '$errorContext$userMessage',
      error: error,
      category: LogCategory.connection,
      type: errorType,
    );
    
    if (_debug) {
      debugPrint('Connection Error [$errorType]: $userMessage');
      if (error is Error) {
        debugPrintStack(stackTrace: error.stackTrace);
      }
    }
    
    return ConnectionErrorResult(
      type: errorType,
      message: userMessage,
      originalError: error,
    );
  }
  
  /// Categorizes an error based on its type and content.
  ErrorType _categorizeError(dynamic error) {
    if (error == null) {
      return ErrorType.unknown;
    }
    
    // Convert error to string for pattern matching
    final errorString = error.toString().toLowerCase();
    
    // Check for network connectivity issues
    if (errorString.contains('network') || 
        errorString.contains('socket') ||
        errorString.contains('connect') ||
        errorString.contains('connection') ||
        errorString.contains('timed out') ||
        errorString.contains('timeout')) {
      return ErrorType.networkError;
    }
    
    // Check for authentication issues
    if (errorString.contains('auth') || 
        errorString.contains('unauthorized') ||
        errorString.contains('permission') ||
        errorString.contains('access')) {
      return ErrorType.authenticationError;
    }
    
    // Check for server issues
    if (errorString.contains('server') || 
        errorString.contains('5') ||  // 5xx errors
        errorString.contains('service')) {
      return ErrorType.serverError;
    }
    
    // Check for rate limiting
    if (errorString.contains('limit') || 
        errorString.contains('throttle') ||
        errorString.contains('429')) {  // 429 Too Many Requests
      return ErrorType.rateLimitError;
    }
    
    // Default to generic error
    return ErrorType.unknown;
  }
  
  /// Returns a user-friendly message based on the error type.
  String _getUserMessage(ErrorType type, dynamic error) {
    switch (type) {
      case ErrorType.networkError:
        return 'Unable to connect to the server. Please check your internet connection.';
        
      case ErrorType.authenticationError:
        return 'Authentication failed. Please sign in again.';
        
      case ErrorType.serverError:
        return 'The server is experiencing issues. Please try again later.';
        
      case ErrorType.rateLimitError:
        return 'Too many requests. Please try again in a moment.';
        
      case ErrorType.unknown:
      default:
        if (error != null) {
          return 'Connection error: ${error.toString()}';
        } else {
          return 'An unknown connection error occurred.';
        }
    }
  }
  
  /// Determines if an error should trigger automatic reconnection.
  bool shouldReconnect(ErrorType type) {
    switch (type) {
      case ErrorType.networkError:
      case ErrorType.serverError:
      case ErrorType.rateLimitError:
        return true;
      case ErrorType.authenticationError:
      case ErrorType.unknown:
      default:
        return false;
    }
  }
  
  /// Suggests a reconnection delay based on the error type.
  int suggestReconnectDelay(ErrorType type, int attempt) {
    // Base delay is higher for server and rate limit issues
    int baseDelayMs;
    
    switch (type) {
      case ErrorType.rateLimitError:
        baseDelayMs = 5000;  // Start with 5 seconds for rate limiting
        break;
      case ErrorType.serverError:
        baseDelayMs = 3000;  // Start with 3 seconds for server errors
        break;
      case ErrorType.networkError:
      default:
        baseDelayMs = 1000;  // Start with 1 second for network errors
        break;
    }
    
    // Apply exponential backoff with a maximum of 30 seconds
    final delay = baseDelayMs * (1 << (attempt - 1));
    return delay.clamp(baseDelayMs, 30000);
  }
}

/// Result of handling a connection error
class ConnectionErrorResult {
  /// The type of error that occurred
  final ErrorType type;
  
  /// User-friendly error message
  final String message;
  
  /// The original error object
  final dynamic originalError;
  
  /// Whether this error should trigger a reconnection
  bool get shouldReconnect => type == ErrorType.networkError || 
                           type == ErrorType.serverError ||
                           type == ErrorType.rateLimitError;

  /// Creates a new connection error result.
  ConnectionErrorResult({
    required this.type,
    required this.message,
    this.originalError,
  });
} 