// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$filteredProjectsHash() => r'21b5a52647eaa26b2c71b5a95663a35d39104762';

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

/// Provider for accessing filtered projects
///
/// Copied from [filteredProjects].
@ProviderFor(filteredProjects)
const filteredProjectsProvider = FilteredProjectsFamily();

/// Provider for accessing filtered projects
///
/// Copied from [filteredProjects].
class FilteredProjectsFamily extends Family<List<Project>> {
  /// Provider for accessing filtered projects
  ///
  /// Copied from [filteredProjects].
  const FilteredProjectsFamily();

  /// Provider for accessing filtered projects
  ///
  /// Copied from [filteredProjects].
  FilteredProjectsProvider call({
    required ProjectFilter filter,
    ProjectSort sort = ProjectSort.creationDate,
    bool ascending = true,
  }) {
    return FilteredProjectsProvider(
      filter: filter,
      sort: sort,
      ascending: ascending,
    );
  }

  @override
  FilteredProjectsProvider getProviderOverride(
    covariant FilteredProjectsProvider provider,
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
  String? get name => r'filteredProjectsProvider';
}

/// Provider for accessing filtered projects
///
/// Copied from [filteredProjects].
class FilteredProjectsProvider extends AutoDisposeProvider<List<Project>> {
  /// Provider for accessing filtered projects
  ///
  /// Copied from [filteredProjects].
  FilteredProjectsProvider({
    required ProjectFilter filter,
    ProjectSort sort = ProjectSort.creationDate,
    bool ascending = true,
  }) : this._internal(
         (ref) => filteredProjects(
           ref as FilteredProjectsRef,
           filter: filter,
           sort: sort,
           ascending: ascending,
         ),
         from: filteredProjectsProvider,
         name: r'filteredProjectsProvider',
         debugGetCreateSourceHash:
             const bool.fromEnvironment('dart.vm.product')
                 ? null
                 : _$filteredProjectsHash,
         dependencies: FilteredProjectsFamily._dependencies,
         allTransitiveDependencies:
             FilteredProjectsFamily._allTransitiveDependencies,
         filter: filter,
         sort: sort,
         ascending: ascending,
       );

