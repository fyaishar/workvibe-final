import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../connection/connection_manager.dart';
import '../error/realtime_error_handler.dart';
import '../error/logging_service.dart';
import 'subscription_types.dart';

/// Manages real-time subscriptions with robust error handling and reconnection.
class SubscriptionManager {
  // Singleton instance
  static final SubscriptionManager _instance = SubscriptionManager._internal();
  
  factory SubscriptionManager() {
    return _instance;
  }
  
  // Private constructor
  SubscriptionManager._internal();
  
  // Dependencies
  final SupabaseClient _supabase = Supabase.instance.client;
  final LoggingService _logger = LoggingService();
  final ConnectionManager _connectionManager = ConnectionManager();
  final RealtimeErrorHandler _errorHandler = RealtimeErrorHandler();
  
  // Subscription tracking
  final Map<String, SubscriptionInfo> _subscriptions = {};
  final Map<String, StreamController> _streamControllers = {};
  final Map<String, RealtimeChannel> _channels = {};
  
  // Status tracking
  final _statusController = StreamController<SubscriptionStatusUpdate>.broadcast();
  
  /// Stream of subscription status updates
  Stream<SubscriptionStatusUpdate> get onStatus => _statusController.stream;
  
  /// Get a list of all active subscriptions
  List<SubscriptionInfo> get activeSubscriptions => 
      _subscriptions.values.where((sub) => 
          sub.status == SubscriptionStatus.connected || 
          sub.status == SubscriptionStatus.reconnecting).toList();
  
  /// Get a subscription by ID
  SubscriptionInfo? getSubscription(String id) => _subscriptions[id];
  
  /// Subscribes to all changes for a table
  Stream<List<Map<String, dynamic>>> subscribeToTable(
    String tableName, {
    SubscriptionConfig? config,
  }) {
    final subscriptionId = _generateSubscriptionId();
    final channelName = 'realtime:${tableName}_${subscriptionId}';
    
    // Create subscription info
    final subscriptionInfo = SubscriptionInfo(
      id: subscriptionId,
      channelName: channelName,
      tableName: tableName,
      type: SubscriptionType.table,
      status: SubscriptionStatus.initializing,
      createdAt: DateTime.now(),
    );
    
    // Store subscription info
    _subscriptions[subscriptionId] = subscriptionInfo;
    
    // Create stream controller for this subscription
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    _streamControllers[subscriptionId] = controller;
    
    // Update status
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.connecting,
      'Connecting to table $tableName',
    );
    
    // Create channel
    final channel = _supabase.channel(channelName);
    
