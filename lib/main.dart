// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'app/app.dart';
import 'core/config/riverpod_config.dart';
import 'config/env.dart';
import 'services/supabase_service.dart';
import 'services/error/index.dart';
import 'shared/widgets/showcase/showcase_screen.dart';
import 'app/theme/theme.dart';
import 'app/theme/colors.dart';
import 'features/session/presentation/session_screen.dart';
import 'shared/widgets/buttons.dart'; // Import our custom buttons

// Global logging service instance for use in error handling.
final LoggingService _logger = LoggingService();

// Add a global key for navigator access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logger.error(
      'Flutter error caught by global handler',
      category: LogCategory.ui,
      error: details.exception,
      stackTrace: details.stack,
      additionalData: {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'none',
      },
    );
  };

  // Handle errors that are not caught by Flutter's error handling
  PlatformDispatcher.instance.onError = (error, stack) {
    _logger.fatal(
      'Uncaught platform error',
      category: LogCategory.general,
      error: error,
      stackTrace: stack,
    );
    return true; // Returning true indicates we've handled the error
  };
  
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Supabase with auth persistence
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
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
          _logger.info(
            'User signed in',
            category: LogCategory.auth,
            additionalData: {'email': data.session?.user.email},
          );
          break;
        case AuthChangeEvent.signedOut:
          _logger.info('User signed out', category: LogCategory.auth);
          break;
        case AuthChangeEvent.userUpdated:
          _logger.info(
            'User updated',
            category: LogCategory.auth,
            additionalData: {'email': data.session?.user.email},
          );
          break;
        case AuthChangeEvent.passwordRecovery:
          _logger.info(
            'Password recovery requested',
            category: LogCategory.auth,
            additionalData: {'email': data.session?.user.email},
          );
          break;
        case AuthChangeEvent.tokenRefreshed:
          _logger.debug('Token refreshed', category: LogCategory.auth);
          break;
        default:
          _logger.debug(
            'Auth event',
            category: LogCategory.auth,
            additionalData: {'event': event.toString()},
          );
      }
    });
    
    runApp(
      ProviderScope(
        observers: [RiverpodLogger()],
        child: const WorkVibeApp(),
      ),
    );
  }, (error, stackTrace) {
    // This handles any errors not caught by the Flutter framework
    _logger.fatal(
      'Uncaught error in app',
      category: LogCategory.general,
      error: error,
      stackTrace: stackTrace,
    );
  });
}

class WorkVibeApp extends StatelessWidget {
  const WorkVibeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkVibe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // Use dark theme per PRD requirement
      home: const HomeScreen(),
      routes: {
        '/session': (context) => const SessionScreen(),
        '/showcase': (context) => const ShowcaseScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('WorkVibe'),
        backgroundColor: AppColors.moduleBackground,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use our custom button instead of ElevatedButton
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, '/session');
              },
              child: const Text('Open Session Screen'),
            ),
            const SizedBox(height: 20),
            // Use our custom button instead of ElevatedButton
            CustomButton(
              onPressed: () {
                Navigator.pushNamed(context, '/showcase');
              },
              child: const Text('UI Component Showcase'),
            ),
            const SizedBox(height: 20),
            // Add a text button example
            CustomTextButton(
              onPressed: () {
                // Show a simple dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Custom Buttons'),
                    content: const Text('All Material Design ripple effects have been removed!'),
                    actions: [
                      CustomButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('About Custom Buttons'),
            ),
          ],
        ),
      ),
    );
  }
} 