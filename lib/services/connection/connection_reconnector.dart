import 'dart:async';
import 'dart:math';

/// A class that handles reconnection logic with configurable backoff strategy.
class ConnectionReconnector {
  /// Initial delay in milliseconds before first reconnection attempt
  final int initialDelayMs;
  
  /// Maximum delay in milliseconds between reconnection attempts
  final int maxDelayMs;
  
  /// Maximum number of reconnection attempts
  final int maxAttempts;
  
  /// Backoff factor for exponential delay increase
  final double backoffFactor;
  
  /// Whether to add randomness to the delay
  final bool useJitter;
  
  /// How much jitter to add as a proportion of the delay (0.0-1.0)
  final double jitterFactor;
  
  /// Current reconnection attempt count
  int _attempts = 0;
  
  /// The timer for the current reconnection attempt
  Timer? _reconnectTimer;
  
  /// Random number generator for jitter calculation
  final _random = Random();
  
  /// Whether a reconnection is in progress
  bool get isReconnecting => _reconnectTimer != null;
  
  /// Number of attempts made so far
  int get attempts => _attempts;
  
  /// Creates a new ConnectionReconnector
  ConnectionReconnector({
    required this.initialDelayMs,
    required this.maxDelayMs,
    required this.maxAttempts,
    this.backoffFactor = 1.5,
    this.useJitter = true,
    this.jitterFactor = 0.2,
  });
  
  /// Attempt to reconnect using the configured backoff strategy.
  /// 
  /// The [connect] function should return a Future<bool> indicating success.
  /// The [onGiveUp] callback is called when all attempts are exhausted.
  void reconnect({
    required Future<bool> Function() connect,
    VoidCallback? onGiveUp,
  }) {
    // Cancel any existing reconnection timer
    cancelReconnect();
    
    // Start the reconnection process
    _executeReconnection(connect, onGiveUp);
  }
  
  /// Cancel any ongoing reconnection attempts
  void cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// Reset the reconnection attempt counter
  void reset() {
    _attempts = 0;
    cancelReconnect();
  }
  
  /// Calculate the delay for the current reconnection attempt with jitter
  int _calculateDelay() {
    // Calculate base delay with exponential backoff: initialDelay * (backoffFactor ^ attempts)
    final baseDelay = initialDelayMs * pow(backoffFactor, _attempts);
    
    // Cap at maxDelayMs
    final cappedDelay = min(baseDelay, maxDelayMs.toDouble());
    
    // Add jitter if enabled
    if (useJitter) {
      // Calculate jitter as a percentage of the delay
      final jitterRange = cappedDelay * jitterFactor;
      
      // Generate a random jitter value between -jitterRange/2 and +jitterRange/2
      final jitter = ((_random.nextDouble() * jitterRange) - (jitterRange / 2));
      
      // Apply jitter to the delay
      return max(initialDelayMs / 2, (cappedDelay + jitter)).round();
    } else {
      return cappedDelay.round();
    }
  }
  
  /// Execute the reconnection logic
  void _executeReconnection(
    Future<bool> Function() connect,
    VoidCallback? onGiveUp,
  ) async {
    // Increment attempts counter
    _attempts++;
    
    // Check if we've exceeded the maximum number of attempts
    if (_attempts > maxAttempts) {
      if (onGiveUp != null) {
        onGiveUp();
      }
      reset();
      return;
    }
    
    // Try to reconnect
    final success = await connect();
    
    // If successful, reset the counter and return
    if (success) {
      reset();
      return;
    }
    
    // Otherwise, schedule another attempt
    final delayMs = _calculateDelay();
    
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), () {
      _executeReconnection(connect, onGiveUp);
    });
  }
}

/// Callback for void functions
typedef VoidCallback = void Function(); 