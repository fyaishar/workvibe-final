import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/supabase_service.dart';

/// Authentication state model
class AuthState {
  final bool isAuthenticated;
  final User? user;
  final Session? session;
  final bool isLoading;
  final String? error;

  /// Default constructor
  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.session,
    this.isLoading = false,
    this.error,
  });

  /// Create initial state
  factory AuthState.initial() => const AuthState(
        isAuthenticated: false,
        user: null,
        session: null,
        isLoading: false,
        error: null,
      );

  /// Create loading state
  AuthState setLoading() => AuthState(
        isAuthenticated: isAuthenticated,
        user: user,
        session: session,
        isLoading: true,
        error: null,
      );

  /// Create authenticated state
  AuthState setAuthenticated(User user, Session session) => AuthState(
        isAuthenticated: true,
        user: user,
        session: session,
        isLoading: false,
        error: null,
      );

  /// Create unauthenticated state
  AuthState setUnauthenticated() => const AuthState(
        isAuthenticated: false,
        user: null,
        session: null,
        isLoading: false,
        error: null,
      );

  /// Create error state
  AuthState setError(String errorMessage) => AuthState(
        isAuthenticated: isAuthenticated,
        user: user,
        session: session,
        isLoading: false,
        error: errorMessage,
      );

  /// Create a copy of the state with modified properties
  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    Session? session,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Auth state notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  /// Default constructor
  AuthNotifier() : super(AuthState.initial()) {
    // Initialize auth state from current session
    _initializeAuthState();
  }

  /// Initialize the auth state from the current session
  Future<void> _initializeAuthState() async {
    final currentUser = SupabaseService.currentUser;
    final currentSession = SupabaseService.session;

    if (currentUser != null && currentSession != null) {
      state = state.setAuthenticated(currentUser, currentSession);
      
      // Setup token refresh
      SupabaseService.setupTokenRefresh();
    } else {
      state = state.setUnauthenticated();
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      state = state.setLoading();
      
      final response = await SupabaseService.signInWithEmail(email, password);
      
      if (response.user != null && response.session != null) {
        state = state.setAuthenticated(response.user!, response.session!);
        
        // Setup token refresh
        SupabaseService.setupTokenRefresh();
      } else {
        state = state.setError('Authentication failed');
      }
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      state = state.setLoading();
      
      final response = await SupabaseService.signUpWithEmail(email, password);
      
      if (response.user != null) {
        if (response.session != null) {
          state = state.setAuthenticated(response.user!, response.session!);
          
          // Setup token refresh
          SupabaseService.setupTokenRefresh();
        } else {
          // User created but not authenticated (email confirmation required)
          state = state.copyWith(
            isLoading: false,
            error: null,
          );
        }
      } else {
        state = state.setError('Sign up failed');
      }
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.setLoading();
      
      final success = await SupabaseService.signInWithGoogle();
      
      // OAuth flow doesn't return user/session immediately
      // because it redirects to a browser. The success value
      // only indicates if the redirect was successful.
      if (!success) {
        state = state.setError('Failed to initiate Google sign-in');
      }
      // Keep loading state until redirect is handled with handleAuthRedirect
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      state = state.setLoading();
      
      final success = await SupabaseService.signInWithApple();
      
      // OAuth flow doesn't return user/session immediately
      // because it redirects to a browser. The success value
      // only indicates if the redirect was successful.
      if (!success) {
        state = state.setError('Failed to initiate Apple sign-in');
      }
      // Keep loading state until redirect is handled with handleAuthRedirect
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Handle auth redirect for social login
  Future<void> handleAuthRedirect(Uri uri) async {
    try {
      final success = await SupabaseService.handleAuthRedirect(uri);
      
      if (success) {
        // Refresh state after successful redirect
        await _initializeAuthState();
      } else {
        state = state.setError('Authentication failed after redirect');
      }
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      state = state.setLoading();
      
      await SupabaseService.resetPassword(email);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      state = state.setLoading();
      
      await SupabaseService.updatePassword(newPassword);
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.setLoading();
      
      await SupabaseService.signOut();
      
      state = state.setUnauthenticated();
    } catch (e) {
      state = state.setError(e.toString());
    }
  }
  
  /// Refresh session
  Future<void> refreshSession() async {
    try {
      final refreshedSession = await SupabaseService.refreshSession();
      
      if (refreshedSession != null && SupabaseService.currentUser != null) {
        state = state.setAuthenticated(
          SupabaseService.currentUser!,
          refreshedSession,
        );
      } else if (state.isAuthenticated) {
        // If previously authenticated but now session is gone, sign out
        state = state.setUnauthenticated();
      }
    } catch (e) {
      // Session refresh errors shouldn't be shown to the user normally
      // Just update the state if the authentication is invalid
      if (state.isAuthenticated && !SupabaseService.isAuthenticated) {
        state = state.setUnauthenticated();
      }
    }
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
}); 