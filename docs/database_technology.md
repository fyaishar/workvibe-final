# Supabase: Official Database Technology for Workvibe

## Overview

This document serves as the official clarification regarding Workvibe's database technology choice. **Supabase** is the correct and official database technology for this project, not Firebase (despite Firebase being mentioned in Task #1 and some early PRD documents).

## Why Supabase?

Supabase was chosen as the primary database technology for the Workvibe project for several reasons:

1. **Open Source Architecture**: Supabase provides an open-source alternative to Firebase, giving more control over our data and infrastructure.

2. **PostgreSQL Foundation**: Built on PostgreSQL, Supabase offers powerful relational database capabilities with the flexibility to handle semi-structured data.

3. **Real-time Capabilities**: Supabase Realtime provides WebSocket-based real-time data synchronization similar to Firebase but with the benefits of a SQL database.

4. **Auth System**: Supabase Auth offers a complete user management system including authentication, authorization, and user management.

5. **Simplified Migration Path**: The project initially referenced Firebase but has been fully implemented with Supabase, providing better scalability and SQL query capabilities.

## Supabase Packages Used

The project uses several key Supabase packages:

### 1. supabase_flutter

The main package that enables Supabase integration with Flutter applications.

```dart
// Initialization in main.dart
await Supabase.initialize(
  url: Env.supabaseUrl,
  anonKey: Env.supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
  ),
  debug: true, // Set to false in production
);
```

### 2. Supabase Auth

Used for authentication flows, user management, and session handling.

```dart
// Example of authentication using SupabaseService
static Future<AuthResponse> signInWithEmail(String email, String password) async {
  try {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  } catch (e) {
    rethrow;
  }
}
```

Key auth features implemented:
- Email/password authentication
- Session management with token refresh
- Auth state change listeners

### 3. Supabase Realtime Services

Implemented for real-time functionality, WebSocket connections, channels, and event handling.

```dart
// Example from SupabaseRealtimeService
Future<void> _setupPresenceChannel() async {
  final channel = _supabase.channel('presence');
  
  channel
    .onPresenceSync((payload) {
      _presenceEventController.add({
        'event': 'presence_sync',
        'payload': payload
      });
    })
    .onPresenceJoin((payload) {
      _presenceEventController.add({
        'event': 'presence_join',
        'payload': payload
      });
    })
    .onPresenceLeave((payload) {
      _presenceEventController.add({
        'event': 'presence_leave',
        'payload': payload
      });
    });

  await channel.subscribe(
    (status, [error]) {
      debugPrint('Presence channel status: $status');
      if (error != null) {
        debugPrint('Presence channel error: $error');
      }
    }
  );
  
  // Store channel reference
  _channels['presence'] = channel;
  
  // Send initial state
  await channel.track({
    'user_id': _supabase.auth.currentUser?.id,
    'online_at': DateTime.now().toIso8601String(),
  });
}
```

## Supabase Integration Points

### 1. User Authentication and Session Management

The application uses Supabase Auth for all user authentication operations, including:
- Sign up and sign in flows
- Password reset functionality
- Token management and refresh
- User profile management

```dart
// SupabaseService session refresh mechanism
static Future<Session?> refreshSession() async {
  try {
    if (session == null) return null;
    
    // Check if token needs refresh (if less than 60 seconds remaining)
    final expiresAt = session!.expiresAt;
    if (expiresAt != null) {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expiresIn = expiresAt - now;
      
      if (expiresIn < 60) {
        final response = await client.auth.refreshSession();
        return response.session;
      }
    }
    
    return session;
  } catch (e) {
    // Handle errors
    return session;
  }
}
```

### 2. Real-time User Presence and Activity Tracking

The application uses Supabase Realtime Presence to track which users are online and active:

- User online status tracking
- Notification when users join/leave rooms
- Real-time activity updates

```dart
// Example of presence tracking in SocketService
Future<void> updatePresence(Map<String, dynamic> presence) async {
  try {
    await _realtimeService.updatePresence(presence);
  } catch (e) {
    _handleError('Error updating presence', e);
  }
}
```

### 3. Data Storage and Retrieval Patterns

The application uses Supabase PostgreSQL database for data storage and retrieval:

- Projects, tasks, and sessions data storage
- User profile information
- Activity logs and statistics

```dart
// Example data retrieval pattern
static Future<List<Map<String, dynamic>>> getProjects(String userId) async {
  try {
    final response = await client
      .from('projects')
      .select('*')
      .eq('user_id', userId)
      .order('created_at');
      
    if (response.error != null) throw response.error!;
    
    return response.data as List<Map<String, dynamic>>;
  } catch (e) {
    rethrow;
  }
}
```

### 4. Real-time Event Broadcasting

The application uses Supabase Realtime for broadcasting events between users:

- Changes to shared projects and tasks
- Session updates
- Room occupancy changes

```dart
// SocketService mimicking Socket.IO API with Supabase
void on(String event, Function callback) {
  if (!_eventCallbacks.containsKey(event)) {
    _eventCallbacks[event] = [];
  }
  _eventCallbacks[event]!.add(callback);
}

void emit(String event, Map<String, dynamic> data) {
  // Forward to appropriate realtime service method based on event
  _handleEmit(event, data);
}
```

## Database Schema

The Supabase database schema is defined with proper relationships, UUIDs, and timestamps, as shown in the project README.md. Key tables include:

- `users`: User account information
- `rooms`: Different room types with active session tracking
- `projects`: User projects with metadata
- `tasks`: Project tasks with progress tracking
- `sessions`: User work sessions with status and relations
- `logbooks`: User activity logs
- `task_sessions`: Junction table linking tasks and sessions

## Migration Notes

The project was originally conceived with Firebase but has been fully implemented with Supabase from the beginning of actual development. References to Firebase in the project setup (Task #1) and PRD documents should be considered legacy artifacts.

Key migration points:
- No actual migration code was needed as implementation began with Supabase
- Socket.IO compatibility layer provides API familiarity while using Supabase underneath
- Architectural design accommodates Supabase's capabilities with backward compatibility

## Conclusion

Supabase is the singular database technology used throughout the Workvibe project. It provides all necessary functionality for authentication, real-time data synchronization, and data storage. Any references to Firebase in task descriptions or PRD documents should be considered superseded by this official clarification.

## Additional Resources

- [Supabase Documentation](https://supabase.io/docs)
- [Supabase Flutter SDK](https://github.com/supabase/supabase-flutter)
- Project-specific implementation details:
  - [lib/services/README.md](../lib/services/README.md): Details on the real-time services architecture
  - [README.md](../README.md): Project overview with Supabase schema 