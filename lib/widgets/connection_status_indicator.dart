import 'package:flutter/material.dart';
import '../services/connection/connection_state.dart' as conn;

/// A widget that displays the current connection status with a visual indicator.
class ConnectionStatusIndicator extends StatelessWidget {
  /// The current connection status
  final conn.ConnectionStatus status;
  
  /// Size of the indicator
  final double size;
  
  /// Whether to show a text label with the status
  final bool showLabel;
  
  /// Whether to show detailed message on hover/tap
  final bool showDetailedTooltip;

  /// Creates a connection status indicator.
  const ConnectionStatusIndicator({
    Key? key,
    required this.status,
    this.size = 12.0,
    this.showLabel = false,
    this.showDetailedTooltip = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: showDetailedTooltip ? _getTooltipText() : _getStatusText(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.3),
                  blurRadius: size / 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: status.state == conn.ConnectionState.reconnecting
                ? _buildPulsingIndicator()
                : null,
          ),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: size * 1.2,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds a pulsing animation for the reconnecting status
  Widget _buildPulsingIndicator() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.5, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
        onEnd: () => _buildPulsingIndicator(),
      ),
    );
  }

  /// Returns the appropriate color for the current status
  Color _getStatusColor() {
    switch (status.state) {
      case conn.ConnectionState.connected:
        return Colors.green;
      case conn.ConnectionState.connecting:
        return Colors.blue;
      case conn.ConnectionState.reconnecting:
        return Colors.orange;
      case conn.ConnectionState.disconnected:
        return Colors.grey;
      case conn.ConnectionState.failed:
        return Colors.red;
    }
  }

  /// Returns a human-readable status text
  String _getStatusText() {
    switch (status.state) {
      case conn.ConnectionState.connected:
        return 'Connected';
      case conn.ConnectionState.connecting:
        return 'Connecting';
      case conn.ConnectionState.reconnecting:
        return 'Reconnecting';
      case conn.ConnectionState.disconnected:
        return 'Disconnected';
      case conn.ConnectionState.failed:
        return 'Connection Failed';
    }
  }

  /// Returns a detailed tooltip text with status message
  String _getTooltipText() {
    final baseText = _getStatusText();
    if (status.message != null && status.message!.isNotEmpty) {
      return '$baseText: ${status.message}';
    }
    return baseText;
  }
} 