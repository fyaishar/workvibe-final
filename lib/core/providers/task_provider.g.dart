// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredTasksHash() => r'203507356ca8bcc2e4508515ab8fcceb49096438';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for accessing filtered tasks
///
/// Copied from [filteredTasks].
@ProviderFor(filteredTasks)
const filteredTasksProvider = FilteredTasksFamily();

/// Provider for accessing filtered tasks
///
/// Copied from [filteredTasks].
class FilteredTasksFamily extends Family<List<Task>> {
  /// Provider for accessing filtered tasks
  ///
  /// Copied from [filteredTasks].
  const FilteredTasksFamily();

  /// Provider for accessing filtered tasks
  ///
  /// Copied from [filteredTasks].
  FilteredTasksProvider call({
    required TaskFilter filter,
    TaskSort sort = TaskSort.creationDate,
    bool ascending = true,
  }) {
    return FilteredTasksProvider(
      filter: filter,
      sort: sort,
      ascending: ascending,
    );
  }

  @override
  FilteredTasksProvider getProviderOverride(
    covariant FilteredTasksProvider provider,
  ) {
    return call(
      filter: provider.filter,
      sort: provider.sort,
      ascending: provider.ascending,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredTasksProvider';
}

/// Provider for accessing filtered tasks
///
/// Copied from [filteredTasks].
class FilteredTasksProvider extends AutoDisposeProvider<List<Task>> {
  /// Provider for accessing filtered tasks
  ///
  /// Copied from [filteredTasks].
  FilteredTasksProvider({
    required TaskFilter filter,
    TaskSort sort = TaskSort.creationDate,
    bool ascending = true,
  }) : this._internal(
         (ref) => filteredTasks(
           ref as FilteredTasksRef,
           filter: filter,
           sort: sort,
           ascending: ascending,
         ),
         from: filteredTasksProvider,
         name: r'filteredTasksProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$filteredTasksHash,
         dependencies: FilteredTasksFamily._dependencies,
         allTransitiveDependencies:
             FilteredTasksFamily._allTransitiveDependencies,
         filter: filter,
         sort: sort,
         ascending: ascending,
       );

  FilteredTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
    required this.sort,
    required this.ascending,
  }) : super.internal();

  final TaskFilter filter;
  final TaskSort sort;
  final bool ascending;

  @override
  Override overrideWith(List<Task> Function(FilteredTasksRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FilteredTasksProvider._internal(
        (ref) => create(ref as FilteredTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
        sort: sort,
        ascending: ascending,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Task>> createElement() {
    return _FilteredTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTasksProvider &&
        other.filter == filter &&
        other.sort == sort &&
        other.ascending == ascending;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);
    hash = _SystemHash.combine(hash, sort.hashCode);
    hash = _SystemHash.combine(hash, ascending.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredTasksRef on AutoDisposeProviderRef<List<Task>> {
  /// The parameter `filter` of this provider.
  TaskFilter get filter;

  /// The parameter `sort` of this provider.
  TaskSort get sort;

  /// The parameter `ascending` of this provider.
  bool get ascending;
}

class _FilteredTasksProviderElement
    extends AutoDisposeProviderElement<List<Task>>
    with FilteredTasksRef {
  _FilteredTasksProviderElement(super.provider);

  @override
  TaskFilter get filter => (origin as FilteredTasksProvider).filter;
  @override
  TaskSort get sort => (origin as FilteredTasksProvider).sort;
  @override
  bool get ascending => (origin as FilteredTasksProvider).ascending;
}

String _$taskByIdHash() => r'14d0f6d7a09096ce6431eb8cf70a5202223178a9';

/// Provider for accessing a task by ID
///
/// Copied from [taskById].
@ProviderFor(taskById)
const taskByIdProvider = TaskByIdFamily();

/// Provider for accessing a task by ID
///
/// Copied from [taskById].
class TaskByIdFamily extends Family<Task?> {
  /// Provider for accessing a task by ID
  ///
  /// Copied from [taskById].
  const TaskByIdFamily();

  /// Provider for accessing a task by ID
  ///
  /// Copied from [taskById].
  TaskByIdProvider call(String id) {
    return TaskByIdProvider(id);
  }

  @override
  TaskByIdProvider getProviderOverride(covariant TaskByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'taskByIdProvider';
}

/// Provider for accessing a task by ID
///
/// Copied from [taskById].
class TaskByIdProvider extends AutoDisposeProvider<Task?> {
  /// Provider for accessing a task by ID
  ///
  /// Copied from [taskById].
  TaskByIdProvider(String id)
    : this._internal(
        (ref) => taskById(ref as TaskByIdRef, id),
        from: taskByIdProvider,
        name: r'taskByIdProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$taskByIdHash,
        dependencies: TaskByIdFamily._dependencies,
        allTransitiveDependencies: TaskByIdFamily._allTransitiveDependencies,
        id: id,
      );

  TaskByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(Task? Function(TaskByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: TaskByIdProvider._internal(
        (ref) => create(ref as TaskByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<Task?> createElement() {
    return _TaskByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TaskByIdRef on AutoDisposeProviderRef<Task?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _TaskByIdProviderElement extends AutoDisposeProviderElement<Task?>
    with TaskByIdRef {
  _TaskByIdProviderElement(super.provider);

  @override
  String get id => (origin as TaskByIdProvider).id;
}

String _$userTasksHash() => r'7ce14d93f35f10c8c7866d5fc62c40118a4e497e';

/// Provider for tasks assigned to the current user
///
/// Copied from [userTasks].
@ProviderFor(userTasks)
const userTasksProvider = UserTasksFamily();

/// Provider for tasks assigned to the current user
///
/// Copied from [userTasks].
class UserTasksFamily extends Family<List<Task>> {
  /// Provider for tasks assigned to the current user
  ///
  /// Copied from [userTasks].
  const UserTasksFamily();

  /// Provider for tasks assigned to the current user
  ///
  /// Copied from [userTasks].
  UserTasksProvider call(String userId) {
    return UserTasksProvider(userId);
  }

  @override
  UserTasksProvider getProviderOverride(covariant UserTasksProvider provider) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userTasksProvider';
}

/// Provider for tasks assigned to the current user
///
/// Copied from [userTasks].
class UserTasksProvider extends AutoDisposeProvider<List<Task>> {
  /// Provider for tasks assigned to the current user
  ///
  /// Copied from [userTasks].
  UserTasksProvider(String userId)
    : this._internal(
        (ref) => userTasks(ref as UserTasksRef, userId),
        from: userTasksProvider,
        name: r'userTasksProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$userTasksHash,
        dependencies: UserTasksFamily._dependencies,
        allTransitiveDependencies: UserTasksFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(List<Task> Function(UserTasksRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: UserTasksProvider._internal(
        (ref) => create(ref as UserTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Task>> createElement() {
    return _UserTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserTasksProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserTasksRef on AutoDisposeProviderRef<List<Task>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserTasksProviderElement extends AutoDisposeProviderElement<List<Task>>
    with UserTasksRef {
  _UserTasksProviderElement(super.provider);

  @override
  String get userId => (origin as UserTasksProvider).userId;
}

String _$taskNotifierHash() => r'310fb3baff896733571a27f97efc6d7fbd06c5a8';

/// Notifier for managing tasks with filtered views and sorting
///
/// Copied from [TaskNotifier].
@ProviderFor(TaskNotifier)
final taskNotifierProvider =
    AutoDisposeAsyncNotifierProvider<TaskNotifier, List<Task>>.internal(
      TaskNotifier.new,
      name: r'taskNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$taskNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TaskNotifier = AutoDisposeAsyncNotifier<List<Task>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
