// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_users_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeUsersHash() => r'f7ad8504a545a99d0ccd5a59d4516dccff3a06ed';

/// Provider for all active users
///
/// Copied from [activeUsers].
@ProviderFor(activeUsers)
final activeUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  activeUsers,
  name: r'activeUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$activeUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$onlineUsersHash() => r'4dbd3b16622382b4805efafd1bab6caa86a716ca';

/// Provider for online users only
///
/// Copied from [onlineUsers].
@ProviderFor(onlineUsers)
final onlineUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  onlineUsers,
  name: r'onlineUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$onlineUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OnlineUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$pausedUsersHash() => r'c37665c2807e6ca40ba04556c0fb927fcbecfb73';

/// Provider for users who are paused
///
/// Copied from [pausedUsers].
@ProviderFor(pausedUsers)
final pausedUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  pausedUsers,
  name: r'pausedUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pausedUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PausedUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$idleUsersHash() => r'6e46dc666affabb9134c7dc88038da175eef2384';

/// Provider for idle users
///
/// Copied from [idleUsers].
@ProviderFor(idleUsers)
final idleUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  idleUsers,
  name: r'idleUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$idleUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IdleUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$activeUsersNotifierHash() =>
    r'a89d531b40bcc297bdcbb3da5f8d2066d5847b12';

/// Notifier class for managing the list of active users in the system
///
/// Copied from [ActiveUsersNotifier].
@ProviderFor(ActiveUsersNotifier)
final activeUsersNotifierProvider = AutoDisposeNotifierProvider<
  ActiveUsersNotifier,
  List<SessionInfo>
>.internal(
  ActiveUsersNotifier.new,
  name: r'activeUsersNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeUsersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveUsersNotifier = AutoDisposeNotifier<List<SessionInfo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
