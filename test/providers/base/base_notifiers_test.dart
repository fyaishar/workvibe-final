import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalworkvibe/core/providers/base/base_state_notifier.dart';
import 'package:finalworkvibe/core/providers/base/base_async_notifier.dart';
import 'package:finalworkvibe/core/providers/base/base_crud_notifier.dart';

// Test implementation of BaseStateNotifier
class TestStateNotifier extends BaseStateNotifier<int> {
  TestStateNotifier() : super(0);

  void increment() => updateState(state + 1);
  void update(int Function(int) updater) => updateStateWith(updater);
  
  @override
  int get initialState => 0;
}

// Test implementation of BaseAsyncNotifier
class TestAsyncNotifier extends BaseAsyncNotifier<String> {
  Future<void> loadData(bool shouldSucceed) async {
    await runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!shouldSucceed) throw Exception('Test error');
      return 'Test data';
    });
  }

  Future<void> loadQuiet(bool shouldSucceed) async {
    await runAsyncQuiet(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!shouldSucceed) throw Exception('Test error');
      return 'Test data';
    });
  }
}

// Test implementation of BaseCrudNotifier
class TestItem implements Identifiable {
  @override
  final String id;
  final String name;

  TestItem(this.id, this.name);
}

class TestCrudNotifier extends BaseCrudNotifier<TestItem> {
  final List<TestItem> _items = [];

  @override
  Future<List<TestItem>> loadItems() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _items;
  }

  @override
  Future<void> saveItems(List<TestItem> items) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _items
      ..clear()
      ..addAll(items);
  }
}

