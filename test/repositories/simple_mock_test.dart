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
    return SimpleFilterBuilder(_client, _table);
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

void main() {
  late SimpleSupabaseClient client;
  
  setUp(() {
    client = SimpleSupabaseClient();
    
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
  
  group('SimpleSupabaseClient', () {
    test('select returns all records', () async {
      final result = await client.from('users').select().execute();
      
      expect(result.length, equals(2));
      expect(result[0]['id'], equals('user-1'));
      expect(result[1]['id'], equals('user-2'));
    });
    
    test('select with filter returns matching records', () async {
      final result = await client.from('users').select().eq('id', 'user-1').execute();
      
      expect(result.length, equals(1));
      expect(result[0]['id'], equals('user-1'));
      expect(result[0]['name'], equals('Test User'));
    });
    
    test('single returns one record', () async {
      final result = await client.from('users').select().eq('id', 'user-1').single();
      
      expect(result['id'], equals('user-1'));
      expect(result['name'], equals('Test User'));
    });
    
    test('update modifies record', () async {
      await client.from('users').update({'name': 'Updated User'}).eq('id', 'user-1').execute();
      
      final result = await client.from('users').select().eq('id', 'user-1').single();
      expect(result['name'], equals('Updated User'));
      expect(result['email'], equals('test@example.com')); // Unchanged field
    });
    
    test('insert adds new record', () async {
      await client.from('users').insert({
        'id': 'user-3',
        'name': 'New User',
        'email': 'new@example.com'
      }).select();
      
      final result = await client.from('users').select().execute();
      expect(result.length, equals(3));
      
      final newUser = await client.from('users').select().eq('id', 'user-3').single();
      expect(newUser['name'], equals('New User'));
    });
    
    test('delete removes record', () async {
      await client.from('users').delete().eq('id', 'user-1').execute();
      
      final result = await client.from('users').select().execute();
      expect(result.length, equals(1));
      expect(result[0]['id'], equals('user-2'));
    });
  });
} 