import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finalworkvibe/core/models/exceptions/repository_exceptions.dart';
import 'package:finalworkvibe/services/error/repository_error_handler.dart';

// Create mock class for PostgrestException since we can't easily instantiate it directly
class MockPostgrestException extends Mock implements PostgrestException {
  @override
  final String message;
  @override
  final String code;
  
  MockPostgrestException({required this.message, required this.code});
}

// Generate mocks for dependencies
@GenerateMocks([RepositoryErrorHandler])
void main() {
  group('RepositoryExceptionFactory Tests', () {
    test('fromSupabaseError should create ResourceNotFoundException for not found errors', () {
      final error = MockPostgrestException(message: 'no rows returned', code: 'PGRST116');
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'getById',
        error: error,
      );
      
      expect(exception, isA<ResourceNotFoundException>());
      expect(exception.message, contains('not found'));
    });
    
    test('fromSupabaseError should create DuplicateResourceException for unique constraint violations', () {
      final error = MockPostgrestException(
        message: 'Key (email)=(test@example.com) already exists',
        code: '23505',
      );
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'create',
        error: error,
      );
      
      expect(exception, isA<DuplicateResourceException>());
      expect((exception as DuplicateResourceException).conflictingField, equals('email'));
    });
    
    test('fromSupabaseError should create ConstraintViolationException for foreign key violations', () {
      final error = MockPostgrestException(
        message: 'violates foreign key constraint',
        code: '23503',
      );
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'create',
        error: error,
      );
      
      expect(exception, isA<ConstraintViolationException>());
      expect((exception as ConstraintViolationException).constraintType, equals('foreign_key'));
    });
    
    test('fromSupabaseError should create PermissionDeniedException for permission errors', () {
      final error = MockPostgrestException(
        message: 'permission denied for table users',
        code: '42501',
      );
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'update',
        error: error,
      );
      
      expect(exception, isA<PermissionDeniedException>());
    });
    
    test('fromSupabaseError should create NetworkException for network errors', () {
      final error = SocketException('Connection refused');
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'query',
        error: error,
      );
      
      expect(exception, isA<NetworkException>());
      expect((exception as NetworkException).isRetryable, isTrue);
    });
    
    test('fromSupabaseError should create TimeoutException for timeout errors', () {
      final error = 'timeout occurred during database operation';
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'query',
        error: error,
      );
      
      expect(exception, isA<NetworkException>());
      expect(exception.message, contains('Network'));
    });
    
    test('fromSupabaseError should create generic RepositoryException for unknown errors', () {
      final error = Exception('Unknown error');
      
      final exception = RepositoryExceptionFactory.fromSupabaseError(
        operation: 'executeQuery',
        error: error,
      );
      
      expect(exception, isA<RepositoryException>());
      expect(exception, isNot(isA<NetworkException>()));
      expect(exception, isNot(isA<ResourceNotFoundException>()));
    });
  });
  
  group('RepositoryException Tests', () {
    test('RepositoryException should have correct string representation', () {
      final exception = RepositoryException(
        operation: 'test',
        message: 'Test message',
        originalError: 'Original error',
        context: {'key': 'value'},
      );
      
      final exceptionString = exception.toString();
      expect(exceptionString, contains('RepositoryException'));
      expect(exceptionString, contains('test'));
      expect(exceptionString, contains('Test message'));
      expect(exceptionString, contains('Original error'));
      expect(exceptionString, contains('key'));
      expect(exceptionString, contains('value'));
    });
    
    test('ResourceNotFoundException should have user-friendly message', () {
      final exception = ResourceNotFoundException(
        operation: 'getById',
        resourceId: '123',
        resourceType: 'user',
      );
      
      expect(exception.toUserFriendlyMessage(), contains('could not be found'));
    });
    
    test('ValidationException should include validation errors in user-friendly message', () {
      final exception = ValidationException(
        operation: 'create',
        validationErrors: {
          'email': 'Invalid email format',
          'password': 'Password too short',
        },
      );
      
      final message = exception.toUserFriendlyMessage();
      expect(message, contains('email'));
      expect(message, contains('Invalid email format'));
      expect(message, contains('password'));
      expect(message, contains('Password too short'));
    });
    
    test('DuplicateResourceException should include field in user-friendly message', () {
      final exception = DuplicateResourceException(
        operation: 'create',
        conflictingField: 'email',
      );
      
      expect(exception.toUserFriendlyMessage(), contains('email'));
      expect(exception.toUserFriendlyMessage(), contains('already exists'));
    });
    
    test('NetworkException should have appropriate message based on retryable status', () {
      final retryableException = NetworkException(
        operation: 'query',
        isRetryable: true,
      );
      
      final nonRetryableException = NetworkException(
        operation: 'query',
        isRetryable: false,
      );
      
      expect(retryableException.toUserFriendlyMessage(), contains('check your internet connection'));
      expect(nonRetryableException.toUserFriendlyMessage(), contains('network error occurred'));
    });
  });
  
  group('RepositoryErrorHandler Tests', () {
    late RepositoryErrorHandler handler;
    
    setUp(() {
      handler = RepositoryErrorHandler();
    });
    
    test('executeWithRetry should return result on successful operation', () async {
      final result = await handler.executeWithRetry<String>(
        operationName: 'test',
        operation: () async => 'success',
      );
      
      expect(result, equals('success'));
    });
    
    test('executeWithRetry should retry and succeed after temporary failure', () async {
      int attempts = 0;
      
      final result = await handler.executeWithRetry<String>(
        operationName: 'test',
        operation: () async {
          attempts++;
          if (attempts < 2) {
            throw NetworkException(
              operation: 'test',
              isRetryable: true,
            );
          }
          return 'success after retry';
        },
        retryDelay: const Duration(milliseconds: 1), // Short delay for testing
      );
      
      expect(attempts, equals(2));
      expect(result, equals('success after retry'));
    });
    
    test('executeWithRetry should throw after exceeding max retries', () async {
      expect(() async {
        await handler.executeWithRetry<String>(
          operationName: 'test',
          operation: () async {
            throw NetworkException(
              operation: 'test',
              isRetryable: true,
            );
          },
          maxRetries: 3,
          retryDelay: const Duration(milliseconds: 1), // Short delay for testing
        );
      }, throwsA(isA<NetworkException>()));
    });
    
    test('executeWithRetry should not retry non-retryable exceptions', () async {
      int attempts = 0;
      
      expect(() async {
        await handler.executeWithRetry<String>(
          operationName: 'test',
          operation: () async {
            attempts++;
            throw ValidationException(
              operation: 'test',
              validationErrors: {'field': 'error'},
            );
          },
          maxRetries: 3,
          retryDelay: const Duration(milliseconds: 1), // Short delay for testing
        );
      }, throwsA(isA<ValidationException>()));
      
      expect(attempts, equals(1)); // Should not retry
    });
  });
} 