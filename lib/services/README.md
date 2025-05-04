# Workvibe Real-time Services

This directory contains the implementation of Workvibe's real-time communication layer.

## Migration from Socket.IO to Supabase Realtime

The original implementation used a Node.js backend with Socket.IO for real-time communication. We've migrated this to use Supabase Realtime, eliminating the need for a custom backend server while preserving the same functionality.

## Architecture

The real-time services are organized in three layers:

1. **Supabase Integration Layer** - Direct interaction with Supabase
   - Uses Supabase Realtime Channels API and Postgres Changes
   - Handles database CRUD operations

2. **Real-time Service Layer** - Domain-specific event handling
   - Translates database events into application-specific events
   - Manages channel subscriptions

3. **Socket.IO Compatibility Layer** - Backward compatibility API
   - Provides a Socket.IO-like API for the frontend
   - Allows minimal changes to existing frontend code

## Components

### SupabaseRealtimeService

This service handles the direct interaction with Supabase:

- Sets up real-time channel subscriptions for tables (sessions, tasks, projects, rooms)
- Implements presence functionality for online users
- Exposes streams for application events
- Provides methods for CRUD operations

### SocketService

This service provides a Socket.IO-like API on top of SupabaseRealtimeService:

- Implements `on`/`off` methods for event subscription
- Provides callback-based API similar to Socket.IO
- Handles connection status and error management
- Maps Socket.IO events to Supabase Realtime events

## Event Flow

1. A database change occurs in Supabase (insert, update, delete)
2. Supabase Realtime sends the change to subscribed clients
3. `SupabaseRealtimeService` captures the change and interprets the event type
4. `SupabaseRealtimeService` emits the event through the appropriate stream controller
5. `SocketService` receives the event through stream subscription
6. `SocketService` routes the event to registered callbacks

## Key Features

- **Real-time Data Synchronization** - Changes to sessions, tasks, projects and rooms are instantly synchronized across all connected clients
- **Presence** - Tracks which users are online and notifies when users join/leave
- **Backward Compatibility** - Frontend code can continue using a Socket.IO-like API
- **Serverless Architecture** - No need to maintain a separate Node.js server

## Testing

The services are thoroughly tested with:

- Unit tests for individual service classes
- Integration tests that verify the proper interaction between layers
- Mock tests that isolate the services from actual Supabase calls

## Usage Example

```dart
// Initialize socket service
final socketService = SocketService();
await socketService.initialize();

// Listen for events using Socket.IO-like API
socketService.on('session_created', (data) {
  print('New session created: ${data['id']}');
});

// Perform operations
await socketService.startSession({
  'user_id': 'user123',
  'status': 'active',
  'start_time': DateTime.now().toIso8601String(),
});
``` 