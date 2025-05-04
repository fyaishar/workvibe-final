import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the state of an asynchronous operation
class AsyncState<T> {
  final bool isLoading;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const AsyncState({
    this.isLoading = false,
    this.data,
    this.error,
    this.stackTrace,
  });

  /// Create a loading state
  AsyncState<T> loading() => AsyncState<T>(
    isLoading: true,
    data: data,
  );

  /// Create a data state
  AsyncState<T> withData(T newData) => AsyncState<T>(
    data: newData,
  );

  /// Create an error state
  AsyncState<T> withError(Object error, [StackTrace? stackTrace]) => AsyncState<T>(
    error: error,
    stackTrace: stackTrace,
    data: data,
  );

  /// Check if the state has data
  bool get hasData => data != null;

  /// Check if the state has an error
  bool get hasError => error != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AsyncState<T> &&
      other.isLoading == isLoading &&
      other.data == data &&
      other.error == error &&
      other.stackTrace == stackTrace;
  }

  @override
  int get hashCode => Object.hash(isLoading, data, error, stackTrace);
}

/// Base class for state notifiers that handle asynchronous operations
abstract class BaseAsyncNotifier<T> extends StateNotifier<AsyncState<T>> {
  BaseAsyncNotifier() : super(AsyncState<T>());

  /// Run an async operation and handle its state
  @protected
  Future<void> runAsync(Future<T> Function() operation) async {
    try {
      state = state.loading();
      final result = await operation();
      state = state.withData(result);
    } catch (error, stackTrace) {
      state = state.withError(error, stackTrace);
      debugPrint('Error in ${runtimeType.toString()}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Run an async operation without loading state
  @protected
  Future<void> runAsyncQuiet(Future<T> Function() operation) async {
    try {
      final result = await operation();
      state = state.withData(result);
    } catch (error, stackTrace) {
      state = state.withError(error, stackTrace);
      debugPrint('Error in ${runtimeType.toString()}: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /// Clear any error state
  @protected
  void clearError() {
    state = AsyncState(data: state.data);
  }

  /// Reset to initial state
  @protected
  void reset() {
    state = const AsyncState();
  }
} 