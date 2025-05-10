import 'package:intl/intl.dart';

/// A utility class for adapting between Supabase database format and Freezed models
///
/// This class provides methods for converting field names between camelCase (Dart/Freezed)
/// and snake_case (Supabase/Postgres), as well as handling common data type conversions.
class ModelAdapter {
  // Singleton instance
  static final ModelAdapter _instance = ModelAdapter._internal();
  factory ModelAdapter() => _instance;
  ModelAdapter._internal();

  // ISO date pattern for matching date strings
  static final RegExp _isoDatePattern = RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z?$');

  /// Converts a Supabase JSON object to a format compatible with Freezed models
  ///
  /// This handles:
  /// - Converting snake_case keys to camelCase
  /// - Converting ISO date strings to DateTime objects
  /// - Converting boolean values properly
  Map<String, dynamic> toFreezedJson(Map<String, dynamic> supabaseJson) {
    final result = <String, dynamic>{};

    supabaseJson.forEach((key, value) {
      // Convert snake_case to camelCase
      final camelCaseKey = _snakeToCamel(key);
      
      // Process value based on type
      if (value is String && _isIsoDateString(value)) {
        // Convert date strings to DateTime
        result[camelCaseKey] = DateTime.parse(value);
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested objects
        result[camelCaseKey] = toFreezedJson(value);
      } else if (value is List) {
        // Handle lists - if they contain maps, convert each item
        result[camelCaseKey] = _processListValues(value);
      } else {
        // Keep other values as-is
        result[camelCaseKey] = value;
      }
    });

    return result;
  }

  /// Converts a Freezed model JSON to a format compatible with Supabase
  ///
  /// This handles:
  /// - Converting camelCase keys to snake_case
  /// - Converting DateTime objects to ISO strings
  /// - Ensuring JSON compatibility for database operations
  Map<String, dynamic> toSupabaseJson(Map<String, dynamic> freezedJson) {
    final result = <String, dynamic>{};

    freezedJson.forEach((key, value) {
      // Skip internal Freezed fields and runtimeType
      if (key.startsWith('_\$') || key == 'runtimeType') {
        return;
      }
      
      // Convert camelCase to snake_case
      final snakeCaseKey = _camelToSnake(key);
      
      // Process value based on type
      if (value is DateTime) {
        // Convert DateTime to ISO string
        result[snakeCaseKey] = value.toUtc().toIso8601String();
      } else if (value is Map<String, dynamic>) {
        // Recursively convert nested objects
        result[snakeCaseKey] = toSupabaseJson(value);
      } else if (value is List) {
        // Handle lists - if they contain maps or DateTime objects, convert them
        result[snakeCaseKey] = _processListValues(value, toSupabase: true);
      } else {
        // Keep other values as-is
        result[snakeCaseKey] = value;
      }
    });

    return result;
  }

  /// Processes list values, handling conversions for items in the list
  List _processListValues(List list, {bool toSupabase = false}) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        // For maps, apply the appropriate conversion
        return toSupabase 
            ? toSupabaseJson(item) 
            : toFreezedJson(item);
      } else if (toSupabase && item is DateTime) {
        // For DateTime in a list, convert to ISO string
        return item.toUtc().toIso8601String();
      } else if (!toSupabase && item is String && _isIsoDateString(item)) {
        // For ISO date strings in a list, convert to DateTime
        return DateTime.parse(item);
      }
      
      // Keep other values as-is
      return item;
    }).toList();
  }

  /// Converts snake_case to camelCase
  String _snakeToCamel(String text) {
    if (text.isEmpty) return text;
    
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (Match match) => match.group(1)!.toUpperCase(),
    );
  }

  /// Converts camelCase to snake_case
  String _camelToSnake(String text) {
    if (text.isEmpty) return text;
    
    return text.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (Match match) => '_${match.group(1)!.toLowerCase()}',
    );
  }

  /// Checks if a string is in ISO date format
  bool _isIsoDateString(String text) {
    try {
      // Check if the string can be parsed as a date and matches ISO format
      final date = DateTime.parse(text);
      return _isoDatePattern.hasMatch(text);
    } catch (e) {
      return false;
    }
  }
} 