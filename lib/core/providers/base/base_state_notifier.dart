import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for state notifiers with common functionality
abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  BaseStateNotifier(T initialState) : super(initialState);

  /// Update the state with a new value
  @protected
  void updateState(T newState) {
    state = newState;
  }

  /// Update part of the state using a callback
  @protected
  void updateStateWith(T Function(T currentState) updater) {
    state = updater(state);
  }

  /// Reset the state to its initial value
  @protected
  void resetState() {
    state = initialState;
  }

  /// Get the initial state value
  @protected
  T get initialState;
} 