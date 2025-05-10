/// Exception class for repository-related errors.
/// 
/// This class is used to provide more context around errors that occur during
/// repository operations (e.g., database queries, real-time subscriptions).
class RepositoryException implements Exception {
  /// The operation that failed (e.g., 'getById', 'update')
  final String operation;
  
  /// A user-friendly error message
  final String message;
  
  /// The original error that caused this exception
  final Object? originalError;
  
  /// Creates a new [RepositoryException].
  /// 
  /// [operation] identifies the repository method that failed.
  /// [message] provides a human-readable description of the error.
  /// [originalError] contains the underlying exception for debugging.
  RepositoryException({
    required this.operation,
    required this.message,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'RepositoryException: [$operation] $message'
        '${originalError != null ? '\nCaused by: $originalError' : ''}';
  }
} 