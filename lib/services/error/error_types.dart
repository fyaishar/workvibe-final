/// Types of errors that can occur in the application
enum ErrorType {
  /// Network connectivity-related errors
  networkError,
  
  /// Authentication or authorization errors
  authenticationError,
  
  /// Server-side errors
  serverError,
  
  /// Rate limiting or throttling errors
  rateLimitError,
  
  /// Validation errors in forms or API requests
  validationError,
  
  /// Errors related to data parsing or serialization
  dataError,
  
  /// Generic/unknown errors
  unknown
}

/// Categories for logging errors
enum LogCategory {
  /// Network-related logs
  network,
  
  /// Authentication-related logs
  auth,
  
  /// User interface logs
  ui,
  
  /// Database-related logs
  database,
  
  /// API-related logs
  api,
  
  /// WebSocket connection logs
  connection,
  
  /// Background tasks and processes
  background,
  
  /// General/uncategorized logs
  general
} 