void main() {
  group('BaseStateNotifier Tests', () {
    late ProviderContainer container;
    late StateNotifierProvider<TestStateNotifier, int> provider;

    setUp(() {
      container = ProviderContainer();
      provider = StateNotifierProvider<TestStateNotifier, int>((ref) {
        return TestStateNotifier();
      });
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be correct', () {
      expect(container.read(provider), 0);
    });

    test('updateState should work', () {
      container.read(provider.notifier).increment();
      expect(container.read(provider), 1);
    });

    test('updateStateWith should work', () {
      container.read(provider.notifier).update((state) => state + 2);
      expect(container.read(provider), 2);
    });

    test('resetState should work', () {
      container.read(provider.notifier)
        ..increment()
        ..increment()
        ..resetState();
      expect(container.read(provider), 0);
    });
  });

  group('BaseAsyncNotifier Tests', () {
    late ProviderContainer container;
    late StateNotifierProvider<TestAsyncNotifier, AsyncState<String>> provider;

    setUp(() {
      container = ProviderContainer();
      provider = StateNotifierProvider<TestAsyncNotifier, AsyncState<String>>((ref) {
        return TestAsyncNotifier();
      });
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be correct', () {
      final state = container.read(provider);
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.error, null);
    });

    test('runAsync should handle success', () async {
      container.read(provider.notifier).loadData(true);
      
      // Should be loading
      expect(container.read(provider).isLoading, true);
      
      // Wait for operation to complete
      await Future.delayed(const Duration(milliseconds: 150));
      
      final state = container.read(provider);
      expect(state.isLoading, false);
      expect(state.data, 'Test data');
      expect(state.error, null);
    });

    test('runAsync should handle error', () async {
      container.read(provider.notifier).loadData(false);
      
      // Should be loading
      expect(container.read(provider).isLoading, true);
      
      // Wait for operation to complete
      await Future.delayed(const Duration(milliseconds: 150));
      
      final state = container.read(provider);
      expect(state.isLoading, false);
      expect(state.data, null);
      expect(state.error, isA<Exception>());
      expect((state.error as Exception).toString(), 'Exception: Test error');
    });

    test('runAsyncQuiet should not show loading state', () async {
      container.read(provider.notifier).loadQuiet(true);
      
      // Should not be loading
      expect(container.read(provider).isLoading, false);
      
      // Wait for operation to complete
      await Future.delayed(const Duration(milliseconds: 150));
      
      final state = container.read(provider);
      expect(state.isLoading, false);
      expect(state.data, 'Test data');
      expect(state.error, null);
    });
  });

  group('BaseCrudNotifier Tests', () {
    late ProviderContainer container;
    late StateNotifierProvider<TestCrudNotifier, AsyncState<List<TestItem>>> provider;

    setUp(() {
      container = ProviderContainer();
      provider = StateNotifierProvider<TestCrudNotifier, AsyncState<List<TestItem>>>((ref) {
        return TestCrudNotifier();
      });
    });

    tearDown(() {
      container.dispose();
    });

    test('create should add new item', () async {
      final item = TestItem('1', 'Test Item');
      await container.read(provider.notifier).create(item);
      
      final state = container.read(provider);
      expect(state.data?.length, 1);
      expect(state.data?.first.id, '1');
      expect(state.data?.first.name, 'Test Item');
    });

    test('update should modify existing item', () async {
      final item = TestItem('1', 'Test Item');
      await container.read(provider.notifier).create(item);
      
      final updatedItem = TestItem('1', 'Updated Item');
      await container.read(provider.notifier).update(updatedItem);
      
      final state = container.read(provider);
      expect(state.data?.length, 1);
      expect(state.data?.first.name, 'Updated Item');
    });

    test('delete should remove item', () async {
      final item = TestItem('1', 'Test Item');
      await container.read(provider.notifier).create(item);
      await container.read(provider.notifier).delete('1');
      
      final state = container.read(provider);
      expect(state.data?.isEmpty, true);
    });

    test('batchUpdate should update multiple items', () async {
      final items = [
        TestItem('1', 'Item 1'),
        TestItem('2', 'Item 2'),
      ];
      
      for (final item in items) {
        await container.read(provider.notifier).create(item);
      }
      
      final updates = [
        TestItem('1', 'Updated 1'),
        TestItem('2', 'Updated 2'),
      ];
      
      await container.read(provider.notifier).batchUpdate(updates);
      
      final state = container.read(provider);
      expect(state.data?.length, 2);
      expect(state.data?[0].name, 'Updated 1');
      expect(state.data?[1].name, 'Updated 2');
    });

    test('getById should return correct item', () async {
      final items = [
        TestItem('1', 'Item 1'),
        TestItem('2', 'Item 2'),
      ];
      
      for (final item in items) {
        await container.read(provider.notifier).create(item);
      }
      
      final item = container.read(provider.notifier).getById('2');
      expect(item?.name, 'Item 2');
    });

    test('exists should work correctly', () async {
      final item = TestItem('1', 'Test Item');
      await container.read(provider.notifier).create(item);
      
      expect(container.read(provider.notifier).exists('1'), true);
      expect(container.read(provider.notifier).exists('2'), false);
    });

    test('where should filter items correctly', () async {
      final items = [
        TestItem('1', 'Apple'),
        TestItem('2', 'Banana'),
        TestItem('3', 'Apple'),
      ];
      
      for (final item in items) {
        await container.read(provider.notifier).create(item);
      }
      
      final apples = container.read(provider.notifier)
        .where((item) => item.name == 'Apple');
      
      expect(apples.length, 2);
      expect(apples.every((item) => item.name == 'Apple'), true);
    });

    test('sort should order items correctly', () async {
      final items = [
        TestItem('1', 'Zebra'),
        TestItem('2', 'Apple'),
        TestItem('3', 'Banana'),
      ];
      
      for (final item in items) {
        await container.read(provider.notifier).create(item);
      }
      
      container.read(provider.notifier)
        .sort((a, b) => a.name.compareTo(b.name));
      
      final state = container.read(provider);
      expect(state.data?[0].name, 'Apple');
      expect(state.data?[1].name, 'Banana');
      expect(state.data?[2].name, 'Zebra');
    });
  });
} 