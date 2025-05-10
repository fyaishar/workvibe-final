import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/models/exceptions/repository_exceptions.dart';
import 'error_service.dart';
import 'logging_service.dart';
import 'repository_error_handler.dart';

/// A specialized error handler for Supabase operations with retry functionality
class SupabaseErrorHandler {
  static final SupabaseErrorHandler _instance = SupabaseErrorHandler._internal();
  final ErrorService _errorService = ErrorService();
  final LoggingService _loggingService = LoggingService();
  final RepositoryErrorHandler _repositoryErrorHandler = RepositoryErrorHandler();
  
  factory SupabaseErrorHandler() {
    return _instance;
  }
  
  SupabaseErrorHandler._internal();
  
  /// Execute a Supabase operation with automatic error handling and retry logic
  /// This method now delegates to the repository error handler for advanced error handling
  Future<T> executeWithRetry<T>({
    required String operationName,
    required Future<T> Function() operation,
    String? tableName,
    String? recordId,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
    bool shouldRethrow = false,
  }) async {
    try {
      return await _repositoryErrorHandler.executeWithRetry(
        operationName: operationName,
        operation: operation,
        entityType: tableName,
        entityId: recordId,
        context: {'shouldRethrow': shouldRethrow},
        maxRetries: maxRetries,
        retryDelay: retryDelay,
      );
    } catch (error) {
      // If not using repository exceptions (legacy code), map to user-friendly message
      if (error is! RepositoryException && shouldRethrow) {
        rethrow;
      } else if (error is! RepositoryException) {
        throw _errorService.handleSupabaseError(error);
      } else {
        throw error;
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
} 