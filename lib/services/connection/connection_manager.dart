import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../error/error_service.dart';
import '../error/logging_service.dart' as logging;
import '../error/error_types.dart' as error_types;
import 'connection_config.dart';
import 'connection_state.dart';
import 'connection_monitor.dart';
import 'connection_reconnector.dart';
import 'connection_error_handler.dart';

/// Manages WebSocket connection state and reconnection logic.
class ConnectionManager {
  // Dependencies
  final SupabaseClient _supabase = Supabase.instance.client;
  final ErrorService _errorService = ErrorService();
  final logging.LoggingService _loggingService = logging.LoggingService();
  final ConnectionErrorHandler _errorHandler = ConnectionErrorHandler();
  
  // Configuration
  final ConnectionConfig _config;
  
  // State management
  ConnectionState _state = ConnectionState.disconnected;
  DateTime? _lastHeartbeatSent;
  DateTime? _lastHeartbeatReceived;
  Timer? _heartbeatTimer;
  Timer? _heartbeatTimeoutTimer;
  
  // Advanced reconnection handling
  late final ConnectionReconnector _reconnector;
  
  // Connection monitoring
  late final ConnectionMonitor _monitor;
  
  // Status controller for UI updates
  final _connectionStatusController = StreamController<ConnectionStatus>.broadcast();
  
  // Channel management
  final Map<String, RealtimeChannel> _channels = {};
  
  /// Events related to connection status changes
  Stream<ConnectionStatus> get onConnectionStatus => _connectionStatusController.stream;
  
  /// Events for connection health metrics updates
  Stream<ConnectionHealthMetrics> get onHealthMetricsChanged => _monitor.onMetricsChanged;
  
  /// The current connection state
  ConnectionState get state => _state;
  
  /// Whether the connection is currently active
  bool get isConnected => _state == ConnectionState.connected;
  
  /// Time of the last successful ping in milliseconds, or null if no ping yet
  int? get lastPingTime => _monitor.lastLatencyMs;
  
  /// Current stability rating (0-100)
  int get stabilityRating => _monitor.healthMetrics.stabilityRating;
  
  /// Creates a new connection manager.
  ConnectionManager({ConnectionConfig? config})
      : _config = config ?? ConnectionConfig() {
    // Initialize the reconnector with the config
    _reconnector = ConnectionReconnector(
      initialDelayMs: _config.initialReconnectDelayMs,
      maxDelayMs: _config.maxReconnectDelayMs,
      maxAttempts: _config.maxReconnectionAttempts,
      backoffFactor: _config.reconnectionPolicy == ReconnectionPolicy.aggressive ? 1.5 :
                    _config.reconnectionPolicy == ReconnectionPolicy.conservative ? 2.0 : 1.75,
      useJitter: true,
      jitterFactor: _config.reconnectionPolicy == ReconnectionPolicy.aggressive ? 0.1 :
                   _config.reconnectionPolicy == ReconnectionPolicy.conservative ? 0.25 : 0.2,
    );
    
    // Initialize the connection monitor
    _monitor = ConnectionMonitor();
    
    // Set the initial status
    _updateStatus(ConnectionState.disconnected, 'Not connected');
  }
  
  /// Initializes the connection manager and connects if autoConnect is true.
  void initialize({bool autoConnect = true}) {
    if (autoConnect) {
      connect();
    }
  }
  
  /// Connect to the Supabase Realtime service.
  Future<bool> connect() async {
    if (_state == ConnectionState.connected || 
        _state == ConnectionState.connecting) {
      return true;
    }
    
    try {
      _updateStatus(ConnectionState.connecting, 'Establishing connection...');
      
      // Reset reconnection counters and state
      _reconnector.reset();
      
      // Connect to Supabase Realtime
      await _supabase.realtime.connect();
      
      // Start heartbeat monitoring
      _startHeartbeat();
      
      // Update the state
      _updateStatus(ConnectionState.connected, 'Connected successfully');
      
      // Reset the health metrics
      _monitor.reset();
      
      return true;
    } catch (e, stackTrace) {
      // Handle the error with our specialized handler
      final errorResult = _errorHandler.handleConnectionError(
        e, 
        context: 'connecting to Supabase Realtime'
      );
      
      _updateStatus(
        ConnectionState.failed, 
        'Connection failed: ${errorResult.message}'
      );
      
      // If this is an error we should automatically retry
      if (errorResult.shouldReconnect) {
        _attemptReconnect();
      }
      
      return false;
    }
  }
  
