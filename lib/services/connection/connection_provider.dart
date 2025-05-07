import 'package:flutter/material.dart';
import 'connection_manager.dart';
import 'connection_state.dart' as conn;
import 'connection_config.dart';

/// A provider that manages a ConnectionManager and makes it
/// available to the widget tree.
class ConnectionProvider extends InheritedWidget {
  /// The connection manager instance to provide
  final ConnectionManager connectionManager;
  
  /// Creates a connection provider with a connection manager.
  ConnectionProvider({
    Key? key,
    required Widget child,
    ConnectionConfig? config,
  }) : connectionManager = ConnectionManager(config: config),
       super(key: key, child: child);
  
  /// Get the connection provider from the context.
  static ConnectionProvider of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ConnectionProvider>();
    if (provider == null) {
      throw FlutterError(
        'ConnectionProvider.of() called with a context that does not contain a ConnectionProvider.\n'
        'No ConnectionProvider ancestor could be found starting from the context that was passed to '
        'ConnectionProvider.of(). This can happen because you do not have a ConnectionProvider '
        'above this context in the widget tree.\n'
        'The context used was:\n'
        '  $context',
      );
    }
    return provider;
  }
  
  /// Get the connection manager from the context.
  static ConnectionManager managerOf(BuildContext context) {
    return of(context).connectionManager;
  }
  
  /// Check if the connection is active.
  static bool isConnected(BuildContext context) {
    return managerOf(context).isConnected;
  }
  
  /// Stream of connection status updates.
  static Stream<conn.ConnectionStatus> statusStream(BuildContext context) {
    return managerOf(context).onConnectionStatus;
  }
  
  @override
  bool updateShouldNotify(ConnectionProvider oldWidget) {
    return connectionManager != oldWidget.connectionManager;
  }
}

/// A widget that ensures a connection is established and maintained.
class ConnectionConsumer extends StatefulWidget {
  /// Widget to render
  final Widget child;
  
  /// Optional builder that gives access to connection status
  final Widget Function(BuildContext context, conn.ConnectionStatus status)? builder;
  
  /// Whether to automatically connect when the widget is mounted
  final bool autoConnect;
  
  /// Widget to show while connecting
  final Widget? connectingWidget;
  
  /// Widget to show when disconnected
  final Widget? disconnectedWidget;
  
  /// Widget to show when connection fails
  final Widget? errorWidget;
  
  /// Creates a connection consumer.
  const ConnectionConsumer({
    Key? key,
    required this.child,
    this.builder,
    this.autoConnect = true,
    this.connectingWidget,
    this.disconnectedWidget,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<ConnectionConsumer> createState() => _ConnectionConsumerState();
}

class _ConnectionConsumerState extends State<ConnectionConsumer> {
  late ConnectionManager _connectionManager;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _connectionManager = ConnectionProvider.managerOf(context);
    
    if (widget.autoConnect && !_connectionManager.isConnected) {
      _connectionManager.connect();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.builder != null) {
      return StreamBuilder<conn.ConnectionStatus>(
        stream: _connectionManager.onConnectionStatus,
        builder: (context, snapshot) {
          final status = snapshot.data ?? 
              conn.ConnectionStatus(
                state: conn.ConnectionState.disconnected, 
                message: 'Not connected'
              );
          
          return widget.builder!(context, status);
        },
      );
    }
    
    return StreamBuilder<conn.ConnectionStatus>(
      stream: _connectionManager.onConnectionStatus,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return widget.connectingWidget ?? widget.child;
        }
        
        final status = snapshot.data!;
        
        switch (status.state) {
          case conn.ConnectionState.connected:
            return widget.child;
            
          case conn.ConnectionState.connecting:
          case conn.ConnectionState.reconnecting:
            return widget.connectingWidget ?? widget.child;
            
          case conn.ConnectionState.disconnected:
            return widget.disconnectedWidget ?? widget.child;
            
          case conn.ConnectionState.failed:
            return widget.errorWidget ?? widget.child;
        }
      },
    );
  }
} 