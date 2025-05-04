import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:finalworkvibe/services/socket_service.dart';
import 'package:finalworkvibe/services/supabase_realtime_service.dart';
import 'dart:async';

@GenerateMocks([SupabaseRealtimeService])
import 'socket_supabase_integration_test.mocks.dart';

/// Integration test for SocketService and SupabaseRealtimeService
/// 
/// This test demonstrates how SocketService correctly maps the Socket.IO-like API
/// to Supabase Realtime functionality. It uses mocks to simulate the Supabase backend
/// and verifies the correct integration between the two services.
void main() {
  late MockSupabaseRealtimeService mockRealtimeService;
  late SocketService socketService;
  
  setUp(() {
    mockRealtimeService = MockSupabaseRealtimeService();
    
    // Configure mock streams
    when(mockRealtimeService.onSessionEvent).thenAnswer((_) => 
      Stream<Map<String, dynamic>>.fromIterable([]));
    when(mockRealtimeService.onTaskEvent).thenAnswer((_) => 
      Stream<Map<String, dynamic>>.fromIterable([]));
    when(mockRealtimeService.onProjectEvent).thenAnswer((_) => 
      Stream<Map<String, dynamic>>.fromIterable([]));
    when(mockRealtimeService.onRoomEvent).thenAnswer((_) => 
      Stream<Map<String, dynamic>>.fromIterable([]));
    when(mockRealtimeService.onPresenceEvent).thenAnswer((_) => 
      Stream<Map<String, dynamic>>.fromIterable([]));
    
    // Create SocketService with the mock
    socketService = SocketService(realtimeService: mockRealtimeService);
  });
  
  group('Session management', () {
    test('startSession correctly initializes a new session in Supabase', () async {
      // Arrange
      final userId = 'user123';
      final sessionData = {
        'user_id': userId,
        'status': 'active',
        'start_time': DateTime.now().toIso8601String(),
      };
      
      when(mockRealtimeService.startSession(sessionData))
          .thenAnswer((_) async => {
            'id': 'session-456',
            ...sessionData
          });
      
      // Act
      final result = await socketService.startSession(sessionData);
      
      // Assert
      expect(result['id'], 'session-456');
      expect(result['user_id'], userId);
      verify(mockRealtimeService.startSession(sessionData)).called(1);
    });
    
    test('getCurrentSession retrieves session data from Supabase', () async {
      // Arrange
      final sessionId = 'session-456';
      when(mockRealtimeService.getCurrentSession(sessionId))
          .thenAnswer((_) async => {
            'id': sessionId,
            'user_id': 'user123',
            'status': 'active',
          });
      
      // Act
      final result = await socketService.getCurrentSession({'sessionId': sessionId});
      
      // Assert
      expect(result['id'], sessionId);
      expect(result['status'], 'active');
      verify(mockRealtimeService.getCurrentSession(sessionId)).called(1);
    });
    
    test('updateTask sends task updates to Supabase', () async {
      // Arrange
      final sessionId = 'session-456';
      final taskId = 'task-789';
      when(mockRealtimeService.updateTask(sessionId, taskId))
          .thenAnswer((_) async => {});
      
      // Act
      await socketService.updateTask({
        'sessionId': sessionId,
        'currentTask': taskId,
      });
      
      // Assert
      verify(mockRealtimeService.updateTask(sessionId, taskId)).called(1);
    });
    
    test('endSession correctly finalizes a session in Supabase', () async {
      // Arrange
      final sessionId = 'session-456';
      final endTime = DateTime.now();
      when(mockRealtimeService.endSession(sessionId, any))
          .thenAnswer((_) async => {});
      
      // Act
      await socketService.endSession({
        'sessionId': sessionId,
        'endTime': endTime.millisecondsSinceEpoch,
      });
      
      // Assert
      verify(mockRealtimeService.endSession(sessionId, any)).called(1);
    });
  });
  
  group('Room management', () {
    test('createRoom initializes a new room in Supabase', () async {
      // Arrange
      final roomData = {
        'name': 'Test Room',
        'created_by': 'user123',
        'active_sessions': 0,
      };
      
      when(mockRealtimeService.createRoom(roomData))
          .thenAnswer((_) async => {
            'id': 'room-789',
            ...roomData,
          });
      
      // Act
      final result = await socketService.createRoom(roomData);
      
      // Assert
      expect(result['id'], 'room-789');
      expect(result['name'], 'Test Room');
      verify(mockRealtimeService.createRoom(roomData)).called(1);
    });
    
    test('getActiveSessions retrieves active sessions count from Supabase', () async {
      // Arrange
      final roomId = 'room-789';
      when(mockRealtimeService.getActiveSessions(roomId))
          .thenAnswer((_) async => 5);
      
      // Act
      final count = await socketService.getActiveSessions(roomId);
      
      // Assert
      expect(count, 5);
      verify(mockRealtimeService.getActiveSessions(roomId)).called(1);
    });
    
    test('updateActiveSessions updates session count in Supabase', () async {
      // Arrange
      final roomId = 'room-789';
      final activeSessions = 6;
      when(mockRealtimeService.updateActiveSessions(roomId, activeSessions))
          .thenAnswer((_) async => {});
      
      // Act
      await socketService.updateActiveSessions({
        'roomId': roomId,
        'activeSessions': activeSessions,
      });
      
      // Assert
      verify(mockRealtimeService.updateActiveSessions(roomId, activeSessions)).called(1);
    });
    
    test('deleteRoom removes a room from Supabase', () async {
      // Arrange
      final roomId = 'room-789';
      when(mockRealtimeService.deleteRoom(roomId))
          .thenAnswer((_) async => {});
      
      // Act
      await socketService.deleteRoom(roomId);
      
      // Assert
      verify(mockRealtimeService.deleteRoom(roomId)).called(1);
    });
  });
  
  group('Event handling', () {
    test('SocketService correctly relays Supabase events to registered callbacks', () async {
      // Arrange
      final sessionEventController = StreamController<Map<String, dynamic>>();
      when(mockRealtimeService.onSessionEvent)
          .thenAnswer((_) => sessionEventController.stream);
      
      bool callbackFired = false;
      Map<String, dynamic>? receivedData;
      
      // Initialize service and set up event listener
      when(mockRealtimeService.initialize()).thenAnswer((_) async => {});
      await socketService.initialize();
      
      // Register callback
      socketService.on('session-updated', (data) {
        callbackFired = true;
        receivedData = data;
      });
      
      // Act - Simulate a Supabase event
      final testData = {'id': 'session-456', 'status': 'updated'};
      sessionEventController.add({
        'event': 'session-updated',
        'data': testData,
      });
      
      // Wait for async processing
      await Future.delayed(Duration(milliseconds: 100));
      
      // Assert
      expect(callbackFired, true);
      expect(receivedData, testData);
      
      // Cleanup
      sessionEventController.close();
    });
    
    test('off() correctly unregisters callbacks', () async {
      // Arrange
      final sessionEventController = StreamController<Map<String, dynamic>>();
      when(mockRealtimeService.onSessionEvent)
          .thenAnswer((_) => sessionEventController.stream);
      
      int callCount = 0;
      final callback = (data) => callCount++;
      
      // Initialize service
      when(mockRealtimeService.initialize()).thenAnswer((_) async => {});
      await socketService.initialize();
      
      // Register and then unregister callback
      socketService.on('test-event', callback);
      socketService.off('test-event', callback);
      
      // Act - Simulate event
      sessionEventController.add({
        'event': 'test-event',
        'data': {'test': true},
      });
      
      // Wait for async processing
      await Future.delayed(Duration(milliseconds: 100));
      
      // Assert
      expect(callCount, 0); // Callback should not have been called
      
      // Cleanup
      sessionEventController.close();
    });
  });
} 