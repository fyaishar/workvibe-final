import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' show HttpClient, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/env.dart';
import 'package:http/http.dart' as http;

/// Service class to manage Supabase client instance 
class SupabaseService {
  /// Get the Supabase client instance
  static final SupabaseClient client = Supabase.instance.client;

  /// Get current user session
  static Session? get session => client.auth.currentSession;

  /// Get current user
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
  
  /// For debugging - contains Supabase connection status
  static String platformInfo = kIsWeb 
      ? 'Running on Web'
      : '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
      
  /// Authenticates a user with email and password
  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    try {
      // Use a different approach for Mac (which often has permission issues)
      if (!kIsWeb && Platform.isMacOS) {
        // First try the regular approach, catch specific OS Permission errors
        try {
          return await client.auth.signInWithPassword(
            email: email,
            password: password,
          );
        } catch (e) {
          if (e.toString().contains('Operation not permitted')) {
            // Fall back to http package on permission errors
            final response = await http.post(
              Uri.parse('${Env.supabaseUrl}/auth/v1/token?grant_type=password'),
              headers: {
                'apikey': Env.supabaseAnonKey,
                'Content-Type': 'application/json',
              },
              body: '{"email":"$email","password":"$password"}',
            );
            
            if (response.statusCode == 200) {
              // Manually refresh the auth state
              return await client.auth.refreshSession();
            } else {
              throw 'Authentication failed: ${response.body}';
            }
          } else {
            rethrow;
          }
        }
      } else {
        // Regular flow for non-macOS platforms
        return await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Signs up a new user with email and password
  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    try {
      // Use a different approach for Mac (which often has permission issues)
      if (!kIsWeb && Platform.isMacOS) {
        // First try the regular approach, catch specific OS Permission errors
        try {
          return await client.auth.signUp(
            email: email,
            password: password,
          );
        } catch (e) {
          if (e.toString().contains('Operation not permitted')) {
            // Fall back to http package on permission errors
            final response = await http.post(
              Uri.parse('${Env.supabaseUrl}/auth/v1/signup'),
              headers: {
                'apikey': Env.supabaseAnonKey,
                'Content-Type': 'application/json',
              },
              body: '{"email":"$email","password":"$password"}',
            );
            
            if (response.statusCode == 200 || response.statusCode == 201) {
              // Manual sign-up was successful, try to get a session
              return AuthResponse(
                session: null,
                user: User(
                  id: 'pending_confirmation',
                  appMetadata: {},
                  userMetadata: {},
                  aud: '',
                  email: email,
                  createdAt: DateTime.now().toIso8601String(),
                ),
              );
            } else {
              throw 'Sign up failed: ${response.body}';
            }
          } else {
            rethrow;
          }
        }
      } else {
        // Regular flow for non-macOS platforms
        return await client.auth.signUp(
          email: email,
          password: password,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Signs out the current user
  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      // Handle alternative approach for MacOS if needed
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        // Fall back to a custom approach if regular signOut fails on MacOS
        try {
          final response = await http.post(
            Uri.parse('${Env.supabaseUrl}/auth/v1/logout'),
            headers: {
              'apikey': Env.supabaseAnonKey,
              'Authorization': 'Bearer ${session?.accessToken ?? ''}',
              'Content-Type': 'application/json',
            },
          );
          
          if (response.statusCode != 200) {
            throw 'Sign out failed: ${response.body}';
          }
        } catch (httpError) {
          throw 'Sign out failed: $httpError';
        }
      } else {
        rethrow;
      }
    }
  }
  
  /// Sends a password reset email to the specified email address
  static Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'io.supabase.workvibe://reset-callback/',
      );
    } catch (e) {
      // Handle alternative approach for MacOS if needed
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        try {
          final response = await http.post(
            Uri.parse('${Env.supabaseUrl}/auth/v1/recover'),
            headers: {
              'apikey': Env.supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: '{"email":"$email"}',
          );
          
          if (response.statusCode != 200) {
            throw 'Password reset failed: ${response.body}';
          }
        } catch (httpError) {
          throw 'Password reset failed: $httpError';
        }
      } else {
        rethrow;
      }
    }
  }
  
  /// Updates the user's password with a new one after reset
  static Future<void> updatePassword(String newPassword) async {
    try {
      await client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      // Handle alternative approach for MacOS if needed
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        try {
          final response = await http.put(
            Uri.parse('${Env.supabaseUrl}/auth/v1/user'),
            headers: {
              'apikey': Env.supabaseAnonKey,
              'Authorization': 'Bearer ${session?.accessToken ?? ''}',
              'Content-Type': 'application/json',
            },
            body: '{"password":"$newPassword"}',
          );
          
          if (response.statusCode != 200) {
            throw 'Password update failed: ${response.body}';
          }
        } catch (httpError) {
          throw 'Password update failed: $httpError';
        }
      } else {
        rethrow;
      }
    }
  }
  
  /// Sign in with Google
  static Future<bool> signInWithGoogle() async {
    try {
      final result = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.workvibe://login-callback/',
      );
      return result;
    } catch (e) {
      // If macOS has issues, we cannot easily handle OAuth via REST API
      // as it requires a web browser redirect flow
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        throw 'Google sign-in is not supported on this platform with current permissions. Try email sign-in instead.';
      }
      rethrow;
    }
  }
  
  /// Sign in with Apple
  static Future<bool> signInWithApple() async {
    try {
      final result = await client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb ? null : 'io.supabase.workvibe://login-callback/',
      );
      return result;
    } catch (e) {
      // If macOS has issues, we cannot easily handle OAuth via REST API
      // as it requires a web browser redirect flow
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        throw 'Apple sign-in is not supported on this platform with current permissions. Try email sign-in instead.';
      }
      rethrow;
    }
  }
  
  /// Callback handler for social auth redirects
  static Future<bool> handleAuthRedirect(Uri uri) async {
    try {
      // Extract the fragment or query parameters from the URI
      final hasFragment = uri.toString().contains('#');
      final hasAccessToken = uri.toString().contains('access_token');
      
      if ((hasFragment || hasAccessToken) && (uri.path.contains('login-callback') || uri.path.contains('reset-callback'))) {
        final response = await client.auth.getSessionFromUrl(uri);
        return response.session != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Manually refreshes the session if needed
  static Future<Session?> refreshSession() async {
    try {
      if (session == null) return null;
      
      // Check if token needs refresh (if less than 60 seconds remaining)
      final expiresAt = session!.expiresAt;
      if (expiresAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final expiresIn = expiresAt - now;
        
        if (expiresIn < 60) {
          final response = await client.auth.refreshSession();
          return response.session;
        }
      }
      
      return session;
    } catch (e) {
      // Try platform-specific approach for MacOS if needed
      if (!kIsWeb && Platform.isMacOS && e.toString().contains('Operation not permitted')) {
        try {
          final response = await http.post(
            Uri.parse('${Env.supabaseUrl}/auth/v1/token?grant_type=refresh_token'),
            headers: {
              'apikey': Env.supabaseAnonKey,
              'Content-Type': 'application/json',
            },
            body: '{"refresh_token":"${session?.refreshToken}"}',
          );
          
          if (response.statusCode == 200) {
            // Force a full refresh after manual refresh
            return (await client.auth.refreshSession()).session;
          }
        } catch (_) {
          // Fail silently and return current session
        }
      }
      return session;
    }
  }
  
  /// Sets up a periodic token refresh
  static void setupTokenRefresh() {
    // Refresh token every 30 minutes to ensure it doesn't expire
    const refreshInterval = Duration(minutes: 30);
    
    Future<void> performRefresh() async {
      if (isAuthenticated) {
        await refreshSession();
      }
    }
    
    // Initial refresh
    performRefresh();
    
    // Setup periodic refresh
    Stream.periodic(refreshInterval).listen((_) {
      performRefresh();
    });
  }
  
  /// Test connection to Supabase with detailed diagnostics
  static Future<String> testConnection() async {
    try {
      // First, test basic network connectivity
      String connectionInfo = '';
      
      connectionInfo += 'Platform: $platformInfo\n';
      
      // Fix potential typos in URL by trimming and validating
      final url = Env.supabaseUrl.trim();
      
      // Print connection details for debugging
      connectionInfo += 'URL: $url\n';
      connectionInfo += 'Key length: ${Env.supabaseAnonKey.length} chars\n';
      
      // Try a simple HTTP connection with dart:io HttpClient
      if (!kIsWeb) {
        try {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = const Duration(seconds: 10);
          
          // Parse the URL to extract the host
          final uri = Uri.parse(url);
          final host = uri.host;
          connectionInfo += 'Connecting to host: $host\n';
          
          // Use http package for potentially better error handling
          final request = await httpClient.getUrl(Uri.parse('$url/rest/v1/'));
          request.headers.add('apikey', Env.supabaseAnonKey);
          
          final httpResponse = await request.close();
          connectionInfo += 'HttpClient response: ${httpResponse.statusCode}\n';
          
          httpClient.close();
        } catch (e) {
          connectionInfo += 'HttpClient connection error: $e\n';
        }
      }
      
      // Try alternative http package
      try {
        connectionInfo += 'Trying alternative http package...\n';
        final response = await http.get(
          Uri.parse('$url/rest/v1/'),
          headers: {'apikey': Env.supabaseAnonKey},
        );
        connectionInfo += 'Http package response: ${response.statusCode}\n';
      } catch (e) {
        connectionInfo += 'Http package error: $e\n';
      }
      
      // Try Supabase API
      try {
        // Simple ping to server using a table that always exists
        final response = await client
            .from('_pgsodium_key_rotation')
            .select('created_at')
            .limit(1)
            .maybeSingle();
        
        connectionInfo += 'Supabase API connection successful!\n';
      } catch (e) {
        connectionInfo += 'Supabase API error: $e\n';
      }
      
      return connectionInfo;
    } catch (e) {
      return 'Connection test error: $e';
    }
  }
} 