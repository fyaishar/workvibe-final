import 'package:flutter/material.dart';
import '../services/connection/connection_manager.dart';
import '../services/connection/connection_state.dart' as conn;
import '../services/connection/connection_monitor.dart';
import 'connection_status_indicator.dart';
import 'connection_health_indicator.dart';

/// A widget that listens to connection status changes and displays the appropriate
/// visual indicators.
class ConnectionStatusWidget extends StatelessWidget {
  /// The connection manager to listen to for status updates
  final ConnectionManager connectionManager;
  
  /// Size of the status indicator dot
  final double statusIndicatorSize;
  
  /// Whether to show a label next to the status indicator
  final bool showLabel;
  
  /// Whether to show the detailed health indicator
  final bool showHealthIndicator;
  
  /// Whether to show a detailed tooltip on hover/tap
  final bool showDetailedTooltip;
  
  /// Widget to display when expanded to show detailed info
  final Widget? detailsWidget;
  
  /// Whether the widget is expanded to show detailed information
  final bool isExpanded;
  
  /// Callback when the expand/collapse button is pressed
  final ValueChanged<bool>? onExpandChanged;

  /// Creates a connection status widget.
  const ConnectionStatusWidget({
    Key? key,
    required this.connectionManager,
    this.statusIndicatorSize = 12.0,
    this.showLabel = true,
    this.showHealthIndicator = false,
    this.showDetailedTooltip = true,
    this.detailsWidget,
    this.isExpanded = false,
    this.onExpandChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<conn.ConnectionStatus>(
      stream: connectionManager.onConnectionStatus,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data ?? 
            conn.ConnectionStatus(
              state: conn.ConnectionState.disconnected,
              message: 'Not connected',
            );
            
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusRow(context, status),
            if (showHealthIndicator && status.state == conn.ConnectionState.connected) ...[
              const SizedBox(height: 8),
              _buildHealthIndicator(),
            ],
            if (isExpanded && detailsWidget != null) ...[
              const SizedBox(height: 16),
              detailsWidget!,
            ],
          ],
        );
      },
    );
  }
  
  /// Builds the row containing the status indicator and optional expand button
  Widget _buildStatusRow(BuildContext context, conn.ConnectionStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConnectionStatusIndicator(
          status: status,
          size: statusIndicatorSize,
          showLabel: showLabel,
          showDetailedTooltip: showDetailedTooltip,
        ),
        const Spacer(),
        if (detailsWidget != null)
          IconButton(
            icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () => onExpandChanged?.call(!isExpanded),
            tooltip: isExpanded ? 'Show less' : 'Show more details',
            iconSize: statusIndicatorSize * 1.5,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: statusIndicatorSize * 2,
              minHeight: statusIndicatorSize * 2,
            ),
          ),
      ],
    );
  }
  
  /// Builds the health indicator with live metrics
  Widget _buildHealthIndicator() {
    return StreamBuilder<ConnectionHealthMetrics>(
      stream: connectionManager.onHealthMetricsChanged,
      builder: (context, metricsSnapshot) {
        final metrics = metricsSnapshot.data ?? ConnectionHealthMetrics.empty();
        
        return ConnectionHealthIndicator(
          healthMetrics: metrics,
          showLabels: true,
          showValues: true,
        );
      },
    );
  }
}

/// A widget that displays a floating connection status in a corner of the screen.
class FloatingConnectionStatus extends StatelessWidget {
  /// The connection manager to listen to for status updates
  final ConnectionManager connectionManager;
  
  /// Position of the widget on the screen
  final FloatingPosition position;
  
  /// Padding from the edge of the screen
  final EdgeInsets padding;
  
  /// Size of the status indicator
  final double indicatorSize;
  
  /// Whether to show text labels
  final bool showLabels;

  /// Creates a floating connection status indicator.
  const FloatingConnectionStatus({
    Key? key,
    required this.connectionManager,
    this.position = FloatingPosition.bottomRight,
    this.padding = const EdgeInsets.all(16.0),
    this.indicatorSize = 10.0,
    this.showLabels = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position == FloatingPosition.topLeft || position == FloatingPosition.bottomLeft
          ? padding.left
          : null,
      right: position == FloatingPosition.topRight || position == FloatingPosition.bottomRight
          ? padding.right
          : null,
      top: position == FloatingPosition.topLeft || position == FloatingPosition.topRight
          ? padding.top
          : null,
      bottom: position == FloatingPosition.bottomLeft || position == FloatingPosition.bottomRight
          ? padding.bottom
          : null,
      child: Material(
        elevation: 4.0,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: StreamBuilder<conn.ConnectionStatus>(
            stream: connectionManager.onConnectionStatus,
            builder: (context, snapshot) {
              final status = snapshot.data ?? 
                  conn.ConnectionStatus(
                    state: conn.ConnectionState.disconnected,
                    message: 'Not connected',
                  );
              
              return ConnectionStatusIndicator(
                status: status,
                size: indicatorSize,
                showLabel: showLabels,
                showDetailedTooltip: true,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Position for the floating connection status widget
enum FloatingPosition {
  /// Top-left corner
  topLeft,
  
  /// Top-right corner
  topRight,
  
  /// Bottom-left corner
  bottomLeft,
  
  /// Bottom-right corner
  bottomRight,
} 