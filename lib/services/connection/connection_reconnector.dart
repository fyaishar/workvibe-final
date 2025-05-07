import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// A class that implements various reconnection strategies,
/// including exponential backoff, jitter, and circuit breaker pattern.
class ConnectionReconnector {
  /// Maximum number of reconnection attempts before the circuit breaks
  final int maxAttempts;
  
  /// Initial delay in milliseconds for the first reconnection attempt
  final int initialDelayMs;
  
  /// Maximum delay in milliseconds for any reconnection attempt
  final int maxDelayMs;
  
  /// Whether to add jitter (randomness) to the delay to prevent thundering herd
  final bool useJitter;
  
  /// The multiplier for exponential backoff (defaults to 2)
  final double backoffFactor;
  
  /// Amount of jitter to apply, as a factor of the calculated delay (0.0-1.0)
  final double jitterFactor;
  
  /// Callback for when an attempt is scheduled
  final void Function(int attempt, int delayMs, int maxAttempts)? onAttemptScheduled;
  
  /// Callback for when the circuit breaker trips (too many failures)
  final void Function()? onCircuitBreakerTripped;
  
  /// Internal counter for attempt number
  int _currentAttempt = 0;
  
  /// Timer used for scheduling reconnection attempts
  Timer? _reconnectTimer;
  
  /// Whether the circuit breaker has been tripped
  bool _isCircuitBroken = false;
  
  /// Random number generator for jitter
  final Random _random = Random();
  
  /// Whether a reconnection attempt is currently scheduled
  bool get isReconnecting => _reconnectTimer != null;
  
  /// The current attempt number (1-based)
  int get currentAttempt => _currentAttempt;
  
  /// Whether the circuit breaker has been tripped
  bool get isCircuitBroken => _isCircuitBroken;

  /// Creates a new ConnectionReconnector with the specified parameters.
  ConnectionReconnector({
    this.maxAttempts = 5,
    this.initialDelayMs = 1000,
    this.maxDelayMs = 30000,
    this.useJitter = true,
    this.backoffFactor = 2.0,
    this.jitterFactor = 0.2,
    this.onAttemptScheduled,
    this.onCircuitBreakerTripped,
  }) : assert(jitterFactor >= 0.0 && jitterFactor <= 1.0, 'jitterFactor must be between 0.0 and 1.0'),
       assert(backoffFactor > 1.0, 'backoffFactor must be greater than 1.0');
  
