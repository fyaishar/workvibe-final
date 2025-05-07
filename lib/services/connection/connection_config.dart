import 'connection_reconnector.dart';

/// Configuration options for the ConnectionManager.
class ConnectionConfig {
  /// Maximum number of reconnection attempts before failing
  final int maxReconnectionAttempts;
  
  /// Initial delay in milliseconds for reconnection
  final int initialReconnectDelayMs;
  
  /// Maximum delay in milliseconds for reconnection (caps exponential backoff)
  final int maxReconnectDelayMs;
  
  /// Delay before considering a connection attempt timed out
  final int connectionTimeoutMs;
  
  /// Interval for sending heartbeat/ping messages in milliseconds
  final int heartbeatIntervalMs;
  
  /// How long to wait for a heartbeat response before considering the connection lost
  final int heartbeatTimeoutMs;
  
  /// Whether to automatically try to reconnect when the connection is lost
  final bool autoReconnect;
  
  /// Whether to automatically connect when the ConnectionManager is initialized
  final bool autoConnect;
  
  /// Debug name for this connection for logging purposes
  final String debugName;
  
  /// Reconnection policy to use for reconnection attempts
  final ReconnectionPolicy reconnectionPolicy;

  /// Creates a new ConnectionConfig with default or custom values.
  ConnectionConfig({
    this.maxReconnectionAttempts = 5,
    this.initialReconnectDelayMs = 1000,
    this.maxReconnectDelayMs = 30000,
    this.connectionTimeoutMs = 10000,
    this.heartbeatIntervalMs = 30000,
    this.heartbeatTimeoutMs = 5000,
    this.autoReconnect = true,
    this.autoConnect = false,
    this.debugName = 'default',
    this.reconnectionPolicy = ReconnectionPolicy.exponentialBackoff,
  });
  
  /// Creates a ConnectionConfig for testing with more aggressive settings.
  factory ConnectionConfig.forTesting() {
    return ConnectionConfig(
      maxReconnectionAttempts: 3,
      initialReconnectDelayMs: 100,
      maxReconnectDelayMs: 1000,
      connectionTimeoutMs: 2000,
      heartbeatIntervalMs: 1000,
      heartbeatTimeoutMs: 500,
      autoReconnect: true,
      autoConnect: false,
      debugName: 'test',
      reconnectionPolicy: ReconnectionPolicy.aggressive,
    );
  }
  
  /// Creates a copy of this config with the given values replaced.
  ConnectionConfig copyWith({
    int? maxReconnectionAttempts,
    int? initialReconnectDelayMs,
    int? maxReconnectDelayMs,
    int? connectionTimeoutMs,
    int? heartbeatIntervalMs,
    int? heartbeatTimeoutMs,
    bool? autoReconnect,
    bool? autoConnect,
    String? debugName,
    ReconnectionPolicy? reconnectionPolicy,
  }) {
    return ConnectionConfig(
      maxReconnectionAttempts: maxReconnectionAttempts ?? this.maxReconnectionAttempts,
      initialReconnectDelayMs: initialReconnectDelayMs ?? this.initialReconnectDelayMs,
      maxReconnectDelayMs: maxReconnectDelayMs ?? this.maxReconnectDelayMs,
      connectionTimeoutMs: connectionTimeoutMs ?? this.connectionTimeoutMs,
      heartbeatIntervalMs: heartbeatIntervalMs ?? this.heartbeatIntervalMs,
      heartbeatTimeoutMs: heartbeatTimeoutMs ?? this.heartbeatTimeoutMs,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      autoConnect: autoConnect ?? this.autoConnect,
      debugName: debugName ?? this.debugName,
      reconnectionPolicy: reconnectionPolicy ?? this.reconnectionPolicy,
    );
  }
} 