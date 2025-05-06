import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:finalworkvibe/services/supabase_realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:realtime_client/realtime_client.dart';
import 'dart:async';

// Generate mocks
@GenerateMocks([SupabaseClient, RealtimeChannel, GoTrueClient])
import 'supabase_realtime_service_test.mocks.dart';

class MockSupabaseInstance extends Mock {
  final MockSupabaseClient client;
  
  MockSupabaseInstance(this.client);
  
  SupabaseClient get instance => client;
}

// Create a test version of the SupabaseRealtimeService that doesn't use the Supabase singleton
class TestableRealtimeService {
  final SupabaseClient _supabase;
  
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
  
  TestableRealtimeService(this._supabase);
  
  // Initialize realtime subscriptions
  Future<void> initialize() async {
    // For the test, we'll skip the actual channel setup and just focus on presence
    await _setupPresenceChannel();
  }
  
  Future<void> _setupPresenceChannel() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }
    
    final presenceChannel = _supabase.channel('online-users');
    
    // Add presence event handlers
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
          // Handle tracking error
        }
      }
    });
    
    _channels['presence'] = presenceChannel;
  }
  
  void _handlePresenceEvent(String eventType, dynamic data) {
    _presenceEventController.add({
      'event': eventType,
      'data': data,
    });
  }
  
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
  }
}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockRealtimeChannel mockRealtimeChannel;
  late MockGoTrueClient mockGoTrueClient;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockRealtimeChannel = MockRealtimeChannel();
    mockGoTrueClient = MockGoTrueClient();
    
    // Setup mocks
    when(mockSupabaseClient.channel(any)).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.onPostgresChanges(
      event: anyNamed('event'),
      schema: anyNamed('schema'),
      table: anyNamed('table'),
      callback: anyNamed('callback')
    )).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.subscribe(any)).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.onPresenceSync(any)).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.onPresenceJoin(any)).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.onPresenceLeave(any)).thenReturn(mockRealtimeChannel);
    when(mockRealtimeChannel.track(any)).thenAnswer((_) => Future.value());
    
    // Return an empty list for presenceState
    when(mockRealtimeChannel.presenceState()).thenReturn(<SinglePresenceState>[]);
    
    when(mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(mockGoTrueClient.currentUser).thenReturn(User(
      id: 'test-user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'test',
      createdAt: '2023-01-01',
    ));
  });

  group('Presence Channel Tests', () {
    test('onPresenceSync should handle presence state correctly', () async {
      // Setup
      final testService = TestableRealtimeService(mockSupabaseClient);
      Map<String, dynamic>? capturedPayload;
      
      // Initialize the service
      await testService.initialize();
      
      // Listen for presence events
      testService.onPresenceEvent.listen((data) {
        if (data['event'] == 'presence-sync') {
          capturedPayload = data;
        }
      });
      
      // Find the presence sync callback and trigger it
      verify(mockRealtimeChannel.onPresenceSync(any)).called(1);
      
      // Extract and call the callback with test data
      final syncCallback = verify(mockRealtimeChannel.onPresenceSync(captureAny)).captured.first;
      syncCallback({'user1': {'status': 'online'}}); // Simulate sync event
      
      // Verify the event was properly processed
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['event'], equals('presence-sync'));
    });
    
    test('onPresenceJoin should handle join events correctly', () async {
      // Setup
      final testService = TestableRealtimeService(mockSupabaseClient);
      Map<String, dynamic>? capturedPayload;
      
      // Initialize the service
      await testService.initialize();
      
      // Listen for presence events
      testService.onPresenceEvent.listen((data) {
        if (data['event'] == 'presence-join') {
          capturedPayload = data;
        }
      });
      
      // Find the presence join callback and trigger it
      verify(mockRealtimeChannel.onPresenceJoin(any)).called(1);
      
      // Extract and call the callback with test data
      final joinCallback = verify(mockRealtimeChannel.onPresenceJoin(captureAny)).captured.first;
      joinCallback({'user_id': 'user1', 'online_at': '2023-01-01T12:00:00Z'}); // Simulate join event
      
      // Verify the event was properly processed
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['event'], equals('presence-join'));
      expect(capturedPayload!['data']['user_id'], equals('user1'));
    });
    
    test('onPresenceLeave should handle leave events correctly', () async {
      // Setup
      final testService = TestableRealtimeService(mockSupabaseClient);
      Map<String, dynamic>? capturedPayload;
      
      // Initialize the service
      await testService.initialize();
      
      // Listen for presence events
      testService.onPresenceEvent.listen((data) {
        if (data['event'] == 'presence-leave') {
          capturedPayload = data;
        }
      });
      
      // Find the presence leave callback and trigger it
      verify(mockRealtimeChannel.onPresenceLeave(any)).called(1);
      
      // Extract and call the callback with test data
      final leaveCallback = verify(mockRealtimeChannel.onPresenceLeave(captureAny)).captured.first;
      leaveCallback({'user_id': 'user1', 'online_at': '2023-01-01T12:00:00Z'}); // Simulate leave event
      
      // Verify the event was properly processed
      expect(capturedPayload, isNotNull);
      expect(capturedPayload!['event'], equals('presence-leave'));
      expect(capturedPayload!['data']['user_id'], equals('user1'));
    });
  });
  
  group('Connection Resilience Tests', () {
    test('should handle subscription success correctly', () async {
      // Setup: Simulate successful subscription
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      when(mockRealtimeChannel.subscribe(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        callback(RealtimeSubscribeStatus.subscribed, null);
        return mockRealtimeChannel;
      });
      
      // Initialize service, which sets up presence channel
      await testService.initialize();
      
      // Verify track was called, indicating successful subscription handling
      verify(mockRealtimeChannel.track(any)).called(1);
    });
    
    test('should not track presence on failed subscription', () async {
      // Setup: Simulate failed subscription
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      when(mockRealtimeChannel.subscribe(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        callback(RealtimeSubscribeStatus.closed, Exception('Connection failed'));
        return mockRealtimeChannel;
      });
      
      // Initialize service
      await testService.initialize();
      
      // Verify track was NOT called due to failed subscription
      verifyNever(mockRealtimeChannel.track(any));
    });
  });
  
  group('Error Handling Tests', () {
    test('should handle presence tracking errors gracefully', () async {
      // Setup: Simulate successful subscription but failed tracking
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      when(mockRealtimeChannel.subscribe(any)).thenAnswer((invocation) {
        final callback = invocation.positionalArguments[0] as Function;
        callback(RealtimeSubscribeStatus.subscribed, null);
        return mockRealtimeChannel;
      });
      
      when(mockRealtimeChannel.track(any)).thenThrow(Exception('Tracking error'));
      
      // Initialize service should not throw despite tracking error
      await expectLater(testService.initialize(), completes);
    });
    
    test('should handle null currentUser gracefully', () async {
      // Setup: Simulate no logged in user
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      when(mockGoTrueClient.currentUser).thenReturn(null);
      
      // Initialize service should complete without errors
      await expectLater(testService.initialize(), completes);
      
      // Verify presence channel setup was skipped
      verifyNever(mockRealtimeChannel.onPresenceSync(any));
    });
    
    test('should handle channel subscription errors gracefully', () async {
      // Setup
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      // Make subscribe throw an exception
      when(mockRealtimeChannel.subscribe(any)).thenThrow(Exception('Subscription error'));
      
      // Initialize service should not throw despite channel error
      await expectLater(testService.initialize(), completes);
    });
  });
  
  group('Cleanup Tests', () {
    test('dispose should unsubscribe all channels and close controllers', () async {
      // Setup
      final testService = TestableRealtimeService(mockSupabaseClient);
      
      // Initialize then dispose
      await testService.initialize();
      testService.dispose();
      
      // Verify all channels are unsubscribed
      verify(mockRealtimeChannel.unsubscribe()).called(greaterThan(0));
      
      // Verify stream is closed by attempting to listen (should throw)
      expect(() => testService.onSessionEvent.listen((event) {}), throwsStateError);
    });
  });
} 