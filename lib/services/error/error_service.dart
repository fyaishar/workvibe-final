import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'dart:async' show TimeoutException;

/// A centralized service for handling errors throughout the application
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  
  factory ErrorService() {
    return _instance;
  }
  
  ErrorService._internal();
  
  /// Handles Supabase errors and returns user-friendly error messages
  String handleSupabaseError(Object error) {
    if (error is AuthException) {
      return _handleAuthError(error);
    } else if (error is PostgrestException) {
      return _handleDataError(error);
    } else if (error is String && error.contains('Operation not permitted')) {
      return 'Network permissions error. Please check your connection settings.';
    } else {
      return _handleGenericError(error);
    }
  }
  
  /// Handles authentication related errors
  String _handleAuthError(AuthException error) {
    switch (error.message) {
      case 'Invalid login credentials':
        return 'Email or password is incorrect. Please try again.';
      case 'Email not confirmed':
        return 'Please verify your email before logging in.';
      case 'Password should be at least 6 characters':
        return 'Password must be at least 6 characters long.';
      case 'User already registered':
        return 'An account with this email already exists.';
      default:
        return 'Authentication error: ${error.message}';
    }
  }
  
  /// Handles database operation errors
  String _handleDataError(PostgrestException error) {
    // Extract HTTP status code
    final statusCode = error.code;
    
    if (statusCode == '23505') {
      return 'This record already exists.';
    } else if (statusCode == '23503') {
      return 'Cannot perform this action because related records exist.';
    } else if (statusCode == '42P01') {
      return 'Database error: Table does not exist.';
    } else if (statusCode == '42601') {
      return 'Database error: Invalid query syntax.';
    } else {
      return 'Database error: ${error.message}';
    }
  }
  
  /// Handles network related errors
  String handleNetworkError(Object error) {
    if (error is SocketException) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error is TimeoutException) {
      return 'Request timed out. Please try again later.';
    } else {
      return 'Network error: ${error.toString()}';
    }
  }
  
  /// Handles Supabase Realtime connection errors
  String handleRealtimeError(Object error) {
    if (error is String) {
      if (error.contains('connection closed')) {
        return 'Realtime connection closed. Attempting to reconnect...';
      } else if (error.contains('connection error')) {
        return 'Realtime connection error. Please check your network.';
      }
    }
    return 'Realtime error: ${error.toString()}';
  }
  
  /// Handles generic errors
  String _handleGenericError(Object error) {
    final errorString = error.toString();
    
    if (errorString.contains('permission')) {
      return 'Permission error: The app does not have necessary permissions.';
    } else if (errorString.contains('timeout')) {
      return 'The operation timed out. Please try again later.';
    } else {
      // In debug mode, we return more detailed error information
      if (kDebugMode) {
        return 'Error: $errorString';
      } else {
        return 'An unexpected error occurred. Please try again later.';
      }
    }
  }
  
  /// Log errors to console (will be replaced with proper logging)
  void logError(String source, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$source] Error: ${error.toString()}');
      if (stackTrace != null) {
        print('[$source] Stack trace: $stackTrace');
      }
    }
  }
} 