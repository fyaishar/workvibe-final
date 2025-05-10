import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/models/exceptions/repository_exceptions.dart';
import 'logging_service.dart';

/// A specialized error handler for repository operations with comprehensive error mapping
/// and retry functionality.
class RepositoryErrorHandler {
  static final RepositoryErrorHandler _instance = RepositoryErrorHandler._internal();
  final LoggingService _loggingService = LoggingService();
  
  factory RepositoryErrorHandler() {
    return _instance;
  }
  
  RepositoryErrorHandler._internal();
  
  /// Execute a repository operation with automatic error handling and retry logic
  /// 
  /// [operationName] - The name of the repository operation for logging and error context
  /// [operation] - The actual operation function to execute
  /// [entityType] - The type of entity being operated on (e.g., 'user', 'task')
  /// [entityId] - The ID of the specific entity (if applicable)
  /// [context] - Additional context information for error reporting
  /// [maxRetries] - Maximum number of retry attempts for retryable errors
  /// [retryDelay] - Initial delay between retry attempts (doubles with each attempt)
  /// 
  /// Returns the result of the operation if successful
  /// Throws an appropriate RepositoryException if the operation fails
  Future<T> executeWithRetry<T>({
    required String operationName,
    required Future<T> Function() operation,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? context,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    Duration currentDelay = retryDelay;
    Map<String, dynamic> errorContext = {
      if (entityType != null) 'entityType': entityType,
      if (entityId != null) 'entityId': entityId,
      if (context != null) ...context,
    };
    
    RepositoryException? lastException;
    
    while (attempts < maxRetries) {
      attempts++;
      
      try {
        final result = await operation();
        
        // Log success if this wasn't the first attempt (means we recovered from an error)
        if (attempts > 1) {
          _loggingService.info(
            'Repository operation succeeded after $attempts attempts',
            category: LogCategory.database,
            additionalData: {
              'operation': operationName,
              ...errorContext,
            },
          );
        }
        
        return result;
      } catch (error, stackTrace) {
        // Convert to appropriate repository exception
        final exception = _mapToRepositoryException(
          operationName: operationName,
          error: error,
          context: {
            'attempt': attempts,
            'maxRetries': maxRetries,
            ...errorContext,
          },
        );
        
        lastException = exception;
        
        // Log the error
        _loggingService.error(
          'Repository operation failed: $operationName',
          category: LogCategory.database,
          error: error,
          stackTrace: stackTrace,
          additionalData: {
            'exception': exception.toString(),
            'attempt': attempts,
            'maxRetries': maxRetries,
            ...errorContext,
          },
        );
        
        // Determine if we should retry based on exception type
        final shouldRetry = _shouldRetryException(exception) && attempts < maxRetries;
        
        if (!shouldRetry) {
          // Don't retry, throw the exception
          break;
        }
        
        // Log retry attempt
        _loggingService.info(
          'Retrying repository operation: $operationName (attempt ${attempts + 1}/$maxRetries)',
          category: LogCategory.database,
          additionalData: {
            'delay': currentDelay.inMilliseconds,
            ...errorContext,
          },
        );
        
        // Wait before retrying with exponential backoff
        await Future.delayed(currentDelay);
        currentDelay *= 2;
      }
    }
    
    // If we get here, all retries failed or we determined not to retry
    throw lastException ?? RepositoryException(
      operation: operationName,
      message: 'Repository operation failed after $attempts attempts',
      context: errorContext,
    );
  }
  
  /// Maps various error types to appropriate repository exceptions
  RepositoryException _mapToRepositoryException({
    required String operationName,
    required Object error,
    Map<String, dynamic>? context,
  }) {
    // If it's already a repository exception, just return it
    if (error is RepositoryException) {
      return error;
    }
    
    // Use factory to create appropriate exception type
    return RepositoryExceptionFactory.fromSupabaseError(
      operation: operationName,
      error: error,
      context: context,
    );
  }
  
  /// Determines if an exception should be retried based on its type and properties
  bool _shouldRetryException(RepositoryException exception) {
    // Network exceptions are generally retryable
    if (exception is NetworkException) {
      return exception.isRetryable;
    }
    
    // Timeout exceptions are generally retryable
    if (exception is TimeoutException) {
      return exception.isRetryable;
    }
    
    // Permission and validation errors are not retryable
    if (exception is PermissionDeniedException || 
        exception is ValidationException ||
        exception is DuplicateResourceException) {
      return false;
    }
    
    // Resource not found exceptions are usually not retryable
    if (exception is ResourceNotFoundException) {
      return false;
    }
    
    // Constraint violations are not retryable
    if (exception is ConstraintViolationException) {
      return false;
    }
    
    // Check if the context has a retryable flag
    if (exception.context != null && 
        exception.context!.containsKey('isRetryable')) {
      return exception.context!['isRetryable'] as bool;
    }
    
    // By default, don't retry generic exceptions
    return false;
  }
}

/// Extension for the LogCategory enum to add repository-specific categories
extension LogCategoryExtension on LogCategory {
  static const LogCategory repository = LogCategory('repository');
} 