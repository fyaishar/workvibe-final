import 'package:flutter/foundation.dart';
import 'base_async_notifier.dart';

/// Interface for entities with an ID
abstract class Identifiable {
  String get id;
}

/// Base class for CRUD operations on a collection of items
abstract class BaseCrudNotifier<T extends Identifiable> extends BaseAsyncNotifier<List<T>> {
  BaseCrudNotifier() : super();

  /// Create a new item
  @protected
  Future<void> create(T item) async {
    await runAsync(() async {
      final currentItems = state.data ?? [];
      final items = [...currentItems, item];
      await saveItems(items);
      return items;
    });
  }

  /// Read all items
  @protected
  Future<void> readAll() async {
    await runAsync(() async {
      final items = await loadItems();
      return items;
    });
  }

  /// Update an existing item
  @protected
  Future<void> update(T item) async {
    await runAsync(() async {
      final currentItems = state.data ?? [];
      final items = currentItems.map((existing) {
        return existing.id == item.id ? item : existing;
      }).toList();
      await saveItems(items);
      return items;
    });
  }

  /// Delete an item by ID
  @protected
  Future<void> delete(String id) async {
    await runAsync(() async {
      final currentItems = state.data ?? [];
      final items = currentItems.where((item) => item.id != id).toList();
      await saveItems(items);
      return items;
    });
  }

  /// Batch update multiple items
  @protected
  Future<void> batchUpdate(List<T> updatedItems) async {
    await runAsync(() async {
      final currentItems = state.data ?? [];
      final itemMap = Map.fromEntries(
        currentItems.map((item) => MapEntry(item.id, item)),
      );

      for (final item in updatedItems) {
        itemMap[item.id] = item;
      }

      final items = itemMap.values.toList();
      await saveItems(items);
      return items;
    });
  }

  /// Save items to persistent storage
  @protected
  Future<void> saveItems(List<T> items);

  /// Load items from persistent storage
  @protected
  Future<List<T>> loadItems();

  /// Get an item by ID
  T? getById(String id) {
    return state.data?.firstWhere(
      (item) => item.id == id,
      orElse: () => throw Exception('Item not found: $id'),
    );
  }

  /// Check if an item exists
  bool exists(String id) {
    return state.data?.any((item) => item.id == id) ?? false;
  }

  /// Get all items that match a predicate
  List<T> where(bool Function(T item) predicate) {
    return state.data?.where(predicate).toList() ?? [];
  }

  /// Sort items using a comparison function
  void sort(int Function(T a, T b) compare) {
    if (state.data != null) {
      state = state.withData([...state.data!]..sort(compare));
    }
  }
} 