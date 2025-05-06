import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A simple mock login widget for testing
class MockLoginScreen extends StatefulWidget {
  const MockLoginScreen({Key? key}) : super(key: key);

  @override
  State<MockLoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends State<MockLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WorkVibe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Welcome back', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            
            // Email field
            TextFormField(
              key: const Key('email_field'),
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password field
            TextFormField(
              key: const Key('password_field'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            // Login button
            ElevatedButton(
              key: const Key('login_button'),
              onPressed: () {},
              child: const Text('Sign In'),
            ),
            
            TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {},
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('MockLoginScreen UI Tests', () {
    testWidgets('displays email and password fields', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Verify email field is present
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      
      // Verify password field is present
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      
      // Verify login button is present
      expect(find.byKey(const Key('login_button')), findsOneWidget);
    });

    testWidgets('has correct UI elements', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Verify app title is displayed
      expect(find.text('WorkVibe'), findsOneWidget);
      
      // Verify the welcome message is displayed
      expect(find.text('Welcome back'), findsOneWidget);
      
      // Verify sign up prompt is displayed
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
    });
    
    testWidgets('email and password fields accept input', (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: MockLoginScreen(),
        ),
      );

      // Enter text in the email field
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      expect(find.text('test@example.com'), findsOneWidget);
      
      // Enter text in the password field
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      expect(find.text('password123'), findsOneWidget);
    });
  });
} 