  FilteredProjectsProvider._internal(
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

  final ProjectFilter filter;
  final ProjectSort sort;
  final bool ascending;

  @override
  Override overrideWith(
    List<Project> Function(FilteredProjectsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredProjectsProvider._internal(
        (ref) => create(ref as FilteredProjectsRef),
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
  AutoDisposeProviderElement<List<Project>> createElement() {
    return _FilteredProjectsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredProjectsProvider &&
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
mixin FilteredProjectsRef on AutoDisposeProviderRef<List<Project>> {
  /// The parameter `filter` of this provider.
  ProjectFilter get filter;

  /// The parameter `sort` of this provider.
  ProjectSort get sort;

  /// The parameter `ascending` of this provider.
  bool get ascending;
}

class _FilteredProjectsProviderElement
    extends AutoDisposeProviderElement<List<Project>>
    with FilteredProjectsRef {
  _FilteredProjectsProviderElement(super.provider);

  @override
  ProjectFilter get filter => (origin as FilteredProjectsProvider).filter;
  @override
  ProjectSort get sort => (origin as FilteredProjectsProvider).sort;
  @override
  bool get ascending => (origin as FilteredProjectsProvider).ascending;
}

String _$projectByIdHash() => r'1efb73dc56d8c8220f8951ae8b7b403cd2ed96f0';

/// Provider for accessing a project by ID
///
/// Copied from [projectById].
@ProviderFor(projectById)
const projectByIdProvider = ProjectByIdFamily();

/// Provider for accessing a project by ID
///
/// Copied from [projectById].
class ProjectByIdFamily extends Family<Project?> {
  /// Provider for accessing a project by ID
  ///
  /// Copied from [projectById].
  const ProjectByIdFamily();

  /// Provider for accessing a project by ID
  ///
  /// Copied from [projectById].
  ProjectByIdProvider call(String id) {
    return ProjectByIdProvider(id);
  }

  @override
  ProjectByIdProvider getProviderOverride(
    covariant ProjectByIdProvider provider,
  ) {
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
  String? get name => r'projectByIdProvider';
}

/// Provider for accessing a project by ID
///
/// Copied from [projectById].
class ProjectByIdProvider extends AutoDisposeProvider<Project?> {
  /// Provider for accessing a project by ID
  ///
  /// Copied from [projectById].
  ProjectByIdProvider(String id)
    : this._internal(
        (ref) => projectById(ref as ProjectByIdRef, id),
        from: projectByIdProvider,
        name: r'projectByIdProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$projectByIdHash,
        dependencies: ProjectByIdFamily._dependencies,
        allTransitiveDependencies: ProjectByIdFamily._allTransitiveDependencies,
        id: id,
      );

  ProjectByIdProvider._internal(
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
  Override overrideWith(Project? Function(ProjectByIdRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ProjectByIdProvider._internal(
        (ref) => create(ref as ProjectByIdRef),
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
  AutoDisposeProviderElement<Project?> createElement() {
    return _ProjectByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectByIdProvider && other.id == id;
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
mixin ProjectByIdRef on AutoDisposeProviderRef<Project?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _ProjectByIdProviderElement extends AutoDisposeProviderElement<Project?>
    with ProjectByIdRef {
  _ProjectByIdProviderElement(super.provider);

  @override
  String get id => (origin as ProjectByIdProvider).id;
}

String _$userProjectsHash() => r'a0af395a843df050beae07ab6db8b16307130a65';

/// Provider for projects that a user is a member of
///
/// Copied from [userProjects].
@ProviderFor(userProjects)
const userProjectsProvider = UserProjectsFamily();

/// Provider for projects that a user is a member of
///
/// Copied from [userProjects].
class UserProjectsFamily extends Family<List<Project>> {
  /// Provider for projects that a user is a member of
  ///
  /// Copied from [userProjects].
  const UserProjectsFamily();

  /// Provider for projects that a user is a member of
  ///
  /// Copied from [userProjects].
  UserProjectsProvider call(String userId) {
    return UserProjectsProvider(userId);
  }

  @override
  UserProjectsProvider getProviderOverride(
    covariant UserProjectsProvider provider,
  ) {
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
  String? get name => r'userProjectsProvider';
}

/// Provider for projects that a user is a member of
///
/// Copied from [userProjects].
class UserProjectsProvider extends AutoDisposeProvider<List<Project>> {
  /// Provider for projects that a user is a member of
  ///
  /// Copied from [userProjects].
  UserProjectsProvider(String userId)
    : this._internal(
        (ref) => userProjects(ref as UserProjectsRef, userId),
        from: userProjectsProvider,
        name: r'userProjectsProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$userProjectsHash,
        dependencies: UserProjectsFamily._dependencies,
        allTransitiveDependencies:
            UserProjectsFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserProjectsProvider._internal(
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
  Override overrideWith(
    List<Project> Function(UserProjectsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProjectsProvider._internal(
        (ref) => create(ref as UserProjectsRef),
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
  AutoDisposeProviderElement<List<Project>> createElement() {
    return _UserProjectsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProjectsProvider && other.userId == userId;
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
mixin UserProjectsRef on AutoDisposeProviderRef<List<Project>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProjectsProviderElement
    extends AutoDisposeProviderElement<List<Project>>
    with UserProjectsRef {
  _UserProjectsProviderElement(super.provider);

  @override
  String get userId => (origin as UserProjectsProvider).userId;
}

String _$projectTasksHash() => r'516f0dcb8286aeba0c49f19ab9d6b9d5ca6f8d6d';

/// Provider for project tasks (returns all tasks for a specific project)
///
/// Copied from [projectTasks].
@ProviderFor(projectTasks)
const projectTasksProvider = ProjectTasksFamily();

/// Provider for project tasks (returns all tasks for a specific project)
///
/// Copied from [projectTasks].
class ProjectTasksFamily extends Family<List<Task>> {
  /// Provider for project tasks (returns all tasks for a specific project)
  ///
  /// Copied from [projectTasks].
  const ProjectTasksFamily();

  /// Provider for project tasks (returns all tasks for a specific project)
  ///
  /// Copied from [projectTasks].
  ProjectTasksProvider call(String projectId) {
    return ProjectTasksProvider(projectId);
  }

  @override
  ProjectTasksProvider getProviderOverride(
    covariant ProjectTasksProvider provider,
  ) {
    return call(provider.projectId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectTasksProvider';
}

/// Provider for project tasks (returns all tasks for a specific project)
///
/// Copied from [projectTasks].
class ProjectTasksProvider extends AutoDisposeProvider<List<Task>> {
  /// Provider for project tasks (returns all tasks for a specific project)
  ///
  /// Copied from [projectTasks].
  ProjectTasksProvider(String projectId)
    : this._internal(
        (ref) => projectTasks(ref as ProjectTasksRef, projectId),
        from: projectTasksProvider,
        name: r'projectTasksProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$projectTasksHash,
        dependencies: ProjectTasksFamily._dependencies,
        allTransitiveDependencies:
            ProjectTasksFamily._allTransitiveDependencies,
        projectId: projectId,
      );

  ProjectTasksProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final String projectId;

  @override
  Override overrideWith(List<Task> Function(ProjectTasksRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: ProjectTasksProvider._internal(
        (ref) => create(ref as ProjectTasksRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<Task>> createElement() {
    return _ProjectTasksProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectTasksProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProjectTasksRef on AutoDisposeProviderRef<List<Task>> {
  /// The parameter `projectId` of this provider.
  String get projectId;
}

class _ProjectTasksProviderElement
    extends AutoDisposeProviderElement<List<Task>>
    with ProjectTasksRef {
  _ProjectTasksProviderElement(super.provider);

  @override
  String get projectId => (origin as ProjectTasksProvider).projectId;
}

String _$projectNotifierHash() => r'0980dd6a9d23f49aa74712d731fb205daa727f66';

/// Notifier for managing projects with filtered views and sorting
///
/// Copied from [ProjectNotifier].
@ProviderFor(ProjectNotifier)
final projectNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ProjectNotifier, List<Project>>.internal(
      ProjectNotifier.new,
      name: r'projectNotifierProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$projectNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProjectNotifier = AutoDisposeAsyncNotifier<List<Project>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
