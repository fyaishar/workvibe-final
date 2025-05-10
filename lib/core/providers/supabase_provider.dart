import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/env.dart';

/// Provider for the Supabase client instance
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Configuration function to initialize Supabase in the app
class SupabaseConfig {
  /// Initialize Supabase with the project URL and anon key.
  /// 
  /// This should be called in the app's initialization phase,
  /// typically before runApp().
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      // Add any other configuration options needed
      debug: false,
    );
  }
} 