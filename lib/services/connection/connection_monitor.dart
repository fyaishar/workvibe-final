import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

import 'connection_state.dart';

/// Metrics for monitoring connection health
class ConnectionHealthMetrics {
  /// Average latency in milliseconds
  final double averageLatencyMs;
  
  /// Connection attempts success rate as a percentage
  final double successRatePercent;
  
  /// Overall connection stability rating (0-100)
  final int stabilityRating;
  
  /// Creates connection health metrics
  const ConnectionHealthMetrics({
    required this.averageLatencyMs,
    required this.successRatePercent,
    required this.stabilityRating,
  });
  
  /// Creates empty metrics with default values
  factory ConnectionHealthMetrics.empty() {
    return const ConnectionHealthMetrics(
      averageLatencyMs: 0.0,
      successRatePercent: 0.0,
      stabilityRating: 0,
    );
  }
}

/// Monitors connection health by tracking latency, success rates, and stability
class ConnectionMonitor {
  // Latency queue
  final Queue<int> _latencySamples = Queue<int>();
  
  // Success/failure tracking
  int _connectionSuccesses = 0;
  int _connectionFailures = 0;
  int _reconnectionSuccesses = 0;
  int _reconnectionFailures = 0;
  
  // Latest calculated metrics
  ConnectionHealthMetrics _healthMetrics = ConnectionHealthMetrics.empty();
  
  // Stream controller for metrics updates
  final _metricsController = StreamController<ConnectionHealthMetrics>.broadcast();
  
  // Configuration
  final int _maxSamples;
  final int _stabilityThreshold;
  
  /// Last recorded latency in milliseconds, null if none recorded yet
  int? lastLatencyMs;
  
  /// Stream of health metrics updates
  Stream<ConnectionHealthMetrics> get onMetricsChanged => _metricsController.stream;
  
  /// Current health metrics
  ConnectionHealthMetrics get healthMetrics => _healthMetrics;
  
  /// Creates a connection monitor
  ConnectionMonitor({
    int maxSamples = 10,
    int stabilityThreshold = 70,
  })  : _maxSamples = maxSamples,
        _stabilityThreshold = stabilityThreshold;
  
  /// Records a latency measurement and updates metrics
  void recordLatency(int latencyMs) {
    if (latencyMs < 0) return; // Ignore invalid values
    
    // Store the last latency
    lastLatencyMs = latencyMs;
    
    // Add to samples, removing oldest if needed
    _latencySamples.add(latencyMs);
    if (_latencySamples.length > _maxSamples) {
      _latencySamples.removeFirst();
    }
    
    // Update metrics
    _updateMetrics();
  }
  
  /// Records a successful connection and updates metrics
  void recordConnectionSuccess() {
    _connectionSuccesses++;
    _updateMetrics();
  }
  
  /// Records a connection failure and updates metrics
  void recordConnectionFailure() {
    _connectionFailures++;
    _updateMetrics();
  }
  
  /// Records a successful reconnection and updates metrics
  void recordReconnectionSuccess() {
    _reconnectionSuccesses++;
    _updateMetrics();
  }
  
  /// Records a reconnection failure and updates metrics
  void recordReconnectionFailure() {
    _reconnectionFailures++;
    _updateMetrics();
  }
  
  /// Updates the health metrics based on current data
  void _updateMetrics() {
    // Calculate average latency
    double avgLatency = 0.0;
    if (_latencySamples.isNotEmpty) {
      avgLatency = _latencySamples.reduce((a, b) => a + b) / _latencySamples.length;
    }
    
    // Calculate success rate
    final totalAttempts = _connectionSuccesses + _connectionFailures;
    double successRate = totalAttempts > 0 
        ? (_connectionSuccesses / totalAttempts) * 100
        : 0.0;
    
    // Calculate stability rating (0-100)
    int stabilityRating = _calculateStabilityRating(
      avgLatency, 
      successRate,
      _reconnectionSuccesses,
      _reconnectionFailures
    );
    
    // Update the metrics
    _healthMetrics = ConnectionHealthMetrics(
      averageLatencyMs: avgLatency,
      successRatePercent: successRate,
      stabilityRating: stabilityRating,
    );
    
    // Notify listeners
    if (!_metricsController.isClosed) {
      _metricsController.add(_healthMetrics);
    }
  }
  
  /// Calculates a stability rating from 0-100 based on various factors
  int _calculateStabilityRating(
    double avgLatency, 
    double successRate,
    int reconnectionSuccesses,
    int reconnectionFailures
  ) {
    // Start with base rating from success rate (0-60 points)
    int rating = (successRate * 0.6).round();
    
    // Add latency factor (0-30 points)
    // Lower latency = higher score
    // 0ms = 30 points, 300+ms = 0 points
    if (avgLatency > 0) {
      final latencyFactor = 1.0 - (avgLatency.clamp(0, 300) / 300);
      rating += (latencyFactor * 30).round();
    }
    
    // Add reconnection factor (0-10 points)
    // More successful reconnections = higher score
    final totalReconnections = reconnectionSuccesses + reconnectionFailures;
    if (totalReconnections > 0) {
      final reconnectionRate = reconnectionSuccesses / totalReconnections;
      rating += (reconnectionRate * 10).round();
    } else {
      // If no reconnections needed, this is good
      rating += 10;
    }
    
    // Clamp result to 0-100
    return rating.clamp(0, 100);
  }
  
  /// Resets all metrics and samples
  void reset() {
    _latencySamples.clear();
    _connectionSuccesses = 0;
    _connectionFailures = 0;
    _reconnectionSuccesses = 0;
    _reconnectionFailures = 0;
    lastLatencyMs = null;
    _healthMetrics = ConnectionHealthMetrics.empty();
    
    // Notify listeners of reset
    if (!_metricsController.isClosed) {
      _metricsController.add(_healthMetrics);
    }
  }
  
  /// Closes the controller and cleans up resources
  void dispose() {
    if (!_metricsController.isClosed) {
      _metricsController.close();
    }
  }
} 