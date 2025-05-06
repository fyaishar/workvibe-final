import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:finalworkvibe/features/auth/state/auth_state.dart';
import 'package:finalworkvibe/services/supabase_service.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSession extends Mock implements Session {}
class MockAuthSessionUrlResponse extends Mock implements AuthSessionUrlResponse {}
class MockUserResponse extends Mock implements UserResponse {}
class FakeUserAttributes extends Fake implements UserAttributes {}
class FakeUri extends Fake implements Uri {}

void main() {
  late MockSupabaseClient mockClient;
  late MockGoTrueClient mockAuth;
  late ProviderContainer container;
  
  setUpAll(() {
    registerFallbackValue(FakeUserAttributes());
    registerFallbackValue(FakeUri());
  });
  
  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    
    when(() => mockClient.auth).thenReturn(mockAuth);
    
    // Setup for SupabaseService
    SupabaseService.testSetClient(mockClient);
    
    // Setup provider container with overrides
    container = ProviderContainer(
      overrides: [
        // No overrides needed as we're using the real AuthNotifier
        // which depends on SupabaseService that we've already mocked
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
    SupabaseService.clearTestValues();
  });
  
  group('Auth Integration Tests', () {
    test('AuthNotifier initializes in unauthenticated state', () {
      // Arrange
      when(() => mockAuth.currentSession).thenReturn(null);
      
      // Act
      final authState = container.read(authProvider);
      
      // Assert
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      expect(authState.user, null);
      expect(authState.session, null);
    });
    
    test('AuthNotifier signInWithEmail updates state correctly on success', () async {
      // Arrange
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockResponse();
      
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockSession.accessToken).thenReturn('token-123');
      when(() => mockSession.refreshToken).thenReturn('refresh-token-123');
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);
      
      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act: initial state should be unauthenticated
      expect(container.read(authProvider).isAuthenticated, false);
      
      // Perform sign in
      await container.read(authProvider.notifier).signInWithEmail(
        'test@example.com',
        'password123',
      );
      
      // Assert: state should now be authenticated
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      expect(authState.user, mockUser);
      expect(authState.session, mockSession);
    });
    
    test('AuthNotifier signInWithEmail handles failure correctly', () async {
      // Arrange
      when(() => mockAuth.signInWithPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow('Invalid credentials');
      
      // Act: initial state should be unauthenticated
      expect(container.read(authProvider).isAuthenticated, false);
      
      // Attempt sign in with invalid credentials
      await container.read(authProvider.notifier).signInWithEmail(
        'wrong@example.com',
        'invalid-password',
      );
      
      // Assert: state should be error
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, isNotNull);
      expect(authState.user, null);
      expect(authState.session, null);
    });
    
    test('AuthNotifier signUpWithEmail updates state correctly on success', () async {
      // Arrange
      final mockUser = MockUser();
      final mockSession = MockSession();
      final mockResponse = MockResponse();
      
      when(() => mockUser.email).thenReturn('new@example.com');
      when(() => mockUser.id).thenReturn('new-user-123');
      when(() => mockSession.accessToken).thenReturn('new-token-123');
      when(() => mockSession.refreshToken).thenReturn('new-refresh-token-123');
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);
      
      when(() => mockAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockResponse);
      
      // Act: initial state should be unauthenticated
      expect(container.read(authProvider).isAuthenticated, false);
      
      // Perform sign up
      await container.read(authProvider.notifier).signUpWithEmail(
        'new@example.com',
        'newpassword123',
      );
      
      // Assert: state should now be authenticated
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, true);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      expect(authState.user, mockUser);
      expect(authState.session, mockSession);
    });
    
    test('AuthNotifier signUpWithEmail handles failure correctly', () async {
      // Arrange
      when(() => mockAuth.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow('Email already in use');
      
      // Act: initial state should be unauthenticated
      expect(container.read(authProvider).isAuthenticated, false);
      
      // Attempt sign up with already used email
      await container.read(authProvider.notifier).signUpWithEmail(
        'existing@example.com',
        'password123',
      );
      
      // Assert: state should be error
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, isNotNull);
      expect(authState.user, null);
      expect(authState.session, null);
    });
    
    test('AuthNotifier basic operations exist', () {
      // Test that the basic operations exist on the notifier
      final notifier = container.read(authProvider.notifier);
      
      // Verify that critical methods exist
      expect(notifier.signInWithEmail, isA<Function>());
      expect(notifier.signUpWithEmail, isA<Function>());
      expect(notifier.signOut, isA<Function>());
      expect(notifier.resetPassword, isA<Function>());
      expect(notifier.refreshSession, isA<Function>());
      
      // Also verify social login methods
      expect(notifier.signInWithGoogle, isA<Function>());
      expect(notifier.signInWithApple, isA<Function>());
      expect(notifier.handleAuthRedirect, isA<Function>());
    });
    
    test('AuthNotifier resetPassword sends reset email', () async {
      // Arrange
      when(() => mockAuth.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      )).thenAnswer((_) async {});
      
      // Initial state
      expect(container.read(authProvider).isLoading, false);
      
      // Act
      await container.read(authProvider.notifier).resetPassword(
        'reset@example.com',
      );
      
      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, null);
      verify(() => mockAuth.resetPasswordForEmail(
        'reset@example.com',
        redirectTo: any(named: 'redirectTo'),
      )).called(1);
    });
    
    test('AuthNotifier resetPassword handles failure', () async {
      // Arrange
      when(() => mockAuth.resetPasswordForEmail(
        any(),
        redirectTo: any(named: 'redirectTo'),
      )).thenThrow('Email not found');
      
      // Initial state
      expect(container.read(authProvider).isLoading, false);
      
      // Act
      await container.read(authProvider.notifier).resetPassword(
        'nonexistent@example.com',
      );
      
      // Assert
      final authState = container.read(authProvider);
      expect(authState.isAuthenticated, false);
      expect(authState.isLoading, false);
      expect(authState.error, isNotNull);
    });
  });
} 