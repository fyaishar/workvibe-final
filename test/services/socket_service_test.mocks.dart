// Mocks generated by Mockito 5.4.5 from annotations
// in finalworkvibe/test/services/socket_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:finalworkvibe/services/supabase_realtime_service.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [SupabaseRealtimeService].
///
/// See the documentation for Mockito's code generation for more information.
class MockSupabaseRealtimeService extends _i1.Mock
    implements _i2.SupabaseRealtimeService {
  MockSupabaseRealtimeService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<Map<String, dynamic>> get onSessionEvent =>
      (super.noSuchMethod(
            Invocation.getter(#onSessionEvent),
            returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
          )
          as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Stream<Map<String, dynamic>> get onTaskEvent =>
      (super.noSuchMethod(
            Invocation.getter(#onTaskEvent),
            returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
          )
          as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Stream<Map<String, dynamic>> get onProjectEvent =>
      (super.noSuchMethod(
            Invocation.getter(#onProjectEvent),
            returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
          )
          as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Stream<Map<String, dynamic>> get onRoomEvent =>
      (super.noSuchMethod(
            Invocation.getter(#onRoomEvent),
            returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
          )
          as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Stream<Map<String, dynamic>> get onPresenceEvent =>
      (super.noSuchMethod(
            Invocation.getter(#onPresenceEvent),
            returnValue: _i3.Stream<Map<String, dynamic>>.empty(),
          )
          as _i3.Stream<Map<String, dynamic>>);

  @override
  _i3.Future<void> initialize() =>
      (super.noSuchMethod(
            Invocation.method(#initialize, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  void dispose() => super.noSuchMethod(
    Invocation.method(#dispose, []),
    returnValueForMissingStub: null,
  );

  @override
  _i3.Future<Map<String, dynamic>> startSession(
    Map<String, dynamic>? sessionData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#startSession, [sessionData]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<Map<String, dynamic>> getCurrentSession(String? sessionId) =>
      (super.noSuchMethod(
            Invocation.method(#getCurrentSession, [sessionId]),
            returnValue: _i3.Future<Map<String, dynamic>>.value(
              <String, dynamic>{},
            ),
          )
          as _i3.Future<Map<String, dynamic>>);

  @override
  _i3.Future<void> updateSession(
    String? sessionId,
    Map<String, dynamic>? sessionData,
  ) =>
      (super.noSuchMethod(
            Invocation.method(#updateSession, [sessionId, sessionData]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> endSession(String? sessionId) =>
      (super.noSuchMethod(
            Invocation.method(#endSession, [sessionId]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);
}
