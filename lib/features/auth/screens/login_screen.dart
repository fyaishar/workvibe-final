import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import '../state/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _connectionStatus;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Test basic connection to Supabase
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _connectionStatus = 'Testing connection...';
    });

    try {
      final details = await SupabaseService.testConnection();
      
      setState(() {
        _connectionStatus = 'Diagnostic Results:\n$details';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _connectionStatus = 'Connection error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    // Use Riverpod auth provider to sign in
    await ref.read(authProvider.notifier).signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    // Get the auth state after sign in attempt
    final authState = ref.read(authProvider);
    
    // Check for errors
    if (authState.error != null) {
      setState(() {
        _errorMessage = authState.error;
      });
    } else if (authState.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
      }
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    // Use Riverpod auth provider to sign up
    await ref.read(authProvider.notifier).signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    // Get the auth state after sign up attempt
    final authState = ref.read(authProvider);
    
    // Check for errors
    if (authState.error != null) {
      setState(() {
        _errorMessage = authState.error;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up successful! Please check your email.'),
          ),
        );
      }
    }
  }

  Future<void> _resetPassword() async {
    // Validate just the email
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    // Use Riverpod auth provider to request password reset
    await ref.read(authProvider.notifier).resetPassword(
      _emailController.text.trim(),
    );
    
    // Get the auth state after reset attempt
    final authState = ref.read(authProvider);
    
    // Check for errors
    if (authState.error != null) {
      setState(() {
        _errorMessage = authState.error;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent. Please check your inbox.'),
          ),
        );
      }
    }
  }
  
  Future<void> _signInWithGoogle() async {
    await ref.read(authProvider.notifier).signInWithGoogle();
    
    // Error handling is managed in the state
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      setState(() {
        _errorMessage = authState.error;
      });
    }
  }
  
  Future<void> _signInWithApple() async {
    await ref.read(authProvider.notifier).signInWithApple();
    
    // Error handling is managed in the state
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      setState(() {
        _errorMessage = authState.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes 
    final authState = ref.watch(authProvider);
    _isLoading = authState.isLoading;
    
    // Update error message from auth state if available
    if (authState.error != null && _errorMessage != authState.error) {
      _errorMessage = authState.error;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkVibe Login'),
        actions: [
          IconButton(
            icon: const Icon(Icons.network_check),
            onPressed: _testConnection,
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome to WorkVibe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Connection status indicator
                if (_connectionStatus != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _connectionStatus!.contains('error') 
                          ? Colors.red.shade100 
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _connectionStatus!,
                      style: TextStyle(
                        color: _connectionStatus!.contains('error') 
                            ? Colors.red.shade900 
                            : Colors.green.shade900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: const Text('Create Account'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  child: const Text('Forgot Password?'),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Sign in with Google'),
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.apple),
                  label: const Text('Sign in with Apple'),
                  onPressed: _isLoading ? null : _signInWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 