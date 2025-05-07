import 'package:flutter/foundation.dart';

/// Log levels for categorizing log messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Log categories for organizing logs by feature or component
enum LogCategory {
  auth,
  database,
  network,
  realtime,
  ui,
  general,
}

/// A centralized service for structured logging throughout the application
class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  static void Function(Object?) _printFn = print;
  static void set printFn(void Function(Object?) fn) => _printFn = fn;
  static void Function(Object?) get printFn => _printFn;
  
  factory LoggingService() {
    return _instance;
  }
  
  LoggingService._internal();
  
  /// Log a message with the specified level and category
  void log(
    String message, {
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.general,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    if (!_shouldLog(level)) return;
    
    final logEntry = {
      'timestamp': DateTime.now().toIso8601String(),
      'level': level.toString().split('.').last.toUpperCase(),
      'category': category.toString().split('.').last,
      'message': message,
      if (error != null) 'error': error.toString(),
      if (additionalData != null) ...additionalData,
    };
    
    // In a production app, this would send logs to a backend service
    // For now, we just print them in debug mode
    if (kDebugMode) {
      _printFn('LOG: ${_formatLogEntry(logEntry)}');
      if (stackTrace != null && (level == LogLevel.error || level == LogLevel.fatal)) {
        _printFn('STACK TRACE: $stackTrace');
      }
    }
  }
  
  /// Log a debug message
  void debug(String message, {LogCategory category = LogCategory.general, Map<String, dynamic>? additionalData}) {
    log(message, level: LogLevel.debug, category: category, additionalData: additionalData);
  }
  
  /// Log an info message
  void info(String message, {LogCategory category = LogCategory.general, Map<String, dynamic>? additionalData}) {
    log(message, level: LogLevel.info, category: category, additionalData: additionalData);
  }
  
  /// Log a warning message
  void warning(String message, {LogCategory category = LogCategory.general, Object? error, Map<String, dynamic>? additionalData}) {
    log(message, level: LogLevel.warning, category: category, error: error, additionalData: additionalData);
  }
  
  /// Log an error message
  void error(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace, Map<String, dynamic>? additionalData}) {
    log(message, level: LogLevel.error, category: category, error: error, stackTrace: stackTrace, additionalData: additionalData);
  }
  
  /// Log a fatal error message
  void fatal(String message, {LogCategory category = LogCategory.general, Object? error, StackTrace? stackTrace, Map<String, dynamic>? additionalData}) {
    log(message, level: LogLevel.fatal, category: category, error: error, stackTrace: stackTrace, additionalData: additionalData);
  }
  
  /// Format log entry for console output
  String _formatLogEntry(Map<String, dynamic> entry) {
    final buffer = StringBuffer();
    buffer.write('[${entry['timestamp']}] ');
    buffer.write('[${entry['level']}] ');
    buffer.write('[${entry['category']}] ');
    buffer.write(entry['message']);
    
    if (entry.containsKey('error')) {
      buffer.write(' - Error: ${entry['error']}');
    }
    
    // Add additional data if any
    entry.forEach((key, value) {
      if (!['timestamp', 'level', 'category', 'message', 'error'].contains(key)) {
        buffer.write(' - $key: $value');
      }
    });
    
    return buffer.toString();
  }
  
  /// Determine if the message should be logged based on current log level settings
  bool _shouldLog(LogLevel level) {
    // In a real app, this would check against a configurable minimum log level
    // For now, we log everything in debug mode and only warnings and above in release
    if (kDebugMode) {
      return true;
    } else {
      return level.index >= LogLevel.warning.index;
    }
  }
  
  /// Log a Supabase database operation
  void logSupabaseOperation(
    String operation,
    String table, {
    String? id,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final level = error != null ? LogLevel.error : LogLevel.debug;
    final additionalData = <String, dynamic>{
      'operation': operation,
      'table': table,
      if (id != null) 'id': id,
      if (data != null) 'data': data.toString(),
    };
    
    log(
      'Supabase $operation on $table',
      level: level,
      category: LogCategory.database,
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }
  
  /// Log a Supabase authentication event
  void logAuthEvent(
    String event, {
    String? userId,
    String? email,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final level = error != null ? LogLevel.error : LogLevel.info;
    final additionalData = <String, dynamic>{
      'event': event,
      if (userId != null) 'userId': userId,
      if (email != null) 'email': email,
    };
    
    log(
      'Auth event: $event',
      level: level,
      category: LogCategory.auth,
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }
  
  /// Log a Supabase Realtime event
  void logRealtimeEvent(
    String event,
    String channel, {
    String? eventType,
    Object? payload,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final level = error != null ? LogLevel.error : LogLevel.debug;
    final additionalData = <String, dynamic>{
      'event': event,
      'channel': channel,
      if (eventType != null) 'eventType': eventType,
      if (payload != null) 'payload': payload.toString(),
    };
    
    log(
      'Realtime event: $event on $channel',
      level: level,
      category: LogCategory.realtime,
      error: error,
      stackTrace: stackTrace,
      additionalData: additionalData,
    );
  }
} 