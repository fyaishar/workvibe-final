import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Status of a real-time subscription
enum SubscriptionStatus {
  /// Initial state before subscription is established
  initializing,
  
  /// Subscription is being established
  connecting,
  
  /// Subscription is active and receiving events
  connected,
  
  /// Subscription was disconnected and is attempting to reconnect
  reconnecting,
  
  /// Subscription is permanently disconnected
  disconnected,
  
  /// Subscription encountered an error
  error,
  
  /// Subscription was cancelled by the user
  cancelled
}

/// Subscription type to distinguish between different subscription patterns
enum SubscriptionType {
  /// Subscription to an entire table/collection
  table,
  
  /// Subscription to a specific record by ID
  record,
  
  /// Subscription to a filtered subset of records
  query
}

/// Policy for how to handle reconnection attempts
enum ReconnectionPolicy {
  /// Aggressive reconnection with short delays
  aggressive,
  
  /// Balanced reconnection with moderate delays
  balanced,
  
  /// Conservative reconnection with longer delays
  conservative,
  
  /// No automatic reconnection
  none
}

/// Configuration options for a subscription
class SubscriptionConfig {
  /// Maximum reconnection attempts (0 for unlimited)
  final int maxReconnectionAttempts;
  
  /// Initial delay before first reconnection attempt (ms)
  final int initialReconnectDelayMs;
  
  /// Maximum delay between reconnection attempts (ms)
  final int maxReconnectDelayMs;
  
  /// Exponential backoff factor for reconnection attempts
  final double backoffFactor;
  
  /// Whether to apply jitter to reconnection delays
  final bool useJitter;
  
  /// Jitter factor (0.0-1.0) to apply to reconnection delays
  final double jitterFactor;
  
  /// Reconnection policy to use
  final ReconnectionPolicy reconnectionPolicy;
  
  /// Whether to automatically reconnect on network changes
  final bool reconnectOnNetworkChange;
  
  /// Whether to fetch initial data for the subscription
  final bool fetchInitialData;
  
  /// Creates a new subscription configuration with default values.
  const SubscriptionConfig({
    this.maxReconnectionAttempts = 5,
    this.initialReconnectDelayMs = 1000,
    this.maxReconnectDelayMs = 30000,
    this.backoffFactor = 1.5,
    this.useJitter = true,
    this.jitterFactor = 0.2,
    this.reconnectionPolicy = ReconnectionPolicy.balanced,
    this.reconnectOnNetworkChange = true,
    this.fetchInitialData = true,
  });
  
  /// Creates an aggressive reconnection configuration with shorter delays.
  factory SubscriptionConfig.aggressive() => const SubscriptionConfig(
    maxReconnectionAttempts: 10,
    initialReconnectDelayMs: 500,
    maxReconnectDelayMs: 10000,
    backoffFactor: 1.2,
    jitterFactor: 0.1,
    reconnectionPolicy: ReconnectionPolicy.aggressive,
  );
  
  /// Creates a conservative reconnection configuration with longer delays.
  factory SubscriptionConfig.conservative() => const SubscriptionConfig(
    maxReconnectionAttempts: 3,
    initialReconnectDelayMs: 2000,
    maxReconnectDelayMs: 60000,
    backoffFactor: 2.0,
    jitterFactor: 0.25,
    reconnectionPolicy: ReconnectionPolicy.conservative,
  );
  
  /// Creates a configuration with no automatic reconnection.
  factory SubscriptionConfig.noReconnect() => const SubscriptionConfig(
    maxReconnectionAttempts: 0,
    reconnectionPolicy: ReconnectionPolicy.none,
  );
  
  /// Creates a copy of this configuration with the given fields replaced.
  SubscriptionConfig copyWith({
    int? maxReconnectionAttempts,
    int? initialReconnectDelayMs,
    int? maxReconnectDelayMs,
    double? backoffFactor,
    bool? useJitter,
    double? jitterFactor,
    ReconnectionPolicy? reconnectionPolicy,
    bool? reconnectOnNetworkChange,
    bool? fetchInitialData,
  }) {
    return SubscriptionConfig(
      maxReconnectionAttempts: maxReconnectionAttempts ?? this.maxReconnectionAttempts,
      initialReconnectDelayMs: initialReconnectDelayMs ?? this.initialReconnectDelayMs,
      maxReconnectDelayMs: maxReconnectDelayMs ?? this.maxReconnectDelayMs,
      backoffFactor: backoffFactor ?? this.backoffFactor,
      useJitter: useJitter ?? this.useJitter,
      jitterFactor: jitterFactor ?? this.jitterFactor,
      reconnectionPolicy: reconnectionPolicy ?? this.reconnectionPolicy,
      reconnectOnNetworkChange: reconnectOnNetworkChange ?? this.reconnectOnNetworkChange,
      fetchInitialData: fetchInitialData ?? this.fetchInitialData,
    );
  }
}

