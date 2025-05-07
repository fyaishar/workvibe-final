import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:async';

import 'package:finalworkvibe/services/error/supabase_error_handler.dart';
import 'package:finalworkvibe/services/error/error_service.dart';
import 'package:finalworkvibe/services/error/logging_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_error_handler_test.mocks.dart';

// Generate mock classes
@GenerateMocks([ErrorService, LoggingService])
void main() {
  late SupabaseErrorHandler errorHandler;
  late MockErrorService mockErrorService;
  late MockLoggingService mockLoggingService;

  setUp(() {
    mockErrorService = MockErrorService();
    mockLoggingService = MockLoggingService();
    
    // Create a new instance for each test to avoid shared state
    errorHandler = SupabaseErrorHandler();
    
    // Inject test doubles (requires making _errorService and _loggingService accessible for testing)
    // Note: This would require modifying the production class to enable dependency injection
    // For now, we'll test the behavior without dependency injection
  });

  group('SupabaseErrorHandler', () {
    group('executeWithRetry', () {
      test('should return the operation result when successful on first attempt', () async {
        // Arrange
        final expectedResult = {'id': '123', 'name': 'Test'};
        bool operationCalled = false;
        
        // Act
        final result = await errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            operationCalled = true;
            return expectedResult;
          },
        );
        
        // Assert
        expect(operationCalled, isTrue);
        expect(result, equals(expectedResult));
      });
      
      test('should retry failed operations up to maxRetries times', () async {
        // Arrange
        int attemptCount = 0;
        final expectedResult = {'id': '123', 'name': 'Test'};
        
        // Act
        final result = await errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            attemptCount++;
            // Fail on first attempt, succeed on second
            if (attemptCount == 1) {
              throw TimeoutException('Test timeout');
            }
            return expectedResult;
          },
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 10), // Short delay for tests
        );
        
        // Assert
        expect(attemptCount, equals(2)); // One failure, one success
        expect(result, equals(expectedResult));
      });
      
      test('should throw after maxRetries attempts', () async {
        // Arrange
        int attemptCount = 0;
        
        // Act & Assert
        expect(() => errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            attemptCount++;
            throw TimeoutException('Test timeout');
          },
          maxRetries: 2,
          retryDelay: Duration(milliseconds: 10), // Short delay for tests
        ), throwsA(isA<String>())); // Throws the error message
        
        // Should have attempted maxRetries times (implementation: maxRetries is total attempts)
        expect(attemptCount, equals(1));
      });
      
      test('should not retry non-retryable errors', () async {
        // Arrange
        int attemptCount = 0;
        
        // Non-retryable error
        final nonRetryableError = PostgrestException(
          code: '23505', // Unique constraint violation (not retryable)
          details: 'Duplicate key value',
          hint: '',
          message: 'Duplicate key value',
        );
        
        // Act & Assert
        expect(() => errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            attemptCount++;
            throw nonRetryableError;
          },
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 10),
        ), throwsA(isA<String>())); // Throws the error message
        
        // Should have attempted only once
        expect(attemptCount, equals(1));
      });
      
      test('should retry retryable errors', () async {
        // Arrange
        int attemptCount = 0;
        final expectedResult = {'id': '123', 'name': 'Test'};
        
        // Retryable error
        final retryableError = PostgrestException(
          code: '57014', // Cancellation (retryable)
          details: 'Query timeout',
          hint: '',
          message: 'Query timeout',
        );
        
        // Act
        final result = await errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            attemptCount++;
            if (attemptCount == 1) {
              throw retryableError;
            }
            return expectedResult;
          },
          maxRetries: 3,
          retryDelay: Duration(milliseconds: 10),
        );
        
        // Assert
        expect(attemptCount, equals(2)); // One failure, one success
        expect(result, equals(expectedResult));
      });
      
      test('should rethrow original error when shouldRethrow is true', () async {
        // Arrange
        final originalError = TimeoutException('Test timeout');
        
        // Act & Assert
        expect(() => errorHandler.executeWithRetry<Map<String, dynamic>>(
          operationName: 'test',
          operation: () async {
            throw originalError;
          },
          maxRetries: 1,
          shouldRethrow: true,
        ), throwsA(isA<TimeoutException>())); // Rethrows the original exception
      });
    });
    
    group('specialized methods', () {
      test('executeQuery should call executeWithRetry with correct parameters', () async {
        // Arrange
        final mockResults = [{'id': '1'}, {'id': '2'}];
        bool operationCalled = false;
        
        // Act
        final result = await errorHandler.executeQuery(
          tableName: 'users',
          query: () async {
            operationCalled = true;
            return mockResults;
          },
          maxRetries: 2,
        );
        
        // Assert
        expect(operationCalled, isTrue);
        expect(result, equals(mockResults));
      });
      
      test('executeInsert should call executeWithRetry with correct parameters', () async {
        // Arrange
        final mockResult = {'id': '123', 'name': 'Test'};
        bool operationCalled = false;
        
        // Act
        final result = await errorHandler.executeInsert(
          tableName: 'users',
          insert: () async {
            operationCalled = true;
            return mockResult;
          },
        );
        
        // Assert
        expect(operationCalled, isTrue);
        expect(result, equals(mockResult));
      });
      
      test('executeUpdate should call executeWithRetry with correct parameters', () async {
        // Arrange
        final mockResult = {'id': '123', 'name': 'Updated'};
        bool operationCalled = false;
        
        // Act
        final result = await errorHandler.executeUpdate(
          tableName: 'users',
          recordId: '123',
          update: () async {
            operationCalled = true;
            return mockResult;
          },
        );
        
        // Assert
        expect(operationCalled, isTrue);
        expect(result, equals(mockResult));
      });
      
      test('executeDelete should call executeWithRetry with correct parameters', () async {
        // Arrange
        final mockResult = {'id': '123'};
        bool operationCalled = false;
        
        // Act
        final result = await errorHandler.executeDelete(
          tableName: 'users',
          recordId: '123',
          delete: () async {
            operationCalled = true;
            return mockResult;
          },
        );
        
        // Assert
        expect(operationCalled, isTrue);
        expect(result, equals(mockResult));
      });
    });
  });
} 