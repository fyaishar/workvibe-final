import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async';

import 'package:finalworkvibe/services/error/error_service.dart';

void main() {
  late ErrorService errorService;

  setUp(() {
    errorService = ErrorService();
  });

  group('ErrorService', () {
    group('handleSupabaseError', () {
      test('should handle AuthException correctly', () {
        // Test various auth errors
        final invalidLogin = AuthException('Invalid login credentials');
        expect(
          errorService.handleSupabaseError(invalidLogin),
          'Email or password is incorrect. Please try again.',
        );

        final emailNotConfirmed = AuthException('Email not confirmed');
        expect(
          errorService.handleSupabaseError(emailNotConfirmed),
          'Please verify your email before logging in.',
        );

        final weakPassword = AuthException('Password should be at least 6 characters');
        expect(
          errorService.handleSupabaseError(weakPassword),
          'Password must be at least 6 characters long.',
        );

        final existingUser = AuthException('User already registered');
        expect(
          errorService.handleSupabaseError(existingUser),
          'An account with this email already exists.',
        );

        final otherAuthError = AuthException('Some other auth error');
        expect(
          errorService.handleSupabaseError(otherAuthError),
          'Authentication error: Some other auth error',
        );
      });

      test('should handle PostgrestException correctly', () {
        // Test database errors
        final duplicateRecord = PostgrestException(
          code: '23505',
          details: 'Duplicate key value violates unique constraint',
          hint: '',
          message: 'Duplicate key value violates unique constraint',
        );
        expect(
          errorService.handleSupabaseError(duplicateRecord),
          'This record already exists.',
        );

        final foreignKeyError = PostgrestException(
          code: '23503',
          details: 'Foreign key constraint violation',
          hint: '',
          message: 'Foreign key constraint violation',
        );
        expect(
          errorService.handleSupabaseError(foreignKeyError),
          'Cannot perform this action because related records exist.',
        );

        final tableNotExistError = PostgrestException(
          code: '42P01',
          details: 'Table does not exist',
          hint: '',
          message: 'Table does not exist',
        );
        expect(
          errorService.handleSupabaseError(tableNotExistError),
          'Database error: Table does not exist.',
        );

        final syntaxError = PostgrestException(
          code: '42601',
          details: 'Syntax error',
          hint: '',
          message: 'Syntax error',
        );
        expect(
          errorService.handleSupabaseError(syntaxError),
          'Database error: Invalid query syntax.',
        );

        final otherDbError = PostgrestException(
          code: '99999',
          details: 'Some other database error',
          hint: '',
          message: 'Some other database error',
        );
        expect(
          errorService.handleSupabaseError(otherDbError),
          'Database error: Some other database error',
        );
      });

      test('should handle macOS "Operation not permitted" errors', () {
        const macOsError = "Operation not permitted";
        expect(
          errorService.handleSupabaseError(macOsError),
          'Network permissions error. Please check your connection settings.',
        );
      });

      test('should handle generic errors', () {
        final randomError = Exception('Random error occurred');
        expect(
          errorService.handleSupabaseError(randomError),
          'Error: Exception: Random error occurred',
        );

        final permissionError = Exception('Permission denied');
        expect(
          errorService.handleSupabaseError(permissionError),
          'Permission error: The app does not have necessary permissions.',
        );

        final timeoutError = Exception('The operation timed out');
        expect(
          errorService.handleSupabaseError(timeoutError),
          'The operation timed out. Please try again later.',
        );
      });
    });

    group('handleNetworkError', () {
      test('should handle SocketException correctly', () {
        final socketError = SocketException('Failed to connect to the server');
        expect(
          errorService.handleNetworkError(socketError),
          'Network connection error. Please check your internet connection.',
        );
      });

      test('should handle TimeoutException correctly', () {
        final timeoutError = TimeoutException('Request timed out');
        expect(
          errorService.handleNetworkError(timeoutError),
          'Request timed out. Please try again later.',
        );
      });

      test('should handle other network errors generically', () {
        final otherError = Exception('Some other network issue');
        expect(
          errorService.handleNetworkError(otherError).startsWith('Network error:'),
          true,
        );
      });
    });

    group('handleRealtimeError', () {
      test('should handle connection closed errors', () {
        const connectionClosedError = 'connection closed';
        expect(
          errorService.handleRealtimeError(connectionClosedError),
          'Realtime connection closed. Attempting to reconnect...',
        );
      });

      test('should handle connection error messages', () {
        const connectionError = 'connection error: failed to connect';
        expect(
          errorService.handleRealtimeError(connectionError),
          'Realtime connection error. Please check your network.',
        );
      });

      test('should handle other realtime errors generically', () {
        final otherError = Exception('Some other realtime issue');
        expect(
          errorService.handleRealtimeError(otherError).startsWith('Realtime error:'),
          true,
        );
      });
    });
  });
} 