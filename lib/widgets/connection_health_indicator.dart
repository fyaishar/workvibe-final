import 'package:flutter/material.dart';
import '../services/connection/connection_monitor.dart';

/// A widget that displays detailed connection health metrics.
class ConnectionHealthIndicator extends StatelessWidget {
  /// The current connection health metrics
  final ConnectionHealthMetrics healthMetrics;
  
  /// Width of the indicator
  final double width;
  
  /// Height of the indicator
  final double height;
  
  /// Whether to show labels for the metrics
  final bool showLabels;
  
  /// Whether to show detailed values for metrics
  final bool showValues;
  
  /// Color for good health status
  final Color goodColor;
  
  /// Color for medium health status
  final Color mediumColor;
  
  /// Color for poor health status
  final Color poorColor;

  /// Creates a connection health indicator.
  const ConnectionHealthIndicator({
    Key? key,
    required this.healthMetrics,
    this.width = 150.0,
    this.height = 40.0,
    this.showLabels = true,
    this.showValues = true,
    this.goodColor = Colors.green,
    this.mediumColor = Colors.orange,
    this.poorColor = Colors.red,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStabilityIndicator(),
          if (showLabels || showValues) ...[
            const SizedBox(height: 4),
            _buildMetricsRow(),
          ],
        ],
      ),
    );
  }

  /// Builds the stability indicator bar
  Widget _buildStabilityIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels) ...[
          Text(
            'Connection Stability',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: healthMetrics.stabilityRating / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getColorForStability(healthMetrics.stabilityRating),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a row showing detailed metrics
  Widget _buildMetricsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricItem(
          'Latency', 
          '${healthMetrics.averageLatencyMs.round()} ms',
          healthMetrics.averageLatencyMs < 150 
              ? goodColor 
              : healthMetrics.averageLatencyMs < 300 
                  ? mediumColor 
                  : poorColor,
        ),
        _buildMetricItem(
          'Success', 
          '${healthMetrics.successRatePercent.round()}%',
          healthMetrics.successRatePercent > 95 
              ? goodColor 
              : healthMetrics.successRatePercent > 80 
                  ? mediumColor 
                  : poorColor,
        ),
      ],
    );
  }

  /// Builds a single metric item
  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabels)
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        if (showValues)
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
      ],
    );
  }

  /// Gets the appropriate color for the stability rating
  Color _getColorForStability(int stability) {
    if (stability > 80) {
      return goodColor;
    } else if (stability > 50) {
      return mediumColor;
    } else {
      return poorColor;
    }
  }
} 