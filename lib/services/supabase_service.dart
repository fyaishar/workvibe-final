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
      : Platform.operatingSystem + ' ' + Platform.operatingSystemVersion;
      
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
          
          final response = await request.close();
          connectionInfo += 'HttpClient response: ${response.statusCode}\n';
          
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