import 'package:flutter/material.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/spacing.dart';
import '../status/status_indicator.dart';

/// Connection states for the app.
enum NetworkState {
  /// Connected to the server
  connected,
  
  /// Attempting to establish a connection
  connecting,
  
  /// No connection to the server
  disconnected,
}

/// A widget that displays the current connection status.
class ConnectionStatus extends StatelessWidget {
  /// The current connection state.
  final NetworkState state;
  
  /// Custom message to display.
  final String? message;
  
  /// Action to take to reconnect.
  final VoidCallback? onReconnect;

  const ConnectionStatus({
    Key? key,
    required this.state,
    this.message,
    this.onReconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.medium,
        vertical: Spacing.small,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(Spacing.borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusIndicator(
            type: _getStatusIndicatorType(),
            pulsing: state == NetworkState.connecting,
            size: StatusIndicatorSize.small,
          ),
          const SizedBox(width: Spacing.small),
          Text(
            message ?? _getDefaultMessage(),
            style: TextStyle(
              color: _getTextColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state == NetworkState.disconnected && onReconnect != null) ...[
            const SizedBox(width: Spacing.small),
            InkWell(
              onTap: onReconnect,
              child: Text(
                'Reconnect',
                style: TextStyle(
                  color: _getTextColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get the background color based on the connection state.
  Color _getBackgroundColor() {
    switch (state) {
      case NetworkState.connected:
        return AppColors.connected.withOpacity(0.1);
      case NetworkState.connecting:
        return AppColors.connecting.withOpacity(0.1);
      case NetworkState.disconnected:
        return AppColors.disconnected.withOpacity(0.1);
    }
  }

  /// Get the text color based on the connection state.
  Color _getTextColor() {
    switch (state) {
      case NetworkState.connected:
        return AppColors.connected;
      case NetworkState.connecting:
        return AppColors.connecting;
      case NetworkState.disconnected:
        return AppColors.disconnected;
    }
  }

  /// Get the default message based on the connection state.
  String _getDefaultMessage() {
    switch (state) {
      case NetworkState.connected:
        return 'Connected';
      case NetworkState.connecting:
        return 'Connecting...';
      case NetworkState.disconnected:
        return 'Disconnected';
    }
  }

  /// Get the status indicator type based on the connection state.
  StatusIndicatorType _getStatusIndicatorType() {
    switch (state) {
      case NetworkState.connected:
        return StatusIndicatorType.success;
      case NetworkState.connecting:
        return StatusIndicatorType.warning;
      case NetworkState.disconnected:
        return StatusIndicatorType.error;
    }
  }
} 