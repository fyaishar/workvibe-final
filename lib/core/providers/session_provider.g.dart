// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentSessionHash() => r'6ee3e64f5ed22801a6964423edf70f7f6a6cffbd';

/// Provider for the current user's session information
///
/// Copied from [currentSession].
@ProviderFor(currentSession)
final currentSessionProvider = AutoDisposeProvider<SessionInfo?>.internal(
  currentSession,
  name: r'currentSessionProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentSessionRef = AutoDisposeProviderRef<SessionInfo?>;
String _$isLoggedInHash() => r'35ba1eef3e730d1700494f3a7f3582277651e1be';

/// Provider that exposes whether the user is currently logged in
///
/// Copied from [isLoggedIn].
@ProviderFor(isLoggedIn)
final isLoggedInProvider = AutoDisposeProvider<bool>.internal(
  isLoggedIn,
  name: r'isLoggedInProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isLoggedInHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsLoggedInRef = AutoDisposeProviderRef<bool>;
String _$currentUserStatusHash() => r'c801049909a86457b9d2d6d55e2c627598c3b917';

/// Provider that exposes the current user's status
///
/// Copied from [currentUserStatus].
@ProviderFor(currentUserStatus)
final currentUserStatusProvider = AutoDisposeProvider<UserStatus?>.internal(
  currentUserStatus,
  name: r'currentUserStatusProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentUserStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserStatusRef = AutoDisposeProviderRef<UserStatus?>;
String _$sessionNotifierHash() => r'6d6f3b967d5d6f4537eece7551d2a22c055952d3';

/// Notifier class for managing the current user's session state
///
/// Copied from [SessionNotifier].
@ProviderFor(SessionNotifier)
final sessionNotifierProvider =
    AutoDisposeNotifierProvider<SessionNotifier, SessionInfo?>.internal(
      SessionNotifier.new,
      name: r'sessionNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$sessionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SessionNotifier = AutoDisposeNotifier<SessionInfo?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