  /// Disconnects from Supabase Realtime.
  Future<void> disconnect() async {
    // Stop heartbeat
    _stopHeartbeat();
    
    // Cancel any reconnection attempts
    _reconnector.cancelReconnect();
    
    try {
      // Disconnect all channels
      _channels.forEach((name, channel) {
        channel.unsubscribe();
      });
      _channels.clear();
      
      // Disconnect from Supabase Realtime
      await _supabase.realtime.disconnect();
      
      _updateStatus(ConnectionState.disconnected, 'Disconnected');
    } catch (e) {
      _errorHandler.handleConnectionError(
        e, 
        context: 'disconnecting from Supabase Realtime'
      );
    }
  }
  
  /// Creates and subscribes to a Supabase Realtime channel.
  ///
  /// Returns the channel if successful, or null if there was an error.
  /// If the channel already exists, returns the existing channel.
  RealtimeChannel? createChannel(
    String channelName, {
    dynamic opts, 
    Function(dynamic payload)? callback
  }) {
    // Check if we already have this channel
    if (_channels.containsKey(channelName)) {
      return _channels[channelName];
    }
    
    try {
      // Create a new channel
      final channel = _supabase.channel(channelName);
      
      // If a callback is provided, add it
      if (callback != null) {
        channel.subscribe((status, [error]) {
          callback(status);
        });
      } else {
        // Just subscribe to the channel
        channel.subscribe();
      }
      
      // Store the channel
      _channels[channelName] = channel;
      
      _log('Created channel: $channelName', level: 'info');
      
      return channel;
    } catch (e) {
      final error = _errorHandler.handleConnectionError(
        e, 
        context: 'creating channel $channelName'
      );
      
      _log('Failed to create channel $channelName: ${error.message}', level: 'error');
      
      return null;
    }
  }
  
  /// Closes a Supabase Realtime channel.
  Future<void> closeChannel(String channelName) async {
    final channel = _channels[channelName];
    if (channel == null) {
      return;
    }
    
    try {
      // Unsubscribe from the channel
      await channel.unsubscribe();
      
      // Remove the channel
      _channels.remove(channelName);
      
      _log('Closed channel: $channelName', level: 'info');
    } catch (e) {
      _errorHandler.handleConnectionError(
        e, 
        context: 'closing channel $channelName'
      );
    }
  }
  
  /// Helper for logging messages related to connection.
  void _log(String message, {
    String level = 'debug',
    dynamic error,
    StackTrace? stackTrace,
  }) {
    switch (level) {
      case 'error':
        _loggingService.logError(
          message: message,
          error: error,
          stackTrace: stackTrace,
          category: 'connection',
        );
        break;
      case 'warning':
        _loggingService.logWarning(
          message: message,
          category: 'connection',
        );
        break;
      case 'info':
        _loggingService.logInfo(
          message: message,
          category: 'connection',
        );
        break;
      default:
        _loggingService.log(
          message, 
          level: logging.LogLevel.debug, 
          category: logging.LogCategory.realtime,
        );
    }
  }
  
  /// Updates the connection status and notifies listeners.
  void _updateStatus(ConnectionState state, [String message = '']) {
    _state = state;
    final status = ConnectionStatus(state: state, message: message);
    _connectionStatusController.add(status);
    
    _log('Connection status: ${state.toString().split('.').last}${message.isNotEmpty ? ' - $message' : ''}',
      level: state == ConnectionState.failed ? 'error' : 'info'
    );
    
    // Update the health metrics
    if (state == ConnectionState.connected) {
      _monitor.recordConnectionSuccess();
    } else if (state == ConnectionState.failed) {
      _monitor.recordConnectionFailure();
    }
  }
  
  /// Starts the heartbeat timer for connection monitoring.
  void _startHeartbeat() {
    // Cancel any existing timers
    _stopHeartbeat();
    
    // Start a new timer
    _heartbeatTimer = Timer.periodic(
      Duration(milliseconds: _config.heartbeatIntervalMs), 
      (_) => _sendHeartbeat()
    );
  }
  
