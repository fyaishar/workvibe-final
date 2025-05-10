import 'dart:async';

// Define a simple enum for PostgresChangeEvent
enum PostgresChangeEvent {
  insert,
  update,
  delete,
  all,
}

// Simple payload class for realtime changes
class RealtimeChangePayload {
  final PostgresChangeEvent eventType;
  final String table;
  final Map<String, dynamic>? newRecord;
  final Map<String, dynamic>? oldRecord;
  
  RealtimeChangePayload({
    required this.eventType,
    required this.table,
    this.newRecord,
    this.oldRecord,
  });
}

// Simple mock database client
class MockSupabaseClient {
  final Map<String, List<Map<String, dynamic>>> _tables = {};
  final Map<String, StreamController<RealtimeChangePayload>> _subscriptions = {};
  
  // Get access to a table
  MockQueryBuilder from(String table) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    
    return MockQueryBuilder(this, table);
  }
  
  // Create a subscription channel
  MockChannel channel(String name) {
    return MockChannel(this, name);
  }
  
  // Remove a channel
  void removeChannel(MockChannel channel) {
    final subscription = _subscriptions[channel.name];
    if (subscription != null && !subscription.isClosed) {
      subscription.close();
      _subscriptions.remove(channel.name);
    }
  }
  
  // Method to simulate insert into a table for testing
  void simulateInsert(String table, Map<String, dynamic> record) {
    if (!_tables.containsKey(table)) {
      _tables[table] = [];
    }
    
    // Add record to table
    _tables[table]!.add(record);
    
    // Notify subscribers
    _notifySubscribers(
      table, 
      PostgresChangeEvent.insert, 
      record, 
      null,
    );
  }
  
  // Method to simulate updates to a table for testing
  void simulateUpdate(String table, String id, Map<String, dynamic> updatedRecord) {
    if (!_tables.containsKey(table)) return;
    
    final oldRecordIndex = _tables[table]!.indexWhere((r) => r['id'] == id);
    Map<String, dynamic>? oldRecord;
    
    if (oldRecordIndex >= 0) {
      oldRecord = Map.from(_tables[table]![oldRecordIndex]);
      _tables[table]![oldRecordIndex] = updatedRecord;
    } else {
      _tables[table]!.add(updatedRecord);
    }
    
    // Notify subscribers
    _notifySubscribers(
      table, 
      PostgresChangeEvent.update, 
      updatedRecord, 
      oldRecord,
    );
  }
  
  // Method to simulate deletions from a table for testing
  void simulateDelete(String table, String id) {
    if (!_tables.containsKey(table)) return;
    
    final oldRecordIndex = _tables[table]!.indexWhere((r) => r['id'] == id);
    Map<String, dynamic>? oldRecord;
    
    if (oldRecordIndex >= 0) {
      oldRecord = _tables[table]![oldRecordIndex];
      _tables[table]!.removeAt(oldRecordIndex);
    }
    
    if (oldRecord != null) {
      // Notify subscribers
      _notifySubscribers(
        table, 
        PostgresChangeEvent.delete, 
        null, 
        oldRecord,
      );
    }
  }
  
  // Helper to notify subscribers
  void _notifySubscribers(
    String table,
    PostgresChangeEvent eventType,
    Map<String, dynamic>? newRecord,
    Map<String, dynamic>? oldRecord,
  ) {
    final subscriptionKeys = _subscriptions.keys
        .where((key) => key.contains(table))
        .toList();
    
    for (final key in subscriptionKeys) {
      final subscription = _subscriptions[key];
      if (subscription != null && !subscription.isClosed) {
        final String? recordId = newRecord?['id'] ?? oldRecord?['id'];
        
        // For id-specific subscriptions, only notify if the ID matches
        if (key.contains(':id_') && !key.contains(recordId!)) {
          continue;
        }
        
        final payload = RealtimeChangePayload(
          eventType: eventType,
          table: table,
          newRecord: newRecord,
          oldRecord: oldRecord,
        );
        
        subscription.add(payload);
      }
    }
  }
  
  void setupSubscription(String channelName) {
    if (!_subscriptions.containsKey(channelName)) {
      _subscriptions[channelName] = StreamController<RealtimeChangePayload>.broadcast();
    }
  }
  
  StreamController<RealtimeChangePayload>? getSubscription(String channelName) {
    return _subscriptions[channelName];
  }
}

class MockQueryBuilder {
  final MockSupabaseClient _client;
  final String _table;
  
  MockQueryBuilder(this._client, this._table);
  
  MockFilterBuilder select() {
    return MockFilterBuilder(_client, _table);
  }
  
