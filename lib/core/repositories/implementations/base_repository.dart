import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../models/exceptions/repository_exception.dart';
import '../interfaces/base_repository.dart';
import '../../../services/error/supabase_error_handler.dart';
import '../../../services/error/logging_service.dart';

/// Base implementation of the IRepository interface using Supabase as the backend.
///
/// This generic repository handles CRUD operations and real-time subscriptions
/// for any entity type T. Subclasses should specify the table name and provide
/// conversion methods between Supabase JSON data and the entity model.
abstract class SupabaseRepository<T> implements IRepository<T> {
  /// The Supabase client instance
  final SupabaseClient _client = Supabase.instance.client;
  
  /// Error handling utilities
  final _errorHandler = SupabaseErrorHandler();
  final _loggingService = LoggingService();
  
  /// The table name in the Supabase database for this entity type
  String get tableName;
  
  /// The primary key column name (usually 'id')
  String get primaryKeyField => 'id';
  
  /// Maximum number of retry attempts for operations
  int get maxRetries => 3;
  
  /// Converts a Supabase JSON map to an entity of type T
  T fromJson(Map<String, dynamic> json);
  
  /// Converts an entity of type T to a Supabase JSON map
  Map<String, dynamic> toJson(T entity);
  
  /// Gets the primary key value from an entity
  String getIdFromEntity(T entity);
  
  @override
  Future<T?> getById(String id) async {
    try {
      final result = await _errorHandler.executeWithRetry(
        operationName: 'getById',
        operation: () => _client
            .from(tableName)
            .select()
            .eq(primaryKeyField, id)
            .single(),
        tableName: tableName,
        recordId: id,
      );
      
      return fromJson(result);
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to get entity by ID',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {'table': tableName, 'id': id},
      );
      
      // Return null if the record wasn't found
      if (e.toString().contains('not found') || 
          e.toString().contains('no rows returned')) {
        return null;
      }
      
      throw RepositoryException(
        operation: 'getById',
        message: 'Failed to fetch $tableName with ID $id',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<T>> getAll() async {
    try {
      final result = await _errorHandler.executeWithRetry(
        operationName: 'getAll',
        operation: () => _client
            .from(tableName)
            .select(),
        tableName: tableName,
      );
      
      return (result as List<dynamic>)
          .map((item) => fromJson(item))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to get all entities',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {'table': tableName},
      );
      
      throw RepositoryException(
        operation: 'getAll',
        message: 'Failed to fetch all $tableName records',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<T>> query(Map<String, dynamic> queryParams) async {
    try {
      // Start with the basic query
      var query = _client.from(tableName).select();
      
      // Apply each query parameter as a filter
      queryParams.forEach((field, value) {
        if (value is List) {
          query = query.inFilter(field, value);
        } else {
          query = query.eq(field, value);
        }
      });
      
      // Execute the query
      final result = await _errorHandler.executeWithRetry(
        operationName: 'query',
        operation: () => query,
        tableName: tableName,
      );
      
      return (result as List<dynamic>)
          .map((item) => fromJson(item))
          .toList();
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to query entities',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'table': tableName,
          'queryParams': queryParams.toString(),
        },
      );
      
      throw RepositoryException(
        operation: 'query',
        message: 'Failed to query $tableName records',
        originalError: e,
      );
    }
  }
  
  @override
  Future<T> create(T entity) async {
    try {
      final entityJson = toJson(entity);
      
      final result = await _errorHandler.executeWithRetry(
        operationName: 'create',
        operation: () => _client
            .from(tableName)
            .insert(entityJson)
            .select()
            .single(),
        tableName: tableName,
      );
      
      return fromJson(result);
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to create entity',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'table': tableName,
          'entity': toJson(entity).toString(),
        },
      );
      
      throw RepositoryException(
        operation: 'create',
        message: 'Failed to create new $tableName record',
        originalError: e,
      );
    }
  }
  
  @override
  Future<T> update(T entity) async {
    try {
      final id = getIdFromEntity(entity);
      final entityJson = toJson(entity);
      
      final result = await _errorHandler.executeWithRetry(
        operationName: 'update',
        operation: () => _client
            .from(tableName)
            .update(entityJson)
            .eq(primaryKeyField, id)
            .select()
            .single(),
        tableName: tableName,
        recordId: id,
      );
      
      return fromJson(result);
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to update entity',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'table': tableName,
          'entity': toJson(entity).toString(),
        },
      );
      