/// Information about a subscription event
class SubscriptionEvent {
  /// The channel the event occurred on
  final String channelName;
  
  /// The type of event
  final PostgresChangeEvent eventType;
  
  /// The table or collection the event occurred on
  final String table;
  
  /// The schema the event occurred in (if applicable)
  final String schema;
  
  /// The new record after the change (if applicable)
  final Map<String, dynamic>? newRecord;
  
  /// The old record before the change (if applicable)
  final Map<String, dynamic>? oldRecord;
  
  /// Creates a new subscription event.
  SubscriptionEvent({
    required this.channelName,
    required this.eventType,
    required this.table,
    required this.schema,
    this.newRecord,
    this.oldRecord,
  });
  
  /// Creates a subscription event from a Supabase Postgres Change payload.
  factory SubscriptionEvent.fromPostgresChangesPayload(PostgresChangePayload payload) {
    return SubscriptionEvent(
      channelName: 'pg_changes', // Use a default value since there's no channelName in the payload
      eventType: payload.eventType,
      table: payload.table,
      schema: payload.schema,
      newRecord: payload.newRecord,
      oldRecord: payload.oldRecord,
    );
  }
  
  @override
  String toString() {
    return 'SubscriptionEvent{channelName: $channelName, eventType: $eventType, '
           'table: $table, schema: $schema}';
  }
}

/// Status update for a subscription
class SubscriptionStatusUpdate {
  /// The unique ID of the subscription
  final String subscriptionId;
  
  /// The current status of the subscription
  final SubscriptionStatus status;
  
  /// An error that occurred (if any)
  final Object? error;
  
  /// A message explaining the status update
  final String? message;
  
  /// Creates a new subscription status update.
  SubscriptionStatusUpdate({
    required this.subscriptionId,
    required this.status,
    this.error,
    this.message,
  });
  
  @override
  String toString() {
    return 'SubscriptionStatusUpdate{subscriptionId: $subscriptionId, '
           'status: $status, message: $message}';
  }
}

/// Information about a subscription
class SubscriptionInfo {
  /// Unique identifier for this subscription
  final String id;
  
  /// The channel name used for this subscription
  final String channelName;
  
  /// The table or collection being subscribed to
  final String tableName;
  
  /// The type of subscription
  final SubscriptionType type;
  
  /// Current status of the subscription
  final SubscriptionStatus status;
  
  /// Filter applied to this subscription (if any)
  final Map<String, dynamic>? filter;
  
  /// Last error encountered (if any)
  final Object? lastError;
  
  /// Time the subscription was created
  final DateTime createdAt;
  
  /// Time the subscription was last updated
  final DateTime? updatedAt;
  
  /// Number of connection attempts
  final int connectionAttempts;
  
  /// Creates a new subscription info object.
  SubscriptionInfo({
    required this.id,
    required this.channelName,
    required this.tableName,
    required this.type,
    required this.status,
    this.filter,
    this.lastError,
    required this.createdAt,
    this.updatedAt,
    this.connectionAttempts = 0,
  });
  
  /// Creates a copy of this subscription info with updated fields.
  SubscriptionInfo copyWith({
    String? id,
    String? channelName,
    String? tableName,
    SubscriptionType? type,
    SubscriptionStatus? status,
    Map<String, dynamic>? filter,
    Object? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? connectionAttempts,
  }) {
    return SubscriptionInfo(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      tableName: tableName ?? this.tableName,
      type: type ?? this.type,
      status: status ?? this.status,
      filter: filter ?? this.filter,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      connectionAttempts: connectionAttempts ?? this.connectionAttempts,
    );
  }
  
  @override
  String toString() {
    return 'SubscriptionInfo{id: $id, tableName: $tableName, '
           'type: $type, status: $status}';
  }
} 