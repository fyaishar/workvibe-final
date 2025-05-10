import 'dart:io' show SocketException;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Base exception for all repository-related errors
class RepositoryException implements Exception {
  /// The repository operation that failed
  final String operation;
  
  /// A user-friendly error message
  final String message;
  
  /// The original error that caused this exception
  final Object? originalError;
  
  /// Additional context information about the error
  final Map<String, dynamic>? context;
  
  /// Creates a new [RepositoryException]
  /// 
  /// [operation] identifies the repository method that failed
  /// [message] provides a human-readable description of the error
  /// [originalError] contains the underlying exception for debugging
  /// [context] contains additional information about the error context
  RepositoryException({
    required this.operation,
    required this.message,
    this.originalError,
    this.context,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('RepositoryException: [$operation] $message');
    
    if (originalError != null) {
      buffer.write('\nCaused by: $originalError');
    }
    
    if (context != null && context!.isNotEmpty) {
      buffer.write('\nContext: $context');
    }
    
    return buffer.toString();
  }
  
  /// Creates a user-friendly message suitable for displaying in the UI
  String toUserFriendlyMessage() {
    return message;
  }
}

/// Exception thrown when a resource is not found in the repository
class ResourceNotFoundException extends RepositoryException {
  /// The ID of the resource that was not found
  final String? resourceId;
  
  /// The type of resource that was not found
  final String? resourceType;
  
