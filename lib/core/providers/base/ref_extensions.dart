import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_async_notifier.dart';

/// Extension methods for WidgetRef to handle async state
extension AsyncStateRef on WidgetRef {
  /// Watch an async state and return its data
  T? watchData<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return watch(provider).data;
  }

  /// Watch an async state and return whether it's loading
  bool watchIsLoading<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return watch(provider).isLoading;
  }

  /// Watch an async state and return its error
  Object? watchError<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return watch(provider).error;
  }

  /// Watch an async state and return whether it has data
  bool watchHasData<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return watch(provider).hasData;
  }

  /// Watch an async state and return whether it has an error
  bool watchHasError<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return watch(provider).hasError;
  }

  /// Read an async state's data
  T? readData<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return read(provider).data;
  }

  /// Read whether an async state is loading
  bool readIsLoading<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return read(provider).isLoading;
  }

  /// Read an async state's error
  Object? readError<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return read(provider).error;
  }

  /// Read whether an async state has data
  bool readHasData<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return read(provider).hasData;
  }

  /// Read whether an async state has an error
  bool readHasError<T>(StateNotifierProvider<BaseAsyncNotifier<T>, AsyncState<T>> provider) {
    return read(provider).hasError;
  }
} 