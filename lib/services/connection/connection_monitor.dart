import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connection_state.dart';

/// A class that monitors connection health and metrics.
class ConnectionMonitor {
  /// Health metrics for the connection
  ConnectionHealthMetrics _healthMetrics = ConnectionHealthMetrics();
  
  /// The most recent latency measurement in milliseconds
  int? _lastLatencyMs;
  
  /// A list of recent latency values in milliseconds
  final List<int> _latencyHistory = [];
  
  /// Maximum number of latency values to keep in history
  final int _maxLatencyHistorySize = 20;
  
  /// Stream controller for health metrics updates
  final _metricsController = StreamController<ConnectionHealthMetrics>.broadcast();
  
  /// Stream of health metrics updates
  Stream<ConnectionHealthMetrics> get onMetricsChanged => _metricsController.stream;
  
  /// Get the current health metrics
  ConnectionHealthMetrics get healthMetrics => _healthMetrics;
  
  /// Get the last measured latency in milliseconds
  int? get lastLatencyMs => _lastLatencyMs;
  
  /// Records a successful connection
  void recordConnectionSuccess() {
    _healthMetrics = _healthMetrics.copyWith(
      successfulConnections: _healthMetrics.successfulConnections + 1,
    );
    _recalculateStabilityRating();
    _notifyMetricsChanged();
  }
  
  /// Records a connection failure
  void recordConnectionFailure() {
    _healthMetrics = _healthMetrics.copyWith(
      failedConnections: _healthMetrics.failedConnections + 1,
    );
    _recalculateStabilityRating();
    _notifyMetricsChanged();
  }
  
  /// Records a reconnection attempt
  void recordReconnectionAttempt() {
    _healthMetrics = _healthMetrics.copyWith(
      reconnectionAttempts: _healthMetrics.reconnectionAttempts + 1,
    );
    _notifyMetricsChanged();
  }
  
  /// Records a successful reconnection
  void recordReconnectionSuccess() {
    _healthMetrics = _healthMetrics.copyWith(
      successfulReconnections: _healthMetrics.successfulReconnections + 1,
    );
    _recalculateStabilityRating();
    _notifyMetricsChanged();
  }
  
  /// Records a reconnection failure
  void recordReconnectionFailure() {
    // The reconnection attempt is already recorded, so we just need to
    // recalculate the stability rating based on the failed attempt
    _recalculateStabilityRating();
    _notifyMetricsChanged();
  }
  
  /// Records a latency measurement in milliseconds
  void recordLatency(int latencyMs) {
    _lastLatencyMs = latencyMs;
    
    // Add to history
    _latencyHistory.add(latencyMs);
    
    // Trim history if needed
    if (_latencyHistory.length > _maxLatencyHistorySize) {
      _latencyHistory.removeAt(0);
    }
    
    // Calculate average
    if (_latencyHistory.isNotEmpty) {
      int sum = _latencyHistory.fold(0, (prev, current) => prev + current);
      int average = sum ~/ _latencyHistory.length;
      
      _healthMetrics = _healthMetrics.copyWith(
        averageLatencyMs: average,
      );
    }
    
    _notifyMetricsChanged();
  }
  
  /// Resets all metrics to their initial values
  void reset() {
    _healthMetrics = ConnectionHealthMetrics();
    _lastLatencyMs = null;
    _latencyHistory.clear();
    _notifyMetricsChanged();
  }
  
  /// Recalculates the stability rating based on current metrics
  void _recalculateStabilityRating() {
    // Calculate base stability score (0-100)
    int totalAttempts = _healthMetrics.successfulConnections + 
                        _healthMetrics.failedConnections;
    
    int stabilityScore;
    
    if (totalAttempts == 0) {
      // No data yet
      stabilityScore = 100;
    } else {
      // Calculate success percentage
      double successRate = _healthMetrics.successfulConnections / totalAttempts;
      
      // Convert to 0-100 rating
      stabilityScore = (successRate * 100).round();
      
      // Apply a penalty for excessive reconnection attempts
      int reconnectionPenalty = 0;
      if (_healthMetrics.reconnectionAttempts > 0) {
        // Calculate ratio of successful reconnections to total attempts
        double reconnectionSuccessRate = 
            _healthMetrics.successfulReconnections / 
            _healthMetrics.reconnectionAttempts;
        
        // More penalty for lower success rate
        reconnectionPenalty = ((1 - reconnectionSuccessRate) * 30).round();
        
        // Cap the penalty
        reconnectionPenalty = reconnectionPenalty.clamp(0, 30);
      }
      
      // Apply penalty
      stabilityScore = (stabilityScore - reconnectionPenalty).clamp(0, 100);
    }
    
    // Update the metrics
    _healthMetrics = _healthMetrics.copyWith(
      stabilityRating: stabilityScore,
    );
  }
  
  /// Notifies listeners of health metrics changes
  void _notifyMetricsChanged() {
    if (!_metricsController.isClosed) {
      _metricsController.add(_healthMetrics);
    }
    
    // Log metrics in debug mode
    if (kDebugMode) {
      print('Connection health: ${_formatHealthMetrics()}');
    }
  }
  
  /// Formats health metrics for logging
  String _formatHealthMetrics() {
    return 'Stability: ${_healthMetrics.stabilityRating}%, ' +
        'Latency: ${_healthMetrics.averageLatencyMs ?? "N/A"}ms, ' +
        'Success/Failure: ${_healthMetrics.successfulConnections}/${_healthMetrics.failedConnections}, ' +
        'Reconnects: ${_healthMetrics.successfulReconnections}/${_healthMetrics.reconnectionAttempts}';
  }
  
  /// Disposes resources
  void dispose() {
    _metricsController.close();
  }
} 