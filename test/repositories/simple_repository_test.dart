import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

// Simple mock classes for testing repository pattern
class SimpleSupabaseClient {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  
  SimpleQueryBuilder from(String table) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    return SimpleQueryBuilder(this, table);
  }
  
  // Helper method for tests to directly insert data
  void addRecord(String table, Map<String, dynamic> data) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    _tables[table]?.add(data);
  }
}

class SimpleQueryBuilder {
  final SimpleSupabaseClient _client;
  final String _table;
  
  SimpleQueryBuilder(this._client, this._table);
  
  SimpleFilterBuilder select() {
    return SimpleFilterBuilder(_client, _table);
  }
  
  SimpleFilterBuilder update(Map<String, dynamic> data) {
    return SimpleFilterBuilder(_client, _table, updateData: data);
  }
  
  SimpleFilterBuilder delete() {
    return SimpleFilterBuilder(_client, _table, isDelete: true);
  }
  
  SimpleInsertBuilder insert(Map<String, dynamic> data) {
    return SimpleInsertBuilder(_client, _table, data);
  }
}

class SimpleInsertBuilder {
  final SimpleSupabaseClient _client;
  final String _table;
  final Map<String, dynamic> _data;
  
  SimpleInsertBuilder(this._client, this._table, this._data);
  
  SimpleFilterBuilder select() {
    // First insert the data, then return filter builder for select
    _client._tables[_table]?.add(_data);
    return SimpleFilterBuilder(_client, _table).eq('id', _data['id']);
  }
}

class SimpleFilterBuilder {
  final SimpleSupabaseClient _client;
  final String _table;
  final Map<String, dynamic>? updateData;
  final bool isDelete;
  Map<String, dynamic> _filters = {};
  
  SimpleFilterBuilder(
    this._client, 
    this._table, {
    this.updateData,
    this.isDelete = false
  });
  
  SimpleFilterBuilder eq(String field, dynamic value) {
    _filters[field] = value;
    return this;
  }
  
  Future<List<Map<String, dynamic>>> execute() async {
    final data = _client._tables[_table] ?? [];
    
    // Apply filters
    final filteredData = data.where((item) {
      if (_filters.isEmpty) return true;
      
      return _filters.entries.every((filter) {
        return item[filter.key] == filter.value;
      });
    }).toList();
    
    // Handle delete operation
    if (isDelete) {
      for (final item in filteredData) {
        _client._tables[_table]?.remove(item);
      }
      return filteredData;
    }
    
    // Handle update operation
    if (updateData != null) {
      for (final item in filteredData) {
        final index = _client._tables[_table]?.indexOf(item) ?? -1;
        if (index >= 0) {
          _client._tables[_table]?[index] = {
            ...item,
            ...updateData!,
          };
        }
      }
      
      return filteredData.map((item) {
        final id = item['id'];
        return _client._tables[_table]?.firstWhere((e) => e['id'] == id) ?? item;
      }).toList();
    }
    
    return filteredData;
  }
  
  Future<Map<String, dynamic>> single() async {
    final results = await execute();
    if (results.isEmpty) {
      throw Exception('No record found');
    }
    return results.first;
  }
}

// Simple User model
class SimpleUser {
  final String id;
  final String name;
  final String email;
  
  SimpleUser({required this.id, required this.name, required this.email});
  
  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
  
  SimpleUser copyWith({String? id, String? name, String? email}) {
    return SimpleUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }
}

// Simple repository interface
abstract class SimpleRepository<T> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<bool> delete(String id);
}

// Repository implementation
class SimpleUserRepository implements SimpleRepository<SimpleUser> {
  final SimpleSupabaseClient _client;
  final String _tableName = 'users';
  
  SimpleUserRepository(this._client);
  
  @override
  Future<SimpleUser> create(SimpleUser entity) async {
    final result = await _client.from(_tableName)
        .insert(entity.toJson())
        .select()
        .single();
    
    return SimpleUser.fromJson(result);
  }
  
  @override
  Future<bool> delete(String id) async {
    await _client.from(_tableName)
        .delete()
        .eq('id', id)
        .execute();
    
    return true;
  }
  