  /// Stops the heartbeat timer.
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    
    _heartbeatTimeoutTimer?.cancel();
    _heartbeatTimeoutTimer = null;
  }
  
  /// Sends a heartbeat to verify the connection.
  Future<void> _sendHeartbeat() async {
    if (_state != ConnectionState.connected) {
      return;
    }
    
    _lastHeartbeatSent = DateTime.now();
    
    try {
      // Create a temporary heartbeat channel
      final heartbeatChannel = _supabase.channel('heartbeat-${DateTime.now().millisecondsSinceEpoch}');
      
      // Set up the timeout timer
      _heartbeatTimeoutTimer?.cancel();
      _heartbeatTimeoutTimer = Timer(
        Duration(milliseconds: _config.heartbeatTimeoutMs), 
        _handleHeartbeatTimeout
      );
      
      // Subscribe to the channel which will trigger a server response
      heartbeatChannel.subscribe((status, [error]) async {
        // Record the time we received the response
        _lastHeartbeatReceived = DateTime.now();
        
        // Cancel the timeout timer
        _heartbeatTimeoutTimer?.cancel();
        _heartbeatTimeoutTimer = null;
        
        // Calculate latency and record it
        if (_lastHeartbeatSent != null) {
          final latencyMs = _lastHeartbeatReceived!.difference(_lastHeartbeatSent!).inMilliseconds;
          _monitor.recordLatency(latencyMs);
        }
        
        // Clean up the temporary channel
        await heartbeatChannel.unsubscribe();
      });
    } catch (e) {
      _errorHandler.handleConnectionError(
        e,
        context: 'sending heartbeat'
      );
    }
  }
  
  /// Handles a heartbeat timeout (no response received).
  void _handleHeartbeatTimeout() {
    // Record the timeout as a connection failure
    _monitor.recordConnectionFailure();
    
    // If we're too unstable, go to reconnecting state
    if (_monitor.healthMetrics.stabilityRating < 50) {
      _log('Heartbeat timeout detected, connection unstable', level: 'warning');
      
      // If we're currently connected, transition to reconnecting
      if (_state == ConnectionState.connected) {
        _updateStatus(ConnectionState.reconnecting, 'Connection unstable, reconnecting...');
        _attemptReconnect();
      }
    }
  }
  
  /// Attempts to reconnect using the reconnection strategy.
  void _attemptReconnect() {
    // Use the reconnector to handle reconnection logic
    _reconnector.reconnect(
      // The actual reconnection function
      connect: () async {
        try {
          _updateStatus(ConnectionState.reconnecting, 'Attempting to reconnect...');
          
          // Disconnect first to ensure a clean state
          await _supabase.realtime.disconnect();
          
          // Attempt to reconnect
          await _supabase.realtime.connect();
          
          // Resubscribe to all channels
          for (final channelName in _channels.keys.toList()) {
            createChannel(channelName);
          }
          
          // Success! Update status and restart heartbeat
          _updateStatus(ConnectionState.connected, 'Reconnected successfully');
          _startHeartbeat();
          
          // Record the reconnection success
          _monitor.recordReconnectionSuccess();
          
          return true;
        } catch (e) {
          // Handle the error and determine if we should retry
          final errorResult = _errorHandler.handleConnectionError(
            e,
            context: 'reconnecting'
          );
          
          _updateStatus(ConnectionState.reconnecting, 
            'Reconnection attempt failed: ${errorResult.message}. Retrying...'
          );
          
          // Record the reconnection failure
          _monitor.recordReconnectionFailure();
          
          return false;
        }
      },
      
      // Called when all reconnection attempts are exhausted
      onGiveUp: () {
        _updateStatus(ConnectionState.failed, 
          'Reconnection failed after ${_reconnector.attempts} attempts'
        );
      }
    );
  }
  
  /// Resets the health statistics for the connection.
  void resetHealthStatistics() {
    _monitor.reset();
  }
  
  /// Disposes the connection manager.
  void dispose() async {
    // Clean up timers
    _stopHeartbeat();
    
    // Cancel any reconnection attempts
    _reconnector.cancelReconnect();
    
    // Disconnect if connected
    if (_state == ConnectionState.connected || _state == ConnectionState.reconnecting) {
      await disconnect();
    }
    
    // Close the status controller
    _connectionStatusController.close();
  }
} 