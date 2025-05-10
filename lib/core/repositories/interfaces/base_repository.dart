/// Base repository interface defining the contract for CRUD operations
/// and real-time data subscriptions.
/// 
/// Type parameter [T] represents the model/entity type this repository manages.
/// All repositories in the application should implement this interface.
abstract class IRepository<T> {
  /// Retrieves an entity by its unique identifier.
  /// 
  /// Returns null if the entity with [id] doesn't exist.
  Future<T?> getById(String id);
  
  /// Retrieves all entities of type [T].
  /// 
  /// Returns an empty list if no entities exist.
  Future<List<T>> getAll();
  
  /// Queries entities based on a filter criteria.
  /// 
  /// [queryParams] is a map of column names to values for filtering.
  /// Returns matching entities or an empty list if none match.
  Future<List<T>> query(Map<String, dynamic> queryParams);
  
  /// Creates a new entity.
  /// 
  /// Returns the created entity with any server-generated fields (like id).
  Future<T> create(T entity);
  
  /// Updates an existing entity.
  /// 
  /// [entity] must contain the id of the entity to update.
  /// Returns the updated entity.
  Future<T> update(T entity);
  
  /// Deletes an entity by its unique identifier.
  /// 
  /// Returns true if deletion was successful, false otherwise.
  Future<bool> delete(String id);
  
  /// Subscribes to real-time updates for all entities of type [T].
  /// 
  /// Returns a stream that emits the latest list of entities whenever 
  /// there's a change in the database.
  Stream<List<T>> subscribe();
  
  /// Subscribes to real-time updates for a specific entity.
  /// 
  /// Returns a stream that emits the latest entity whenever it changes,
  /// or null if the entity is deleted.
  Stream<T?> subscribeToId(String id);
  
  /// Executes a custom query with optional transaction support.
  /// 
  /// This method allows for more complex database operations beyond
  /// the standard CRUD operations.
  Future<List<T>> executeQuery(String query, {Map<String, dynamic>? params});
} 