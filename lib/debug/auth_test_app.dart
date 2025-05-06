import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finalworkvibe/config/env.dart';
import 'auth_test_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with credentials from Env class
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
    debug: true, // Set to false in production
  );
  
  runApp(const ProviderScope(child: AuthTestApp()));
}

class AuthTestApp extends StatelessWidget {
  const AuthTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        primaryColor: Colors.blue,
      ),
      themeMode: ThemeMode.system,
      home: const AuthTestScreen(),
    );
  }
}

// To run this test app:
// 1. Run the following command in your terminal:
//    flutter run -t lib/debug/auth_test_app.dart 