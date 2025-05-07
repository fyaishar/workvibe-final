import 'package:flutter/material.dart';
import '../services/connection/connection_manager.dart';
import '../services/connection/connection_state.dart' as conn;
import '../widgets/connection_status_widget.dart';

/// A demo screen to showcase the connection status indicators
class ConnectionStatusDemoScreen extends StatefulWidget {
  /// The connection manager to display status for
  final ConnectionManager connectionManager;

  /// Creates a connection status demo screen
  const ConnectionStatusDemoScreen({
    Key? key,
    required this.connectionManager,
  }) : super(key: key);

  @override
  State<ConnectionStatusDemoScreen> createState() => _ConnectionStatusDemoScreenState();
}

class _ConnectionStatusDemoScreenState extends State<ConnectionStatusDemoScreen> {
  bool _showDetailedView = false;
  bool _showFloatingIndicator = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Status'),
        actions: [
          _buildConnectionStatusIndicator(),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildStatusCard(),
                const SizedBox(height: 24),
                _buildControlsCard(),
              ],
            ),
          ),
          if (_showFloatingIndicator)
            FloatingConnectionStatus(
              connectionManager: widget.connectionManager,
              position: FloatingPosition.bottomRight,
              showLabels: false,
            ),
        ],
      ),
    );
  }

  /// Builds a small connection status indicator for the app bar
  Widget _buildConnectionStatusIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Center(
        child: ConnectionStatusWidget(
          connectionManager: widget.connectionManager,
          statusIndicatorSize: 10.0,
          showLabel: false,
          showHealthIndicator: false,
        ),
      ),
    );
  }

  /// Builds the info card with description
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Connection Status Indicators',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This screen demonstrates different ways to display realtime connection status. '
              'The indicators update automatically when connection status changes.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the main status card with detailed view
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConnectionStatusWidget(
              connectionManager: widget.connectionManager,
              statusIndicatorSize: 16.0,
              showLabel: true,
              showHealthIndicator: true,
              showDetailedTooltip: true,
              isExpanded: _showDetailedView,
              onExpandChanged: (expanded) {
                setState(() {
                  _showDetailedView = expanded;
                });
              },
              detailsWidget: _buildDetailedConnectionInfo(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds detailed connection information panel
  Widget _buildDetailedConnectionInfo() {
    return StreamBuilder<conn.ConnectionStatus>(
      stream: widget.connectionManager.onConnectionStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? 
            conn.ConnectionStatus(
              state: conn.ConnectionState.disconnected,
              message: 'Not connected',
            );
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            Text(
              'Connection Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildDetailRow('Status', status.state.toString().split('.').last),
            if (status.message != null && status.message!.isNotEmpty)
              _buildDetailRow('Message', status.message!),
            _buildDetailRow('Ping', widget.connectionManager.lastPingTime != null 
                ? '${widget.connectionManager.lastPingTime} ms' 
                : 'N/A'),
            _buildDetailRow('Stability', '${widget.connectionManager.stabilityRating}/100'),
          ],
        );
      },
    );
  }

  /// Builds a detail row for the detailed connection info
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds controls for the demo
  Widget _buildControlsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildControlButton(
              'Connect',
              widget.connectionManager.isConnected ? Colors.grey : Colors.blue,
              widget.connectionManager.isConnected
                  ? null
                  : () => widget.connectionManager.connect(),
            ),
            const SizedBox(height: 8),
            _buildControlButton(
              'Disconnect',
              widget.connectionManager.isConnected ? Colors.red : Colors.grey,
              widget.connectionManager.isConnected
                  ? () => widget.connectionManager.disconnect()
                  : null,
            ),
            const SizedBox(height: 8),
            _buildControlButton(
              'Reset Statistics',
              Colors.orange,
              () => widget.connectionManager.resetHealthStatistics(),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Floating Indicator'),
              value: _showFloatingIndicator,
              onChanged: (value) {
                setState(() {
                  _showFloatingIndicator = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a control button with given text and onPressed handler
  Widget _buildControlButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 40),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
} 