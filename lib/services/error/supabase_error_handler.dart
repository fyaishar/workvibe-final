import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_service.dart';
import 'logging_service.dart';

/// A specialized error handler for Supabase operations with retry functionality
class SupabaseErrorHandler {
  static final SupabaseErrorHandler _instance = SupabaseErrorHandler._internal();
  final ErrorService _errorService = ErrorService();
  final LoggingService _loggingService = LoggingService();
  
  factory SupabaseErrorHandler() {
    return _instance;
  }
  
  SupabaseErrorHandler._internal();
  
  /// Execute a Supabase operation with automatic error handling and retry logic
  Future<T> executeWithRetry<T>({
    required String operationName,
    required Future<T> Function() operation,
    String? tableName,
    String? recordId,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool shouldRethrow = false,
  }) async {
    int attempts = 0;
    Duration currentDelay = retryDelay;
    
    while (true) {
      attempts++;
      try {
        final result = await operation();
        
        // Log success if this wasn't the first attempt (means we recovered from an error)
        if (attempts > 1) {
          _loggingService.info(
            'Supabase operation succeeded after $attempts attempts',
            category: LogCategory.database,
            additionalData: {
              'operation': operationName,
              if (tableName != null) 'table': tableName,
              if (recordId != null) 'recordId': recordId,
            },
          );
        }
        
        return result;
      } catch (error, stackTrace) {
        final errorMessage = _errorService.handleSupabaseError(error);
        
        _loggingService.error(
          'Supabase operation failed: $operationName',
          category: LogCategory.database,
          error: error,
          stackTrace: stackTrace,
          additionalData: {
            'attempt': attempts,
            'maxRetries': maxRetries,
            if (tableName != null) 'table': tableName,
            if (recordId != null) 'recordId': recordId,
            'errorMessage': errorMessage,
          },
        );
        
        // If we've exceeded max retries or the error is not retryable, throw
        if (attempts >= maxRetries || !_isRetryableError(error)) {
          if (shouldRethrow) {
            rethrow;
          } else {
            throw errorMessage;
          }
        }
        
        // Implement exponential backoff (delay doubles after each retry)
        await Future.delayed(currentDelay);
        currentDelay *= 2;
      }
    }
  }
  
  /// Execute a database query with retries
  Future<List<Map<String, dynamic>>> executeQuery({
    required String tableName,
    required Future<List<Map<String, dynamic>>> Function() query,
    int maxRetries = 3,
  }) {
    return executeWithRetry(
      operationName: 'query',
      operation: query,
      tableName: tableName,
      maxRetries: maxRetries,
    );
  }
  
  /// Execute a database insert operation with retries
  Future<Map<String, dynamic>> executeInsert({
    required String tableName,
    required Future<Map<String, dynamic>> Function() insert,
    int maxRetries = 3,
  }) {
    return executeWithRetry(
      operationName: 'insert',
      operation: insert,
      tableName: tableName,
      maxRetries: maxRetries,
    );
  }
  
  /// Execute a database update operation with retries
  Future<Map<String, dynamic>> executeUpdate({
    required String tableName,
    required String recordId,
    required Future<Map<String, dynamic>> Function() update,
    int maxRetries = 3,
  }) {
    return executeWithRetry(
      operationName: 'update',
      operation: update,
      tableName: tableName,
      recordId: recordId,
      maxRetries: maxRetries,
    );
  }
  
  /// Execute a database delete operation with retries
  Future<Map<String, dynamic>> executeDelete({
    required String tableName,
    required String recordId,
    required Future<Map<String, dynamic>> Function() delete,
    int maxRetries = 3,
  }) {
    return executeWithRetry(
      operationName: 'delete',
      operation: delete,
      tableName: tableName,
      recordId: recordId,
      maxRetries: maxRetries,
    );
  }
  
  /// Determine if an error is retryable
  bool _isRetryableError(Object error) {
    // Network errors and timeouts are generally retryable
    if (error is TimeoutException) {
      return true;
    }
    
    // PostgrestError with certain codes are retryable
    if (error is PostgrestException) {
      // HTTP 5xx errors, gateway timeouts, and connection issues
      final retryableCodes = ['08000', '08006', '57P01', '57014', 'XX000'];
      return retryableCodes.contains(error.code);
    }
    
    // Some auth errors might be retryable (e.g., temporary service issues)
    if (error is AuthException) {
      return error.message.toLowerCase().contains('timeout') || 
             error.message.toLowerCase().contains('temporary') ||
             error.message.toLowerCase().contains('unavailable');
    }
    
    // Error messages that suggest retrying
    if (error is String) {
      return error.toLowerCase().contains('timeout') ||
             error.toLowerCase().contains('temporary') ||
             error.toLowerCase().contains('connection') ||
             error.toLowerCase().contains('network');
    }
    
    // For other error types, check the error message
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('timeout') ||
           errorMessage.contains('temporary') ||
           errorMessage.contains('connection') ||
           errorMessage.contains('network');
  }
} 