  MockFilterBuilder delete() {
    return MockFilterBuilder(_client, _table, isDelete: true);
  }
  
  MockFilterBuilder update(Map<String, dynamic> updateValues) {
    return MockFilterBuilder(_client, _table, updateValues: updateValues);
  }
  
  MockInsertBuilder insert(dynamic values) {
    return MockInsertBuilder(_client, _table, values);
  }
}

class MockInsertBuilder {
  final MockSupabaseClient _client;
  final String _table;
  final dynamic _values;
  
  MockInsertBuilder(this._client, this._table, this._values);
  
  MockFilterBuilder select() {
    if (_values is List) {
      for (final value in _values) {
        final Map<String, dynamic> record = {...value};
        if (!record.containsKey('id')) {
          record['id'] = 'test-${DateTime.now().millisecondsSinceEpoch}-${_client._tables[_table]!.length}';
        }
        _client._tables[_table]!.add(record);
      }
    } else if (_values is Map<String, dynamic>) {
      final Map<String, dynamic> record = {..._values};
      if (!record.containsKey('id')) {
        record['id'] = 'test-${DateTime.now().millisecondsSinceEpoch}';
      }
      _client._tables[_table]!.add(record);
      
      return MockFilterBuilder(_client, _table).eq('id', record['id']);
    }
    
    return MockFilterBuilder(_client, _table);
  }
}

class MockFilterBuilder {
  final MockSupabaseClient _client;
  final String _table;
  final bool isDelete;
  final Map<String, dynamic>? updateValues;
  
  Map<String, dynamic> _filters = {};
  bool _isSingle = false;
  
  MockFilterBuilder(
    this._client, 
    this._table, {
    this.isDelete = false,
    this.updateValues,
  });
  
  MockFilterBuilder eq(String column, dynamic value) {
    _filters[column] = value;
    return this;
  }
  
  Future<Map<String, dynamic>> single() async {
    final result = await execute();
    if (result.isEmpty) {
      throw Exception('No record found');
    }
    return result.first;
  }
  
  Future<List<Map<String, dynamic>>> execute() async {
    final filteredData = _client._tables[_table]!.where((record) {
      if (_filters.isEmpty) return true;
      
      return _filters.entries.every((filter) {
        final key = filter.key;
        final value = filter.value;
        
        if (key.contains('.in')) {
          final field = key.split('.').first;
          final List valueList = value as List;
          return valueList.contains(record[field]);
        }
        
        return record[key] == value;
      });
    }).toList();
    
    if (isDelete) {
      // Process delete operation
      for (final record in filteredData) {
        final recordId = record['id'];
        _client._tables[_table]!.removeWhere((r) => r['id'] == recordId);
      }
      
      return filteredData;
    } else if (updateValues != null) {
      // Process update operation
      for (final record in filteredData) {
        final index = _client._tables[_table]!.indexWhere((r) => r['id'] == record['id']);
        if (index >= 0) {
          _client._tables[_table]![index] = {
            ..._client._tables[_table]![index],
            ...updateValues!,
          };
        }
      }
      
      return filteredData.map((rec) {
        final index = _client._tables[_table]!.indexWhere((r) => r['id'] == rec['id']);
        return _client._tables[_table]![index];
      }).toList();
    }
    
    if (_isSingle && filteredData.isEmpty) {
      throw Exception('No record found');
    }
    
    return filteredData;
  }
}

class MockChannel {
  final MockSupabaseClient _client;
  final String name;
  bool _isSubscribed = false;
  
  MockChannel(this._client, this.name);
  
  MockChannel on(
    String event,
    dynamic filter,
    Function callback,
  ) {
    return this;
  }
  
  MockChannel onPostgresChanges({
    required PostgresChangeEvent event,
    required String schema,
    required String table,
    dynamic filter,
    required Function(RealtimeChangePayload) callback,
  }) {
    // Create channel name
    final String channelName = name;
    
    // Setup subscription
    _client.setupSubscription(channelName);
    
    // Listen to subscription events
    final subscription = _client.getSubscription(channelName);
    if (subscription != null) {
      subscription.stream.listen((payload) {
        if (payload.eventType == event || event == PostgresChangeEvent.all) {
          callback(payload);
        }
      });
    }
    
    return this;
  }
  
  MockChannel subscribe([Function? callback]) {
    _isSubscribed = true;
    if (callback != null) {
      callback('SUBSCRIBED');
    }
    return this;
  }
  
  void unsubscribe() {
    _isSubscribed = false;
    _client.removeChannel(this);
  }
} 