// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/riverpod_config.dart';
import 'config/env.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with auth persistence
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    authFlowType: AuthFlowType.pkce,
    debug: true, // Set to false in production
  );
  
  // Set up token refresh mechanism
  SupabaseService.setupTokenRefresh();
  
  // Set up auth state change listener
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    
    // Handle different auth events
    switch (event) {
      case AuthChangeEvent.signedIn:
        debugPrint('User signed in: ${data.session?.user.email}');
        break;
      case AuthChangeEvent.signedOut:
        debugPrint('User signed out');
        break;
      case AuthChangeEvent.userUpdated:
        debugPrint('User updated: ${data.session?.user.email}');
        break;
      case AuthChangeEvent.passwordRecovery:
        debugPrint('Password recovery requested: ${data.session?.user.email}');
        break;
      case AuthChangeEvent.tokenRefreshed:
        debugPrint('Token refreshed');
        break;
      default:
        debugPrint('Auth event: $event');
    }
  });
  
  runApp(
    ProviderScope(
      observers: [RiverpodLogger()],
      child: const MyApp(),
    ),
  );
} 