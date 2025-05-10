import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../models/exceptions/repository_exceptions.dart';
import '../interfaces/base_repository.dart';
import '../../../services/error/repository_error_handler.dart';
import '../../../services/error/supabase_error_handler.dart';
import '../../../services/error/logging_service.dart';
import '../../../services/subscription/subscription_manager.dart';
import '../../utils/model_adapter_mixin.dart';

/// Base implementation of the IRepository interface using Supabase as the backend.
///
/// This generic repository handles CRUD operations and real-time subscriptions
/// for any entity type T. Subclasses should specify the table name and provide
/// conversion methods between Supabase JSON data and the entity model.
abstract class SupabaseRepository<T> with FreezedModelAdapterMixin implements IRepository<T> {
  /// The Supabase client instance
  final SupabaseClient _client = Supabase.instance.client;
  
  /// Error handling utilities
  final _errorHandler = SupabaseErrorHandler();
  final _repositoryErrorHandler = RepositoryErrorHandler();
  final _loggingService = LoggingService();
  
  /// The subscription manager instance
  final SubscriptionManager _subscriptionManager = SubscriptionManager();
  
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
      final result = await _repositoryErrorHandler.executeWithRetry(
        operationName: 'getById',
        operation: () => _client
            .from(tableName)
            .select()
            .eq(primaryKeyField, id)
            .single(),
        entityType: tableName,
        entityId: id,
      );
      
      // Adapt the Supabase result to a Freezed-compatible format before conversion
      return result != null ? fromJson(adaptToFreezed(result)) : null;
    } catch (e) {
      // Special handling for 'not found' errors - return null instead of throwing
      if (e is ResourceNotFoundException) {
        return null;
      }
      rethrow;
    }
  }
  
  @override
  Future<List<T>> getAll() async {
    final result = await _repositoryErrorHandler.executeWithRetry(
      operationName: 'getAll',
      operation: () => _client
          .from(tableName)
          .select(),
      entityType: tableName,
    );
    
    // Adapt each result item and convert to entity
    return (result as List<dynamic>)
        .map((item) => item is Map<String, dynamic> 
            ? fromJson(adaptToFreezed(item)) 
            : throw FormatException('Expected a map but got ${item.runtimeType}'))
        .toList();
  }
  
  @override
  Future<List<T>> query(Map<String, dynamic> queryParams) async {
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
    final result = await _repositoryErrorHandler.executeWithRetry(
      operationName: 'query',
      operation: () => query,
      entityType: tableName,
      context: {'queryParams': queryParams},
    );
    
    // Adapt results and convert to entities
    return (result as List<dynamic>)
        .map((item) => item is Map<String, dynamic> 
            ? fromJson(adaptToFreezed(item)) 
            : throw FormatException('Expected a map but got ${item.runtimeType}'))
        .toList();
  }
  
  @override
  Future<T> create(T entity) async {
    // Convert entity to JSON and adapt for Supabase
    final freezedJson = toJson(entity);
    final entityJson = adaptToSupabase(freezedJson);
    
    // Validate entity before creating
    _validateEntity(entityJson, 'create');
    
    // Create the entity in the database
    final result = await _repositoryErrorHandler.executeWithRetry(
      operationName: 'create',
      operation: () => _client
          .from(tableName)
          .insert(entityJson)
          .select()
          .single(),
      entityType: tableName,
      context: {'entityData': entityJson},
    );
    
    // Adapt the result to Freezed format and return as entity
    return fromJson(adaptToFreezed(result));
  }
  
  @override
  Future<T> update(T entity) async {
    final id = getIdFromEntity(entity);
    
    // Convert entity to JSON and adapt for Supabase
    final freezedJson = toJson(entity);
    final entityJson = adaptToSupabase(freezedJson);
    
    // Validate entity before updating
    _validateEntity(entityJson, 'update');
    
    // Update the entity in the database
    final result = await _repositoryErrorHandler.executeWithRetry(
      operationName: 'update',
      operation: () => _client
          .from(tableName)
          .update(entityJson)
          .eq(primaryKeyField, id)
          .select()
          .single(),
      entityType: tableName,
      entityId: id,
      context: {'entityData': entityJson},
    );
    
    // Adapt the result to Freezed format and return as entity
    return fromJson(adaptToFreezed(result));
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _repositoryErrorHandler.executeWithRetry(
        operationName: 'delete',
        operation: () => _client
            .from(tableName)
            .delete()
            .eq(primaryKeyField, id),
        entityType: tableName,
        entityId: id,
      );
      
      return true;
    } catch (e) {
      // If the error is that the record wasn't found, consider the delete successful
      if (e is ResourceNotFoundException) {
        _loggingService.info(
          'Delete operation on non-existent record treated as success',
          category: LogCategory.database,
          additionalData: {'table': tableName, 'id': id},
        );
        return true;
      }
      rethrow;
    }
  }
  
  @override
  Stream<List<T>> subscribe() {
    // Create subscription using the SubscriptionManager
    return _subscriptionManager
        .subscribeToTable(tableName)
        .map((records) => records
            .map((item) => fromJson(adaptToFreezed(item)))
            .toList());
  }
  
  @override
  Stream<T?> subscribeToId(String id) {
    // Create subscription using the SubscriptionManager
    return _subscriptionManager
        .subscribeToRecord(tableName, id)
        .map((record) => record != null ? fromJson(adaptToFreezed(record)) : null);
  }
  
  /// Subscribes to a filtered query on this repository's table
  Stream<List<T>> subscribeToQuery(Map<String, dynamic> queryParams) {
    // Create subscription using the SubscriptionManager
    return _subscriptionManager
        .subscribeToQuery(tableName, queryParams)
        .map((records) => records
            .map((item) => fromJson(adaptToFreezed(item)))
            .toList());
  }
  
  @override
  Future<List<T>> executeQuery(String query, {Map<String, dynamic>? params}) async {
    final result = await _repositoryErrorHandler.executeWithRetry(
      operationName: 'executeQuery',
      operation: () => _client.rpc(
        query,
        params: params ?? {},
      ),
      entityType: tableName,
      context: {
        'query': query,
        if (params != null) 'params': params,
      },
    );
    
    // Check if the result is a list that can be converted to entities
    if (result is List) {
      return result
          .map((item) => item is Map<String, dynamic> 
              ? fromJson(adaptToFreezed(item)) 
              : null)
          .whereType<T>()
          .toList();
    }
    
    // If the result is a single entity
    if (result is Map<String, dynamic>) {
      return [fromJson(adaptToFreezed(result))];
    }
    
    // Return empty list for other result types
    return [];
  }
  
  /// Validates entity data before create/update operations
  /// 
  /// This provides a hook for subclasses to implement validation logic.
  /// It should throw a [ValidationException] when validation fails.
  void _validateEntity(Map<String, dynamic> entityJson, String operation) {
    // Base implementation doesn't do validation
    // Subclasses can override this method to implement specific validation
  }
  
  /// Helper method to create a validation exception with field-specific errors
  ValidationException createValidationException({
    required String operation,
    required Map<String, String> validationErrors,
    String? message,
    Object? originalError,
  }) {
    return ValidationException(
      operation: operation,
      message: message ?? 'Validation failed for $tableName entity',
      validationErrors: validationErrors,
      originalError: originalError,
      context: {'table': tableName},
    );
  }
} 