  @override
  Future<List<SimpleUser>> getAll() async {
    final result = await _client.from(_tableName)
        .select()
        .execute();
    
    return result.map((json) => SimpleUser.fromJson(json)).toList();
  }
  
  @override
  Future<SimpleUser?> getById(String id) async {
    try {
      final result = await _client.from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return SimpleUser.fromJson(result);
    } catch (e) {
      if (e.toString().contains('No record found')) {
        return null;
      }
      rethrow;
    }
  }
  
  @override
  Future<SimpleUser> update(SimpleUser entity) async {
    final result = await _client.from(_tableName)
        .update(entity.toJson())
        .eq('id', entity.id)
        .single();
    
    return SimpleUser.fromJson(result);
  }
  
  // User-specific methods
  Future<SimpleUser?> getByEmail(String email) async {
    try {
      final result = await _client.from(_tableName)
          .select()
          .eq('email', email)
          .single();
      
      return SimpleUser.fromJson(result);
    } catch (e) {
      if (e.toString().contains('No record found')) {
        return null;
      }
      rethrow;
    }
  }
}

void main() {
  late SimpleSupabaseClient client;
  late SimpleUserRepository repository;
  
  setUp(() {
    client = SimpleSupabaseClient();
    repository = SimpleUserRepository(client);
    
    // Add test data
    client.addRecord('users', {
      'id': 'user-1',
      'name': 'Test User',
      'email': 'test@example.com'
    });
    
    client.addRecord('users', {
      'id': 'user-2',
      'name': 'Another User',
      'email': 'another@example.com'
    });
  });
  
  group('SimpleUserRepository', () {
    test('getById returns correct user', () async {
      final user = await repository.getById('user-1');
      
      expect(user, isNotNull);
      expect(user?.id, equals('user-1'));
      expect(user?.name, equals('Test User'));
      expect(user?.email, equals('test@example.com'));
    });
    
    test('getById returns null for non-existent user', () async {
      final user = await repository.getById('non-existent');
      
      expect(user, isNull);
    });
    
    test('getAll returns all users', () async {
      final users = await repository.getAll();
      
      expect(users.length, equals(2));
      expect(users.any((u) => u.id == 'user-1'), isTrue);
      expect(users.any((u) => u.id == 'user-2'), isTrue);
    });
    
    test('create adds a new user', () async {
      final newUser = SimpleUser(
        id: 'user-3',
        name: 'New User',
        email: 'new@example.com'
      );
      
      final createdUser = await repository.create(newUser);
      
      expect(createdUser.id, equals('user-3'));
      expect(createdUser.name, equals('New User'));
      
      // Verify user was added to repository
      final users = await repository.getAll();
      expect(users.length, equals(3));
      expect(users.any((u) => u.id == 'user-3'), isTrue);
    });
    
    test('update modifies existing user', () async {
      // First get the user
      final user = await repository.getById('user-1');
      expect(user, isNotNull);
      
      // Update the user
      final updatedUser = await repository.update(
        user!.copyWith(name: 'Updated Name')
      );
      
      expect(updatedUser.id, equals('user-1'));
      expect(updatedUser.name, equals('Updated Name'));
      expect(updatedUser.email, equals('test@example.com')); // Unchanged
      
      // Verify user was updated in repository
      final refreshedUser = await repository.getById('user-1');
      expect(refreshedUser?.name, equals('Updated Name'));
    });
    
    test('delete removes user', () async {
      final result = await repository.delete('user-1');
      
      expect(result, isTrue);
      
      // Verify user was removed from repository
      final user = await repository.getById('user-1');
      expect(user, isNull);
      
      final users = await repository.getAll();
      expect(users.length, equals(1));
      expect(users.any((u) => u.id == 'user-1'), isFalse);
    });
    
    test('getByEmail returns correct user', () async {
      final user = await repository.getByEmail('test@example.com');
      
      expect(user, isNotNull);
      expect(user?.id, equals('user-1'));
      expect(user?.name, equals('Test User'));
    });
    
    test('getByEmail returns null for non-existent email', () async {
      final user = await repository.getByEmail('non-existent@example.com');
      
      expect(user, isNull);
    });
  });
} 