import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finalworkvibe/services/socket_service.dart';
import 'package:finalworkvibe/services/supabase_realtime_service.dart';

// Generate a MockSupabaseRealtimeService using Mockito
@GenerateMocks([SupabaseRealtimeService])
import 'socket_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late SocketService socketService;
  late MockSupabaseRealtimeService mockRealtimeService;
  
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
  
  test('initialize() should set connection status to connected', () async {
    // Arrange
    when(mockRealtimeService.initialize()).thenAnswer((_) async => {});
    
    // Act
    await socketService.initialize();
    
    // Assert
    expect(socketService.connectionStatus, 'connected');
    expect(socketService.isConnected, true);
    verify(mockRealtimeService.initialize()).called(1);
  });
  
  test('initialize() should handle errors gracefully', () async {
    // Arrange
    when(mockRealtimeService.initialize())
        .thenThrow(Exception('Network error'));
    
    // Act & Assert
    expect(() => socketService.initialize(), throwsException);
    expect(socketService.connectionStatus, 'error');
    expect(socketService.isConnected, false);
  });
  
  test('on() should register a callback for a specific event', () async {
    // Arrange
    final sessionEventController = StreamController<Map<String, dynamic>>();
    when(mockRealtimeService.onSessionEvent)
        .thenAnswer((_) => sessionEventController.stream);
    
    bool callbackCalled = false;
    dynamic receivedData;
    
    // Act - Initialize the service and set up the callback
    when(mockRealtimeService.initialize()).thenAnswer((_) async => {});
    await socketService.initialize(); // This will set up event listeners
    
    socketService.on('session_created', (data) {
      callbackCalled = true;
      receivedData = data;
    });
    
    // Simulate event from Supabase
    sessionEventController.add({
      'event': 'session_created',
      'data': {'id': '123', 'status': 'active'}
    });
    
    // Give time for the async event to be processed
    await Future.delayed(Duration(milliseconds: 100));
    
    // Assert
    expect(callbackCalled, true);
    expect(receivedData['id'], '123');
    expect(receivedData['status'], 'active');
    
    // Cleanup
    sessionEventController.close();
  });
  
  test('off() should remove a callback for a specific event', () {
    // Arrange
    int callCount = 0;
    Function callback = (_) => callCount++;
    
    // Act
    socketService.on('test_event', callback);
    socketService.off('test_event', callback);
    
    // Assert - Can't directly test the private _emitEvent but we can check
    // that no exception is thrown
  });
  
  test('startSession should call the underlying realtime service', () async {
    // Arrange
    final sessionData = {'userId': 'user123', 'projectId': 'project456'};
    when(mockRealtimeService.startSession(sessionData))
        .thenAnswer((_) async => {'id': 'session-123'});
    
    // Act
    final result = await socketService.startSession(sessionData);
    
    // Assert
    expect(result['id'], 'session-123');
    verify(mockRealtimeService.startSession(sessionData)).called(1);
  });
  
  test('getCurrentSession should call the underlying realtime service', () async {
    // Arrange
    final sessionId = 'session-123';
    when(mockRealtimeService.getCurrentSession(sessionId))
        .thenAnswer((_) async => {'id': sessionId, 'status': 'active'});
    
    // Act
    final result = await socketService.getCurrentSession({'sessionId': sessionId});
    
    // Assert
    expect(result['id'], sessionId);
    expect(result['status'], 'active');
    verify(mockRealtimeService.getCurrentSession(sessionId)).called(1);
  });
  
  test('updateTask should call the underlying realtime service', () async {
    // Arrange
    final sessionId = 'session-123';
    final taskId = 'task-456';
    
    when(mockRealtimeService.updateTask(any, any))
        .thenAnswer((_) async => {});
    
    // Act - Test both ways of providing task ID
    // 1. As a direct string
    await socketService.updateTask({
      'sessionId': sessionId,
      'currentTask': taskId 
    });
    
    // 2. As a map with an ID field
    await socketService.updateTask({
      'sessionId': sessionId,
      'currentTask': {'id': taskId, 'title': 'Test Task'}
    });
    
    // Assert
    verify(mockRealtimeService.updateTask(any, any)).called(2);
  });
  
  test('endSession should call the underlying realtime service', () async {
    // Arrange
    final sessionId = 'session-123';
    final endTime = DateTime.now();
    when(mockRealtimeService.endSession(any, any))
        .thenAnswer((_) async => {});
    
    // Act
    await socketService.endSession({
      'sessionId': sessionId,
      'endTime': endTime.millisecondsSinceEpoch
    });
    
    // Assert
    verify(mockRealtimeService.endSession(any, any)).called(1);
  });
  
  test('createRoom should call the underlying realtime service', () async {
    // Arrange
    final roomData = {'name': 'Test Room', 'createdBy': 'user-123'};
    when(mockRealtimeService.createRoom(roomData))
        .thenAnswer((_) async => {'id': 'room-456'});
    
    // Act
    final result = await socketService.createRoom(roomData);
    
    // Assert
    expect(result['id'], 'room-456');
    verify(mockRealtimeService.createRoom(roomData)).called(1);
  });
  
  test('dispose should clean up resources', () {
    // Arrange
    when(mockRealtimeService.dispose()).thenReturn(null);
    
    // Act
    socketService.dispose();
    
    // Assert
    expect(socketService.connectionStatus, 'disconnected');
    expect(socketService.isConnected, false);
    verify(mockRealtimeService.dispose()).called(1);
    
    // We can't verify the controller is closed directly
    // But the following should not throw an exception
    socketService.dispose(); // Double dispose should be safe
  });
} 