  /// Schedules the next reconnection attempt with exponential backoff.
  /// Returns the delay in milliseconds until the next attempt, or null if the circuit breaker has tripped.
  int? scheduleReconnection(VoidCallback reconnectCallback) {
    // Cancel any existing timer
    _reconnectTimer?.cancel();
    
    // Increment attempt counter
    _currentAttempt++;
    
    // Check if we've exceeded max attempts
    if (_currentAttempt > maxAttempts) {
      _isCircuitBroken = true;
      onCircuitBreakerTripped?.call();
      return null;
    }
    
    // Calculate delay with exponential backoff
    final delay = _calculateBackoffDelay(_currentAttempt);
    
    // Notify about scheduled attempt
    onAttemptScheduled?.call(_currentAttempt, delay, maxAttempts);
    
    // Schedule reconnection attempt
    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      _reconnectTimer = null;
      reconnectCallback();
    });
    
    return delay;
  }
  
  /// Calculates the backoff delay for the given attempt number.
  int _calculateBackoffDelay(int attempt) {
    // Calculate base delay: initialDelay * (backoffFactor ^ (attempt-1))
    final double baseDelay = initialDelayMs.toDouble() * pow(backoffFactor, attempt - 1);
    double delay = baseDelay;
    
    // Add jitter if enabled
    if (useJitter) {
      // Apply jitter (randomness) to prevent all clients reconnecting simultaneously
      // Use a random factor between 1-jitterFactor and 1+jitterFactor
      final jitter = 1.0 + ((_random.nextDouble() * 2 - 1) * jitterFactor);
      delay *= jitter;
    }
    
    // Round to get an integer value
    int roundedDelay = delay.round();
    
    // Apply min-max bounds
    if (roundedDelay < initialDelayMs) {
      roundedDelay = initialDelayMs;
    } else if (roundedDelay > maxDelayMs) {
      roundedDelay = maxDelayMs;
    }
    
    return roundedDelay;
  }
  
  /// Resets the reconnector to its initial state.
  void reset() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _currentAttempt = 0;
    _isCircuitBroken = false;
  }
  
  /// Cancels any scheduled reconnection attempt.
  void cancel() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// Disposes the reconnector and releases any resources.
  void dispose() {
    cancel();
  }
  
  /// Creates a ConnectionReconnector configured for testing.
  @visibleForTesting
  static ConnectionReconnector forTesting() {
    return ConnectionReconnector(
      maxAttempts: 3,
      initialDelayMs: 100,
      maxDelayMs: 1000,
      useJitter: false,
    );
  }
  
  /// Alias for scheduleReconnection with a simplified interface
  void reconnect({
    required Future<bool> Function() connect,
    required void Function() onGiveUp,
  }) {
    // Adapter method to provide compatibility
    scheduleReconnection(() async {
      final success = await connect();
      if (!success && isCircuitBroken) {
        onGiveUp();
      }
    });
  }
  
  /// Alias for cancel() to provide backward compatibility
  void cancelReconnect() {
    cancel();
  }
  
  /// Alias for currentAttempt to provide backward compatibility
  int get attempts => currentAttempt;
}

/// An enum that defines different reconnection policies.
enum ReconnectionPolicy {
  /// Standard exponential backoff with jitter.
  exponentialBackoff,
  
  /// Aggressive reconnection with shorter delays.
  aggressive,
  
  /// More conservative approach with slower backoff.
  conservative,
  
  /// Custom reconnection policy.
  custom
}

/// Factory for creating reconnection strategies based on defined policies
class ReconnectionPolicyFactory {
  /// Create a reconnector with a predefined policy
  static ConnectionReconnector create(
    ReconnectionPolicy policy, {
    void Function(int attempt, int delayMs, int maxAttempts)? onAttemptScheduled,
    void Function()? onCircuitBreakerTripped,
  }) {
    switch (policy) {
      case ReconnectionPolicy.exponentialBackoff:
        return ConnectionReconnector(
          maxAttempts: 5,
          initialDelayMs: 1000,
          maxDelayMs: 30000,
          useJitter: true,
          backoffFactor: 2.0,
          jitterFactor: 0.2,
          onAttemptScheduled: onAttemptScheduled,
          onCircuitBreakerTripped: onCircuitBreakerTripped,
        );
        
      case ReconnectionPolicy.aggressive:
        return ConnectionReconnector(
          maxAttempts: 10,
          initialDelayMs: 500,
          maxDelayMs: 10000,
          useJitter: true,
          backoffFactor: 1.5,
          jitterFactor: 0.1,
          onAttemptScheduled: onAttemptScheduled,
          onCircuitBreakerTripped: onCircuitBreakerTripped,
        );
        
      case ReconnectionPolicy.conservative:
        return ConnectionReconnector(
          maxAttempts: 3,
          initialDelayMs: 2000,
          maxDelayMs: 60000,
          useJitter: true,
          backoffFactor: 3.0,
          jitterFactor: 0.3,
          onAttemptScheduled: onAttemptScheduled,
          onCircuitBreakerTripped: onCircuitBreakerTripped,
        );
        
      case ReconnectionPolicy.custom:
        // Return default, but this would normally be configured with custom parameters
        return ConnectionReconnector(
          onAttemptScheduled: onAttemptScheduled,
          onCircuitBreakerTripped: onCircuitBreakerTripped,
        );
    }
  }
} 