  ResourceNotFoundException({
    required String operation,
    String? message,
    this.resourceId,
    this.resourceType,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'The requested ${resourceType ?? 'resource'} ${resourceId != null ? 'with ID $resourceId ' : ''}was not found',
         originalError: originalError,
         context: {
           if (resourceId != null) 'resourceId': resourceId,
           if (resourceType != null) 'resourceType': resourceType,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    return 'The requested ${resourceType ?? 'item'} could not be found. It may have been deleted or moved.';
  }
}

/// Exception thrown when validation fails on repository operations
class ValidationException extends RepositoryException {
  /// Map of field names to validation error messages
  final Map<String, String>? validationErrors;
  
  ValidationException({
    required String operation,
    String? message,
    this.validationErrors,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'Validation failed for $operation operation',
         originalError: originalError,
         context: {
           if (validationErrors != null) 'validationErrors': validationErrors,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return 'Some data entered is invalid. Please check the form and try again.';
    }
    
    final errorList = validationErrors!.entries
        .map((e) => '• ${e.key}: ${e.value}')
        .join('\n');
    return 'Please fix the following issues:\n$errorList';
  }
}

/// Exception thrown when a duplicate resource is detected
class DuplicateResourceException extends RepositoryException {
  /// The field that caused the duplicate conflict
  final String? conflictingField;
  
  DuplicateResourceException({
    required String operation,
    String? message,
    this.conflictingField,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'A duplicate resource was detected',
         originalError: originalError,
         context: {
           if (conflictingField != null) 'conflictingField': conflictingField,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    if (conflictingField != null) {
      return 'A record with the same $conflictingField already exists.';
    }
    return 'This record already exists in the system.';
  }
}

/// Exception thrown when a user lacks permission for an operation
class PermissionDeniedException extends RepositoryException {
  /// The permission that was required but missing
  final String? requiredPermission;
  
  PermissionDeniedException({
    required String operation,
    String? message,
    this.requiredPermission,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'Permission denied for $operation operation',
         originalError: originalError,
         context: {
           if (requiredPermission != null) 'requiredPermission': requiredPermission,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    return 'You don\'t have permission to perform this action.';
  }
}

/// Exception thrown when a repository operation fails due to network issues
class NetworkException extends RepositoryException {
  /// Whether the operation should be retried
  final bool isRetryable;
  
  /// The number of retry attempts already made
  final int retryAttempts;
  
  NetworkException({
    required String operation,
    String? message,
    this.isRetryable = true,
    this.retryAttempts = 0,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'Network error during $operation operation',
         originalError: originalError,
         context: {
           'isRetryable': isRetryable,
           'retryAttempts': retryAttempts,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    if (isRetryable) {
      return 'Network connection issue. Please check your internet connection and try again.';
    }
    return 'A network error occurred. Please try again later.';
  }
  
  /// Creates a new NetworkException with an incremented retry count
  NetworkException withIncrementedRetryCount() {
    return NetworkException(
      operation: operation,
      message: message,
      isRetryable: isRetryable,
      retryAttempts: retryAttempts + 1,
      originalError: originalError,
      context: context,
    );
  }
}

/// Exception thrown when a repository operation times out
class TimeoutException extends RepositoryException {
  /// Whether the operation should be retried
  final bool isRetryable;
  
  /// The duration after which the operation timed out
  final Duration? timeoutDuration;
  
  TimeoutException({
    required String operation,
    String? message,
    this.isRetryable = true,
    this.timeoutDuration,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'Operation $operation timed out',
         originalError: originalError,
         context: {
           'isRetryable': isRetryable,
           if (timeoutDuration != null) 'timeoutDuration': timeoutDuration.toString(),
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    return 'The operation took too long to complete. Please try again later.';
  }
}

/// Exception for database constraint violations
class ConstraintViolationException extends RepositoryException {
  /// The name of the constraint that was violated
  final String? constraintName;
  
  /// The type of constraint (e.g., 'foreign_key', 'unique', 'check')
  final String? constraintType;
  
  ConstraintViolationException({
    required String operation,
    String? message,
    this.constraintName,
    this.constraintType,
    Object? originalError,
    Map<String, dynamic>? context,
  }) : super(
         operation: operation,
         message: message ?? 'Constraint violation during $operation operation',
         originalError: originalError,
         context: {
           if (constraintName != null) 'constraintName': constraintName,
           if (constraintType != null) 'constraintType': constraintType,
           if (context != null) ...context,
         },
       );
       
  @override
  String toUserFriendlyMessage() {
    if (constraintType == 'foreign_key') {
      return 'This action would break data relationships. Please check related items.';
    } else if (constraintType == 'unique') {
      return 'A duplicate entry was detected. Please use a unique value.';
    }
    return 'This operation violates database constraints.';
  }
}

/// Factory class for creating repository exceptions from Supabase errors
class RepositoryExceptionFactory {
  /// Creates the appropriate repository exception based on the error type
  static RepositoryException fromSupabaseError({
    required String operation,
    required Object error,
    Map<String, dynamic>? context,
  }) {
    // PostgreSQL errors
    if (error is PostgrestException) {
      final code = error.code;
      
      // Resource not found
      if (code == 'PGRST116' || error.message.contains('not found') || error.message.contains('no rows')) {
        return ResourceNotFoundException(
          operation: operation,
          originalError: error,
          context: context,
        );
      }
      
      // Foreign key violations
      if (code == '23503') {
        return ConstraintViolationException(
          operation: operation,
          constraintType: 'foreign_key',
          originalError: error,
          context: context,
        );
      }
      
      // Unique constraint violations
      if (code == '23505') {
        final fieldMatch = RegExp(r'Key \((.+)\)=').firstMatch(error.message);
        final field = fieldMatch?.group(1);
        
        return DuplicateResourceException(
          operation: operation,
          conflictingField: field,
          originalError: error,
          context: context,
        );
      }
      
      // Check constraint violations
      if (code == '23514') {
        return ConstraintViolationException(
          operation: operation,
          constraintType: 'check',
          originalError: error,
          context: context,
        );
      }
      
      // Permission errors
      if (code == '42501' || error.message.contains('permission denied')) {
        return PermissionDeniedException(
          operation: operation,
          originalError: error,
          context: context,
        );
      }
    }
    
    // Authentication errors
    if (error is AuthException) {
      if (error.message.contains('timeout') || error.message.contains('timed out')) {
        return TimeoutException(
          operation: operation,
          originalError: error,
          context: context,
        );
      }
      
      // Various auth errors
      if (error.message.contains('invalid') || error.message.contains('password')) {
        return ValidationException(
          operation: operation,
          message: error.message,
          originalError: error,
          context: context,
        );
      }
      
      if (error.message.contains('permission') || error.message.contains('not allowed')) {
        return PermissionDeniedException(
          operation: operation,
          originalError: error,
          context: context,
        );
      }
    }
    
    // Dart socket exceptions -> Network errors
    if (error is SocketException) {
      return NetworkException(
        operation: operation,
        originalError: error,
        context: context,
      );
    }
    
    // Generic Supabase errors for network issues
    if (error.toString().contains('network') || 
        error.toString().contains('connection') ||
        error.toString().contains('timeout') ||
        error.toString().contains('timed out')) {
      
      return NetworkException(
        operation: operation,
        originalError: error,
        context: context,
      );
    }
    
    // Default: generic repository exception
    return RepositoryException(
      operation: operation,
      message: 'An error occurred during repository operation: $operation',
      originalError: error,
      context: context,
    );
  }
} 