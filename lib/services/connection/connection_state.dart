/// Enum representing the different states of a connection
enum ConnectionState {
  /// Not connected to the service
  disconnected,
  
  /// Attempting to establish initial connection
  connecting,
  
  /// Successfully connected to the service
  connected,
  
  /// Connection was lost, attempting to reconnect
  reconnecting,
  
  /// Connection has failed after maximum reconnection attempts
  failed,
}

/// Class representing the current status of a connection with optional message
class ConnectionStatus {
  /// The current state of the connection
  final ConnectionState state;
  
  /// An optional descriptive message about the current state
  final String message;
  
  /// Creates a new connection status with the given state and optional message
  ConnectionStatus({required this.state, this.message = ''});
  
  /// Whether the connection is active (connected or reconnecting)
  bool get isActive => state == ConnectionState.connected || state == ConnectionState.reconnecting;
  
  /// Creates a copy of this status with updated fields
  ConnectionStatus copyWith({ConnectionState? state, String? message}) {
    return ConnectionStatus(
      state: state ?? this.state,
      message: message ?? this.message,
    );
  }
  
  @override
  String toString() => 'ConnectionStatus(state: $state, message: $message)';
}

/// Class representing detailed health metrics for a connection
class ConnectionHealthMetrics {
  /// Stability rating from 0 (unstable) to 100 (stable)
  final int stabilityRating;
  
  /// Average latency in milliseconds or null if not available
  final int? averageLatencyMs;
  
  /// Total number of successful connections
  final int successfulConnections;
  
  /// Total number of failed connections
  final int failedConnections;
  
  /// Total number of reconnection attempts
  final int reconnectionAttempts;
  
  /// Total number of successful reconnections
  final int successfulReconnections;
  
  /// Creates a new set of health metrics
  ConnectionHealthMetrics({
    this.stabilityRating = 100, 
    this.averageLatencyMs,
    this.successfulConnections = 0,
    this.failedConnections = 0,
    this.reconnectionAttempts = 0,
    this.successfulReconnections = 0,
  });
  
  /// Creates a copy with updated values
  ConnectionHealthMetrics copyWith({
    int? stabilityRating,
    int? averageLatencyMs,
    int? successfulConnections,
    int? failedConnections,
    int? reconnectionAttempts,
    int? successfulReconnections,
  }) {
    return ConnectionHealthMetrics(
      stabilityRating: stabilityRating ?? this.stabilityRating,
      averageLatencyMs: averageLatencyMs ?? this.averageLatencyMs,
      successfulConnections: successfulConnections ?? this.successfulConnections,
      failedConnections: failedConnections ?? this.failedConnections,
      reconnectionAttempts: reconnectionAttempts ?? this.reconnectionAttempts,
      successfulReconnections: successfulReconnections ?? this.successfulReconnections,
    );
  }
  
  /// Creates a new instance with default values (fully stable)
  factory ConnectionHealthMetrics.healthy() {
    return ConnectionHealthMetrics(
      stabilityRating: 100,
      successfulConnections: 1,
    );
  }
  
  /// Creates a new instance with poor health values
  factory ConnectionHealthMetrics.unhealthy() {
    return ConnectionHealthMetrics(
      stabilityRating: 0,
      failedConnections: 1,
    );
  }
} 