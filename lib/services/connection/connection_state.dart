import 'package:flutter/foundation.dart';

/// Enum defining all possible connection states.
enum ConnectionState {
  /// Initial state, not yet attempted to connect
  disconnected,
  
  /// Currently attempting to establish connection
  connecting,
  
  /// Connection successfully established
  connected,
  
  /// Connection was lost, attempting to reconnect
  reconnecting,
  
  /// Connection failed after multiple reconnection attempts
  failed
}

/// Enum defining connection event types that can trigger state transitions.
enum ConnectionEvent {
  /// Connect command issued
  connect,
  
  /// Connection successfully established
  connectionEstablished,
  
  /// Connection lost
  connectionLost,
  
  /// Reconnection attempt failed
  reconnectionFailed,
  
  /// Circuit breaker tripped (too many failed attempts)
  circuitBreakerTripped,
  
  /// Heartbeat timeout detected
  heartbeatTimeout,
  
  /// Manual disconnect requested
  disconnect,
  
  /// Connection error occurred
  error
}

/// Class representing the connection status to be broadcasted to listeners.
class ConnectionStatus {
  /// Current state of the connection
  final ConnectionState state;
  
  /// Optional error information if state is failed
  final dynamic error;
  
  /// Human-readable message about the connection status
  final String message;
  
  /// Whether the connection is considered healthy
  bool get isConnected => state == ConnectionState.connected;
  
  /// Whether reconnection is in progress
  bool get isReconnecting => state == ConnectionState.reconnecting;
  
  /// Whether in a failed state (cannot auto-recover)
  bool get isFailed => state == ConnectionState.failed;
  
  ConnectionStatus({
    required this.state,
    this.error,
    required this.message,
  });
  
  @override
  String toString() {
    return 'ConnectionStatus(state: $state, message: $message, hasError: ${error != null})';
  }
  
  /// Debug representation for logging
  String toDebugString() {
    return 'ConnectionStatus(state: $state, message: $message, error: $error)';
  }
} 