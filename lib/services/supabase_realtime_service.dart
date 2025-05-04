import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class SupabaseRealtimeService {
  static final SupabaseRealtimeService _instance = SupabaseRealtimeService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Track active channel subscriptions
  final Map<String, RealtimeChannel> _channels = {};

  // Stream controllers for broadcasting events
  final _sessionEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _taskEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _projectEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _roomEventController = StreamController<Map<String, dynamic>>.broadcast();
  final _presenceEventController = StreamController<Map<String, dynamic>>.broadcast();

  // Expose streams
  Stream<Map<String, dynamic>> get onSessionEvent => _sessionEventController.stream;
  Stream<Map<String, dynamic>> get onTaskEvent => _taskEventController.stream;
  Stream<Map<String, dynamic>> get onProjectEvent => _projectEventController.stream;
  Stream<Map<String, dynamic>> get onRoomEvent => _roomEventController.stream;
  Stream<Map<String, dynamic>> get onPresenceEvent => _presenceEventController.stream;
  
  factory SupabaseRealtimeService() {
    return _instance;
  }
  
  SupabaseRealtimeService._internal();
  
  // Initialize realtime subscriptions
  Future<void> initialize() async {
    // Setup database table subscriptions
    await _setupSessionsChannel();
    await _setupTasksChannel();
    await _setupProjectsChannel();
    await _setupRoomsChannel();
    
    // Setup presence channel
    await _setupPresenceChannel();
    
    debugPrint('SupabaseRealtimeService: All channels initialized');
  }
  
  // Clean up resources when done
  void dispose() {
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    _channels.clear();
    
    _sessionEventController.close();
    _taskEventController.close();
    _projectEventController.close();
    _roomEventController.close();
    _presenceEventController.close();
    
    debugPrint('SupabaseRealtimeService: Disposed all channels and controllers');
  }
  
  // Setup individual channel subscriptions
  
  Future<void> _setupSessionsChannel() async {
    final channel = _supabase.channel('public:sessions');
    
    // Add listeners for session events
    channel
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'sessions',
        callback: (payload) {
          debugPrint('New session started: ${payload.toString()}');
          // Handle session creation event
          _handleSessionEvent('start-session', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'sessions',
        callback: (payload) {
          final newRecord = payload.newRecord;
          final oldRecord = payload.oldRecord;
          
          // Determine which specific update event occurred based on what fields changed
          if (newRecord['current_task'] != oldRecord['current_task']) {
            _handleSessionEvent('update-task', payload.newRecord);
          } else if (newRecord['current_project'] != oldRecord['current_project']) {
            _handleSessionEvent('update-project', payload.newRecord);
          } else if (newRecord['start_time'] != oldRecord['start_time']) {
            _handleSessionEvent('update-thickness', payload.newRecord);
          } else if (newRecord['status'] != oldRecord['status']) {
            _handleSessionEvent('update-status', payload.newRecord);
          } else if (newRecord['end_time'] != null && oldRecord['end_time'] == null) {
            _handleSessionEvent('end-session', payload.newRecord);
          } else {
            // Generic session update
            _handleSessionEvent('update-session', payload.newRecord);
          }
        });
        
    channel.subscribe();
    _channels['sessions'] = channel;
    debugPrint('SupabaseRealtimeService: Sessions channel subscribed');
  }
  
  Future<void> _setupTasksChannel() async {
    final channel = _supabase.channel('public:tasks');
    
    // Add listeners for task events
    channel
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'tasks',
        callback: (payload) {
          _handleTaskEvent('create-task', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'tasks',
        callback: (payload) {
          final newRecord = payload.newRecord;
          final oldRecord = payload.oldRecord;
          
          // Check if the progress_dots field was updated
          if (newRecord['progress_dots'] != oldRecord['progress_dots']) {
            _handleTaskEvent('update-progress-dots', payload.newRecord);
          } else {
            _handleTaskEvent('update-task-details', payload.newRecord);
          }
        });
        
    channel.subscribe();
    _channels['tasks'] = channel;
    debugPrint('SupabaseRealtimeService: Tasks channel subscribed');
  }
  
  Future<void> _setupProjectsChannel() async {
    final channel = _supabase.channel('public:projects');
    
    // Add listeners for project events
    channel
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'projects',
        callback: (payload) {
          _handleProjectEvent('create-project', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'projects',
        callback: (payload) {
          _handleProjectEvent('update-project', payload.newRecord);
        });
        
    channel.subscribe();
    _channels['projects'] = channel;
    debugPrint('SupabaseRealtimeService: Projects channel subscribed');
  }
  
  Future<void> _setupRoomsChannel() async {
    final channel = _supabase.channel('public:rooms');
    
    // Add listeners for room events
    channel
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'rooms',
        callback: (payload) {
          _handleRoomEvent('create-room', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'rooms',
        callback: (payload) {
          final newRecord = payload.newRecord;
          
          // If active_sessions changed
          if (newRecord['active_sessions'] != payload.oldRecord['active_sessions']) {
            _handleRoomEvent('update-activeSessions', payload.newRecord);
          } else {
            _handleRoomEvent('update-room', payload.newRecord);
          }
        });
        
    channel.subscribe();
    _channels['rooms'] = channel;
    debugPrint('SupabaseRealtimeService: Rooms channel subscribed');
  }
  
  Future<void> _setupPresenceChannel() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      debugPrint('SupabaseRealtimeService: Cannot setup presence - user not logged in');
      return;
    }
    
    final presenceChannel = _supabase.channel('online-users');
    
    // Add presence event handlers using the correct API
    presenceChannel
      .onPresenceSync((payload) {
        final presenceState = presenceChannel.presenceState();
        _handlePresenceEvent('presence-sync', presenceState);
      })
      .onPresenceJoin((payload) {
        _handlePresenceEvent('presence-join', payload);
      })
      .onPresenceLeave((payload) {
        _handlePresenceEvent('presence-leave', payload);
      });
    
    // Subscribe to presence channel
    presenceChannel.subscribe((status, [_]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        try {
          await presenceChannel.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
          });
        } catch (e) {
          debugPrint('SupabaseRealtimeService: Error tracking presence: $e');
        }
      }
    });
    
    _channels['presence'] = presenceChannel;
    debugPrint('SupabaseRealtimeService: Presence channel subscribed');
  }
  
  // Event handlers (these will connect to your app's state management)
  void _handleSessionEvent(String eventType, Map<String, dynamic> data) {
    debugPrint('Session event: $eventType, data: $data');
    // Broadcast through the stream controller
    _sessionEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
  void _handleTaskEvent(String eventType, Map<String, dynamic> data) {
    debugPrint('Task event: $eventType, data: $data');
    _taskEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
  void _handleProjectEvent(String eventType, Map<String, dynamic> data) {
    debugPrint('Project event: $eventType, data: $data');
    _projectEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
  void _handleRoomEvent(String eventType, Map<String, dynamic> data) {
    debugPrint('Room event: $eventType, data: $data');
    _roomEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
  void _handlePresenceEvent(String eventType, dynamic data) {
    debugPrint('Presence event: $eventType, data: $data');
    _presenceEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
  // Methods to match old Socket.IO event names (API compatibility layer)
  
  // Session related methods
  Future<Map<String, dynamic>> startSession(Map<String, dynamic> sessionData) async {
    try {
      final response = await _supabase
          .from('sessions')
          .insert(sessionData)
          .select()
          .single();
      
      debugPrint('SupabaseRealtimeService: Session started: ${response.toString()}');
      return response;
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error starting session: $error');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getCurrentSession(String sessionId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('id', sessionId)
          .single();
      
      return response;
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error getting current session: $error');
      rethrow;
    }
  }
  
  Future<List<Map<String, dynamic>>> getSessionHistory(String userId) async {
    try {
      final response = await _supabase
          .from('sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error getting session history: $error');
      rethrow;
    }
  }
  
  Future<void> updateTask(String sessionId, String taskId) async {
    try {
      await _supabase
          .from('sessions')
          .update({'current_task': taskId})
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating task: $error');
      rethrow;
    }
  }
  
  Future<void> updateProject(String sessionId, String projectId) async {
    try {
      await _supabase
          .from('sessions')
          .update({'current_project': projectId})
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating project: $error');
      rethrow;
    }
  }
  
  Future<void> updateThickness(String sessionId, DateTime startTime) async {
    try {
      await _supabase
          .from('sessions')
          .update({'start_time': startTime.toIso8601String()})
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating thickness: $error');
      rethrow;
    }
  }
  
  Future<void> updateStatus(String sessionId, String status) async {
    try {
      await _supabase
          .from('sessions')
          .update({'status': status})
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating status: $error');
      rethrow;
    }
  }
  
  Future<void> endSession(String sessionId, DateTime endTime) async {
    try {
      await _supabase
          .from('sessions')
          .update({
            'status': 'ended',
            'end_time': endTime.toIso8601String()
          })
          .eq('id', sessionId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error ending session: $error');
      rethrow;
    }
  }
  
  // Room related methods
  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> roomData) async {
    try {
      final response = await _supabase
          .from('rooms')
          .insert(roomData)
          .select()
          .single();
          
      return response;
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error creating room: $error');
      rethrow;
    }
  }
  
  Future<int> getActiveSessions(String roomId) async {
    try {
      final response = await _supabase
          .from('rooms')
          .select('active_sessions')
          .eq('id', roomId)
          .single();
      
      return response['active_sessions'] as int;
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error getting active sessions: $error');
      rethrow;
    }
  }
  
  Future<void> updateActiveSessions(String roomId, int activeSessions) async {
    try {
      await _supabase
          .from('rooms')
          .update({'active_sessions': activeSessions})
          .eq('id', roomId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating active sessions: $error');
      rethrow;
    }
  }
  
  Future<void> deleteRoom(String roomId) async {
    try {
      await _supabase
          .from('rooms')
          .delete()
          .eq('id', roomId);
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error deleting room: $error');
      rethrow;
    }
  }
} 