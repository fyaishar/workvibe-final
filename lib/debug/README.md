# Auth Test Screen

This folder contains a standalone application to manually test authentication functionality in the WorkVibe app.

## Setup

1. Open `auth_test_app.dart` and replace the Supabase credentials:
   ```dart
   const String supabaseUrl = 'YOUR_SUPABASE_URL';
   const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

2. Make sure your deep linking is properly configured for OAuth flows:
   - For iOS: Update the `CFBundleURLSchemes` in `ios/Runner/Info.plist`
   - For Android: Update `android:scheme` in `android/app/src/main/AndroidManifest.xml`
   - The expected URL scheme should be `io.supabase.workvibe://`

## Running the Test App

Run the app using:
```
flutter run -t lib/debug/auth_test_app.dart
```

## Testing Features

### Email/Password Authentication
- Use the email and password fields to test:
  - Sign in with existing account
  - Sign up new account
  - Reset password functionality

### Social Authentication
- Test social login with the dedicated buttons for:
  - Google login
  - Apple login
- Check the status card for auth result or errors

### OAuth Redirect Handling
- The "Auth Redirect Test" section allows you to test the OAuth redirect handling
- You can modify the callback URL to simulate various redirect scenarios
- This is useful for testing the deep linking callback handling

### Session Management
- Use the "Refresh Session" button to test token refresh functionality
- The status card displays whether the user is authenticated and shows token information
- The sign out icon in the app bar can be used to terminate the session

## Troubleshooting

- If social login doesn't work, check your Supabase project settings
- OAuth callbacks require proper deep linking setup in your app and correct config in Supabase
- For auth errors, check the status message area for detailed error information 