    // Set up Postgres changes listener
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      callback: (payload) {
        _handlePostgresEvent(subscriptionId, payload);
      },
    );
    
    // Subscribe to the channel
    channel.subscribe((status, error) {
      if (error != null) {
        _handleSubscriptionError(subscriptionId, error);
      } else if (status == RealtimeSubscribeStatus.subscribed) {
        _handleSubscriptionSuccess(subscriptionId);
      } else if (status == RealtimeSubscribeStatus.closed) {
        _handleSubscriptionClosed(subscriptionId);
      }
    });
    
    // Store the channel
    _channels[subscriptionId] = channel;
    
    // Handle stream controller closing
    controller.onCancel = () {
      unsubscribe(subscriptionId);
    };
    
    // Fetch initial data if configured
    _fetchInitialData(subscriptionId, tableName);
    
    // Register with error handler for automatic reconnection
    _errorHandler.registerChannel(channel, subscriptionId);
    
    return controller.stream;
  }
  
  /// Subscribes to changes for a specific record by ID
  Stream<Map<String, dynamic>?> subscribeToRecord(
    String tableName,
    String recordId, {
    SubscriptionConfig? config,
  }) {
    final subscriptionId = _generateSubscriptionId();
    final channelName = 'realtime:${tableName}_${recordId}_${subscriptionId}';
    
    // Create subscription info
    final subscriptionInfo = SubscriptionInfo(
      id: subscriptionId,
      channelName: channelName,
      tableName: tableName,
      type: SubscriptionType.record,
      filter: {'id': recordId},
      status: SubscriptionStatus.initializing,
      createdAt: DateTime.now(),
    );
    
    // Store subscription info
    _subscriptions[subscriptionId] = subscriptionInfo;
    
    // Create stream controller for this subscription
    final controller = StreamController<Map<String, dynamic>?>.broadcast();
    _streamControllers[subscriptionId] = controller;
    
    // Update status
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.connecting,
      'Connecting to record $recordId in table $tableName',
    );
    
    // Create channel
    final channel = _supabase.channel(channelName);
    
    // Create filter for the specific record
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'id',
      value: recordId,
    );
    
    // Set up Postgres changes listener
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      filter: filter,
      callback: (payload) {
        _handleRecordEvent(subscriptionId, payload);
      },
    );
    
    // Subscribe to the channel
    channel.subscribe((status, error) {
      if (error != null) {
        _handleSubscriptionError(subscriptionId, error);
      } else if (status == RealtimeSubscribeStatus.subscribed) {
        _handleSubscriptionSuccess(subscriptionId);
      } else if (status == RealtimeSubscribeStatus.closed) {
        _handleSubscriptionClosed(subscriptionId);
      }
    });
    
    // Store the channel
    _channels[subscriptionId] = channel;
    
    // Handle stream controller closing
    controller.onCancel = () {
      unsubscribe(subscriptionId);
    };
    
    // Fetch initial data if configured
    _fetchInitialRecordData(subscriptionId, tableName, recordId);
    
    // Register with error handler for automatic reconnection
    _errorHandler.registerChannel(channel, subscriptionId);
    
    return controller.stream;
  }
  
  /// Subscribes to changes for a filtered query
  Stream<List<Map<String, dynamic>>> subscribeToQuery(
    String tableName,
    Map<String, dynamic> queryFilter, {
    SubscriptionConfig? config,
  }) {
    final subscriptionId = _generateSubscriptionId();
    final channelName = 'realtime:${tableName}_query_${subscriptionId}';
    
    // Create subscription info
    final subscriptionInfo = SubscriptionInfo(
      id: subscriptionId,
      channelName: channelName,
      tableName: tableName,
      type: SubscriptionType.query,
      filter: queryFilter,
      status: SubscriptionStatus.initializing,
      createdAt: DateTime.now(),
    );
    
    // Store subscription info
    _subscriptions[subscriptionId] = subscriptionInfo;
    
    // Create stream controller for this subscription
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    _streamControllers[subscriptionId] = controller;
    
    // Update status
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.connecting,
      'Connecting to filtered query on table $tableName',
    );
    
    // Create channel
    final channel = _supabase.channel(channelName);
    
    // Set up Postgres changes listener for all changes to this table
    // We will filter the results client-side since complex filters aren't
    // fully supported by Realtime
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      callback: (payload) {
        _handleQueryEvent(subscriptionId, payload, queryFilter);
      },
    );
    
    // Subscribe to the channel
    channel.subscribe((status, error) {
      if (error != null) {
        _handleSubscriptionError(subscriptionId, error);
      } else if (status == RealtimeSubscribeStatus.subscribed) {
        _handleSubscriptionSuccess(subscriptionId);
      } else if (status == RealtimeSubscribeStatus.closed) {
        _handleSubscriptionClosed(subscriptionId);
      }
    });
    
    // Store the channel
    _channels[subscriptionId] = channel;
    
    // Handle stream controller closing
    controller.onCancel = () {
      unsubscribe(subscriptionId);
    };
    
    // Fetch initial data if configured
    _fetchInitialQueryData(subscriptionId, tableName, queryFilter);
    
    // Register with error handler for automatic reconnection
    _errorHandler.registerChannel(channel, subscriptionId);
    
    return controller.stream;
  }
  
  /// Unsubscribes from a subscription and releases resources
  void unsubscribe(String subscriptionId) {
    final subscription = _subscriptions[subscriptionId];
    if (subscription == null) return;
    
    try {
      // Close the channel
      final channel = _channels[subscriptionId];
      if (channel != null) {
        channel.unsubscribe();
        _supabase.removeChannel(channel);
        _channels.remove(subscriptionId);
      }
      
      // Unregister from error handler
      _errorHandler.unregisterChannel(subscriptionId);
      
      // Close stream controller
      final controller = _streamControllers[subscriptionId];
      if (controller != null && !controller.isClosed) {
        controller.close();
        _streamControllers.remove(subscriptionId);
      }
      
      // Update subscription status
      final updatedSubscription = subscription.copyWith(
        status: SubscriptionStatus.cancelled,
        updatedAt: DateTime.now(),
      );
      _subscriptions[subscriptionId] = updatedSubscription;
      
      // Notify listeners
      _updateSubscriptionStatus(
        subscriptionId, 
        SubscriptionStatus.cancelled,
        'Subscription cancelled',
      );
      
      _logger.info(
        'Unsubscribed from $subscriptionId',
        category: LogCategory.realtime,
        additionalData: {
          'table': subscription.tableName,
          'type': subscription.type.toString(),
        },
      );
    } catch (e) {
      _logger.error(
        'Error unsubscribing from $subscriptionId',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'table': subscription.tableName,
          'type': subscription.type.toString(),
        },
      );
    }
  }
  
  /// Force reconnection of a subscription
  void reconnect(String subscriptionId) {
    final subscription = _subscriptions[subscriptionId];
    if (subscription == null) return;
    
    // Get the channel
    final channel = _channels[subscriptionId];
    if (channel == null) return;
    
    // Trigger reconnection through error handler
    _errorHandler.reconnectChannel(subscriptionId);
  }
  
  /// Handles a successful subscription
  void _handleSubscriptionSuccess(String subscriptionId) {
    final subscription = _subscriptions[subscriptionId];
    if (subscription == null) return;
    
    // Update subscription status
    final updatedSubscription = subscription.copyWith(
      status: SubscriptionStatus.connected,
      updatedAt: DateTime.now(),
    );
    _subscriptions[subscriptionId] = updatedSubscription;
    
    // Notify listeners
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.connected,
      'Subscription connected successfully',
    );
    
    _logger.info(
      'Subscription connected: $subscriptionId',
      category: LogCategory.realtime,
      additionalData: {
        'table': subscription.tableName,
        'type': subscription.type.toString(),
      },
    );
  }
  
  /// Handles subscription errors
  void _handleSubscriptionError(String subscriptionId, Object error) {
    final subscription = _subscriptions[subscriptionId];
    if (subscription == null) return;
    
    // Update subscription status
    final updatedSubscription = subscription.copyWith(
      status: SubscriptionStatus.error,
      lastError: error,
      updatedAt: DateTime.now(),
      connectionAttempts: subscription.connectionAttempts + 1,
    );
    _subscriptions[subscriptionId] = updatedSubscription;
    
    // Notify listeners
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.error,
      'Subscription error: ${error.toString()}',
      error: error,
    );
    
    _logger.error(
      'Subscription error: $subscriptionId',
      category: LogCategory.realtime,
      error: error,
      additionalData: {
        'table': subscription.tableName,
        'type': subscription.type.toString(),
        'attempts': updatedSubscription.connectionAttempts,
      },
    );
  }
  
  /// Handles subscription closures
  void _handleSubscriptionClosed(String subscriptionId) {
    final subscription = _subscriptions[subscriptionId];
    if (subscription == null) return;
    
    // Update subscription status
    final updatedSubscription = subscription.copyWith(
      status: SubscriptionStatus.disconnected,
      updatedAt: DateTime.now(),
    );
    _subscriptions[subscriptionId] = updatedSubscription;
    
    // Notify listeners
    _updateSubscriptionStatus(
      subscriptionId, 
      SubscriptionStatus.disconnected,
      'Subscription closed',
    );
    
    _logger.info(
      'Subscription closed: $subscriptionId',
      category: LogCategory.realtime,
      additionalData: {
        'table': subscription.tableName,
        'type': subscription.type.toString(),
      },
    );
  }
  
  /// Handles Postgres events for table subscriptions
  void _handlePostgresEvent(String subscriptionId, PostgresChangePayload payload) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      // Fetch all current data for this table
      _supabase
          .from(payload.table)
          .select()
          .then((result) {
            final data = result as List<dynamic>;
            final records = data.map((item) => item as Map<String, dynamic>).toList();
            
            if (!controller.isClosed) {
              controller.add(records);
            }
          })
          .catchError((error) {
            _logger.error(
              'Error fetching data after Postgres event',
              category: LogCategory.realtime,
              error: error,
              additionalData: {
                'subscriptionId': subscriptionId,
                'table': payload.table,
                'eventType': payload.eventType.toString(),
              },
            );
          });
    } catch (e) {
      _logger.error(
        'Error handling Postgres event',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': payload.table,
          'eventType': payload.eventType.toString(),
        },
      );
    }
  }
  
  /// Handles Postgres events for record subscriptions
  void _handleRecordEvent(String subscriptionId, PostgresChangePayload payload) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      if (payload.eventType == PostgresChangeEvent.delete) {
        // If the record was deleted, emit null
        if (!controller.isClosed) {
          controller.add(null);
        }
      } else {
        // For inserts and updates, emit the new record
        if (!controller.isClosed && payload.newRecord != null) {
          controller.add(payload.newRecord);
        }
      }
    } catch (e) {
      _logger.error(
        'Error handling record event',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': payload.table,
          'eventType': payload.eventType.toString(),
        },
      );
    }
  }
  
  /// Handles Postgres events for query subscriptions with filtering
  void _handleQueryEvent(
    String subscriptionId, 
    PostgresChangePayload payload,
    Map<String, dynamic> queryFilter,
  ) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      // Apply filters to the query
      var query = _supabase.from(payload.table).select();
      
      queryFilter.forEach((key, value) {
        if (value is List) {
          query = query.inFilter(key, value);
        } else {
          query = query.eq(key, value);
        }
      });
      
      // Execute the query with filters
      query.then((result) {
        final data = result as List<dynamic>;
        final records = data.map((item) => item as Map<String, dynamic>).toList();
        
        if (!controller.isClosed) {
          controller.add(records);
        }
      }).catchError((error) {
        _logger.error(
          'Error fetching filtered data after Postgres event',
          category: LogCategory.realtime,
          error: error,
          additionalData: {
            'subscriptionId': subscriptionId,
            'table': payload.table,
            'filter': queryFilter.toString(),
          },
        );
      });
    } catch (e) {
      _logger.error(
        'Error handling query event',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': payload.table,
          'filter': queryFilter.toString(),
        },
      );
    }
  }
  
  /// Fetches initial data for a table subscription
  void _fetchInitialData(String subscriptionId, String tableName) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      _supabase
          .from(tableName)
          .select()
          .then((result) {
            final data = result as List<dynamic>;
            final records = data.map((item) => item as Map<String, dynamic>).toList();
            
            if (!controller.isClosed) {
              controller.add(records);
            }
          })
          .catchError((error) {
            _logger.error(
              'Error fetching initial data',
              category: LogCategory.realtime,
              error: error,
              additionalData: {
                'subscriptionId': subscriptionId,
                'table': tableName,
              },
            );
            
            // Add an empty list to avoid blocking the stream
            if (!controller.isClosed) {
              controller.add([]);
            }
          });
    } catch (e) {
      _logger.error(
        'Error fetching initial data',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': tableName,
        },
      );
      
      // Add an empty list to avoid blocking the stream
      if (!controller.isClosed) {
        controller.add([]);
      }
    }
  }
  
  /// Fetches initial data for a record subscription
  void _fetchInitialRecordData(String subscriptionId, String tableName, String recordId) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      _supabase
          .from(tableName)
          .select()
          .eq('id', recordId)
          .maybeSingle()
          .then((result) {
            if (!controller.isClosed) {
              controller.add(result as Map<String, dynamic>?);
            }
          })
          .catchError((error) {
            _logger.error(
              'Error fetching initial record data',
              category: LogCategory.realtime,
              error: error,
              additionalData: {
                'subscriptionId': subscriptionId,
                'table': tableName,
                'recordId': recordId,
              },
            );
            
            // Add null to avoid blocking the stream
            if (!controller.isClosed) {
              controller.add(null);
            }
          });
    } catch (e) {
      _logger.error(
        'Error fetching initial record data',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': tableName,
          'recordId': recordId,
        },
      );
      
      // Add null to avoid blocking the stream
      if (!controller.isClosed) {
        controller.add(null);
      }
    }
  }
  
  /// Fetches initial data for a query subscription
  void _fetchInitialQueryData(
    String subscriptionId, 
    String tableName,
    Map<String, dynamic> queryFilter,
  ) {
    final controller = _streamControllers[subscriptionId];
    if (controller == null || controller.isClosed) return;
    
    try {
      // Apply filters to the query
      var query = _supabase.from(tableName).select();
      
      queryFilter.forEach((key, value) {
        if (value is List) {
          query = query.inFilter(key, value);
        } else {
          query = query.eq(key, value);
        }
      });
      
      // Execute the query with filters
      query.then((result) {
        final data = result as List<dynamic>;
        final records = data.map((item) => item as Map<String, dynamic>).toList();
        
        if (!controller.isClosed) {
          controller.add(records);
        }
      }).catchError((error) {
        _logger.error(
          'Error fetching initial filtered data',
          category: LogCategory.realtime,
          error: error,
          additionalData: {
            'subscriptionId': subscriptionId,
            'table': tableName,
            'filter': queryFilter.toString(),
          },
        );
        
        // Add an empty list to avoid blocking the stream
        if (!controller.isClosed) {
          controller.add([]);
        }
      });
    } catch (e) {
      _logger.error(
        'Error fetching initial filtered data',
        category: LogCategory.realtime,
        error: e,
        additionalData: {
          'subscriptionId': subscriptionId,
          'table': tableName,
          'filter': queryFilter.toString(),
        },
      );
      
      // Add an empty list to avoid blocking the stream
      if (!controller.isClosed) {
        controller.add([]);
      }
    }
  }
  
  /// Generates a unique subscription ID
  String _generateSubscriptionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final result = StringBuffer();
    
    for (var i = 0; i < 12; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }
    
    return 'sub_${DateTime.now().millisecondsSinceEpoch}_${result.toString()}';
  }
  
  /// Updates subscription status and broadcasts the change
  void _updateSubscriptionStatus(
    String subscriptionId,
    SubscriptionStatus status,
    String message, {
    Object? error,
  }) {
    // Broadcast status update
    _statusController.add(SubscriptionStatusUpdate(
      subscriptionId: subscriptionId,
      status: status,
      message: message,
      error: error,
    ));
  }
  
  /// Dispose all resources
  void dispose() {
    // Unsubscribe from all subscriptions
    final subscriptionIds = _subscriptions.keys.toList();
    for (final id in subscriptionIds) {
      unsubscribe(id);
    }
    
    // Close the status controller
    if (!_statusController.isClosed) {
      _statusController.close();
    }
    
    _errorHandler.dispose();
  }
} 