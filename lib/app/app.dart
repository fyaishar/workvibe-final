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
    
    // Force dark theme for showcase
    return MaterialApp(
      title: 'Workvibe UI Showcase',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      // Directly show the showcase screen without any conditional logic
      home: const ShowcaseScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/start': (context) => const StartPage(),
      },
    );
  }
} 