import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/theme.dart';
import '../features/session/presentation/start_page.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/state/auth_state.dart'; 
import '../shared/widgets/showcase/showcase_screen.dart';
import '../main.dart';

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
      navigatorKey: navigatorKey,
      // Temporarily show ComponentShowcase directly for UI development
      home: const ShowcaseScreen(),
      // Comment out the conditional logic for now
      /*
      home: authState.isAuthenticated 
          ? const StartPage() 
          : const LoginScreen(),
      */
      routes: {
        '/showcase': (context) => const ShowcaseScreen(),
      },
    );
  }
} 