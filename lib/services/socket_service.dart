import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_realtime_service.dart';

/// SocketService provides a unified API for real-time communication
/// that mimics the original Socket.IO API but uses Supabase under the hood.
class SocketService {
  static final SocketService _instance = SocketService._internal();
  
  /// The underlying Supabase realtime service
  final SupabaseRealtimeService _realtimeService;
  
  /// Connection status
  bool _isConnected = false;
  String _connectionStatus = 'disconnected';
  
  /// Stream controllers for connection status events
  final _connectionStatusController = StreamController<String>.broadcast();
  
  /// Stream of connection status events
  Stream<String> get onConnectionStatus => _connectionStatusController.stream;
  
  /// Current connection status
  String get connectionStatus => _connectionStatus;
  
  /// Whether the socket is currently connected
  bool get isConnected => _isConnected;
  
  /// Event streams from the realtime service
  Stream<Map<String, dynamic>> get onSessionEvent => _realtimeService.onSessionEvent;
  Stream<Map<String, dynamic>> get onTaskEvent => _realtimeService.onTaskEvent;
  Stream<Map<String, dynamic>> get onProjectEvent => _realtimeService.onProjectEvent;
  Stream<Map<String, dynamic>> get onRoomEvent => _realtimeService.onRoomEvent;
  Stream<Map<String, dynamic>> get onPresenceEvent => _realtimeService.onPresenceEvent;
  
  /// Subscription references for internal event handling
  List<StreamSubscription> _subscriptions = [];
  
  /// Callback registry for events
  final Map<String, List<Function>> _eventCallbacks = {};
  
  /// Factory constructor that returns singleton instance
  factory SocketService({SupabaseRealtimeService? realtimeService}) {
    if (realtimeService != null) {
      // In test mode - create new instance with provided mock
      return SocketService._test(realtimeService);
    }
    return _instance;
  }
  
  /// Private constructor used by the singleton instance
  SocketService._internal() : _realtimeService = SupabaseRealtimeService();
  
  /// Test constructor to inject mock dependencies
  @visibleForTesting
  SocketService._test(this._realtimeService);
  
  /// Initialize the socket service and connect to Supabase
  Future<void> initialize() async {
    _setConnectionStatus('connecting');
    
    try {
      // Initialize the realtime service
      await _realtimeService.initialize();
      
      // Set up listeners for the realtime service events
      _setupEventListeners();
      
      _setConnectionStatus('connected');
    } catch (e) {
      _setConnectionStatus('error');
      debugPrint('SocketService: Error initializing: $e');
      rethrow;
    }
  }
  
