import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/theme.dart';
import '../features/session/presentation/start_page.dart';
import '../features/auth/screens/login_screen.dart';
import '../services/supabase_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workvibe',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      // Show login screen if not authenticated, otherwise show start page
      home: SupabaseService.isAuthenticated 
          ? const StartPage() 
          : const LoginScreen(),
    );
  }
} 