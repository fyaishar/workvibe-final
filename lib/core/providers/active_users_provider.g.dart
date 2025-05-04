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
String _$focusingUsersHash() => r'774b0d2bae5ee3a5e574e06e39edb024f49ce0c8';

/// Provider for users in focus mode
///
/// Copied from [focusingUsers].
@ProviderFor(focusingUsers)
final focusingUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  focusingUsers,
  name: r'focusingUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$focusingUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FocusingUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$inMeetingUsersHash() => r'47e256b87619600dc6e6f38d397ccca6ac6e2d94';

/// Provider for users in meetings
///
/// Copied from [inMeetingUsers].
@ProviderFor(inMeetingUsers)
final inMeetingUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  inMeetingUsers,
  name: r'inMeetingUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$inMeetingUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InMeetingUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
String _$awayUsersHash() => r'14c101c4f2b6b70f1b1516ba553ec776b4a887c0';

/// Provider for away users
///
/// Copied from [awayUsers].
@ProviderFor(awayUsers)
final awayUsersProvider = AutoDisposeProvider<List<SessionInfo>>.internal(
  awayUsers,
  name: r'awayUsersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$awayUsersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AwayUsersRef = AutoDisposeProviderRef<List<SessionInfo>>;
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
