import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme.dart';
import '../features/session/presentation/start_page.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/state/auth_state.dart'; 

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes
    final authState = ref.watch(authProvider);
    
    return MaterialApp(
      title: 'Workvibe',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      // Show login screen if not authenticated, otherwise show start page
      home: authState.isAuthenticated 
          ? const StartPage() 
          : const LoginScreen(),
    );
  }
} 