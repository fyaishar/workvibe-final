import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents the result of handling a connection error
class ConnectionErrorResult {
  /// The error message (user-friendly)
  final String message;
  
  /// Whether the error is transient and should trigger a reconnection attempt
  final bool shouldReconnect;
  
  /// The error code if available
  final String? code;
  
  /// The original error for debugging
  final Object error;
  
  /// Creates a new ConnectionErrorResult
  ConnectionErrorResult({
    required this.message,
    required this.shouldReconnect,
    required this.error,
    this.code,
  });
  
  /// Creates a result for a transient error that should trigger reconnection
  factory ConnectionErrorResult.transient(Object error, String message, {String? code}) {
    return ConnectionErrorResult(
      message: message,
      shouldReconnect: true,
      error: error,
      code: code,
    );
  }
  
  /// Creates a result for a permanent error that should not trigger reconnection
  factory ConnectionErrorResult.permanent(Object error, String message, {String? code}) {
    return ConnectionErrorResult(
      message: message,
      shouldReconnect: false,
      error: error,
      code: code,
    );
  }
}

/// Custom exception for realtime operations
class RealtimeException implements Exception {
  final String message;
  RealtimeException(this.message);
  
  @override
  String toString() => 'RealtimeException: $message';
}

/// Handles connection-related errors with specialized logic.
class ConnectionErrorHandler {
  /// Handles a connection error and returns a ConnectionErrorResult
  ConnectionErrorResult handleConnectionError(
    Object error, {
    String context = 'connection',
  }) {
    // Log the error in debug mode
    if (kDebugMode) {
      print('Connection error in context: $context');
      print('Error: $error');
    }
    
    // Handle Supabase-specific errors
    if (error is PostgrestException) {
      return _handlePostgrestException(error, context);
    } else if (error is AuthException) {
      return _handleAuthException(error, context);
    } else if (error is RealtimeException) {
      return _handleRealtimeException(error, context);
    }
    
    // Handle network-related errors
    if (error is SocketException) {
      return _handleSocketException(error, context);
    } else if (error is TimeoutException) {
      return ConnectionErrorResult.transient(
        error,
        'Connection timed out: ${error.toString()}. Will try again.',
        code: 'timeout',
      );
    } else if (error is WebSocketException) {
      return ConnectionErrorResult.transient(
        error,
        'WebSocket error: ${error.toString()}. Will try again.',
        code: 'websocket_error',
      );
    }
    
    // Handle platform-specific errors
    if (!kIsWeb) {
      if (Platform.isMacOS && error.toString().contains('Operation not permitted')) {
        return ConnectionErrorResult.permanent(
          error,
          'MacOS permission error: Operation not permitted. Check network permissions.',
          code: 'permission_denied',
        );
      }
    }
    
    // Default case for unknown errors
    return ConnectionErrorResult.transient(
      error,
      'Connection error: ${error.toString()}. Will try again.',
      code: 'unknown',
    );
  }
  
  /// Handles Postgrest errors
  ConnectionErrorResult _handlePostgrestException(
    PostgrestException error,
    String context,
  ) {
    final code = error.code;
    final message = error.message;
    
    // Handle based on error code
    switch (code) {
      case '23505': // Unique violation
        return ConnectionErrorResult.permanent(
          error,
          'Database constraint error: $message',
          code: code,
        );
      case '28P01': // Invalid password
        return ConnectionErrorResult.permanent(
          error,
          'Authentication failed: Invalid credentials',
          code: code,
        );
      case '42P01': // Undefined table
        return ConnectionErrorResult.permanent(
          error,
          'Database error: Table not found',
          code: code,
        );
      case '42501': // Permission denied
        return ConnectionErrorResult.permanent(
          error,
          'Permission denied for operation',
          code: code,
        );
      default:
        // For other errors, check if it's a connection issue
        if (message.toLowerCase().contains('connect') ||
            message.toLowerCase().contains('network') ||
            message.toLowerCase().contains('timeout')) {
          return ConnectionErrorResult.transient(
            error,
            'Database connection error: $message. Will try again.',
            code: code,
          );
        } else {
          return ConnectionErrorResult.permanent(
            error,
            'Database error: $message',
            code: code,
          );
        }
    }
  }
  
  /// Handles authentication errors
  ConnectionErrorResult _handleAuthException(
    AuthException error,
    String context,
  ) {
    final message = error.message;
    
    if (message.toLowerCase().contains('jwt expired')) {
      return ConnectionErrorResult.transient(
        error,
        'Authentication token expired. Will try to refresh.',
        code: 'jwt_expired',
      );
    } else if (message.toLowerCase().contains('invalid token')) {
      return ConnectionErrorResult.permanent(
        error,
        'Invalid authentication token. Please sign in again.',
        code: 'invalid_token',
      );
    } else {
      return ConnectionErrorResult.permanent(
        error,
        'Authentication error: $message',
        code: 'auth_error',
      );
    }
  }
  
  /// Handles Realtime-specific errors
  ConnectionErrorResult _handleRealtimeException(
    RealtimeException error,
    String context,
  ) {
    final message = error.message;
    
    // Most realtime errors are transient and should trigger reconnection
    if (message.toLowerCase().contains('connection') ||
        message.toLowerCase().contains('timeout') ||
        message.toLowerCase().contains('network') ||
        message.toLowerCase().contains('closed')) {
      return ConnectionErrorResult.transient(
        error,
        'Realtime connection error: $message. Will try to reconnect.',
        code: 'realtime_connection',
      );
    } else if (message.toLowerCase().contains('auth')) {
      return ConnectionErrorResult.permanent(
        error,
        'Realtime authentication error: $message',
        code: 'realtime_auth',
      );
    } else {
      return ConnectionErrorResult.transient(
        error,
        'Realtime error: $message. Will try again.',
        code: 'realtime_error',
      );
    }
  }
  
  /// Handles socket exceptions
  ConnectionErrorResult _handleSocketException(
    SocketException error,
    String context,
  ) {
    final message = error.message;
    final osError = error.osError;
    
    // Handle common network errors
    if (osError != null) {
      switch (osError.errorCode) {
        case 7:  // Connection refused
          return ConnectionErrorResult.transient(
            error,
            'Connection refused. Server may be down or unreachable.',
            code: 'connection_refused',
          );
        case 8:  // Host unreachable
          return ConnectionErrorResult.transient(
            error,
            'Host unreachable. Check your internet connection.',
            code: 'host_unreachable',
          );
        case 110: // Connection timed out
          return ConnectionErrorResult.transient(
            error,
            'Connection timed out. Will try again.',
            code: 'connection_timeout',
          );
        case 111: // Connection refused
          return ConnectionErrorResult.transient(
            error,
            'Connection refused. Service may be unavailable.',
            code: 'connection_refused',
          );
        default:
          return ConnectionErrorResult.transient(
            error,
            'Network error: $message. Will try again.',
            code: 'socket_error_${osError.errorCode}',
          );
      }
    }
    
    // Generic socket error
    return ConnectionErrorResult.transient(
      error,
      'Network error: $message. Will try again.',
      code: 'socket_error',
    );
  }
} 