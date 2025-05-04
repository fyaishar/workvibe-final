import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// This file will be used to configure any global Riverpod settings
// and to export commonly used Riverpod types and annotations

// Re-export commonly used Riverpod types for convenience
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:riverpod_annotation/riverpod_annotation.dart';

// Part file that will contain the generated code
part 'riverpod_config.g.dart';

/// Global provider container for testing and manual provider manipulation
final providerContainer = ProviderContainer();

/// Example provider to trigger code generation
@riverpod
class Example extends _$Example {
  @override
  String build() => 'example';
}

/// Custom Riverpod observer for logging state changes during development
class RiverpodLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "oldValue": "$previousValue",
  "newValue": "$newValue"
}''');
  }

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "initialValue": "$value"
}''');
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    print('''
{
  "provider": "${provider.name ?? provider.runtimeType}",
  "action": "disposed"
}''');
  }
} 