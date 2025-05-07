# Connection Management Module

This module provides a robust WebSocket connection management system for the Workvibe application, using Supabase Realtime service. It implements reliable connection monitoring, state management, reconnection strategies, and visual indicators.

## Core Components

### ConnectionManager

The central class that coordinates all connection-related functionality:

- **State Machine**: Handles transitions between connection states (disconnected, connecting, connected, reconnecting, failed)
- **Heartbeat System**: Sends periodic pings to verify connection health
- **Channel Management**: Creates and maintains Supabase Realtime channels
- **Metrics Exposure**: Provides streams for connection status, latency, and health metrics
- **Event Handling**: Processes all connection-related events (connect, disconnect, timeout, etc.)

### ConnectionState and Events

Defines the possible states and events in the connection state machine:

- **States**: disconnected, connecting, connected, reconnecting, failed
- **Events**: connect, disconnect, connectionEstablished, connectionLost, heartbeatTimeout, etc.
- **ConnectionStatus**: A rich object combining state, message, and optional error information

### ConnectionMonitor

Tracks connection health metrics:

- **Latency**: Measures response times for heartbeats
- **Success Rate**: Tracks percentage of successful operations
- **Stability Rating**: Calculates a 0-100 score based on historical performance
- **Health Metrics**: Compiles various metrics into a consolidated health report

### ConnectionReconnector

Implements advanced reconnection strategies:

- **Exponential Backoff**: Gradually increases delay between reconnection attempts
- **Jitter**: Adds randomness to prevent thundering herd problem
- **Circuit Breaker**: Stops reconnection attempts after repeated failures
- **Reconnection Policies**: Preconfigured strategies (standard, aggressive, conservative)

### ConnectionConfig

Centralized configuration for all connection-related parameters:

- **Timeouts**: Connection, heartbeat, and reconnection timeouts
- **Intervals**: Heartbeat frequency and reconnection delays
- **Behavior Flags**: Auto-connect, auto-reconnect settings
- **Reconnection Policy**: Strategy selection for handling connection failures

## Features

1. **State Management**
   - Clear state transitions with proper event handling
   - Broadcast of state changes via streams
   - Rich status information including error details

2. **Health Monitoring**
   - Real-time health metrics collection
   - Stability rating calculation
   - Detection of unstable connections

3. **Auto-Reconnection**
   - Configurable reconnection strategies
   - Exponential backoff with jitter
   - Circuit breaker protection

4. **Error Handling**
   - Comprehensive error categorization
   - Friendly error messages for display
   - Detailed logging for troubleshooting

5. **Visual Indicators**
   - Status streams for UI integration
   - Metrics for visual health displays
   - Ping time measurements

## Usage

```dart
// Create a connection manager with default settings
final connectionManager = ConnectionManager();

// Listen for connection status changes
connectionManager.onConnectionStatus.listen((status) {
  print('Connection status: ${status.state}, message: ${status.message}');
  
  // Update UI indicators based on status
  if (status.state == ConnectionState.connected) {
    // Show connected indicator
  } else if (status.state == ConnectionState.reconnecting) {
    // Show reconnecting indicator
  } else if (status.state == ConnectionState.failed) {
    // Show error indicator with status.message
  }
});

// Listen for health metrics
connectionManager.onHealthMetricsChanged.listen((metrics) {
  print('Connection health: ${metrics.stabilityRating}/100');
  
  // Update health indicator
  updateHealthIndicator(metrics.stabilityRating);
});

// Connect
await connectionManager.connect();

// Later, disconnect when done
await connectionManager.disconnect();

// Dispose when the service is no longer needed
connectionManager.dispose();
```

## Advanced Configuration

```dart
// Custom connection configuration
final config = ConnectionConfig(
  heartbeatIntervalMs: 15000,  // 15 seconds
  reconnectionPolicy: ReconnectionPolicy.aggressive,
  maxReconnectionAttempts: 10,
);

// Create connection manager with custom config
final connectionManager = ConnectionManager(config: config);
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                  ConnectionManager                  │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ State Machine│  │Connection    │  │ Channel    │  │
│  │             │  │Monitor       │  │ Management │  │
│  └─────────────┘  └──────────────┘  └────────────┘  │
│                                                     │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │
│  │ Heartbeat   │  │Connection    │  │ Error      │  │
│  │ System      │  │Reconnector   │  │ Handling   │  │
│  └─────────────┘  └──────────────┘  └────────────┘  │
│                                                     │
└─────────────────────────────────────────────────────┘
       │               │                │
       ▼               ▼                ▼
┌─────────────┐ ┌──────────────┐ ┌────────────────┐
│ UI Status   │ │ Backend      │ │ Logging &      │
│ Indicators  │ │ Service      │ │ Diagnostics    │
└─────────────┘ └──────────────┘ └────────────────┘
```

## Error Handling

The connection module integrates with the application's error service to provide:

- Categorization of network errors
- User-friendly error messages
- Detailed logging for debugging
- Appropriate retry strategies based on error type

## Testing

The module includes testing-specific factory methods for all classes:

```dart
// Create test-optimized instances
final testConfig = ConnectionConfig.forTesting();
final testReconnector = ConnectionReconnector.forTesting();
final testConnectionManager = ConnectionManager.forTesting();
``` 