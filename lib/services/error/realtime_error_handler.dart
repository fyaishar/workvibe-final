import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'error_service.dart';
import 'logging_service.dart';

/// A specialized error handler for Supabase Realtime operations with reconnection logic
class RealtimeErrorHandler {
  static final RealtimeErrorHandler _instance = RealtimeErrorHandler._internal();
  final ErrorService _errorService = ErrorService();
  final LoggingService _loggingService = LoggingService();
  
  // Track reconnection attempts per channel
  final Map<String, int> _reconnectionAttempts = {};
  final Map<String, Timer> _reconnectionTimers = {};
  final Map<String, RealtimeChannel> _channelCache = {};
  
  // Stream controller for broadcasting connection status changes
  final StreamController<RealtimeConnectionStatus> _connectionStatusController = 
      StreamController<RealtimeConnectionStatus>.broadcast();
  
  /// Get the stream of connection status changes
  Stream<RealtimeConnectionStatus> get connectionStatusStream => _connectionStatusController.stream;
  
  /// Maximum reconnection attempts before giving up
  final int maxReconnectionAttempts = 5;
  
  factory RealtimeErrorHandler() {
    return _instance;
  }
  
  RealtimeErrorHandler._internal();
  
  /// Register a channel for monitoring and automatic reconnection
  RealtimeChannel registerChannel(RealtimeChannel channel, String channelId) {
    _channelCache[channelId] = channel;
    
    // Set up error handler using subscription callback
    channel.subscribe((status, error) {
      if (error != null) {
        _handleChannelError(channelId, error);
      } else if (status == RealtimeSubscribeStatus.subscribed) {
        _handleSubscribedStatus(channelId);
      } else if (status == RealtimeSubscribeStatus.closed) {
        _handleClosedStatus(channelId);
      }
    });
    
    return channel;
  }
  
  /// Handle channel errors and initiate reconnection if needed
  void _handleChannelError(String channelId, Object error) {
    final message = _errorService.handleRealtimeError(error);
    
    _loggingService.error(
      'Realtime channel error: $channelId',
      category: LogCategory.realtime,
      error: error,
      additionalData: {
        'channelId': channelId,
        'errorMessage': message,
      },
    );
    
    // Notify listeners about the error
    _connectionStatusController.add(
      RealtimeConnectionStatus(
        channelId: channelId,
        status: RealtimeStatus.error,
        error: error,
        message: message,
      ),
    );
    
    // Attempt to reconnect if needed
    _initiateReconnection(channelId);
  }
  
  /// Handle successful subscription
  void _handleSubscribedStatus(String channelId) {
    // Reset reconnection attempts on successful subscription
    _reconnectionAttempts[channelId] = 0;
    
    _loggingService.info(
      'Channel subscribed: $channelId',
      category: LogCategory.realtime,
    );
    
    // Notify listeners about successful connection
    _connectionStatusController.add(
      RealtimeConnectionStatus(
        channelId: channelId,
        status: RealtimeStatus.connected,
        message: 'Connected successfully',
      ),
    );
  }
  
  /// Handle closed status
  void _handleClosedStatus(String channelId) {
    _loggingService.warning(
      'Channel closed: $channelId',
      category: LogCategory.realtime,
    );
    
    // Notify listeners about closed connection
    _connectionStatusController.add(
      RealtimeConnectionStatus(
        channelId: channelId,
        status: RealtimeStatus.disconnected,
        message: 'Connection closed',
      ),
    );
    
    // Attempt to reconnect
    _initiateReconnection(channelId);
  }
  
