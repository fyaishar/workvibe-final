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
    
    // Setup presence channel - temporarily disabled due to compilation issues
    // await _setupPresenceChannel();
    
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
          debugPrint('Session updated: ${payload.toString()}');
          // Handle session update event
          _handleSessionEvent('update-session', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'sessions',
        callback: (payload) {
          debugPrint('Session ended: ${payload.toString()}');
          // Handle session end event
          _handleSessionEvent('end-session', payload.oldRecord);
        });
    
    // Subscribe to the channel to activate the listeners
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
          debugPrint('New task created: ${payload.toString()}');
          _handleTaskEvent('create-task', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'tasks',
        callback: (payload) {
          debugPrint('Task updated: ${payload.toString()}');
          _handleTaskEvent('update-task', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'tasks',
        callback: (payload) {
          debugPrint('Task deleted: ${payload.toString()}');
          _handleTaskEvent('delete-task', payload.oldRecord);
        });
    
    // Subscribe to the channel to activate the listeners
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
          debugPrint('New project created: ${payload.toString()}');
          _handleProjectEvent('create-project', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'projects',
        callback: (payload) {
          debugPrint('Project updated: ${payload.toString()}');
          _handleProjectEvent('update-project', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'projects',
        callback: (payload) {
          debugPrint('Project deleted: ${payload.toString()}');
          _handleProjectEvent('delete-project', payload.oldRecord);
        });
    
    // Subscribe to the channel to activate the listeners
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
          debugPrint('New room created: ${payload.toString()}');
          _handleRoomEvent('create-room', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'rooms',
        callback: (payload) {
          debugPrint('Room updated: ${payload.toString()}');
          _handleRoomEvent('update-room', payload.newRecord);
        })
      .onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'rooms',
        callback: (payload) {
          debugPrint('Room deleted: ${payload.toString()}');
          _handleRoomEvent('delete-room', payload.oldRecord);
        });
    
    // Subscribe to the channel to activate the listeners
    channel.subscribe();
    
    _channels['rooms'] = channel;
    debugPrint('SupabaseRealtimeService: Rooms channel subscribed');
  }
  
  /* Temporarily commented out to fix compilation errors
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
    presenceChannel.subscribe((status, [error]) async {
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
  */
  
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
  
  Future<void> updateSession(String sessionId, Map<String, dynamic> sessionData) async {
    try {
      await _supabase
          .from('sessions')
          .update(sessionData)
          .eq('id', sessionId);
      
      debugPrint('SupabaseRealtimeService: Session updated: $sessionId');
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error updating session: $error');
      rethrow;
    }
  }
  
  Future<void> endSession(String sessionId) async {
    try {
      await _supabase
          .from('sessions')
          .update({
            'ended_at': DateTime.now().toIso8601String(),
            'is_active': false
          })
          .eq('id', sessionId);
      
      debugPrint('SupabaseRealtimeService: Session ended: $sessionId');
    } catch (error) {
      debugPrint('SupabaseRealtimeService: Error ending session: $error');
      rethrow;
    }
  }
} 