import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finalworkvibe/features/auth/state/auth_state.dart';
import 'package:finalworkvibe/services/supabase_service.dart';

class AuthTestScreen extends ConsumerStatefulWidget {
  const AuthTestScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthTestScreen> createState() => _AuthTestScreenState();
}

class _AuthTestScreenState extends ConsumerState<AuthTestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _callbackUrlController = TextEditingController(
    text: 'io.supabase.workvibe://login-callback/',
  );
  
  String _statusMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _callbackUrlController.dispose();
    super.dispose();
  }

  void _setStatus(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _signIn() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).signInWithEmail(
            _emailController.text,
            _passwordController.text,
          );
      _setStatus('Signed in successfully');
    } catch (e) {
      _setStatus('Error signing in: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signUp() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).signUpWithEmail(
            _emailController.text,
            _passwordController.text,
          );
      _setStatus('Signed up successfully');
    } catch (e) {
      _setStatus('Error signing up: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      _setStatus('Please enter an email');
      return;
    }

    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).resetPassword(
            _emailController.text,
          );
      _setStatus('Password reset email sent');
    } catch (e) {
      _setStatus('Error sending reset email: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signOut() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).signOut();
      _setStatus('Signed out successfully');
    } catch (e) {
      _setStatus('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshSession() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).refreshSession();
      _setStatus('Session refreshed');
    } catch (e) {
      _setStatus('Error refreshing session: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _googleSignIn() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      _setStatus('Google sign-in initiated');
    } catch (e) {
      _setStatus('Error with Google sign-in: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _appleSignIn() async {
    _setLoading(true);
    try {
      await ref.read(authProvider.notifier).signInWithApple();
      _setStatus('Apple sign-in initiated');
    } catch (e) {
      _setStatus('Error with Apple sign-in: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _testAuthRedirect() async {
    if (_callbackUrlController.text.isEmpty) {
      _setStatus('Please enter a callback URL');
      return;
    }

    _setLoading(true);
    try {
      final uri = Uri.parse(_callbackUrlController.text);
      await ref.read(authProvider.notifier).handleAuthRedirect(uri);
      
      _setStatus('Auth redirect handled successfully');
    } catch (e) {
      _setStatus('Error handling redirect: $e');
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Auth Test'),
        actions: [
          if (authState.isAuthenticated)
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: _signOut,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auth Status: ${authState.isAuthenticated ? "Authenticated" : "Not Authenticated"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (authState.isAuthenticated) ...[
                      Text('User ID: ${authState.user?.id ?? "Unknown"}'),
                      Text('Email: ${authState.user?.email ?? "Unknown"}'),
                      Text('Token: ${authState.session?.accessToken?.substring(0, 10) ?? "None"}...'),
                    ],
                    if (authState.error != null)
                      Text(
                        'Error: ${authState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Form fields
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            
            // Email & Password Auth buttons
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _signIn,
                    child: const Text('Sign In with Email'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Sign Up with Email'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _resetPassword,
                    child: const Text('Reset Password'),
                  ),
                ],
              ),
            
            const Divider(height: 40),
            const Text('Social Login:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Social login buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.flutter_dash),
                  label: const Text('Google'),
                  onPressed: _googleSignIn,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.apple),
                  label: const Text('Apple'),
                  onPressed: _appleSignIn,
                ),
              ],
            ),
            
            const Divider(height: 40),
            const Text('Auth Redirect Test:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Auth redirect test
            TextFormField(
              controller: _callbackUrlController,
              decoration: const InputDecoration(
                labelText: 'Callback URL',
                border: OutlineInputBorder(),
                hintText: 'io.supabase.workvibe://login-callback/',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _testAuthRedirect,
              child: const Text('Test Auth Redirect'),
            ),
            
            const Divider(height: 40),
            
            // Utility buttons
            ElevatedButton(
              onPressed: _refreshSession,
              child: const Text('Refresh Session'),
            ),
          ],
        ),
      ),
    );
  }
} 