/// Enum representing different reconnection policies
enum ReconnectionPolicy {
  /// Retry more frequently with shorter delays but more attempts
  aggressive,
  
  /// Balanced approach with moderate delays and attempts
  moderate,
  
  /// More conservative approach with longer delays but fewer total attempts
  conservative
}

/// Configuration options for connection management
class ConnectionConfig {
  /// Initial delay in milliseconds before the first reconnection attempt
  final int initialReconnectDelayMs;
  
  /// Maximum delay in milliseconds between reconnection attempts
  final int maxReconnectDelayMs;
  
  /// Maximum number of reconnection attempts before giving up
  final int maxReconnectionAttempts;
  
  /// The reconnection policy that determines backoff strategy
  final ReconnectionPolicy reconnectionPolicy;
  
  /// The interval in milliseconds between heartbeat checks
  final int heartbeatIntervalMs;
  
  /// The timeout in milliseconds for a heartbeat to be considered failed
  final int heartbeatTimeoutMs;
  
  /// Whether to enable automatic reconnection
  final bool enableAutoReconnect;
  
  /// Whether to log detailed connection events
  final bool enableDetailedLogs;
  
  /// Creates a new ConnectionConfig with default or custom values.
  ConnectionConfig({
    this.initialReconnectDelayMs = 1000,
    this.maxReconnectDelayMs = 30000,
    this.maxReconnectionAttempts = 10,
    this.reconnectionPolicy = ReconnectionPolicy.moderate,
    this.heartbeatIntervalMs = 30000,
    this.heartbeatTimeoutMs = 5000,
    this.enableAutoReconnect = true,
    this.enableDetailedLogs = false,
  });
  
  /// Creates a ConnectionConfig for testing with more aggressive settings.
  factory ConnectionConfig.forTesting() {
    return ConnectionConfig(
      initialReconnectDelayMs: 300,
      maxReconnectDelayMs: 3000,
      maxReconnectionAttempts: 15,
      reconnectionPolicy: ReconnectionPolicy.aggressive,
      heartbeatIntervalMs: 5000,
      heartbeatTimeoutMs: 1000,
      enableDetailedLogs: true,
    );
  }
  
  /// Creates a copy of this ConnectionConfig with updated values.
  ConnectionConfig copyWith({
    int? initialReconnectDelayMs,
    int? maxReconnectDelayMs,
    int? maxReconnectionAttempts,
    ReconnectionPolicy? reconnectionPolicy,
    int? heartbeatIntervalMs,
    int? heartbeatTimeoutMs,
    bool? enableAutoReconnect,
    bool? enableDetailedLogs,
  }) {
    return ConnectionConfig(
      initialReconnectDelayMs: initialReconnectDelayMs ?? this.initialReconnectDelayMs,
      maxReconnectDelayMs: maxReconnectDelayMs ?? this.maxReconnectDelayMs,
      maxReconnectionAttempts: maxReconnectionAttempts ?? this.maxReconnectionAttempts,
      reconnectionPolicy: reconnectionPolicy ?? this.reconnectionPolicy,
      heartbeatIntervalMs: heartbeatIntervalMs ?? this.heartbeatIntervalMs,
      heartbeatTimeoutMs: heartbeatTimeoutMs ?? this.heartbeatTimeoutMs,
      enableAutoReconnect: enableAutoReconnect ?? this.enableAutoReconnect,
      enableDetailedLogs: enableDetailedLogs ?? this.enableDetailedLogs,
    );
  }
} 