  /// Clean up resources when the service is no longer needed
  void dispose() {
    // Cancel all event subscriptions
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    // Close the realtime service
    _realtimeService.dispose();
    
    // Set status variables directly (don't emit)
    _connectionStatus = 'disconnected';
    _isConnected = false;
    
    // Close the connection status controller
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.close();
    }
  }
  
  /// Set up listeners for the realtime service events and route them to callbacks
  @visibleForTesting
  void _setupEventListeners() {
    // Session events
    _subscriptions.add(
      _realtimeService.onSessionEvent.listen((event) {
        final eventType = event['event'] as String;
        final data = event['data'];
        _emitEvent(eventType, data);
      })
    );
    
    // Task events
    _subscriptions.add(
      _realtimeService.onTaskEvent.listen((event) {
        final eventType = event['event'] as String;
        final data = event['data'];
        _emitEvent(eventType, data);
      })
    );
    
    // Project events
    _subscriptions.add(
      _realtimeService.onProjectEvent.listen((event) {
        final eventType = event['event'] as String;
        final data = event['data'];
        _emitEvent(eventType, data);
      })
    );
    
    // Room events
    _subscriptions.add(
      _realtimeService.onRoomEvent.listen((event) {
        final eventType = event['event'] as String;
        final data = event['data'];
        _emitEvent(eventType, data);
      })
    );
    
    // Presence events
    _subscriptions.add(
      _realtimeService.onPresenceEvent.listen((event) {
        final eventType = event['event'] as String;
        final data = event['data'];
        _emitEvent(eventType, data);
      })
    );
  }
  
  /// Update the connection status and emit an event
  void _setConnectionStatus(String status) {
    _connectionStatus = status;
    _isConnected = status == 'connected';
    
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
    
    debugPrint('SocketService: Connection status changed to $status');
  }
  
  /// Register a callback for a specific event type
  void on(String event, Function callback) {
    if (!_eventCallbacks.containsKey(event)) {
      _eventCallbacks[event] = [];
    }
    _eventCallbacks[event]?.add(callback);
  }
  
  /// Remove a callback for a specific event type
  void off(String event, [Function? callback]) {
    if (callback == null) {
      // Remove all callbacks for this event
      _eventCallbacks.remove(event);
    } else {
      // Remove specific callback
      _eventCallbacks[event]?.remove(callback);
      if (_eventCallbacks[event]?.isEmpty ?? false) {
        _eventCallbacks.remove(event);
      }
    }
  }
  
  /// Emit an event to all registered callbacks
  void _emitEvent(String event, dynamic data) {
    final callbacks = _eventCallbacks[event];
    if (callbacks != null) {
      for (var callback in callbacks) {
        if (callback is Function(dynamic)) {
          callback(data);
        } else if (callback is Function(dynamic, Function)) {
          // Support for Socket.IO style callbacks
          callback(data, (dynamic response) {
            debugPrint('SocketService: Callback response for $event: $response');
          });
        }
      }
    }
  }
  
  /// Session methods that match the original Socket.IO API
  
  /// Start a new session
  Future<Map<String, dynamic>> startSession(Map<String, dynamic> sessionData, [Function? callback]) async {
    try {
      final response = await _realtimeService.startSession(sessionData);
      if (callback != null) {
        callback({'status': 201, 'message': 'Session started'});
      }
      return response;
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error starting session: $e'});
      }
      rethrow;
    }
  }
  
  /// Get the current session details
  Future<Map<String, dynamic>> getCurrentSession(Map<String, dynamic> data, [Function? callback]) async {
    try {
      final response = await _realtimeService.getCurrentSession(data['sessionId']);
      if (callback != null) {
        callback({'status': 200, 'sessionData': response});
      }
      return response;
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error retrieving session: $e'});
      }
      rethrow;
    }
  }
  
  /// Get session history
  Future<List<Map<String, dynamic>>> getSessionHistory(Map<String, dynamic> data, [Function? callback]) async {
    try {
      final List<Map<String, dynamic>> response = []; // Temporary empty response
      if (callback != null) {
        callback({'status': 200, 'history': response});
      }
      return response;
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error retrieving history: $e'});
      }
      rethrow;
    }
  }
  
  /// Update the current task in a session
  Future<void> updateTask(Map<String, dynamic> data, [Function? callback]) async {
    try {
      final sessionId = data['sessionId'] as String;
      final taskId = data['currentTask'] is Map ? 
                     data['currentTask']['id'] as String :
                     data['currentTask'] as String;
      
      if (callback != null) {
        callback({'status': 200, 'message': 'Task updated (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error updating task: $e'});
      }
      rethrow;
    }
  }
  
  /// Update the current project in a session
  Future<void> updateProject(Map<String, dynamic> data, [Function? callback]) async {
    try {
      if (callback != null) {
        callback({'status': 200, 'message': 'Project updated (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error updating project: $e'});
      }
      rethrow;
    }
  }
  
  /// Update session thickness (based on start time)
  Future<void> updateThickness(Map<String, dynamic> data, [Function? callback]) async {
    try {
      if (callback != null) {
        callback({'status': 200, 'message': 'Session thickness updated (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error updating thickness: $e'});
      }
      rethrow;
    }
  }
  
  /// Update session status
  Future<void> updateStatus(Map<String, dynamic> data, [Function? callback]) async {
    try {
      if (callback != null) {
        callback({'status': 200, 'message': 'Status updated (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error updating status: $e'});
      }
      rethrow;
    }
  }
  
  /// End a session
  Future<void> endSession(Map<String, dynamic> data, [Function? callback]) async {
    try {
      await _realtimeService.endSession(
        data['sessionId']
      );
      if (callback != null) {
        callback({'status': 200, 'message': 'Session ended'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error ending session: $e'});
      }
      rethrow;
    }
  }
  
  /// Room methods that match the original Socket.IO API
  
  /// Create a new room
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data, [Function? callback]) async {
    try {
      final Map<String, dynamic> response = {}; // Temporary empty response
      if (callback != null) {
        callback({'status': 201, 'message': 'Room created (mocked)'});
      }
      return response;
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error creating room: $e'});
      }
      rethrow;
    }
  }
  
  /// Get active sessions for a room
  Future<int> getActiveSessions(String roomId, [Function? callback]) async {
    try {
      const int response = 0; // Temporary empty response
      if (callback != null) {
        callback({'status': 200, 'data': response});
      }
      return response;
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error fetching active sessions: $e'});
      }
      rethrow;
    }
  }
  
  /// Update active sessions for a room
  Future<void> updateActiveSessions(Map<String, dynamic> data, [Function? callback]) async {
    try {
      if (callback != null) {
        callback({'status': 200, 'message': 'Active sessions updated (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error updating active sessions: $e'});
      }
      rethrow;
    }
  }
  
  /// Delete a room
  Future<void> deleteRoom(String roomId, [Function? callback]) async {
    try {
      if (callback != null) {
        callback({'status': 200, 'message': 'Room deleted (mocked)'});
      }
    } catch (e) {
      if (callback != null) {
        callback({'status': 500, 'message': 'Error deleting room: $e'});
      }
      rethrow;
    }
  }
} 