      throw RepositoryException(
        operation: 'update',
        message: 'Failed to update $tableName record',
        originalError: e,
      );
    }
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _errorHandler.executeWithRetry(
        operationName: 'delete',
        operation: () => _client
            .from(tableName)
            .delete()
            .eq(primaryKeyField, id),
        tableName: tableName,
        recordId: id,
      );
      
      return true;
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to delete entity',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {'table': tableName, 'id': id},
      );
      
      // If the error is that the record wasn't found, consider the delete successful
      if (e.toString().contains('not found') || 
          e.toString().contains('no rows affected')) {
        return true;
      }
      
      throw RepositoryException(
        operation: 'delete',
        message: 'Failed to delete $tableName record with ID $id',
        originalError: e,
      );
    }
  }
  
  @override
  Stream<List<T>> subscribe() {
    final controller = StreamController<List<T>>();
    
    // Initial fetch of all records
    getAll().then((entities) {
      // Only add to the stream if the controller is still active
      if (!controller.isClosed) {
        controller.add(entities);
      }
    }).catchError((e) {
      // Log the error but don't close the stream
      _loggingService.error(
        'Error fetching initial data for subscription',
        category: LogCategory.realtime,
        error: e,
        additionalData: {'table': tableName},
      );
      
      // If the controller is still open, add an empty list
      if (!controller.isClosed) {
        controller.add([]);
      }
    });
    
    // Set up the real-time subscription
    final channelName = 'public:$tableName';
    final channel = _client.channel(channelName);
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      callback: (payload) async {
        try {
          // Fetch all records again when there are changes
          final updatedEntities = await getAll();
          if (!controller.isClosed) {
            controller.add(updatedEntities);
          }
        } catch (e) {
          _loggingService.error(
            'Error handling subscription update',
            category: LogCategory.realtime,
            error: e,
            additionalData: {'table': tableName, 'payload': payload.toString()},
          );
        }
      },
    ).subscribe();
    
    // Clean up when the stream is canceled
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  @override
  Stream<T?> subscribeToId(String id) {
    final controller = StreamController<T?>();
    
    // Initial fetch of the record
    getById(id).then((entity) {
      // Only add to the stream if the controller is still active
      if (!controller.isClosed) {
        controller.add(entity);
      }
    }).catchError((e) {
      // Log the error but don't close the stream
      _loggingService.error(
        'Error fetching initial data for ID subscription',
        category: LogCategory.realtime,
        error: e,
        additionalData: {'table': tableName, 'id': id},
      );
      
      // If the controller is still open, add null
      if (!controller.isClosed) {
        controller.add(null);
      }
    });
    
    // Set up the real-time subscription specifically for this record
    final channelName = 'public:$tableName:id_$id';
    final channel = _client.channel(channelName);
    
    // PostgresChangeFilter for filtering by ID
    final filter = PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: primaryKeyField,
      value: id,
    );
    
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: tableName,
      filter: filter,
      callback: (payload) async {
        try {
          // Handle the specific event type
          if (payload.eventType == PostgresChangeEvent.delete) {
            if (!controller.isClosed) {
              controller.add(null);
            }
          } else {
            // For INSERT or UPDATE, fetch the latest version
            final updatedEntity = await getById(id);
            if (!controller.isClosed) {
              controller.add(updatedEntity);
            }
          }
        } catch (e) {
          _loggingService.error(
            'Error handling ID subscription update',
            category: LogCategory.realtime,
            error: e,
            additionalData: {
              'table': tableName,
              'id': id,
              'payload': payload.toString(),
            },
          );
        }
      },
    ).subscribe();
    
    // Clean up when the stream is canceled
    controller.onCancel = () {
      _client.removeChannel(channel);
    };
    
    return controller.stream;
  }
  
  @override
  Future<List<T>> executeQuery(String query, {Map<String, dynamic>? params}) async {
    try {
      final result = await _errorHandler.executeWithRetry(
        operationName: 'executeQuery',
        operation: () => _client.rpc(
          query,
          params: params ?? {},
        ),
        tableName: tableName,
      );
      
      // Check if the result is a list that can be converted to entities
      if (result is List) {
        return result
            .map((item) => item is Map<String, dynamic> ? fromJson(item) : null)
            .whereType<T>()
            .toList();
      }
      
      // If the result is a single entity
      if (result is Map<String, dynamic>) {
        return [fromJson(result)];
      }
      
      // Return empty list for other result types
      return [];
    } catch (e, stackTrace) {
      _loggingService.error(
        'Failed to execute custom query',
        category: LogCategory.database,
        error: e,
        stackTrace: stackTrace,
        additionalData: {
          'query': query,
          'params': params?.toString(),
        },
      );
      
      throw RepositoryException(
        operation: 'executeQuery',
        message: 'Failed to execute custom query: ${query.substring(0, query.length > 30 ? 30 : query.length)}...',
        originalError: e,
      );
    }
  }
} 