  /// Initiate reconnection with exponential backoff
  void _initiateReconnection(String channelId) {
    // Cancel any existing reconnection timer
    _reconnectionTimers[channelId]?.cancel();
    
    // Increment attempt counter
    _reconnectionAttempts[channelId] = (_reconnectionAttempts[channelId] ?? 0) + 1;
    
    // Check if we've exceeded max attempts
    if ((_reconnectionAttempts[channelId] ?? 0) > maxReconnectionAttempts) {
      _loggingService.warning(
        'Abandoning reconnection attempts for channel: $channelId after $maxReconnectionAttempts attempts',
        category: LogCategory.realtime,
      );
      
      // Notify listeners about permanent failure
      _connectionStatusController.add(
        RealtimeConnectionStatus(
          channelId: channelId,
          status: RealtimeStatus.disconnected,
          message: 'Failed to reconnect after $maxReconnectionAttempts attempts',
        ),
      );
      
      return;
    }
    
    // Calculate delay with exponential backoff (1s, 2s, 4s, 8s, 16s)
    final attempt = _reconnectionAttempts[channelId] ?? 1;
    final delayMs = 1000 * (1 << (attempt - 1)); // 2^(attempt-1) seconds
    
    _loggingService.info(
      'Scheduling reconnection attempt for channel: $channelId',
      category: LogCategory.realtime,
      additionalData: {
        'attempt': attempt,
        'delayMs': delayMs,
        'maxAttempts': maxReconnectionAttempts,
      },
    );
    
    // Notify listeners about reconnection attempt
    _connectionStatusController.add(
      RealtimeConnectionStatus(
        channelId: channelId,
        status: RealtimeStatus.connecting,
        message: 'Reconnecting (attempt $attempt of $maxReconnectionAttempts)...',
      ),
    );
    
    // Schedule reconnection
    _reconnectionTimers[channelId] = Timer(Duration(milliseconds: delayMs), () {
      _executeReconnection(channelId);
    });
  }
  
  /// Execute the actual reconnection
  void _executeReconnection(String channelId) {
    final channel = _channelCache[channelId];
    if (channel == null) {
      _loggingService.error(
        'Cannot reconnect channel: $channelId - not found in cache',
        category: LogCategory.realtime,
      );
      return;
    }
    
    _loggingService.info(
      'Attempting to reconnect channel: $channelId',
      category: LogCategory.realtime,
    );
    
    // Attempt to resubscribe
    try {
      channel.unsubscribe();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          channel.subscribe((status, error) {
            if (error != null) {
              _handleChannelError(channelId, error);
            } else if (status == RealtimeSubscribeStatus.subscribed) {
              // Reset reconnection attempts on successful subscription
              _reconnectionAttempts[channelId] = 0;
              
              _loggingService.info(
                'Successfully reconnected channel: $channelId',
                category: LogCategory.realtime,
              );
              
              // Notify listeners about successful reconnection
              _connectionStatusController.add(
                RealtimeConnectionStatus(
                  channelId: channelId,
                  status: RealtimeStatus.connected,
                  message: 'Successfully reconnected',
                ),
              );
            }
          });
        } catch (e) {
          _loggingService.error(
            'Failed to resubscribe to channel: $channelId',
            category: LogCategory.realtime,
            error: e,
          );
          
          // Try again
          _initiateReconnection(channelId);
        }
      });
    } catch (e) {
      _loggingService.error(
        'Failed to unsubscribe from channel: $channelId',
        category: LogCategory.realtime,
        error: e,
      );
      
      // Try again
      _initiateReconnection(channelId);
    }
  }
  
  /// Manually trigger reconnection for a channel
  void reconnectChannel(String channelId) {
    _reconnectionAttempts[channelId] = 0; // Reset attempts
    _initiateReconnection(channelId);
  }
  
  /// Clean up resources when a channel is no longer needed
  void unregisterChannel(String channelId) {
    _channelCache.remove(channelId);
    _reconnectionAttempts.remove(channelId);
    _reconnectionTimers[channelId]?.cancel();
    _reconnectionTimers.remove(channelId);
  }
  
  /// Clean up all resources when the handler is no longer needed
  void dispose() {
    for (final timer in _reconnectionTimers.values) {
      timer.cancel();
    }
    _reconnectionTimers.clear();
    _reconnectionAttempts.clear();
    _channelCache.clear();
    _connectionStatusController.close();
  }
}

/// Enum representing the status of a realtime connection
enum RealtimeStatus {
  connecting,
  connected,
  disconnected,
  error,
}

/// Class representing the status of a realtime connection
class RealtimeConnectionStatus {
  final String channelId;
  final RealtimeStatus status;
  final Object? error;
  final String? message;
  
  RealtimeConnectionStatus({
    required this.channelId,
    required this.status,
    this.error,
    this.message,
  });
} 