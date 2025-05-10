import 'package:flutter/material.dart';
import '../../core/models/exceptions/repository_exceptions.dart';
import '../../core/repositories/implementations/base_repository.dart';
import '../common/repository_error_widget.dart';

/// Example widget demonstrating how to use the repository error handling system
class ErrorHandlingExample extends StatefulWidget {
  const ErrorHandlingExample({super.key});

  @override
  State<ErrorHandlingExample> createState() => _ErrorHandlingExampleState();
}

class _ErrorHandlingExampleState extends State<ErrorHandlingExample> {
  late Future<void> _dataFuture;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  void _loadData() {
    setState(() {
      _isLoading = true;
      // This future will demonstrate how to handle repository errors
      _dataFuture = _fetchData();
    });
  }
  
  // Simulated data fetching that can produce different repository exceptions
  Future<void> _fetchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Use a random number to simulate different error scenarios
    final random = DateTime.now().millisecondsSinceEpoch % 6;
    
    setState(() {
      _isLoading = false;
    });
    
    switch (random) {
      case 0:
        // Success case - no exception
        return;
      case 1:
        throw ResourceNotFoundException(
          operation: 'getById',
          resourceId: '123',
          resourceType: 'User',
        );
      case 2:
        throw ValidationException(
          operation: 'create',
          validationErrors: {
            'email': 'Invalid email format',
            'password': 'Password must be at least 8 characters',
          },
        );
      case 3:
        throw NetworkException(
          operation: 'query',
          isRetryable: true,
          message: 'Network connection lost',
        );
      case 4:
        throw PermissionDeniedException(
          operation: 'update',
          message: 'You do not have permission to update this resource',
        );
      case 5:
        throw DuplicateResourceException(
          operation: 'create',
          conflictingField: 'email',
          message: 'A user with this email already exists',
        );
      default:
        throw RepositoryException(
          operation: 'unknown',
          message: 'An unexpected error occurred',
        );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Example'),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: _dataFuture,
          builder: (context, snapshot) {
            // Show loading indicator
            if (_isLoading) {
              return const CircularProgressIndicator();
            }
            
            // If the snapshot has a repository error, display it
            if (snapshot.hasRepositoryError) {
              return snapshot.buildRepositoryError(
                onRetry: _loadData,
              );
            }
            
            // If the future completed with data
            if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('Data loaded successfully!', style: TextStyle(fontSize: 18)),
                ],
              );
            }
            
            // For other error types
            if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Unknown error: ${snapshot.error}', style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Try Again'),
                  ),
                ],
              );
            }
            
            // Fallback
            return const Text('Something went wrong');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

/// Example of how to use error handling in a repository implementation
class ExampleUsage {
  /// Example of using error handling in repository methods
  static Future<void> repositoryExample() async {
    // This shows how to use repository error handling in real code
    // This is not actual runnable code, just a demonstration
    
    // First, properly catch and handle different exception types
    try {
      // Repository method call - e.g., userRepository.getUserById('123')
      // If this call fails, it will throw a specific RepositoryException subclass
    } catch (e) {
      if (e is ResourceNotFoundException) {
        // Handle not found error - e.g., show user not found message
        debugPrint('User not found: ${e.toUserFriendlyMessage()}');
      } else if (e is NetworkException && e.isRetryable) {
        // Handle retryable network error - e.g., show retry dialog
        debugPrint('Network error, can retry: ${e.toUserFriendlyMessage()}');
      } else if (e is PermissionDeniedException) {
        // Handle permission error - e.g., request access or show login
        debugPrint('Permission denied: ${e.toUserFriendlyMessage()}');
      } else {
        // Handle generic repository error
        debugPrint('Repository error: ${e.toString()}');
      }
    }
  }
} 