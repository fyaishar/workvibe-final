import 'model_adapter.dart';

/// A mixin that provides Freezed model serialization/deserialization 
/// capabilities to repositories.
///
/// Provides methods for converting between Supabase database format and
/// Freezed model format, while handling common conversion issues.
mixin FreezedModelAdapterMixin {
  /// Shared model adapter instance
  final ModelAdapter _adapter = ModelAdapter();
  
  /// Converts a Supabase JSON map to a Freezed-compatible format
  /// 
  /// This method handles:
  /// - Converting snake_case keys to camelCase
  /// - Converting date strings to DateTime objects
  /// - Proper handling of nested objects and lists
  Map<String, dynamic> adaptToFreezed(Map<String, dynamic> supabaseJson) {
    return _adapter.toFreezedJson(supabaseJson);
  }
  
  /// Converts a Freezed model JSON map to a Supabase-compatible format
  ///
  /// This method handles:
  /// - Converting camelCase keys to snake_case
  /// - Converting DateTime objects to ISO strings
  /// - Proper handling of nested objects and lists
  /// - Removing internal Freezed fields
  Map<String, dynamic> adaptToSupabase(Map<String, dynamic> freezedJson) {
    return _adapter.toSupabaseJson(freezedJson);
  }
  
  /// Converts a list of Supabase JSON maps to a list of Freezed-compatible maps
  List<Map<String, dynamic>> adaptListToFreezed(List<dynamic> supabaseJsonList) {
    return supabaseJsonList
        .map((item) => item is Map<String, dynamic> 
            ? adaptToFreezed(item) 
            : throw ArgumentError('List items must be maps'))
        .toList();
  }
  
  /// Converts a list of Freezed model JSON maps to a list of Supabase-compatible maps
  List<Map<String, dynamic>> adaptListToSupabase(List<dynamic> freezedJsonList) {
    return freezedJsonList
        .map((item) => item is Map<String, dynamic> 
            ? adaptToSupabase(item) 
            : throw ArgumentError('List items must be maps'))
        .toList();
  }
} 